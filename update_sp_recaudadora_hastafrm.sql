-- =====================================================
-- Stored Procedure: recaudadora_hastafrm (ACTUALIZADO)
-- Descripción: Retorna registros de ctrl_reqpredial en el rango de fechas
-- Parámetros:
--   - p_fecha_desde: Fecha inicial del rango
--   - p_fecha_hasta: Fecha final del rango
-- Retorna: Lista de registros con información de requerimientos
-- =====================================================

CREATE OR REPLACE FUNCTION publico.recaudadora_hastafrm(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
)
RETURNS TABLE(
    status VARCHAR,
    mensaje VARCHAR,
    fecha_emision DATE,
    criterio SMALLINT,
    recaud SMALLINT,
    urbrus CHARACTER(1),
    cuenta_inicio INTEGER,
    cuenta_final INTEGER,
    zona SMALLINT,
    subzona SMALLINT,
    monto_min NUMERIC,
    monto_max NUMERIC,
    total_registros INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_registros INTEGER := 0;
    v_fecha_actual DATE := CURRENT_DATE;
BEGIN
    -- Validación 1: Verificar que las fechas no sean nulas
    IF p_fecha_desde IS NULL THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'La fecha inicial es obligatoria'::VARCHAR,
            NULL::DATE,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::CHARACTER(1),
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::NUMERIC,
            NULL::NUMERIC,
            0::INTEGER;
        RETURN;
    END IF;

    IF p_fecha_hasta IS NULL THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'La fecha final es obligatoria'::VARCHAR,
            NULL::DATE,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::CHARACTER(1),
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::NUMERIC,
            NULL::NUMERIC,
            0::INTEGER;
        RETURN;
    END IF;

    -- Validación 2: Verificar que la fecha desde no sea mayor que la fecha hasta
    IF p_fecha_desde > p_fecha_hasta THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'La fecha inicial no puede ser mayor que la fecha final'::VARCHAR,
            NULL::DATE,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::CHARACTER(1),
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::NUMERIC,
            NULL::NUMERIC,
            0::INTEGER;
        RETURN;
    END IF;

    -- Validación 3: Verificar que las fechas no sean futuras
    IF p_fecha_desde > v_fecha_actual THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'La fecha inicial no puede ser mayor a la fecha actual'::VARCHAR,
            NULL::DATE,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::CHARACTER(1),
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::NUMERIC,
            NULL::NUMERIC,
            0::INTEGER;
        RETURN;
    END IF;

    IF p_fecha_hasta > v_fecha_actual THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'La fecha final no puede ser mayor a la fecha actual'::VARCHAR,
            NULL::DATE,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::CHARACTER(1),
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::NUMERIC,
            NULL::NUMERIC,
            0::INTEGER;
        RETURN;
    END IF;

    -- Validación 4: Verificar que el rango no sea mayor a 1 año
    IF (p_fecha_hasta - p_fecha_desde) > 365 THEN
        RETURN QUERY
        SELECT
            'error'::VARCHAR,
            'El rango de fechas no puede ser mayor a 1 año'::VARCHAR,
            NULL::DATE,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::CHARACTER(1),
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::SMALLINT,
            NULL::SMALLINT,
            NULL::NUMERIC,
            NULL::NUMERIC,
            0::INTEGER;
        RETURN;
    END IF;

    -- Contar registros
    SELECT COUNT(*)::INTEGER INTO v_total_registros
    FROM public.ctrl_reqpredial cr
    WHERE cr.fecha_emision BETWEEN p_fecha_desde AND p_fecha_hasta;

    -- Retornar registros encontrados
    RETURN QUERY
    SELECT
        'success'::VARCHAR AS status,
        ('Se encontraron ' || v_total_registros::VARCHAR || ' registros')::VARCHAR AS mensaje,
        r.fecha_emision,
        r.criterio,
        r.recaud,
        r.urbrus,
        r.cuenta_inicio,
        r.cuenta_final,
        r.zona,
        r.subzona,
        r.monto_min,
        r.monto_max,
        v_total_registros
    FROM public.ctrl_reqpredial r
    WHERE r.fecha_emision BETWEEN p_fecha_desde AND p_fecha_hasta
    ORDER BY r.fecha_emision DESC, r.cuenta_inicio
    LIMIT 1000; -- Límite de seguridad para evitar consultas muy grandes

END;
$$;

-- Comentarios sobre el procedimiento
COMMENT ON FUNCTION publico.recaudadora_hastafrm(DATE, DATE) IS
'Retorna registros de ctrl_reqpredial en el rango de fechas especificado.
Incluye validaciones de fechas y limita los resultados a 1000 registros.';
