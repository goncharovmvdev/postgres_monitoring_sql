#!/bin/sh
set -e

if [ "$(id -u)" = "0" ]; then
    if ! dpkg -s postgresql-17-pg-wait-sampling >/dev/null 2>&1; then
        apt-get update -qq
        apt-get install -y -qq --no-install-recommends \
            postgresql-17-pg-wait-sampling \
            postgresql-17-pg-stat-kcache \
            postgresql-17-cron
    fi
    exec gosu postgres sh "$0"
fi
# Идемпотентность повторного старта. Маркер успеха вместо проверки PG_VERSION:
# pg_basebackup пишет файлы по мере стриминга, PG_VERSION появляется задолго до
# конца — после SIGKILL/OOM посреди бэкапа контейнер стартовал бы на
# недокачанном каталоге как на целом. Маркер ставится только после успешного
# бэкапа; нет маркера = каталог сносится целиком и бэкап повторяется.
MARKER="$PGDATA/.basebackup_complete"
if [ ! -f "$MARKER" ]; then
    find "$PGDATA" -mindepth 1 -delete
    until pg_isready -h postgres >/dev/null 2>&1; do sleep 1; done
    # слот мог остаться с прошлой неудачной попытки — повторный -C падает на
    # существующем слоте. Сносим только НЕАКТИВНЫЙ: активный значит по нему
    # уже кто-то стримит, и падение -C ниже будет честной ошибкой
    PGPASSWORD=postgres psql -h postgres -U postgres -d postgres -Atc \
        "SELECT pg_drop_replication_slot(slot_name) FROM pg_replication_slots WHERE slot_name = 'replica_slot' AND NOT active"
    pg_basebackup -d "host=postgres user=replicator application_name=replica1" \
        -D "$PGDATA" -R -X stream -C -S replica_slot --checkpoint=fast
    touch "$MARKER"
fi
# каталог тома в образе создан с правами 1777, postgres требует 0700
chmod 700 "$PGDATA"
# конфиг — ТОТ ЖЕ файл, что у primary (volumes в compose), вместе с pg_hba:
# роли симметричны, дрейф настроек между нодами исключён по построению; раньше
# флаги -c дублировали conf и уже разъехались (реплика жила без log_lock_waits/
# log_temp_files/log_autovacuum). Роль решает standby.signal (пишется
# pg_basebackup -R). pg_cron на standby пассивен (джобы в recovery не
# выполняются), но preload нужен: после promote регламентные сбросы оживут сами
exec postgres -c config_file=/etc/postgresql/postgresql.conf
