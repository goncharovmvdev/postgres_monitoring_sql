# postgres:17 + pg_wait_sampling, pg_stat_kcache и pg_cron из PGDG
# (репозиторий уже настроен в официальном образе)
FROM postgres:17
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-17-pg-wait-sampling \
        postgresql-17-pg-stat-kcache \
        postgresql-17-cron \
    && rm -rf /var/lib/apt/lists/*
