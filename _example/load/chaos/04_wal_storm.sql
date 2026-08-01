-- фаза 4: WAL-шторм + bloat — двойной UPDATE половины accounts (одна транзакция скрипта = один проход)
-- смотреть: генерация WAL, requested-чекпоинты, dead tuples, "таблиц ждут вакуума", размер pg_wal
-- запуск: pgbench -n -f 04_wal_storm.sql -c 1 -t 2
UPDATE pgbench_accounts SET abalance = abalance + 1 WHERE aid <= 250000;
UPDATE pgbench_accounts SET abalance = abalance - 1 WHERE aid <= 250000;
