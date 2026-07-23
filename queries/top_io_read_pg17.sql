-- топ запросов по чтению с диска
SELECT
    queryid,
    LEFT(query, 100) AS query,
    calls,
    shared_blks_read,
    pg_size_pretty(shared_blks_read * current_setting('block_size')::bigint) AS read_size,
    ROUND(shared_blk_read_time::numeric, 2) AS shared_blk_read_time_ms,
    ROUND((shared_blk_read_time / NULLIF(calls, 0))::numeric, 3) AS avg_read_time_ms,
    ROUND(
        100.0 * shared_blks_read
        / NULLIF(shared_blks_read + shared_blks_hit, 0),
        2
    ) AS cache_miss_pct
FROM pg_stat_statements
WHERE shared_blks_read > 0
ORDER BY shared_blks_read DESC
LIMIT 20;
