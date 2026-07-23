-- не-lock ожидания сессий по событиям
SELECT
    wait_event_type,
    wait_event,
    COUNT(*) AS sessions_count,
    ARRAY_AGG(pid ORDER BY pid) AS pids
FROM pg_stat_activity
WHERE wait_event_type IS NOT NULL
  AND wait_event_type <> 'Lock'
  AND pid <> pg_backend_pid()
GROUP BY
    wait_event_type,
    wait_event
ORDER BY
    sessions_count DESC,
    wait_event_type,
    wait_event;
