-- ошибки правил pg_hba
SELECT
    line_number,
    type,
    database,
    user_name,
    address,
    netmask,
    auth_method,
    error
FROM pg_hba_file_rules
WHERE error IS NOT NULL
ORDER BY line_number;
