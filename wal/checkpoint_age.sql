-- возраст чекпоинта и объём crash-recovery
WITH cur AS (
    SELECT
        CASE
            WHEN pg_is_in_recovery() THEN pg_last_wal_replay_lsn()
            ELSE pg_current_wal_lsn()
        END AS current_lsn
)
SELECT
    c.checkpoint_time,
    now() - c.checkpoint_time AS checkpoint_age,
    c.checkpoint_lsn,
    c.redo_lsn,
    c.timeline_id,
    cur.current_lsn,
    pg_wal_lsn_diff(cur.current_lsn, c.redo_lsn) AS crash_recovery_bytes,
    pg_size_pretty(
        pg_wal_lsn_diff(cur.current_lsn, c.redo_lsn)
    ) AS crash_recovery_size
FROM pg_control_checkpoint() AS c
CROSS JOIN cur;
