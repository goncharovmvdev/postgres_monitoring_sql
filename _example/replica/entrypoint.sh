#!/bin/sh
# синхронная физическая реплика: при пустом PGDATA снимаем базовый бэкап с primary
# (-R пишет standby.signal и primary_conninfo с application_name=replica1,
#  -C -S создаёт физический слот replica_slot — его удержание WAL видно на дашборде)
set -e
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    rm -rf "$PGDATA"/*
    until pg_isready -h postgres >/dev/null 2>&1; do sleep 1; done
    pg_basebackup -d "host=postgres user=replicator application_name=replica1" \
        -D "$PGDATA" -R -X stream -C -S replica_slot --checkpoint=fast
fi
# каталог тома в образе создан с правами 1777, postgres требует 0700
chmod 700 "$PGDATA"
# preload и параметры зеркалят primary (postgres/postgresql.conf): kcache для
# CPU per query, auto_explain для планов медленных чтений со standby
# pg_cron на standby пассивен (джобы в recovery не выполняются), но preload
# нужен: после promote регламентные сбросы оживут сами
exec postgres -c hot_standby=on \
    -c shared_preload_libraries=pg_stat_statements,pg_wait_sampling,pg_stat_kcache,auto_explain,pg_cron \
    -c cron.database_name=postgres \
    -c cron.use_background_workers=on \
    -c track_io_timing=on \
    -c track_wal_io_timing=on \
    -c 'log_line_prefix=%m [%p] %q%u@%d app=%a qid=%Q ' \
    -c pg_wait_sampling.profile_period=10 \
    -c pg_wait_sampling.profile_queries=on \
    -c auto_explain.log_min_duration=250ms \
    -c auto_explain.sample_rate=0.1 \
    -c auto_explain.log_analyze=on \
    -c auto_explain.log_timing=off \
    -c auto_explain.log_format=json \
    -c auto_explain.log_verbose=on
