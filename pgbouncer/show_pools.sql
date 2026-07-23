-- состояние пулов PgBouncer: cl_waiting > 0 и растущий maxwait = клиенты стоят в очереди пулера,
-- при этом со стороны Postgres всё выглядит здоровым
-- выполняется против админ-консоли PgBouncer (не Postgres): psql -h <host> -p 6432 -U <admin> pgbouncer
-- консоль не понимает комментарии — команду вводить вручную или экспортировать через pgbouncer_exporter
SHOW POOLS;
