-- свежая статистика сразу после initdb: без неё pg_stats пуст и
-- bloat-оценка (pg_bloat.yml) не отдаёт ни одной строки до первого
-- autoanalyze — панель bloat висела бы в No data
ANALYZE;
