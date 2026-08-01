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

-- pg_stats (bloat-оценка) отдаёт строки только по таблицам, которые роль
-- может читать: pg_monitor этого не даёт, вью пустая -> bloat всегда No data.
-- pg_read_all_data (PG14+) — осознанный компромисс: мониторинг сможет читать
-- ДАННЫЕ всех таблиц; альтернатива в проде — security definer-вью
GRANT pg_read_all_data TO monitoring;

-- расширение для метрик уровня workload
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- сэмплер wait events (continuous profiling нагрузки)
CREATE EXTENSION IF NOT EXISTS pg_wait_sampling;

-- CPU и реальный (физический) IO per query; требует pg_stat_statements
CREATE EXTENSION IF NOT EXISTS pg_stat_kcache;
