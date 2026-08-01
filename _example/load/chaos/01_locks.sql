-- фаза 1: блокировки на горячей строке
-- клиент 0 держит лок branch 1 почти весь прогон, остальные стоят в очереди
-- смотреть: lock waiters, ожидания Lock, блокировки по режимам, longest active query
-- запуск: pgbench -n -f 01_locks.sql -c 6 -T 120
-- сон дольше T нарочно: pgbench после -T дожидается конца текущей итерации,
-- поэтому сон < T означал бы вторую итерацию держателя и фазу вдвое длиннее
\if :client_id = 0
BEGIN;
UPDATE pgbench_branches SET bbalance = bbalance WHERE bid = 1;
\sleep 125 s
COMMIT;
\else
UPDATE pgbench_branches SET bbalance = bbalance + 1 WHERE bid = 1;
\endif
