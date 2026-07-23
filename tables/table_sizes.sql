-- Размеры таблиц с индексами
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    CASE c.relkind
        WHEN 'r' THEN 'table'
        WHEN 'p' THEN 'partitioned table'
        WHEN 'm' THEN 'materialized view'
    END AS relation_type,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size,
    pg_size_pretty(
        pg_table_size(c.oid)
        - COALESCE(pg_total_relation_size(NULLIF(c.reltoastrelid, 0)), 0)
    ) AS heap_size,
    pg_size_pretty(pg_indexes_size(c.oid)) AS indexes_size,
    pg_size_pretty(
        COALESCE(pg_total_relation_size(NULLIF(c.reltoastrelid, 0)), 0)
    ) AS toast_size,
    pg_total_relation_size(c.oid) AS total_size_bytes,
    ROUND(
        100.0 * pg_indexes_size(c.oid)
        / NULLIF(pg_total_relation_size(c.oid), 0),
        2
    ) AS index_percent,
    (SELECT COUNT(*) FROM pg_index i WHERE i.indrelid = c.oid) AS index_count,
    c.reltuples::BIGINT AS estimated_rows,
    s.n_live_tup AS live_rows,
    s.n_dead_tup AS dead_rows,
    ROUND(
        100.0 * s.n_dead_tup
        / NULLIF(s.n_live_tup + s.n_dead_tup, 0),
        2
    ) AS dead_rows_percent,
    GREATEST(s.last_autovacuum, s.last_vacuum) AS last_vacuum_any,
    GREATEST(s.last_autoanalyze, s.last_analyze) AS last_analyze_any
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
LEFT JOIN pg_stat_user_tables s
    ON s.relid = c.oid
WHERE c.relkind IN ('r', 'p', 'm')
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
    AND n.nspname NOT LIKE 'pg_toast%'
ORDER BY pg_total_relation_size(c.oid) DESC
LIMIT 50;
