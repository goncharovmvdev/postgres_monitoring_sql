-- SQL-эквивалент `pgbench -i -s 5`: схема и данные создаются декларативно
-- при initdb, а сервису load остаётся только крутить транзакции.
-- Схема живёт в ПРИКЛАДНОЙ базе appdb (init/03_appdb.sql), не в служебной postgres
\c appdb

CREATE TABLE pgbench_branches (
    bid      INT PRIMARY KEY,
    bbalance INT,
    filler   CHAR(88)
);

CREATE TABLE pgbench_tellers (
    tid      INT PRIMARY KEY,
    bid      INT,
    tbalance INT,
    filler   CHAR(84)
);

CREATE TABLE pgbench_accounts (
    aid      INT PRIMARY KEY,
    bid      INT,
    abalance INT,
    filler   CHAR(84)
);

CREATE TABLE pgbench_history (
    tid    INT,
    bid    INT,
    aid    INT,
    delta  INT,
    mtime  TIMESTAMP,
    filler CHAR(22)
);

-- scale = 5: 5 branches, 50 tellers, 500 000 accounts
INSERT INTO pgbench_branches
SELECT g, 0, '' FROM generate_series(1, 5) g;

INSERT INTO pgbench_tellers
SELECT g, (g - 1) / 10 + 1, 0, '' FROM generate_series(1, 50) g;

INSERT INTO pgbench_accounts
SELECT g, (g - 1) / 100000 + 1, 0, '' FROM generate_series(1, 500000) g;

ANALYZE pgbench_branches, pgbench_tellers, pgbench_accounts;
