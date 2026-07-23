-- непровалидированные NOT VALID констрейнты
SELECT
    n.nspname AS schemaname,
    c.relname,
    con.conname AS constraint_name,
    CASE con.contype
        WHEN 'c' THEN 'CHECK'
        WHEN 'f' THEN 'FOREIGN KEY'
    END AS constraint_type,
    pg_get_constraintdef(con.oid) AS definition
FROM pg_constraint AS con
JOIN pg_class AS c ON c.oid = con.conrelid
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE NOT con.convalidated
  AND con.contype IN ('c', 'f')
ORDER BY n.nspname, c.relname;
