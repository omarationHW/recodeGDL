-- =====================================================
-- Stored Procedure: recaudadora_hastafrm
-- Descripción: Valida y procesa parámetros de operación por rango de fechas
-- Parámetros:
--   - p_fecha_desde: Fecha inicial del rango
--   - p_fecha_hasta: Fecha final del rango
-- Retorna: Resultado con status, mensaje y registros procesados
-- =====================================================

CREATE OR REPLACE FUNCTION publico.recaudadora_hastafrm(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
)
RETURNS TABLE(
    status VARCHAR,
    mensaje VARCHAR,
    registros_procesados INTEGER,
    fecha_desde DATE,
    fecha_hasta DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_registros_procesados INTEGER := 0;
    v_fecha_actual DATE := CURRENT_DATE;
BEGIN
    -- Validación 1: Verificar que las fechas no sean nulas
    IF p_fecha_desde IS NULL THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'La fecha inicial es obligatoria'::VARCHAR,
            0::INTEGER,
            NULL::DATE,
            NULL::DATE;
        RETURN;
    END IF;

    IF p_fecha_hasta IS NULL THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'La fecha final es obligatoria'::VARCHAR,
            0::INTEGER,
            p_fecha_desde,
            NULL::DATE;
        RETURN;
    END IF;

    -- Validación 2: Verificar que la fecha desde no sea mayor que la fecha hasta
    IF p_fecha_desde > p_fecha_hasta THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'La fecha inicial no puede ser mayor que la fecha final'::VARCHAR,
            0::INTEGER,
            p_fecha_desde,
            p_fecha_hasta;
        RETURN;
    END IF;

    -- Validación 3: Verificar que las fechas no sean futuras
    IF p_fecha_desde > v_fecha_actual THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'La fecha inicial no puede ser mayor a la fecha actual'::VARCHAR,
            0::INTEGER,
            p_fecha_desde,
            p_fecha_hasta;
        RETURN;
    END IF;

    IF p_fecha_hasta > v_fecha_actual THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'La fecha final no puede ser mayor a la fecha actual'::VARCHAR,
            0::INTEGER,
            p_fecha_desde,
            p_fecha_hasta;
        RETURN;
    END IF;

    -- Validación 4: Verificar que el rango no sea mayor a 1 año
    IF (p_fecha_hasta - p_fecha_desde) > 365 THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'El rango de fechas no puede ser mayor a 1 año'::VARCHAR,
            0::INTEGER,
            p_fecha_desde,
            p_fecha_hasta;
        RETURN;
    END IF;

    -- Si todas las validaciones pasaron, contar registros en ctrl_reqpredial dentro del rango
    -- (usando ctrl_reqpredial como tabla de ejemplo para demostrar funcionalidad)
    SELECT COUNT(*)::INTEGER INTO v_registros_procesados
    FROM public.ctrl_reqpredial
    WHERE fecha_emision BETWEEN p_fecha_desde AND p_fecha_hasta;

    -- Retornar resultado exitoso
    RETURN QUERY
    SELECT
        'success'::VARCHAR,
        'Validación de fechas completada exitosamente'::VARCHAR,
        v_registros_procesados,
        p_fecha_desde,
        p_fecha_hasta;

END;
$$;

-- Comentarios sobre el procedimiento
COMMENT ON FUNCTION publico.recaudadora_hastafrm(DATE, DATE) IS
'Valida y procesa parámetros de operación por rango de fechas.
Verifica que las fechas sean válidas, no futuras, y que el rango no exceda 1 año.
Retorna el número de registros de ctrl_reqpredial dentro del rango de fechas.';
