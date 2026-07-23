-- кто кого блокирует
SELECT
    blocked.pid AS blocked_pid,
    blocked.usename AS blocked_user,
    blocked.datname AS blocked_db,
    blocked.wait_event_type AS blocked_wait_event_type,
    blocked.wait_event AS blocked_wait_event,
    now() - blocked.query_start AS blocked_wait_duration,
    LEFT(blocked.query, 200) AS blocked_query,
    blocking.pid AS blocking_pid,
    blocking.usename AS blocking_user,
    blocking.application_name AS blocking_app,
    blocking.client_addr AS blocking_client,
    blocking.state AS blocking_state,
    now() - blocking.xact_start AS blocking_xact_duration,
    now() - blocking.state_change AS blocking_state_duration,
    LEFT(blocking.query, 200) AS blocking_query
FROM pg_stat_activity AS blocked
CROSS JOIN LATERAL unnest(pg_blocking_pids(blocked.pid)) AS b(blocking_pid)
JOIN pg_stat_activity AS blocking
    ON blocking.pid = b.blocking_pid
ORDER BY blocked_wait_duration DESC NULLS LAST
LIMIT 100;
