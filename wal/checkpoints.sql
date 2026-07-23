-- статистика чекпоинтов
SELECT
    checkpoints_timed,
    checkpoints_req,
    ROUND(
        checkpoints_timed::NUMERIC * 100
        / NULLIF(checkpoints_timed + checkpoints_req, 0),
        2
    ) AS timed_pct,
    ROUND(
        (checkpoints_timed + checkpoints_req)::NUMERIC * 3600
        / NULLIF(EXTRACT(EPOCH FROM (now() - stats_reset)), 0),
        2
    ) AS checkpoints_per_hour,
    buffers_checkpoint,
    pg_size_pretty(
        buffers_checkpoint * current_setting('block_size')::BIGINT
    ) AS checkpoint_written,
    ROUND(
        buffers_checkpoint::NUMERIC
        / NULLIF(checkpoints_timed + checkpoints_req, 0),
        2
    ) AS avg_buffers_per_checkpoint,
    ROUND(checkpoint_write_time::NUMERIC / 1000, 2) AS write_time_sec,
    ROUND(checkpoint_sync_time::NUMERIC / 1000, 2) AS sync_time_sec,
    ROUND(
        checkpoint_write_time::NUMERIC
        / NULLIF(checkpoints_timed + checkpoints_req, 0) / 1000,
        2
    ) AS avg_write_time_sec,
    stats_reset,
    now() - stats_reset AS stats_age
FROM pg_stat_bgwriter;
