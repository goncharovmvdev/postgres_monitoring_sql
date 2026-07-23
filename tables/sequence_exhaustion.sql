-- Процент исчерпания sequence
WITH seq AS (
    SELECT
        schemaname,
        sequencename,
        data_type,
        last_value,
        min_value,
        max_value,
        increment_by,
        cycle,
        CASE
            WHEN last_value IS NULL THEN 0
            WHEN increment_by > 0 THEN
                ROUND(
                    100.0 * (last_value::numeric - min_value)
                    / NULLIF(max_value::numeric - min_value, 0),
                    2
                )
            ELSE
                ROUND(
                    100.0 * (max_value::numeric - last_value)
                    / NULLIF(max_value::numeric - min_value, 0),
                    2
                )
        END AS exhaustion_pct
    FROM pg_sequences
)
SELECT
    schemaname,
    sequencename,
    data_type,
    last_value,
    max_value,
    increment_by,
    cycle,
    exhaustion_pct
FROM seq
ORDER BY exhaustion_pct DESC NULLS LAST,
         schemaname,
         sequencename
LIMIT 100;
