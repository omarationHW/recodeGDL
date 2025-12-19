-- =====================================================
-- Stored Procedure: recaudadora_rep_oper
-- Base de Datos: multas_reglamentos
-- Esquema: publico
-- Descripción: Genera reporte de operaciones por dependencia
--              en un rango de fechas
-- =====================================================

-- Eliminar función si existe
DROP FUNCTION IF EXISTS publico.recaudadora_rep_oper(DATE, DATE);

-- Crear función
CREATE OR REPLACE FUNCTION publico.recaudadora_rep_oper(
    p_desde DATE,
    p_hasta DATE
)
RETURNS TABLE (
    dependencia INTEGER,
    nombre_dependencia VARCHAR,
    total_operaciones BIGINT,
    multas_emitidas BIGINT,
    multas_canceladas BIGINT,
    multas_pendientes BIGINT,
    total_multas NUMERIC,
    total_gastos NUMERIC,
    total_general NUMERIC,
    promedio_operacion NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar que las fechas sean proporcionadas
    IF p_desde IS NULL OR p_hasta IS NULL THEN
        RAISE EXCEPTION 'Debe proporcionar ambas fechas (desde y hasta)';
    END IF;

    -- Validar que la fecha desde no sea mayor que la fecha hasta
    IF p_desde > p_hasta THEN
        RAISE EXCEPTION 'La fecha desde no puede ser mayor que la fecha hasta';
    END IF;

    -- Retornar reporte de operaciones por dependencia
    RETURN QUERY
    SELECT
        h.id_dependencia::INTEGER as dependencia,
        CASE h.id_dependencia
            WHEN 1 THEN 'Dependencia 1 - Predial'
            WHEN 3 THEN 'Dependencia 3 - Tránsito'
            WHEN 5 THEN 'Dependencia 5 - Obras'
            WHEN 7 THEN 'Dependencia 7 - Reglamentos'
            WHEN 12 THEN 'Dependencia 12 - Licencias'
            WHEN 35 THEN 'Dependencia 35 - Vía Pública'
            ELSE 'Dependencia ' || h.id_dependencia::VARCHAR
        END::VARCHAR as nombre_dependencia,
        COUNT(*)::BIGINT as total_operaciones,
        COUNT(CASE WHEN h.fecha_cancelacion IS NULL THEN 1 END)::BIGINT as multas_emitidas,
        COUNT(CASE WHEN h.fecha_cancelacion IS NOT NULL THEN 1 END)::BIGINT as multas_canceladas,
        COUNT(CASE WHEN h.fecha_cancelacion IS NULL AND h.cvepago IS NULL THEN 1 END)::BIGINT as multas_pendientes,
        COALESCE(SUM(h.multa), 0)::NUMERIC as total_multas,
        COALESCE(SUM(h.gastos), 0)::NUMERIC as total_gastos,
        COALESCE(SUM(h.total), 0)::NUMERIC as total_general,
        CASE
            WHEN COUNT(*) > 0 THEN COALESCE(SUM(h.total), 0) / COUNT(*)
            ELSE 0
        END::NUMERIC as promedio_operacion
    FROM public.h_multasnvo h
    WHERE h.fecha_acta BETWEEN p_desde AND p_hasta
    AND h.id_dependencia IS NOT NULL
    GROUP BY h.id_dependencia
    ORDER BY total_general DESC;

    RETURN;
END;
$$;

-- Comentario de la función
COMMENT ON FUNCTION publico.recaudadora_rep_oper(DATE, DATE) IS
'Genera reporte de operaciones por dependencia en un rango de fechas.
Muestra estadísticas de multas emitidas, canceladas y pendientes.
Parámetros:
  - p_desde: Fecha inicial del rango (formato DATE)
  - p_hasta: Fecha final del rango (formato DATE)
Retorna:
  - dependencia: ID de la dependencia
  - nombre_dependencia: Nombre descriptivo
  - total_operaciones: Total de operaciones en el periodo
  - multas_emitidas: Multas emitidas (no canceladas)
  - multas_canceladas: Multas canceladas
  - multas_pendientes: Multas pendientes de pago
  - total_multas: Suma de montos de multas
  - total_gastos: Suma de gastos de ejecución
  - total_general: Suma total (multas + gastos)
  - promedio_operacion: Promedio por operación';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION publico.recaudadora_rep_oper(DATE, DATE) TO refact;
GRANT EXECUTE ON FUNCTION publico.recaudadora_rep_oper(DATE, DATE) TO PUBLIC;
