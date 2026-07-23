-- системный ввод-вывод pg_stat_io на pg18+
SELECT
    backend_type,
    context,
    SUM(reads) AS reads,
    pg_size_pretty(SUM(read_bytes)) AS read_bytes,
    SUM(writes) AS writes,
    pg_size_pretty(SUM(write_bytes)) AS write_bytes,
    SUM(extends) AS extends,
    pg_size_pretty(SUM(extend_bytes)) AS extend_bytes,
    SUM(hits) AS hits,
    SUM(evictions) AS evictions,
    ROUND(100.0 * SUM(hits) / NULLIF(SUM(hits) + SUM(reads), 0), 2) AS hit_ratio_pct
FROM pg_stat_io
GROUP BY backend_type, context
HAVING COALESCE(SUM(reads), 0) + COALESCE(SUM(writes), 0)
     + COALESCE(SUM(extends), 0) + COALESCE(SUM(hits), 0)
     + COALESCE(SUM(evictions), 0) > 0
ORDER BY SUM(read_bytes) DESC NULLS LAST, backend_type, context;
