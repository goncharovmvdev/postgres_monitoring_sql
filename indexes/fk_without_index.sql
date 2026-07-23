-- внешние ключи без индекса
SELECT
    n.nspname AS schema_name,
    t.relname AS table_name,
    c.conname AS constraint_name,
    (
        SELECT array_agg(a.attname ORDER BY k.ord)
        FROM unnest(c.conkey) WITH ORDINALITY AS k(attnum, ord)
        JOIN pg_attribute a
            ON a.attrelid = c.conrelid
           AND a.attnum = k.attnum
    ) AS fk_columns,
    c.confrelid::REGCLASS AS referenced_table,
    pg_size_pretty(pg_relation_size(c.conrelid)) AS table_size
FROM pg_constraint c
JOIN pg_class t
    ON t.oid = c.conrelid
JOIN pg_namespace n
    ON n.oid = t.relnamespace
WHERE c.contype = 'f'
  AND n.nspname NOT IN ('pg_catalog', 'pg_toast', 'information_schema')
  AND NOT EXISTS (
      SELECT 1
      FROM pg_index i
      WHERE i.indrelid = c.conrelid
        AND i.indisvalid
        AND i.indpred IS NULL
        AND (i.indkey::INT2[])[0:array_length(c.conkey, 1) - 1] @> c.conkey
  )
ORDER BY pg_relation_size(c.conrelid) DESC;
