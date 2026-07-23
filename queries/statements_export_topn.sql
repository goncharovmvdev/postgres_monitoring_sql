-- счётчики top-N запросов для непрерывного экспорта в Prometheus (без текста запроса)
-- экспортировать как counters с лейблами queryid/datname/rolname; rate() в PromQL даёт текущую нагрузку,
-- текст запроса получать отдельным lookup по queryid (см. top_*.sql)
SELECT
    s.queryid,
    COALESCE(d.datname, s.dbid::TEXT) AS datname,
    COALESCE(r.rolname, s.userid::TEXT) AS rolname,
    s.calls,
    ROUND(s.total_exec_time::NUMERIC, 2) AS total_exec_ms,
    s.rows,
    s.shared_blks_hit,
    s.shared_blks_read,
    s.temp_blks_written,
    s.wal_bytes
FROM pg_stat_statements s
LEFT JOIN pg_database d ON d.oid = s.dbid
LEFT JOIN pg_roles r ON r.oid = s.userid
ORDER BY s.total_exec_time DESC
LIMIT 50;
