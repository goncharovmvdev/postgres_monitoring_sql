-- роль для экспортёров: pg_monitor вместо superuser
CREATE ROLE monitoring LOGIN PASSWORD 'monitoring';
GRANT pg_monitor TO monitoring;

-- защита сбора (fixes.txt CRITICAL): зависший запрос коллектора не должен
-- ронять весь scrape — мониторинг обязан переживать инцидент, который меряет
ALTER ROLE monitoring SET statement_timeout = '5s';
ALTER ROLE monitoring SET lock_timeout = '1s';
ALTER ROLE monitoring SET idle_in_transaction_session_timeout = '10s';

-- pg_sequences.last_value виден только с SELECT/USAGE на sequence
-- (pg_monitor этого НЕ даёт) — иначе метрика исчерпания всегда 0%
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO monitoring;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO monitoring;

-- Статистика для bloat-оценки БЕЗ права читать данные.
-- Проблема: pg_stats фильтрует строки по has_column_privilege(current_user) —
-- под pg_monitor вью пустая, а pg_read_all_data (прежнее решение) отдал бы
-- мониторингу ДАННЫЕ всех таблиц. Фильтр в pg_stats не случаен: она показывает
-- most_common_vals/histogram_bounds, то есть буквальные значения из таблиц.
-- Решение: вью владельца (postgres) поверх pg_statistic НАПРЯМУЮ, только с
-- колонками, которые нужны оценке — null_frac и avg_width. Значений (stavalues*,
-- stanumbers*) в ней нет, утекать нечему.
-- Почему не вью поверх pg_stats: вью выполняется с правами ВЛАДЕЛЬЦА, но
-- current_user не подменяет (в отличие от SECURITY DEFINER-функции), поэтому
-- внутренний has_column_privilege всё равно спросит про monitoring -> 0 строк.
-- ВНИМАНИЕ (мультибазовый кластер): pg_statistic — каталог УРОВНЯ БАЗЫ, вью
-- нужна в каждой базе, с которой собирается bloat. Раскатка: цикл psql по
-- pg_database + та же вью в template1, чтобы её наследовали новые базы.
-- На физическую реплику приезжает сама, вместе с WAL.
CREATE VIEW monitoring_column_stats AS
SELECT
  n.nspname     AS schemaname,
  c.relname     AS tablename,
  a.attname,
  s.stainherit  AS inherited,
  s.stanullfrac AS null_frac,
  s.stawidth    AS avg_width
FROM pg_statistic s
JOIN pg_class c     ON c.oid = s.starelid
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = s.staattnum
WHERE NOT a.attisdropped;

-- security_invoker НЕ включать (PG15+): с ним проверка прав уедет на monitoring
-- и вью снова станет пустой
GRANT SELECT ON monitoring_column_stats TO monitoring;

-- расширение для метрик уровня workload
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- сэмплер wait events (continuous profiling нагрузки)
CREATE EXTENSION IF NOT EXISTS pg_wait_sampling;

-- CPU и реальный (физический) IO per query; требует pg_stat_statements
CREATE EXTENSION IF NOT EXISTS pg_stat_kcache;
