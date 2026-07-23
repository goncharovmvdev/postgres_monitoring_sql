-- Статус и лаг реплик
WITH src AS (
    SELECT CASE
               WHEN pg_is_in_recovery() THEN pg_last_wal_replay_lsn()
               ELSE pg_current_wal_lsn()
           END AS current_lsn
)
SELECT
    r.pid,
    r.usename,
    r.application_name,
    r.client_addr,
    r.client_hostname,
    r.state,
    r.sync_state,
    r.sync_priority,
    r.backend_start,
    now() - r.backend_start AS connected_for,
    r.sent_lsn,
    r.write_lsn,
    r.flush_lsn,
    r.replay_lsn,
    pg_size_pretty(pg_wal_lsn_diff(src.current_lsn, r.sent_lsn)) AS sent_lag_size,
    pg_size_pretty(pg_wal_lsn_diff(src.current_lsn, r.flush_lsn)) AS flush_lag_size,
    pg_size_pretty(pg_wal_lsn_diff(src.current_lsn, r.replay_lsn)) AS replay_lag_size,
    r.write_lag,
    r.flush_lag,
    r.replay_lag,
    r.reply_time
FROM pg_stat_replication AS r
CROSS JOIN src
ORDER BY pg_wal_lsn_diff(src.current_lsn, r.replay_lsn) DESC NULLS LAST;
