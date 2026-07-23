-- сводная статистика по базам
SELECT
    d.datname AS database,
    pg_size_pretty(pg_database_size(d.datname)) AS size,
    s.numbackends AS connections,
    s.xact_commit AS commits,
    s.xact_rollback AS rollbacks,
    ROUND(100.0 * s.xact_rollback / NULLIF(s.xact_commit + s.xact_rollback, 0), 2) AS rollback_pct,
    ROUND(100.0 * s.blks_hit / NULLIF(s.blks_hit + s.blks_read, 0), 2) AS cache_hit_pct,
    s.tup_returned,
    s.tup_fetched,
    s.tup_inserted,
    s.tup_updated,
    s.tup_deleted,
    s.temp_files,
    pg_size_pretty(s.temp_bytes) AS temp_size,
    s.deadlocks,
    s.conflicts,
    ROUND(s.blk_read_time::numeric, 2) AS blk_read_time_ms,
    ROUND(s.blk_write_time::numeric, 2) AS blk_write_time_ms,
    s.stats_reset
FROM pg_stat_database s
JOIN pg_database d ON d.oid = s.datid
WHERE NOT d.datistemplate
ORDER BY pg_database_size(d.datname) DESC;
