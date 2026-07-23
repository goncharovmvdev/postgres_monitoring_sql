-- Возраст xid по базам
SELECT
    d.datname,
    age(d.datfrozenxid) AS xid_age,
    mxid_age(d.datminmxid) AS mxid_age,
    current_setting('autovacuum_freeze_max_age')::BIGINT AS freeze_max_age,
    ROUND(100.0 * age(d.datfrozenxid)
          / NULLIF(current_setting('autovacuum_freeze_max_age')::BIGINT, 0), 1) AS pct_to_forced_autovacuum,
    ROUND(100.0 * age(d.datfrozenxid) / 2000000000.0, 1) AS pct_to_wraparound,
    2000000000 - age(d.datfrozenxid) AS xids_left,
    pg_size_pretty(pg_database_size(d.oid)) AS database_size
FROM pg_database d
ORDER BY age(d.datfrozenxid) DESC;
