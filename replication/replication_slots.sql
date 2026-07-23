-- Слоты репликации и удержание WAL
WITH src AS (
    SELECT CASE
               WHEN pg_is_in_recovery() THEN pg_last_wal_replay_lsn()
               ELSE pg_current_wal_lsn()
           END AS current_lsn
)
SELECT
    s.slot_name,
    s.slot_type,
    s.plugin,
    s.database,
    s.temporary,
    s.active,
    s.active_pid,
    s.wal_status,
    s.restart_lsn,
    s.confirmed_flush_lsn,
    s.xmin AS slot_xmin,
    s.catalog_xmin,
    pg_size_pretty(pg_wal_lsn_diff(src.current_lsn, s.restart_lsn)) AS retained_wal,
    pg_size_pretty(pg_wal_lsn_diff(src.current_lsn, s.confirmed_flush_lsn)) AS unconsumed_wal,
    pg_size_pretty(s.safe_wal_size) AS safe_wal_size
FROM pg_replication_slots AS s
CROSS JOIN src
ORDER BY pg_wal_lsn_diff(src.current_lsn, s.restart_lsn) DESC NULLS LAST;
