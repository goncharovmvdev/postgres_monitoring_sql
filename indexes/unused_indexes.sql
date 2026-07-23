-- неиспользуемые индексы
SELECT
    s.schemaname,
    s.relname AS table_name,
    s.indexrelname AS index_name,
    pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_size,
    s.idx_scan,
    s.idx_tup_read,
    s.idx_tup_fetch,
    pg_get_indexdef(s.indexrelid) AS index_definition
FROM pg_stat_user_indexes s
JOIN pg_index i
    ON i.indexrelid = s.indexrelid
WHERE s.idx_scan = 0
  AND NOT i.indisunique
  AND NOT i.indisprimary
  AND NOT i.indisreplident
  AND NOT EXISTS (
      SELECT 1
      FROM pg_constraint c
      WHERE c.conindid = s.indexrelid
  )
ORDER BY pg_relation_size(s.indexrelid) DESC
LIMIT 50;
