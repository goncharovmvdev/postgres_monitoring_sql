-- прогресс vacuum на pg17+ (байты, индексы)
SELECT
    p.pid,
    p.datname,
    p.relid::regclass AS relation,
    p.phase,
    pg_size_pretty(p.heap_blks_total * current_setting('block_size')::BIGINT) AS heap_size,
    ROUND(100.0 * p.heap_blks_scanned / NULLIF(p.heap_blks_total, 0), 2) AS scanned_pct,
    ROUND(100.0 * p.heap_blks_vacuumed / NULLIF(p.heap_blks_total, 0), 2) AS vacuumed_pct,
    p.index_vacuum_count,
    pg_size_pretty(p.dead_tuple_bytes) AS dead_tuple_bytes,
    pg_size_pretty(p.max_dead_tuple_bytes) AS max_dead_tuple_bytes,
    ROUND(100.0 * p.dead_tuple_bytes / NULLIF(p.max_dead_tuple_bytes, 0), 2) AS dead_buffer_pct,
    p.num_dead_item_ids,
    p.indexes_total,
    p.indexes_processed,
    ROUND(100.0 * p.indexes_processed / NULLIF(p.indexes_total, 0), 2) AS indexes_pct,
    now() - a.query_start AS duration,
    a.query
FROM pg_stat_progress_vacuum AS p
JOIN pg_stat_activity AS a
    ON a.pid = p.pid
ORDER BY duration DESC;
