-- статистика spill и streaming логических слотов
SELECT
    st.slot_name,
    rs.active,
    rs.wal_status,
    st.spill_txns,
    st.spill_count,
    pg_size_pretty(st.spill_bytes) AS spill_bytes,
    round(100.0 * st.spill_bytes / NULLIF(st.total_bytes, 0), 2) AS spill_pct_of_total,
    st.stream_txns,
    st.stream_count,
    pg_size_pretty(st.stream_bytes) AS stream_bytes,
    st.total_txns,
    pg_size_pretty(st.total_bytes) AS total_bytes,
    st.stats_reset
FROM pg_stat_replication_slots AS st
LEFT JOIN pg_replication_slots AS rs ON rs.slot_name = st.slot_name
ORDER BY st.spill_bytes DESC, st.total_bytes DESC;
