-- отключённые и условные триггеры пользовательских таблиц
SELECT
    n.nspname AS schemaname,
    c.relname,
    t.tgname AS trigger_name,
    CASE t.tgenabled
        WHEN 'D' THEN 'disabled'
        WHEN 'O' THEN 'origin (fires when session_replication_role = origin/local)'
        WHEN 'R' THEN 'replica (fires only when session_replication_role = replica)'
        WHEN 'A' THEN 'always (fires regardless of session_replication_role)'
    END AS enabled_state,
    t.tgisinternal,
    CASE
        WHEN t.tgisinternal AND t.tgenabled = 'D' THEN 'CRITICAL: disabled FK constraint trigger'
        WHEN t.tgisinternal THEN 'FK constraint trigger'
        ELSE 'user trigger'
    END AS trigger_kind
FROM pg_trigger AS t
JOIN pg_class AS c ON c.oid = t.tgrelid
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE t.tgenabled IN ('D', 'R', 'A')
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND n.nspname NOT LIKE 'pg_toast%'
ORDER BY (t.tgisinternal AND t.tgenabled = 'D') DESC, n.nspname, c.relname, t.tgname;
