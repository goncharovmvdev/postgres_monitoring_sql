-- фаза 5: пиннинг xmin + наплыв коннектов + шторм откатов, роли по client_id:
--   0     — REPEATABLE READ транзакция спит 170 сек и держит xmin (vacuum не чистит мусор)
--   1-40  — просто занятые коннекты (\sleep = клиентская пауза, сессия idle)
--   41+   — цикл BEGIN/UPDATE/ROLLBACK
-- смотреть: xmin-горизонт, oldest xact, dead tuples не убывают до конца фазы, коннекты, rollback
-- запуск: pgbench -n -f 05_xmin_pin.sql -c 44 -j 2 -T 180
-- сны дольше T нарочно: pgbench после -T дожидается конца текущей итерации,
-- так каждый спящий клиент отрабатывает ровно один раз (~185 сек на фазу)
\if :client_id = 0
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*) FROM pgbench_accounts;
\sleep 185 s
COMMIT;
\elif :client_id <= 40
\sleep 185 s
\else
BEGIN;
UPDATE pgbench_tellers SET tbalance = 0 WHERE tid = 3;
ROLLBACK;
\sleep 200 ms
\endif
