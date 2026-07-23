-- Время последних vacuum analyze
SELECT
    schemaname,
    relname,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    n_live_tup,
    n_dead_tup,
    ROUND(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 1) AS dead_pct,
    n_mod_since_analyze,
    n_ins_since_vacuum,
    last_vacuum,
    last_autovacuum,
    GREATEST(last_vacuum, last_autovacuum) AS last_any_vacuum,
    last_analyze,
    last_autoanalyze,
    GREATEST(last_analyze, last_autoanalyze) AS last_any_analyze,
    vacuum_count,
    autovacuum_count,
    analyze_count,
    autoanalyze_count
FROM pg_stat_user_tables
ORDER BY GREATEST(last_vacuum, last_autovacuum, last_analyze, last_autoanalyze) ASC NULLS FIRST
LIMIT 50;
