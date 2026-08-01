-- роль для стриминга физической репликации;
-- доступ на репликацию разрешён в статичном postgres/pg_hba.conf (см. compose)
CREATE ROLE replicator LOGIN REPLICATION;
