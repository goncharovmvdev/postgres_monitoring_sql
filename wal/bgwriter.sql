-- статистика bgwriter: фоновая очистка грязных буферов
-- рост maxwritten_clean = bgwriter упирается в bgwriter_lru_maxpages и не успевает
SELECT
    buffers_clean,
    pg_size_pretty(
        buffers_clean * current_setting('block_size')::BIGINT
    ) AS cleaned_size,
    maxwritten_clean,
    buffers_alloc,
    ROUND(
        buffers_clean::NUMERIC * 3600
        / NULLIF(EXTRACT(EPOCH FROM (now() - stats_reset)), 0),
        2
    ) AS buffers_clean_per_hour,
    stats_reset,
    now() - stats_reset AS stats_age
FROM pg_stat_bgwriter;
