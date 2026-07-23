-- занятость воркеров autovacuum
SELECT
    count(*) AS workers_busy,
    current_setting('autovacuum_max_workers')::int AS workers_max,
    ROUND(100.0 * count(*) / current_setting('autovacuum_max_workers')::int) AS busy_pct,
    min(xact_start) AS oldest_worker_start,
    string_agg(LEFT(query, 120), E'\n' ORDER BY xact_start) AS running_tasks
FROM pg_stat_activity
WHERE backend_type = 'autovacuum worker';
