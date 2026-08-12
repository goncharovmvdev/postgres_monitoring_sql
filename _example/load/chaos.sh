#!/bin/sh
# Управляемый «хаос» (~11 минут): вся логика фаз — в pgbench-скриптах load/chaos/*.sql,
# здесь только последовательный запуск. Запуск:
#   docker compose run --rm --no-deps --entrypoint sh load /load/chaos.sh
H="-h postgres -U postgres -d appdb"
export PGPASSWORD=postgres

echo "=== фаза 1 (2 мин): блокировки на горячей строке"
pgbench $H -n -f /load/chaos/01_locks.sql -c 6 -j 1 -T 120 -P 30

echo "=== фаза 2 (2 мин): deadlocks (в отчёте pgbench — number of failed transactions)"
pgbench $H -n -f /load/chaos/02_deadlocks.sql -c 4 -j 1 -T 120 -P 30

echo "=== фаза 3 (2 мин): temp-спиллы + seq scan при work_mem=64kB"
pgbench $H -n -f /load/chaos/03_temp_spill.sql -c 2 -j 1 -T 120 -P 30

echo "=== фаза 4: WAL-шторм + bloat (2 прохода по полтаблицы)"
pgbench $H -n -f /load/chaos/04_wal_storm.sql -c 1 -j 1 -t 2

echo "=== фаза 5 (3 мин): пиннинг xmin + 40 коннектов + шторм откатов"
pgbench $H -n -f /load/chaos/05_xmin_pin.sql -c 44 -j 2 -T 180 -P 30

echo "=== хаос завершён: наблюдайте расчистку — автовакуум съедает dead tuples, xmin отпущен"
