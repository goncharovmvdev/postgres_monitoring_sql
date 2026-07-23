-- таблицы без первичного ключа
SELECT
    n.nspname AS schemaname,
    c.relname,
    CASE c.relreplident
        WHEN 'd' THEN 'default'
        WHEN 'n' THEN 'nothing'
        WHEN 'f' THEN 'full'
        WHEN 'i' THEN 'index'
    END AS replica_identity,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class AS c
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'p')
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND NOT EXISTS (
      SELECT 1
      FROM pg_constraint AS con
      WHERE con.conrelid = c.oid
        AND con.contype = 'p'
  )
ORDER BY pg_total_relation_size(c.oid) DESC;
