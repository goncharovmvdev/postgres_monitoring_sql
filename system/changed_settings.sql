-- измененные параметры конфигурации
SELECT
    name,
    setting,
    boot_val,
    source,
    sourcefile
FROM pg_settings
WHERE source NOT IN ('default', 'override')
ORDER BY name;
