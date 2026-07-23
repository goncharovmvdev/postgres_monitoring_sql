-- кто удерживает горизонт xmin
WITH holders AS (
    SELECT 'session' AS holder_type,
           pid::text || ' (' || COALESCE(usename::text, 'background') || ', ' || COALESCE(state, '-') || ')' AS holder,
           age(COALESCE(backend_xmin, backend_xid)) AS xmin_age,
           now() - xact_start AS held_for
    FROM pg_stat_activity
    WHERE COALESCE(backend_xmin, backend_xid) IS NOT NULL
      AND backend_type <> 'walsender'
    UNION ALL
    SELECT 'prepared_xact',
           gid,
           age(transaction),
           now() - prepared
    FROM pg_prepared_xacts
    UNION ALL
    SELECT 'replication_slot',
           slot_name || ' (' || slot_type || ', ' || CASE WHEN active THEN 'active' ELSE 'inactive' END || ')',
           GREATEST(age(xmin), age(catalog_xmin)),
           NULL
    FROM pg_replication_slots
    WHERE xmin IS NOT NULL
       OR catalog_xmin IS NOT NULL
    UNION ALL
    SELECT 'walsender',
           pid::text || ' (' || application_name || ')',
           age(backend_xmin),
           NULL
    FROM pg_stat_replication
    WHERE backend_xmin IS NOT NULL
)
SELECT holder_type,
       holder,
       xmin_age,
       held_for
FROM holders
ORDER BY xmin_age DESC NULLS LAST
LIMIT 20;
