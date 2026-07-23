-- служебная статистика pg_stat_statements: вытеснение записей (PG14+)
-- быстрый рост dealloc = pg_stat_statements.max мал, статистика top-запросов недостоверна
SELECT
    i.dealloc,
    i.stats_reset,
    now() - i.stats_reset AS stats_age,
    (SELECT COUNT(*) FROM pg_stat_statements) AS tracked_statements,
    current_setting('pg_stat_statements.max')::INT AS max_statements
FROM pg_stat_statements_info i;
