-- статистика генерации WAL
SELECT
    wal_records,
    wal_fpi,
    wal_bytes,
    pg_size_pretty(wal_bytes) AS wal_size,
    wal_buffers_full,
    stats_reset,
    ROUND(
        wal_bytes / NULLIF(EXTRACT(EPOCH FROM (now() - stats_reset)), 0),
        2
    ) AS avg_bytes_per_sec,
    pg_size_pretty(
        (wal_bytes / NULLIF(EXTRACT(EPOCH FROM (now() - stats_reset)), 0))::numeric(20, 0)
    ) AS avg_per_sec
FROM pg_stat_wal;
