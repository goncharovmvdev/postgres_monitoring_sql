-- топ запросов по суммарному времени
SELECT s.queryid,
       LEFT(regexp_replace(s.query, '\s+', ' ', 'g'), 120) AS query,
       d.datname,
       r.rolname,
       s.calls,
       ROUND(s.total_exec_time::numeric, 2) AS total_exec_ms,
       ROUND(s.mean_exec_time::numeric, 2) AS mean_exec_ms,
       ROUND(s.stddev_exec_time::numeric, 2) AS stddev_exec_ms,
       s.rows,
       ROUND(s.rows::numeric / NULLIF(s.calls, 0), 1) AS rows_per_call,
       ROUND((100.0 * s.total_exec_time / NULLIF(SUM(s.total_exec_time) OVER (), 0))::numeric, 2) AS pct_total_time
FROM pg_stat_statements AS s
JOIN pg_database AS d ON d.oid = s.dbid
JOIN pg_roles AS r ON r.oid = s.userid
ORDER BY s.total_exec_time DESC
LIMIT 20;
