-- прогресс создания индексов
SELECT
    p.pid,
    p.datname,
    p.relid::regclass AS table_name,
    p.index_relid::regclass AS index_name,
    p.command,
    p.phase,
    ROUND(100.0 * p.blocks_done / NULLIF(p.blocks_total, 0), 1) AS blocks_pct,
    ROUND(100.0 * p.tuples_done / NULLIF(p.tuples_total, 0), 1) AS tuples_pct,
    p.lockers_done || '/' || p.lockers_total AS lockers,
    p.current_locker_pid,
    now() - a.query_start AS duration
FROM pg_stat_progress_create_index AS p
JOIN pg_stat_activity AS a ON a.pid = p.pid
ORDER BY duration DESC;
