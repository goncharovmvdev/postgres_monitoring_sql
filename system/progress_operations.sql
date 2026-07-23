-- прогресс идущих служебных операций
WITH ops AS (
    SELECT pid,
           'ANALYZE' AS operation,
           phase,
           ROUND(100.0 * sample_blks_scanned / NULLIF(sample_blks_total, 0), 1) AS progress_pct
    FROM pg_stat_progress_analyze
    UNION ALL
    SELECT pid,
           command,
           phase,
           ROUND(100.0 * heap_blks_scanned / NULLIF(heap_blks_total, 0), 1)
    FROM pg_stat_progress_cluster
    UNION ALL
    SELECT pid,
           'BASE BACKUP',
           phase,
           ROUND(100.0 * backup_streamed / NULLIF(backup_total, 0), 1)
    FROM pg_stat_progress_basebackup
    UNION ALL
    SELECT pid,
           command,
           type,
           ROUND(100.0 * bytes_processed / NULLIF(bytes_total, 0), 1)
    FROM pg_stat_progress_copy
)
SELECT o.pid,
       o.operation,
       o.phase,
       o.progress_pct,
       a.datname,
       a.usename,
       now() - a.query_start AS duration
FROM ops AS o
LEFT JOIN pg_stat_activity AS a ON a.pid = o.pid
ORDER BY duration DESC NULLS LAST;
