-- Регламентный сброс кумулятивной статистики через pg_cron (замена внешнего
-- maintenance-контейнера). Зачем: fixes.txt HIGH "ИСПРАВИТЬ top-N" — без
-- периодического сброса top-N по lifetime-суммам накапливает bias, новый
-- тяжёлый запрос часами не виден. Откат — rollback_cumulative_stats.txt.
-- Требует shared_preload_libraries=pg_cron и cron.database_name='postgres'
-- (postgres/postgresql.conf); расширение создаётся только в этой базе.
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- раз в неделю, воскресенье 03:00 (время GMT — pg_cron игнорирует TimeZone,
-- если не задан cron.timezone); имена джобов зафиксированы в
-- rollback_cumulative_stats.txt (cron.unschedule по имени)
SELECT cron.schedule('pgss_weekly_reset',         '0 3 * * 0', $$SELECT pg_stat_statements_reset()$$);
SELECT cron.schedule('wait_profile_weekly_reset', '0 3 * * 0', $$SELECT pg_wait_sampling_reset_profile()$$);
SELECT cron.schedule('kcache_weekly_reset',       '0 3 * * 0', $$SELECT pg_stat_kcache_reset()$$);

-- ВНИМАНИЕ: pg_cron не выполняет джобы на hot standby, а ЛОКАЛЬНАЯ статистика
-- реплики (pgss/kcache/wait-профиль) — своя. В демо её сбрасывает сервис
-- replica-maintenance (docker-compose.yml); на проде — внешний cron с psql
-- к реплике. После promote реплики её pg_cron оживает сам (preload есть).

-- гигиена самого pg_cron: чистка журнала запусков (cron.job_run_details)
SELECT cron.schedule('cron_history_cleanup', '0 4 * * 0',
       $$DELETE FROM cron.job_run_details WHERE end_time < now() - INTERVAL '30 days'$$);
