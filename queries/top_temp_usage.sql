-- топ запросов по temp файлам
SELECT s.queryid,
       LEFT(regexp_replace(s.query, '\s+', ' ', 'g'), 120) AS query,
       d.datname,
       r.rolname,
       s.calls,
       s.temp_blks_written,
       s.temp_blks_read,
       pg_size_pretty(s.temp_blks_written * current_setting('block_size')::bigint) AS temp_written,
       pg_size_pretty(s.temp_blks_read * current_setting('block_size')::bigint) AS temp_read,
       pg_size_pretty((s.temp_blks_written * current_setting('block_size')::bigint) / NULLIF(s.calls, 0)) AS temp_written_per_call,
       ROUND((100.0 * s.temp_blks_written / NULLIF(SUM(s.temp_blks_written) OVER (), 0))::numeric, 2) AS pct_temp_written
FROM pg_stat_statements AS s
LEFT JOIN pg_database AS d ON d.oid = s.dbid
LEFT JOIN pg_roles AS r ON r.oid = s.userid
WHERE s.temp_blks_written > 0
   OR s.temp_blks_read > 0
ORDER BY s.temp_blks_written DESC, s.temp_blks_read DESC
LIMIT 20;
