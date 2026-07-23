-- Таблицы превысившие порог autovacuum
WITH table_settings AS (
    SELECT
        c.oid AS relid,
        n.nspname AS schemaname,
        c.relname,
        GREATEST(c.reltuples, 0) AS reltuples,
        s.n_dead_tup,
        s.n_mod_since_analyze,
        s.last_autovacuum,
        s.last_autoanalyze,
        COALESCE((SELECT option_value::FLOAT8
                    FROM pg_options_to_table(c.reloptions)
                   WHERE option_name = 'autovacuum_vacuum_threshold'),
                 current_setting('autovacuum_vacuum_threshold')::FLOAT8) AS vacuum_threshold,
        COALESCE((SELECT option_value::FLOAT8
                    FROM pg_options_to_table(c.reloptions)
                   WHERE option_name = 'autovacuum_vacuum_scale_factor'),
                 current_setting('autovacuum_vacuum_scale_factor')::FLOAT8) AS vacuum_scale_factor,
        COALESCE((SELECT option_value::FLOAT8
                    FROM pg_options_to_table(c.reloptions)
                   WHERE option_name = 'autovacuum_analyze_threshold'),
                 current_setting('autovacuum_analyze_threshold')::FLOAT8) AS analyze_threshold,
        COALESCE((SELECT option_value::FLOAT8
                    FROM pg_options_to_table(c.reloptions)
                   WHERE option_name = 'autovacuum_analyze_scale_factor'),
                 current_setting('autovacuum_analyze_scale_factor')::FLOAT8) AS analyze_scale_factor
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN pg_stat_user_tables s ON s.relid = c.oid
    WHERE c.relkind IN ('r', 'm')
)
SELECT
    schemaname,
    relname,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    reltuples::BIGINT AS estimated_rows,
    n_dead_tup,
    (vacuum_threshold + vacuum_scale_factor * reltuples)::BIGINT AS vacuum_trigger,
    ROUND((100.0 * n_dead_tup
           / NULLIF(vacuum_threshold + vacuum_scale_factor * reltuples, 0))::NUMERIC, 1) AS vacuum_trigger_pct,
    n_mod_since_analyze,
    (analyze_threshold + analyze_scale_factor * reltuples)::BIGINT AS analyze_trigger,
    ROUND((100.0 * n_mod_since_analyze
           / NULLIF(analyze_threshold + analyze_scale_factor * reltuples, 0))::NUMERIC, 1) AS analyze_trigger_pct,
    last_autovacuum,
    last_autoanalyze
FROM table_settings
WHERE n_dead_tup > vacuum_threshold + vacuum_scale_factor * reltuples
   OR n_mod_since_analyze > analyze_threshold + analyze_scale_factor * reltuples
ORDER BY vacuum_trigger_pct DESC NULLS LAST
LIMIT 50;
