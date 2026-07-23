-- temp файлы на диске сейчас
SELECT
    t.spcname AS tablespace,
    f.name AS file_name,
    pg_size_pretty(f.size) AS file_size,
    f.modification AS modified_at
FROM pg_tablespace AS t
CROSS JOIN LATERAL pg_ls_tmpdir(t.oid) AS f
WHERE t.spcname <> 'pg_global'
ORDER BY f.size DESC
LIMIT 50;
