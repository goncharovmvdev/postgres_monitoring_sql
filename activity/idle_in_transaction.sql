-- зависшие транзакции в idle
SELECT pid,
       usename,
       datname,
       application_name,
       client_addr,
       state,
       now() - xact_start AS xact_duration,
       now() - state_change AS idle_duration,
       backend_xid,
       backend_xmin,
       AGE(backend_xmin) AS xmin_age,
       LEFT(query, 300) AS last_query
FROM pg_stat_activity
WHERE state IN ('idle in transaction', 'idle in transaction (aborted)')
ORDER BY xact_start ASC
LIMIT 50;
