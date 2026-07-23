-- мертвые строки по таблицам
SELECT
    schemaname,
    relname,
    n_live_tup,
    n_dead_tup,
    ROUND(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_pct,
    n_mod_since_analyze,
    n_ins_since_vacuum,
    vacuum_count,
    autovacuum_count,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    pg_size_pretty(pg_relation_size(relid)) AS table_size,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC
LIMIT 50;
