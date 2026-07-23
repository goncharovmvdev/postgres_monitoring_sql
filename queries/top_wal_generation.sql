-- топ запросов по генерации WAL
SELECT s.queryid,
       LEFT(regexp_replace(s.query, '\s+', ' ', 'g'), 120) AS query,
       d.datname,
       r.rolname,
       s.calls,
       pg_size_pretty(s.wal_bytes) AS wal_total,
       pg_size_pretty(ROUND(s.wal_bytes / NULLIF(s.calls, 0))) AS wal_per_call,
       s.wal_records,
       s.wal_fpi,
       ROUND(100.0 * s.wal_bytes / NULLIF(SUM(s.wal_bytes) OVER (), 0), 2) AS pct_total_wal
FROM pg_stat_statements AS s
JOIN pg_database AS d ON d.oid = s.dbid
JOIN pg_roles AS r ON r.oid = s.userid
ORDER BY s.wal_bytes DESC
LIMIT 20;
