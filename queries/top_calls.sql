-- топ запросов по числу вызовов
SELECT s.queryid,
       LEFT(regexp_replace(s.query, '\s+', ' ', 'g'), 120) AS query,
       d.datname,
       r.rolname,
       s.calls,
       ROUND(100.0 * s.calls / NULLIF(SUM(s.calls) OVER (), 0), 2) AS pct_calls,
       ROUND(s.calls / NULLIF(EXTRACT(EPOCH FROM now() - i.stats_reset), 0), 2) AS calls_per_sec,
       ROUND(s.mean_exec_time::numeric, 3) AS mean_exec_ms,
       ROUND(s.total_exec_time::numeric, 2) AS total_exec_ms,
       s.rows,
       ROUND(s.rows::numeric / NULLIF(s.calls, 0), 1) AS rows_per_call
FROM pg_stat_statements AS s
CROSS JOIN pg_stat_statements_info AS i
JOIN pg_database AS d ON d.oid = s.dbid
JOIN pg_roles AS r ON r.oid = s.userid
ORDER BY s.calls DESC
LIMIT 20;
