-- топ запросов по среднему времени
SELECT s.queryid,
       LEFT(regexp_replace(s.query, '\s+', ' ', 'g'), 120) AS query,
       d.datname,
       r.rolname,
       s.calls,
       ROUND(s.mean_exec_time::numeric, 2) AS mean_exec_ms,
       ROUND(s.min_exec_time::numeric, 2) AS min_exec_ms,
       ROUND(s.max_exec_time::numeric, 2) AS max_exec_ms,
       ROUND(s.stddev_exec_time::numeric, 2) AS stddev_exec_ms,
       ROUND(s.total_exec_time::numeric, 2) AS total_exec_ms,
       ROUND(s.rows::numeric / NULLIF(s.calls, 0), 1) AS rows_per_call
FROM pg_stat_statements AS s
JOIN pg_database AS d ON d.oid = s.dbid
JOIN pg_roles AS r ON r.oid = s.userid
WHERE s.calls >= 5
ORDER BY s.mean_exec_time DESC
LIMIT 20;
