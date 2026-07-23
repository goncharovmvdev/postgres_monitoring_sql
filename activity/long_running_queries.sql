-- запросы работающие дольше 5 минут
SELECT pid,
       usename,
       datname,
       application_name,
       client_addr,
       state,
       wait_event_type,
       wait_event,
       now() - query_start AS query_duration,
       now() - xact_start AS xact_duration,
       pg_blocking_pids(pid) AS blocking_pids,
       LEFT(query, 300) AS query
FROM pg_stat_activity
WHERE state = 'active'
  AND pid <> pg_backend_pid()
  AND query_start IS NOT NULL
  AND now() - query_start > INTERVAL '5 minutes'
ORDER BY query_start ASC
LIMIT 50;
