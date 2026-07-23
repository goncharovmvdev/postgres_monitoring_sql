-- оценка распухания btree индексов
WITH index_base AS (
    SELECT
        ci.relname AS idxname,
        ci.reltuples,
        ci.relpages,
        i.indrelid AS tbloid,
        i.indexrelid AS idxoid,
        i.indnatts,
        COALESCE(SUBSTRING(ARRAY_TO_STRING(ci.reloptions, ' ') FROM 'fillfactor=([0-9]+)')::SMALLINT, 90) AS fillfactor,
        STRING_TO_ARRAY(i.indkey::TEXT, ' ')::INT[] AS indkey
    FROM pg_index i
    JOIN pg_class ci ON ci.oid = i.indexrelid
    WHERE ci.relam = (SELECT oid FROM pg_am WHERE amname = 'btree')
      AND ci.relpages > 0
      AND ci.reltuples >= 0
),
index_attrs AS (
    SELECT
        b.*,
        pos.attpos
    FROM index_base b
    CROSS JOIN LATERAL GENERATE_SERIES(1, b.indnatts) AS pos(attpos)
),
index_cols AS (
    SELECT
        ct.relnamespace,
        ct.relname AS tblname,
        ia.idxname,
        ia.reltuples,
        ia.relpages,
        ia.idxoid,
        ia.fillfactor,
        COALESCE(a1.attname, a2.attname) AS attname,
        COALESCE(a1.atttypid, a2.atttypid) AS atttypid,
        CASE WHEN a1.attnum IS NULL THEN ia.idxname ELSE ct.relname END AS attrelname
    FROM index_attrs ia
    JOIN pg_class ct ON ct.oid = ia.tbloid
    LEFT JOIN pg_attribute a1
        ON ia.indkey[ia.attpos] <> 0
       AND a1.attrelid = ia.tbloid
       AND a1.attnum = ia.indkey[ia.attpos]
    LEFT JOIN pg_attribute a2
        ON ia.indkey[ia.attpos] = 0
       AND a2.attrelid = ia.idxoid
       AND a2.attnum = ia.attpos
),
index_stats AS (
    SELECT
        n.nspname,
        ic.tblname,
        ic.idxname,
        ic.reltuples,
        ic.relpages,
        ic.fillfactor,
        current_setting('block_size')::NUMERIC AS bs,
        8 AS maxalign,
        24 AS pagehdr,
        16 AS pageopqdata,
        CASE
            WHEN MAX(COALESCE(s.null_frac, 0)) = 0 THEN 8
            ELSE 8 + (32 + 8 - 1) / 8
        END AS index_tuple_hdr_bm,
        SUM((1 - COALESCE(s.null_frac, 0)) * COALESCE(s.avg_width, 1024)) AS nulldatawidth,
        MAX(CASE WHEN ic.atttypid = 'pg_catalog.name'::REGTYPE THEN 1 ELSE 0 END) > 0 AS is_na
    FROM index_cols ic
    JOIN pg_namespace n ON n.oid = ic.relnamespace
    JOIN pg_stats s
        ON s.schemaname = n.nspname
       AND s.tablename = ic.attrelname
       AND s.attname = ic.attname
       AND NOT s.inherited
    WHERE n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
    GROUP BY n.nspname, ic.tblname, ic.idxname, ic.reltuples, ic.relpages, ic.fillfactor
),
index_width AS (
    SELECT
        nspname,
        tblname,
        idxname,
        reltuples,
        relpages,
        fillfactor,
        bs,
        pagehdr,
        pageopqdata,
        is_na,
        (
            index_tuple_hdr_bm + maxalign
            - CASE WHEN index_tuple_hdr_bm % maxalign = 0 THEN maxalign ELSE index_tuple_hdr_bm % maxalign END
            + nulldatawidth + maxalign
            - CASE
                WHEN nulldatawidth = 0 THEN 0
                WHEN nulldatawidth::INTEGER % maxalign = 0 THEN maxalign
                ELSE nulldatawidth::INTEGER % maxalign
              END
        )::NUMERIC AS nulldatahdrwidth
    FROM index_stats
),
index_expected AS (
    SELECT
        nspname,
        tblname,
        idxname,
        relpages,
        fillfactor,
        bs,
        is_na,
        COALESCE(
            1 + CEIL(
                reltuples::NUMERIC / NULLIF(
                    FLOOR((bs - pageopqdata - pagehdr) * fillfactor / (100 * (4 + nulldatahdrwidth))),
                    0
                )
            ),
            0
        ) AS est_pages_ff
    FROM index_width
)
SELECT
    nspname AS schemaname,
    tblname AS tablename,
    idxname AS indexname,
    relpages AS actual_pages,
    est_pages_ff::BIGINT AS expected_pages,
    ROUND(relpages / NULLIF(est_pages_ff, 0), 2) AS bloat_ratio,
    ROUND(100.0 * GREATEST(relpages - est_pages_ff, 0) / NULLIF(relpages, 0), 2) AS wasted_pct,
    pg_size_pretty((bs * relpages)::BIGINT) AS index_size,
    pg_size_pretty((bs * GREATEST(relpages - est_pages_ff, 0))::BIGINT) AS wasted_size,
    fillfactor,
    is_na AS stats_na
FROM index_expected
ORDER BY bs * GREATEST(relpages - est_pages_ff, 0) DESC
LIMIT 50;
