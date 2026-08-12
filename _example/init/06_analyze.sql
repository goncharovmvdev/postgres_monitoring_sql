-- свежая статистика сразу после initdb: без неё pg_statistic пуст и
-- bloat-оценка (pg_bloat.yml, job'ы pgNN-appdb) не отдаёт ни одной строки
-- до первого autoanalyze — панель bloat висела бы в No data
\c appdb
ANALYZE;
