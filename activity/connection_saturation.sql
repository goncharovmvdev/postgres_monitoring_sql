-- занятость лимита max_connections
WITH settings AS (
    SELECT current_setting('max_connections')::int AS max_connections,
           current_setting('superuser_reserved_connections')::int AS reserved_connections
),
sessions AS (
    SELECT COUNT(*) FILTER (WHERE backend_type = 'client backend') AS client_backends,
           COUNT(*) FILTER (WHERE backend_type = 'client backend' AND state = 'active') AS active,
           COUNT(*) FILTER (WHERE backend_type = 'client backend' AND state = 'idle') AS idle,
           COUNT(*) FILTER (WHERE backend_type = 'client backend' AND state LIKE 'idle in transaction%') AS idle_in_xact
    FROM pg_stat_activity
)
SELECT st.max_connections,
       st.reserved_connections,
       se.client_backends AS used_connections,
       st.max_connections - st.reserved_connections - se.client_backends AS available_for_clients,
       ROUND(100.0 * se.client_backends / NULLIF(st.max_connections, 0), 1) AS used_pct,
       se.active,
       se.idle,
       se.idle_in_xact
FROM settings st
CROSS JOIN sessions se;
