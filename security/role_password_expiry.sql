-- сроки действия паролей ролей
SELECT
    rolname,
    rolvaliduntil,
    rolvaliduntil - now() AS time_left,
    rolcanlogin,
    rolconnlimit
FROM pg_roles
WHERE rolvaliduntil IS NOT NULL
  AND rolvaliduntil <> 'infinity'
ORDER BY rolvaliduntil;
