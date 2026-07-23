-- версия и аптайм сервера
SELECT
    version() AS server_version,
    current_setting('server_version_num') AS version_num,
    pg_postmaster_start_time() AS start_time,
    date_trunc('second', now() - pg_postmaster_start_time()) AS uptime,
    pg_conf_load_time() AS config_reload_time,
    pg_is_in_recovery() AS in_recovery,
    current_setting('data_directory') AS data_directory,
    inet_server_addr() AS listen_address,
    inet_server_port() AS listen_port;
