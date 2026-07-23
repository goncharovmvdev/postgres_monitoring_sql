-- счётчики объектов PgBouncer: used_clients vs max_client_conn — превышение = отказ новым клиентам
-- выполняется против админ-консоли PgBouncer (не Postgres): psql -h <host> -p 6432 -U <admin> pgbouncer
-- консоль не понимает комментарии — команду вводить вручную или экспортировать через pgbouncer_exporter
SHOW LISTS;
