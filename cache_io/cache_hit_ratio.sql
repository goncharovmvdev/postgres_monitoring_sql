-- cache hit ratio по базам
SELECT
    d.datname AS database_name,
    pg_size_pretty(pg_database_size(d.datname)) AS database_size,
    s.blks_hit,
    s.blks_read,
    ROUND(100.0 * s.blks_hit / NULLIF(s.blks_hit + s.blks_read, 0), 2) AS cache_hit_ratio_pct,
    s.xact_commit,
    s.xact_rollback,
    s.stats_reset
FROM pg_stat_database s
JOIN pg_database d ON d.oid = s.datid
WHERE d.datistemplate = FALSE
ORDER BY cache_hit_ratio_pct ASC NULLS LAST,
         s.blks_read DESC;
