-- ================================================================
-- SP: recaudadora_extractos_rpt
-- Módulo: multas_reglamentos
-- Descripción: Genera extracto de cuenta
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_extractos_rpt(
    p_clave_cuenta VARCHAR DEFAULT ''
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    cuenta TEXT,
    clave_catastral TEXT,
    total_adeudo NUMERIC,
    fecha_extracto TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cuenta INTEGER;
    v_clave_catastral TEXT;
    v_total NUMERIC;
BEGIN
    -- Validar que se proporcione una cuenta
    IF p_clave_cuenta IS NULL OR p_clave_cuenta = '' THEN
        RETURN QUERY
        SELECT
            false,
            'Error: Debe proporcionar una cuenta para generar el extracto',
            NULL::TEXT,
            NULL::TEXT,
            0::NUMERIC,
            CURRENT_DATE::TEXT;
        RETURN;
    END IF;

    -- Intentar convertir a entero
    BEGIN
        v_cuenta := p_clave_cuenta::INTEGER;
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            false,
            'Error: La cuenta debe ser un número válido',
            p_clave_cuenta::TEXT,
            NULL::TEXT,
            0::NUMERIC,
            CURRENT_DATE::TEXT;
        RETURN;
    END;

    -- Buscar información de la cuenta en catastro_gdl.controladora
    BEGIN
        SELECT
            c.cvecatnva,
            COALESCE(c.saldo, 0)
        INTO
            v_clave_catastral,
            v_total
        FROM catastro_gdl.controladora c
        WHERE c.cuenta = v_cuenta
        LIMIT 1;

        -- Verificar si se encontró la cuenta
        IF v_clave_catastral IS NULL THEN
            RETURN QUERY
            SELECT
                false,
                'No se encontró información para la cuenta ' || p_clave_cuenta,
                p_clave_cuenta::TEXT,
                NULL::TEXT,
                0::NUMERIC,
                CURRENT_DATE::TEXT;
            RETURN;
        END IF;

        -- Retornar el extracto
        RETURN QUERY
        SELECT
            true,
            'Extracto generado exitosamente para la cuenta ' || p_clave_cuenta,
            p_clave_cuenta::TEXT,
            v_clave_catastral::TEXT,
            v_total,
            CURRENT_DATE::TEXT;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            false,
            'Error al consultar la cuenta: ' || SQLERRM,
            p_clave_cuenta::TEXT,
            NULL::TEXT,
            0::NUMERIC,
            CURRENT_DATE::TEXT;
    END;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_extractos_rpt(VARCHAR) IS 'Genera extracto de cuenta desde catastro_gdl.controladora';
