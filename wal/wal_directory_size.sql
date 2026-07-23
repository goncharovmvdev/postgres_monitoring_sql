-- размер каталога pg_wal
SELECT
    COUNT(*) AS wal_segments,
    SUM(size) AS total_size_bytes,
    pg_size_pretty(SUM(size)) AS total_size,
    pg_size_pretty(SUM(size) / NULLIF(COUNT(*), 0)) AS avg_segment_size
FROM pg_ls_waldir()
WHERE name ~ '^[0-9A-F]{24}$';
