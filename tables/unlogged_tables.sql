-- unlogged таблицы теряются при сбое
SELECT
    n.nspname AS schemaname,
    c.relname,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class AS c
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE c.relpersistence = 'u'
  AND c.relkind IN ('r', 'p')
ORDER BY pg_total_relation_size(c.oid) DESC;
