-- лаг воспроизведения на самой реплике
SELECT
    pg_is_in_recovery() AS in_recovery,
    pg_last_wal_receive_lsn() AS receive_lsn,
    pg_last_wal_replay_lsn() AS replay_lsn,
    pg_size_pretty(
        pg_wal_lsn_diff(pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn())
    ) AS replay_lag_size,
    pg_last_xact_replay_timestamp() AS last_replay_timestamp,
    CASE
        WHEN pg_last_wal_receive_lsn() = pg_last_wal_replay_lsn()
            THEN INTERVAL '0'
        ELSE now() - pg_last_xact_replay_timestamp()
    END AS replay_delay;
