-- ошибки применения логических подписок (PG15+)
-- рост apply_error_count = подписка в цикле retry и расходится с паблишером, удерживая его WAL
SELECT
    subname,
    apply_error_count,
    sync_error_count,
    stats_reset
FROM pg_stat_subscription_stats
ORDER BY apply_error_count + sync_error_count DESC;
