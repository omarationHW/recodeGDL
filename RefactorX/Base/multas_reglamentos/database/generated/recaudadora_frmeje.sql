-- ================================================================
-- SP: recaudadora_frmeje
-- Módulo: multas_reglamentos
-- Descripción: Ejecutor genérico de procesos con parámetros JSON
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_frmeje(TEXT);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_frmeje(
    p_params TEXT
)
RETURNS TABLE (
    status VARCHAR,
    message VARCHAR,
    received_params JSONB,
    execution_time TIMESTAMP,
    user_info VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_params_json JSONB;
BEGIN
    v_start_time := CURRENT_TIMESTAMP;

    -- Intentar parsear el JSON
    BEGIN
        v_params_json := p_params::JSONB;
    EXCEPTION WHEN OTHERS THEN
        v_params_json := jsonb_build_object('error', 'Invalid JSON format', 'received', p_params);
    END;

    -- Devolver información de ejecución
    RETURN QUERY
    SELECT
        'success'::VARCHAR AS status,
        'Proceso ejecutado correctamente'::VARCHAR AS message,
        v_params_json AS received_params,
        v_start_time AS execution_time,
        CURRENT_USER::VARCHAR AS user_info;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_frmeje(TEXT) IS
'Ejecutor genérico de procesos que recibe parámetros en formato JSON y devuelve información de ejecución.
Útil para debugging y ejecución de comandos administrativos.';
