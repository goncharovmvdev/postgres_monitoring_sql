-- давление на SLRU кэши
SELECT
    name,
    blks_zeroed,
    blks_hit,
    blks_read,
    blks_written,
    blks_exists,
    flushes,
    truncates,
    ROUND(100.0 * blks_hit / NULLIF(blks_hit + blks_read, 0), 2) AS hit_pct,
    stats_reset
FROM pg_stat_slru
ORDER BY blks_read DESC;
