-- ошибки контрольных сумм страниц по базам (PG12+); при data_checksums=off столбцы checksum_* равны NULL
-- любой прирост checksum_failures = повреждение данных на диске, алерт немедленно
SELECT
    current_setting('data_checksums') AS data_checksums,
    COALESCE(d.datname, '<shared objects>') AS datname,
    s.checksum_failures,
    s.checksum_last_failure,
    s.stats_reset
FROM pg_stat_database s
LEFT JOIN pg_database d ON d.oid = s.datid
ORDER BY s.checksum_failures DESC NULLS LAST;
