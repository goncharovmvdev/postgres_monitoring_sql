-- дублирующиеся индексы
WITH index_signatures AS (
    SELECT
        i.indexrelid,
        i.indrelid,
        i.indkey::TEXT
            || '|' || i.indclass::TEXT
            || '|' || i.indoption::TEXT
            || '|' || i.indcollation::TEXT
            || '|' || COALESCE(pg_get_expr(i.indexprs, i.indrelid), '')
            || '|' || COALESCE(pg_get_expr(i.indpred, i.indrelid), '') AS signature
    FROM pg_index i
    JOIN pg_class c
        ON c.oid = i.indexrelid
    JOIN pg_namespace n
        ON n.oid = c.relnamespace
    WHERE n.nspname NOT IN ('pg_catalog', 'pg_toast', 'information_schema')
      AND i.indisvalid
)
SELECT
    s.indrelid::REGCLASS AS table_name,
    array_agg(
        s.indexrelid::REGCLASS
        ORDER BY pg_relation_size(s.indexrelid) DESC
    ) AS duplicate_indexes,
    COUNT(*) AS copies,
    pg_size_pretty(SUM(pg_relation_size(s.indexrelid))::BIGINT) AS total_size,
    pg_size_pretty(
        (SUM(pg_relation_size(s.indexrelid)) - MAX(pg_relation_size(s.indexrelid)))::BIGINT
    ) AS potential_savings
FROM index_signatures s
GROUP BY s.indrelid, s.signature
HAVING COUNT(*) > 1
ORDER BY SUM(pg_relation_size(s.indexrelid)) DESC;
