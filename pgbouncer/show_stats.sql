-- трафик и тайминги PgBouncer по базам: total_query_count, avg_query_time, avg_xact_time, bytes in/out
-- выполняется против админ-консоли PgBouncer (не Postgres): psql -h <host> -p 6432 -U <admin> pgbouncer
-- консоль не понимает комментарии — команду вводить вручную или экспортировать через pgbouncer_exporter
SHOW STATS;
