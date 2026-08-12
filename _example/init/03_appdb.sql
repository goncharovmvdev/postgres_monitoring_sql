-- Прикладная база: приближение к проду — приложение НЕ живёт в служебной
-- postgres. Нагрузка (pgbench, init/04) и ОБЪЕКТНЫЕ коллекторы sql_exporter
-- (pg_objects, pg_objects_slow, pg_bloat — job'ы pgNN-appdb) работают с appdb;
-- инстансовые коллекторы остаются на служебной postgres: кластерные вью
-- (pg_stat_activity, pg_stat_database, pg_stat_statements, WAL/чекпоинты)
-- видны из любой базы, а объектные каталоги — только из подключённой
CREATE DATABASE appdb;

\c appdb

-- Пер-базовая обвязка мониторинга — зеркало init/01_monitoring.sql: гранты и
-- вью живут В КАЖДОЙ базе отдельно (каталоги уровня базы). Новая наблюдаемая
-- база = такой же блок для неё (или вью в template1 — наследуется при CREATE DATABASE)
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO monitoring;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO monitoring;

-- статистика для bloat-оценки БЕЗ права читать данные —
-- развёрнутое объяснение конструкции в init/01_monitoring.sql
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

GRANT SELECT ON monitoring_column_stats TO monitoring;
