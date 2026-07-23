-- Размеры баз данных
SELECT
    d.datname AS database_name,
    pg_catalog.pg_get_userbyid(d.datdba) AS owner,
    t.spcname AS tablespace_name,
    pg_catalog.pg_encoding_to_char(d.encoding) AS encoding,
    pg_size_pretty(pg_database_size(d.oid)) AS database_size,
    pg_database_size(d.oid) AS database_size_bytes,
    ROUND(
        100.0 * pg_database_size(d.oid)
        / NULLIF(SUM(pg_database_size(d.oid)) OVER (), 0),
        2
    ) AS percent_of_cluster,
    s.numbackends AS active_connections,
    d.datconnlimit AS connection_limit,
    ROUND(
        100.0 * s.blks_hit
        / NULLIF(s.blks_hit + s.blks_read, 0),
        2
    ) AS cache_hit_percent,
    s.temp_files AS temp_files,
    pg_size_pretty(s.temp_bytes) AS temp_size,
    s.deadlocks AS deadlocks,
    AGE(d.datfrozenxid) AS frozen_xid_age
FROM pg_database d
JOIN pg_tablespace t
    ON t.oid = d.dattablespace
LEFT JOIN pg_stat_database s
    ON s.datid = d.oid
WHERE d.datistemplate = FALSE
ORDER BY pg_database_size(d.oid) DESC;
