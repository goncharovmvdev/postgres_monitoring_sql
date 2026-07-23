-- fsync по типам процессов через pg_stat_io (PG16+; на PG17+ замена buffers_backend_fsync)
-- fsyncs у backend_type = 'client backend' = очередь fsync переполнена, критический сигнал нехватки shared_buffers/IO
-- fsync_time заполняется только при track_io_timing = on
SELECT
    backend_type,
    object,
    context,
    fsyncs,
    fsync_time,
    stats_reset
FROM pg_stat_io
WHERE fsyncs > 0
ORDER BY fsyncs DESC;
