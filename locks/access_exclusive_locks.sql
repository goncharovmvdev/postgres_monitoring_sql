-- кто и как долго держит accessexclusivelock
SELECT
    l.relation::regclass AS relation,
    a.pid,
    a.usename,
    a.application_name,
    a.state,
    now() - a.xact_start AS xact_duration,
    now() - a.state_change AS state_duration,
    LEFT(a.query, 200) AS query,
    (
        SELECT count(*)
        FROM pg_locks AS w
        WHERE NOT w.granted
            AND w.locktype = 'relation'
            AND w.relation = l.relation
            AND w.database = l.database
    ) AS waiting_count
FROM pg_locks AS l
JOIN pg_stat_activity AS a
    ON a.pid = l.pid
WHERE l.granted
    AND l.mode = 'AccessExclusiveLock'
    AND l.locktype = 'relation'
    AND l.pid <> pg_backend_pid()
ORDER BY xact_duration DESC NULLS LAST
LIMIT 100;
