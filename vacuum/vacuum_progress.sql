-- прогресс текущих vacuum операций
SELECT
    p.pid,
    p.datname,
    p.relid::regclass AS relation,
    p.phase,
    pg_size_pretty(p.heap_blks_total * current_setting('block_size')::BIGINT) AS heap_size,
    ROUND(100.0 * p.heap_blks_scanned / NULLIF(p.heap_blks_total, 0), 2) AS scanned_pct,
    ROUND(100.0 * p.heap_blks_vacuumed / NULLIF(p.heap_blks_total, 0), 2) AS vacuumed_pct,
    p.index_vacuum_count,
    p.num_dead_tuples,
    now() - a.query_start AS duration,
    a.query
FROM pg_stat_progress_vacuum AS p
JOIN pg_stat_activity AS a
    ON a.pid = p.pid
ORDER BY duration DESC;
