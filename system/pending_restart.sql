-- параметры, изменённые в конфиге, но ожидающие рестарта для применения
-- в норме пусто; для экспорта достаточно count(*), алерт на > 0 дольше нескольких часов
-- sourcefile виден только суперпользователю или роли с pg_read_all_settings (входит в pg_monitor)
SELECT
    name,
    setting,
    source,
    sourcefile
FROM pg_settings
WHERE pending_restart
ORDER BY name;
