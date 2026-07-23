-- расхождение версий collation после апгрейда библиотек
SELECT
    'database' AS object_type,
    d.datname AS object_name,
    CASE d.datlocprovider
        WHEN 'c' THEN 'libc'
        WHEN 'i' THEN 'icu'
        WHEN 'b' THEN 'builtin'
    END AS provider,
    d.datcollversion AS recorded_version,
    pg_database_collation_actual_version(d.oid) AS actual_version
FROM pg_database d
WHERE d.datcollversion IS NOT NULL
    AND d.datcollversion IS DISTINCT FROM pg_database_collation_actual_version(d.oid)
UNION ALL
SELECT
    'collation' AS object_type,
    n.nspname || '.' || c.collname AS object_name,
    CASE c.collprovider
        WHEN 'c' THEN 'libc'
        WHEN 'i' THEN 'icu'
        WHEN 'b' THEN 'builtin'
    END AS provider,
    c.collversion AS recorded_version,
    pg_collation_actual_version(c.oid) AS actual_version
FROM pg_collation c
JOIN pg_namespace n
    ON n.oid = c.collnamespace
WHERE c.collversion IS NOT NULL
    AND c.collversion IS DISTINCT FROM pg_collation_actual_version(c.oid)
ORDER BY object_type, object_name;
