-- синхронная репликация: commit будет ждать подтверждения от replica1
-- ВАЖНО: если реплика умерла — запись на primary встанет (осознанная цена sync)
-- Настройка через ALTER SYSTEM (postgresql.auto.conf), а не флагом в compose:
-- флаг наследуется временным сервером init-фазы docker-entrypoint, и тот
-- намертво зависает на CREATE DATABASE в ожидании несуществующей реплики.
-- ALTER SYSTEM применится только к финальному серверу.
ALTER SYSTEM SET synchronous_standby_names = 'replica1';
