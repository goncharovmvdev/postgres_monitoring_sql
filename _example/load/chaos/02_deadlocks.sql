-- фаза 2: deadlocks — чётные и нечётные клиенты обновляют две строки в противоположном порядке
-- pgbench 16+ считает deadlock как failed-транзакцию и продолжает (в логе будет number of failed)
-- смотреть: deadlocks/с, rollback
-- запуск: pgbench -n -f 02_deadlocks.sql -c 4 -T 120
\if :client_id % 2 = 0
BEGIN;
UPDATE pgbench_tellers SET tbalance = tbalance WHERE tid = 1;
\sleep 500 ms
UPDATE pgbench_tellers SET tbalance = tbalance WHERE tid = 2;
COMMIT;
\else
BEGIN;
UPDATE pgbench_tellers SET tbalance = tbalance WHERE tid = 2;
\sleep 500 ms
UPDATE pgbench_tellers SET tbalance = tbalance WHERE tid = 1;
COMMIT;
\endif
