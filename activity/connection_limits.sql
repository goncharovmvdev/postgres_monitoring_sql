-- насыщение лимитов подключений ролей и баз
WITH role_sessions AS (
    SELECT usename,
           COUNT(*) AS used
    FROM pg_stat_activity
    WHERE backend_type = 'client backend'
    GROUP BY usename
),
db_sessions AS (
    SELECT datname,
           numbackends AS used
    FROM pg_stat_database
    WHERE datname IS NOT NULL
)
SELECT 'role' AS scope,
       r.rolname AS name,
       COALESCE(rs.used, 0) AS used,
       r.rolconnlimit AS conn_limit,
       ROUND(100.0 * COALESCE(rs.used, 0) / NULLIF(r.rolconnlimit, 0), 1) AS used_pct,
       r.rolconnlimit - COALESCE(rs.used, 0) AS remaining
FROM pg_roles r
LEFT JOIN role_sessions rs ON rs.usename = r.rolname
WHERE r.rolconnlimit >= 0
UNION ALL
SELECT 'database' AS scope,
       d.datname AS name,
       COALESCE(ds.used, 0) AS used,
       d.datconnlimit AS conn_limit,
       ROUND(100.0 * COALESCE(ds.used, 0) / NULLIF(d.datconnlimit, 0), 1) AS used_pct,
       d.datconnlimit - COALESCE(ds.used, 0) AS remaining
FROM pg_database d
LEFT JOIN db_sessions ds ON ds.datname = d.datname
WHERE d.datconnlimit >= 0
ORDER BY used_pct DESC NULLS LAST, used DESC;
