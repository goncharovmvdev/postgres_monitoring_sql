-- temp файлы по базам
SELECT
    d.datname AS database_name,
    s.temp_files,
    s.temp_bytes,
    pg_size_pretty(s.temp_bytes) AS temp_total_size,
    pg_size_pretty(s.temp_bytes / NULLIF(s.temp_files, 0)) AS avg_temp_file_size,
    ROUND(100.0 * s.temp_bytes / NULLIF(SUM(s.temp_bytes) OVER (), 0), 2) AS pct_of_all_temp,
    ROUND(s.temp_files / NULLIF(EXTRACT(EPOCH FROM (now() - s.stats_reset)) / 3600, 0), 2) AS temp_files_per_hour,
    s.stats_reset
FROM pg_stat_database s
JOIN pg_database d ON d.oid = s.datid
WHERE d.datistemplate = FALSE
ORDER BY s.temp_bytes DESC,
         s.temp_files DESC;
