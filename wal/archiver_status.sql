-- статус архивации WAL
WITH pending AS (
    SELECT COUNT(*) AS ready_count
    FROM pg_ls_archive_statusdir()
    WHERE name LIKE '%.ready'
)
SELECT
    current_setting('archive_mode') AS archive_mode,
    a.archived_count,
    a.last_archived_wal,
    a.last_archived_time,
    now() - a.last_archived_time AS time_since_last_archive,
    a.failed_count,
    a.last_failed_wal,
    a.last_failed_time,
    ROUND(
        a.failed_count::NUMERIC * 100
        / NULLIF(a.archived_count + a.failed_count, 0),
        2
    ) AS failed_pct,
    p.ready_count AS segments_waiting_archive,
    ROUND(
        a.archived_count::NUMERIC * 3600
        / NULLIF(EXTRACT(EPOCH FROM (now() - a.stats_reset)), 0),
        2
    ) AS archived_per_hour,
    a.stats_reset
FROM pg_stat_archiver AS a
CROSS JOIN pending AS p;
