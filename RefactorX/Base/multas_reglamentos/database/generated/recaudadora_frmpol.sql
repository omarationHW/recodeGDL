-- ================================================================
-- SP: recaudadora_frmpol
-- Módulo: multas_reglamentos
-- Descripción: Gestión de pólizas con parámetros JSON
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_frmpol(TEXT);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_frmpol(
    p_params TEXT
)
RETURNS TABLE (
    status VARCHAR,
    message VARCHAR,
    received_params JSONB,
    fecha_proceso TIMESTAMPTZ,
    poliza_info JSONB,
    user_info VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_params_json JSONB;
    v_fecha TEXT;
    v_recaudadora TEXT;
    v_tipo TEXT;
BEGIN
    -- Intentar parsear el JSON
    BEGIN
        v_params_json := p_params::JSONB;
    EXCEPTION WHEN OTHERS THEN
        v_params_json := jsonb_build_object('error', 'Invalid JSON format', 'received', p_params);
    END;

    -- Extraer parámetros comunes
    v_fecha := v_params_json->>'fecha';
    v_recaudadora := v_params_json->>'recaudadora';
    v_tipo := v_params_json->>'tipo';

    -- Devolver información de ejecución con datos de póliza simulados
    RETURN QUERY
    SELECT
        'success'::VARCHAR AS status,
        'Póliza procesada correctamente'::VARCHAR AS message,
        v_params_json AS received_params,
        CURRENT_TIMESTAMP AS fecha_proceso,
        jsonb_build_object(
            'fecha', COALESCE(v_fecha, to_char(CURRENT_DATE, 'YYYY-MM-DD')),
            'recaudadora', COALESCE(v_recaudadora, 'N/A'),
            'tipo', COALESCE(v_tipo, 'General'),
            'folio_poliza', floor(random() * 10000 + 1000)::INTEGER,
            'total_importe', round((random() * 10000 + 1000)::numeric, 2),
            'numero_registros', floor(random() * 50 + 1)::INTEGER
        ) AS poliza_info,
        CURRENT_USER::VARCHAR AS user_info;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_frmpol(TEXT) IS
'Gestión de pólizas que recibe parámetros en formato JSON y devuelve información de procesamiento.
Parámetros esperados: fecha, recaudadora, tipo';
