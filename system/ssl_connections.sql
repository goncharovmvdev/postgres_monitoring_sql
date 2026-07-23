-- TLS-статус TCP-подключений: выявляет незашифрованные и устаревшие протоколы
-- требуется pg_monitor/pg_read_all_stats: без них чужие сессии не видны (client_addr и поля pg_stat_ssl = NULL)
SELECT
    s.ssl,
    s.version AS tls_version,
    s.cipher,
    COUNT(*) AS connections
FROM pg_stat_ssl s
JOIN pg_stat_activity a ON a.pid = s.pid
WHERE a.client_addr IS NOT NULL
GROUP BY s.ssl, s.version, s.cipher
ORDER BY connections DESC;

-- пути к сертификатам для внешней проверки срока действия:
-- openssl x509 -enddate -noout -in <ssl_cert_file>  (алерт при < 30 дней)
SELECT
    name,
    setting
FROM pg_settings
WHERE name IN ('ssl', 'ssl_cert_file', 'ssl_key_file', 'ssl_ca_file', 'ssl_crl_file')
ORDER BY name;
