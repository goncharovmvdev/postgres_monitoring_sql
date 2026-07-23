-- невалидные индексы
SELECT
    n.nspname AS schema_name,
    t.relname AS table_name,
    c.relname AS index_name,
    pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
    i.indisvalid,
    i.indisready,
    i.indislive,
    pg_get_indexdef(i.indexrelid) AS index_definition
FROM pg_index i
JOIN pg_class c
    ON c.oid = i.indexrelid
JOIN pg_class t
    ON t.oid = i.indrelid
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE NOT i.indisvalid
   OR NOT i.indisready
   OR NOT i.indislive
ORDER BY pg_relation_size(i.indexrelid) DESC;
