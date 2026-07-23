-- записи и fsync напрямую из backend'ов (PG<=16; на PG17+ столбцы удалены — смотрите fsyncs в pg_stat_io)
-- buffers_backend_fsync > 0 = очередь fsync переполнена, критический сигнал нехватки shared_buffers/IO
SELECT
    buffers_backend,
    pg_size_pretty(
        buffers_backend * current_setting('block_size')::BIGINT
    ) AS backend_written,
    buffers_backend_fsync,
    stats_reset
FROM pg_stat_bgwriter;
