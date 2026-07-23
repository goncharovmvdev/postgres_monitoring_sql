-- статус логических подписок на стороне подписчика (PG10+)
-- отключённая подписка или отсутствующий worker = репликация молча стоит и копит WAL на паблишере
-- DISTINCT ON отсекает parallel apply workers (PG16+, streaming=parallel): у них тоже relid IS NULL
SELECT DISTINCT ON (sub.oid)
    d.datname,
    sub.subname,
    sub.subenabled,
    st.pid IS NOT NULL AS worker_running,
    st.pid,
    st.received_lsn,
    st.latest_end_lsn,
    pg_size_pretty(
        pg_wal_lsn_diff(st.received_lsn, st.latest_end_lsn)
    ) AS report_gap_size,
    st.last_msg_send_time,
    st.last_msg_receipt_time,
    now() - st.last_msg_receipt_time AS since_last_msg,
    st.latest_end_time
FROM pg_subscription sub
JOIN pg_database d ON d.oid = sub.subdbid
LEFT JOIN pg_stat_subscription st
       ON st.subid = sub.oid AND st.relid IS NULL
ORDER BY sub.oid, st.received_lsn DESC NULLS LAST;
