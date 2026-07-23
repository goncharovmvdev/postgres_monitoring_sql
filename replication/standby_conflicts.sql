-- конфликты восстановления на реплике по типам (отменённые из-за recovery запросы)
-- заполняется только на standby; на PG16+ есть ещё confl_active_logicalslot
SELECT
    d.datname,
    c.confl_tablespace,
    c.confl_lock,
    c.confl_snapshot,
    c.confl_bufferpin,
    c.confl_deadlock,
    c.confl_tablespace + c.confl_lock + c.confl_snapshot
        + c.confl_bufferpin + c.confl_deadlock AS conflicts_total
FROM pg_stat_database_conflicts c
JOIN pg_database d ON d.oid = c.datid
WHERE NOT d.datistemplate
ORDER BY conflicts_total DESC;
