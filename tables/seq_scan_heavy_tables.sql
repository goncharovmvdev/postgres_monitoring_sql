-- таблицы с частыми seq scan
SELECT
    schemaname,
    relname,
    seq_scan,
    seq_tup_read,
    ROUND(seq_tup_read::NUMERIC / NULLIF(seq_scan, 0), 1) AS avg_rows_per_seq_scan,
    COALESCE(idx_scan, 0) AS idx_scan,
    COALESCE(idx_tup_fetch, 0) AS idx_tup_fetch,
    ROUND(100.0 * seq_scan / NULLIF(seq_scan + COALESCE(idx_scan, 0), 0), 2) AS seq_scan_pct,
    n_live_tup,
    pg_size_pretty(pg_relation_size(relid)) AS table_size,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
WHERE seq_scan > 0
  AND pg_relation_size(relid) >= 1048576
ORDER BY seq_tup_read DESC
LIMIT 50;
