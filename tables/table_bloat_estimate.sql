-- оценка распухания таблиц
WITH constants AS (
    SELECT
        current_setting('block_size')::NUMERIC AS bs,
        23 AS hdr,
        8 AS ma
),
column_stats AS (
    SELECT
        s.schemaname,
        s.tablename,
        c.bs,
        c.hdr,
        c.ma,
        SUM((1 - s.null_frac) * s.avg_width) AS datawidth,
        MAX(s.null_frac) AS maxfracsum,
        c.hdr + 1 + (
            SELECT COUNT(*)
            FROM pg_stats s2
            WHERE s2.schemaname = s.schemaname
              AND s2.tablename = s.tablename
              AND s2.null_frac <> 0
        ) / 8 AS nullhdr
    FROM pg_stats s
    CROSS JOIN constants c
    WHERE s.schemaname NOT IN ('pg_catalog', 'information_schema')
    GROUP BY s.schemaname, s.tablename, c.bs, c.hdr, c.ma
),
row_width AS (
    SELECT
        schemaname,
        tablename,
        bs,
        ma,
        (datawidth + (hdr + ma - CASE WHEN hdr % ma = 0 THEN ma ELSE hdr % ma END))::NUMERIC AS datahdr,
        maxfracsum * (nullhdr + ma - CASE WHEN nullhdr % ma = 0 THEN ma ELSE nullhdr % ma END) AS nullhdr2
    FROM column_stats
),
expected AS (
    SELECT
        rw.schemaname,
        rw.tablename,
        rw.bs,
        cc.reltuples,
        cc.relpages,
        CEIL(
            cc.reltuples * (
                rw.datahdr + rw.ma
                - CASE WHEN rw.datahdr % rw.ma = 0 THEN rw.ma ELSE rw.datahdr % rw.ma END
                + rw.nullhdr2 + 4
            ) / (rw.bs - 20)
        ) AS expected_pages
    FROM row_width rw
    JOIN pg_namespace nn ON nn.nspname = rw.schemaname
    JOIN pg_class cc ON cc.relname = rw.tablename
                    AND cc.relnamespace = nn.oid
    WHERE cc.relkind = 'r'
      AND cc.relpages > 0
)
SELECT
    schemaname,
    tablename,
    reltuples::BIGINT AS est_rows,
    relpages AS actual_pages,
    expected_pages::BIGINT AS expected_pages,
    ROUND(relpages / NULLIF(expected_pages, 0), 2) AS bloat_ratio,
    ROUND(100.0 * GREATEST(relpages - expected_pages, 0) / NULLIF(relpages, 0), 2) AS wasted_pct,
    pg_size_pretty((bs * relpages)::BIGINT) AS table_size,
    pg_size_pretty((bs * GREATEST(relpages - expected_pages, 0))::BIGINT) AS wasted_size
FROM expected
ORDER BY bs * GREATEST(relpages - expected_pages, 0) DESC
LIMIT 50;
