-- статус приёмника WAL на реплике
SELECT
    pid,
    status,
    sender_host,
    sender_port,
    slot_name,
    written_lsn,
    flushed_lsn,
    latest_end_lsn,
    pg_size_pretty(pg_wal_lsn_diff(latest_end_lsn, flushed_lsn)) AS flush_gap,
    last_msg_receipt_time,
    now() - last_msg_receipt_time AS since_last_msg
FROM pg_stat_wal_receiver;
