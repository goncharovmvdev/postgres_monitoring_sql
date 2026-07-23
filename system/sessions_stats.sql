-- статистика сессий по базам: обрывы, фатальные ошибки, принудительные завершения (PG14+)
SELECT
    d.datname,
    s.sessions,
    s.sessions_abandoned,
    s.sessions_fatal,
    s.sessions_killed,
    ROUND(s.session_time::NUMERIC / 1000, 0) AS session_time_sec,
    ROUND(s.active_time::NUMERIC / 1000, 0) AS active_time_sec,
    ROUND(s.idle_in_transaction_time::NUMERIC / 1000, 0) AS idle_in_xact_time_sec,
    s.stats_reset
FROM pg_stat_database s
JOIN pg_database d ON d.oid = s.datid
WHERE NOT d.datistemplate
ORDER BY s.sessions_fatal + s.sessions_killed DESC;
