-- статистика чекпоинтов на PG17+ (столбцы переехали из pg_stat_bgwriter в pg_stat_checkpointer)
-- низкий timed_pct = чекпоинты по требованию, вероятно мал max_wal_size
-- num_timed включает пропущенные (skipped) чекпоинты на простаивающем сервере,
-- поэтому checkpoints_per_hour/timed_pct завышены при низкой нагрузке; на PG18+ реальные выполнения — столбец num_done
SELECT
    num_timed,
    num_requested,
    ROUND(
        num_timed::NUMERIC * 100
        / NULLIF(num_timed + num_requested, 0),
        2
    ) AS timed_pct,
    ROUND(
        (num_timed + num_requested)::NUMERIC * 3600
        / NULLIF(EXTRACT(EPOCH FROM (now() - stats_reset)), 0),
        2
    ) AS checkpoints_per_hour,
    buffers_written,
    pg_size_pretty(
        buffers_written * current_setting('block_size')::BIGINT
    ) AS checkpoint_written,
    ROUND(write_time::NUMERIC / 1000, 2) AS write_time_sec,
    ROUND(sync_time::NUMERIC / 1000, 2) AS sync_time_sec,
    restartpoints_timed,
    restartpoints_req,
    restartpoints_done,
    stats_reset,
    now() - stats_reset AS stats_age
FROM pg_stat_checkpointer;
