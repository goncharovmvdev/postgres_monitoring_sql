-- текущие активные запросы
SELECT pid,
       usename,
       datname,
       application_name,
       client_addr,
       backend_type,
       wait_event_type,
       wait_event,
       now() - query_start AS query_duration,
       now() - xact_start AS xact_duration,
       LEFT(query, 300) AS query
FROM pg_stat_activity
WHERE state = 'active'
  AND pid <> pg_backend_pid()
ORDER BY query_start ASC
LIMIT 100;
