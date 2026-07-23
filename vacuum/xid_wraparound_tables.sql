-- возраст xid и mxid по таблицам
SELECT
    n.nspname AS schemaname,
    c.relname,
    age(c.relfrozenxid) AS xid_age,
    mxid_age(c.relminmxid) AS mxid_age,
    ROUND(100.0 * age(c.relfrozenxid) / current_setting('autovacuum_freeze_max_age')::numeric, 1) AS pct_to_forced_freeze,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class AS c
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm', 't')
  AND c.relfrozenxid <> '0'::xid
ORDER BY age(c.relfrozenxid) DESC
LIMIT 50;
