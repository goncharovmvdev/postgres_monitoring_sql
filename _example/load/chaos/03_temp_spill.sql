-- фаза 3: temp-спиллы и seq scan — сортировки/агрегации при крошечном work_mem
-- смотреть: temp байт/с, top "кто спиллит", seq scan на accounts, cache hit, "кто читает диск"
-- запуск: pgbench -n -f 03_temp_spill.sql -c 2 -T 120
SET work_mem = '64kB';
SELECT aid % 977 AS g, SUM(abalance), COUNT(*) FROM pgbench_accounts GROUP BY g ORDER BY 2 DESC LIMIT 5;
SELECT aid, abalance FROM pgbench_accounts ORDER BY abalance DESC, aid LIMIT 10;
