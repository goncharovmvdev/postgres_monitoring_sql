-- системный ввод-вывод pg_stat_io (PG16-17; на PG18 op_bytes удалён — используйте read_bytes/write_bytes/extend_bytes)
SELECT
    backend_type,
    context,
    SUM(reads) AS reads,
    pg_size_pretty(SUM(reads * op_bytes)) AS read_bytes,
    SUM(writes) AS writes,
    pg_size_pretty(SUM(writes * op_bytes)) AS write_bytes,
    SUM(extends) AS extends,
    SUM(hits) AS hits,
    SUM(evictions) AS evictions,
    ROUND(100.0 * SUM(hits) / NULLIF(SUM(hits) + SUM(reads), 0), 2) AS hit_ratio_pct
FROM pg_stat_io
GROUP BY backend_type, context
HAVING COALESCE(SUM(reads), 0) + COALESCE(SUM(writes), 0)
     + COALESCE(SUM(extends), 0) + COALESCE(SUM(hits), 0)
     + COALESCE(SUM(evictions), 0) > 0
ORDER BY SUM(reads * op_bytes) DESC NULLS LAST, backend_type, context;
