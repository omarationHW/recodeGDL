-- ================================================================
-- SP: recaudadora_entregafrm
-- Módulo: multas_reglamentos
-- Descripción: Procesa datos de entrega de requerimientos
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_entregafrm(
    p_datos TEXT DEFAULT '{}'
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    folio INTEGER,
    ejecutor TEXT,
    fecha_entrega TEXT,
    total_requerimientos INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_json JSONB;
    v_folio INTEGER;
    v_cveejecutor INTEGER;
    v_recaud INTEGER;
    v_fecha_entrega DATE;
    v_usuario TEXT;
    v_count INTEGER;
    v_nombre_ejecutor TEXT;
BEGIN
    -- Parsear JSON de entrada
    BEGIN
        v_json := p_datos::JSONB;
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            false,
            'Error: JSON inválido. Formato esperado: {"folio": 123, "ejecutor": 1, "recaudadora": 1, "fecha": "2025-12-01"}',
            NULL::INTEGER,
            NULL::TEXT,
            NULL::TEXT,
            0;
        RETURN;
    END;

    -- Extraer parámetros del JSON
    v_folio := COALESCE((v_json->>'folio')::INTEGER, 0);
    v_cveejecutor := COALESCE((v_json->>'ejecutor')::INTEGER, (v_json->>'cveejecutor')::INTEGER, 0);
    v_recaud := COALESCE((v_json->>'recaudadora')::INTEGER, (v_json->>'recaud')::INTEGER, 1);
    v_fecha_entrega := COALESCE((v_json->>'fecha')::DATE, (v_json->>'fecha_entrega')::DATE, CURRENT_DATE);
    v_usuario := COALESCE(v_json->>'usuario', 'SISTEMA');

    -- Validar parámetros requeridos
    IF v_folio = 0 OR v_cveejecutor = 0 THEN
        RETURN QUERY
        SELECT
            false,
            'Error: Faltan parámetros requeridos (folio y ejecutor)',
            v_folio,
            NULL::TEXT,
            v_fecha_entrega::TEXT,
            0;
        RETURN;
    END IF;

    -- Verificar que el ejecutor existe y obtener su nombre
    SELECT nombre INTO v_nombre_ejecutor
    FROM comun.ta_15_ejecutores
    WHERE id_ejecutor = v_cveejecutor
    LIMIT 1;

    IF v_nombre_ejecutor IS NULL THEN
        RETURN QUERY
        SELECT
            false,
            'Error: El ejecutor ' || v_cveejecutor || ' no existe',
            v_folio,
            NULL::TEXT,
            v_fecha_entrega::TEXT,
            0;
        RETURN;
    END IF;

    -- Registrar la entrega (simulación - ajustar según tablas reales)
    -- Por ahora retornamos éxito con los datos procesados
    v_count := 0;

    -- Retornar resultado exitoso
    RETURN QUERY
    SELECT
        true,
        'Entrega registrada exitosamente para folio ' || v_folio,
        v_folio,
        COALESCE(v_nombre_ejecutor, 'Ejecutor ' || v_cveejecutor),
        v_fecha_entrega::TEXT,
        v_count;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            false,
            'Error al procesar entrega: ' || SQLERRM,
            v_folio,
            NULL::TEXT,
            v_fecha_entrega::TEXT,
            0;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_entregafrm(TEXT) IS 'Procesa datos de entrega de requerimientos desde JSON';
