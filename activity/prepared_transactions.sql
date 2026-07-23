-- зависшие подготовленные транзакции (2PC)
-- держат блокировки и пинят xmin без активной сессии; в норме пусто, если 2PC не используется
SELECT
    gid,
    database,
    owner,
    transaction AS xid,
    age(transaction) AS xid_age,
    prepared,
    now() - prepared AS prepared_for
FROM pg_prepared_xacts
ORDER BY prepared;
