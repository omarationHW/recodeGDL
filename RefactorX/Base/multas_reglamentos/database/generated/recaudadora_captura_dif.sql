-- ================================================================
-- SP: recaudadora_captura_dif
-- Módulo: multas_reglamentos
-- Descripción: Captura de diferencias prediales desde datos JSON
-- Tablas: predial_diferencias
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS public.recaudadora_captura_dif(TEXT);
DROP FUNCTION IF EXISTS comun.recaudadora_captura_dif(TEXT);

CREATE OR REPLACE FUNCTION public.recaudadora_captura_dif(
    p_datos TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR,
    id_insertado INTEGER,
    axo SMALLINT,
    cvecuenta INTEGER,
    monto NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_json JSONB;
    v_axo SMALLINT;
    v_cvecuenta INTEGER;
    v_monto NUMERIC;
    v_status CHAR(1);
    v_id INTEGER;
BEGIN
    -- Validar que se enviaron datos
    IF p_datos IS NULL OR TRIM(p_datos) = '' THEN
        RETURN QUERY
        SELECT
            FALSE,
            'No se proporcionaron datos'::VARCHAR,
            NULL::INTEGER,
            NULL::SMALLINT,
            NULL::INTEGER,
            NULL::NUMERIC;
        RETURN;
    END IF;

    -- Intentar parsear el JSON
    BEGIN
        v_json := p_datos::JSONB;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY
            SELECT
                FALSE,
                'Formato JSON inválido'::VARCHAR,
                NULL::INTEGER,
                NULL::SMALLINT,
                NULL::INTEGER,
                NULL::NUMERIC;
            RETURN;
    END;

    -- Extraer campos del JSON
    v_axo := (v_json->>'axo')::SMALLINT;
    v_cvecuenta := (v_json->>'cvecuenta')::INTEGER;
    v_monto := (v_json->>'monto')::NUMERIC;
    v_status := COALESCE(v_json->>'status', 'A');

    -- Validar campos requeridos
    IF v_axo IS NULL OR v_cvecuenta IS NULL OR v_monto IS NULL THEN
        RETURN QUERY
        SELECT
            FALSE,
            'Faltan campos requeridos: axo, cvecuenta, monto'::VARCHAR,
            NULL::INTEGER,
            v_axo,
            v_cvecuenta,
            v_monto;
        RETURN;
    END IF;

    -- Insertar el registro
    INSERT INTO catastro_gdl.predial_diferencias (
        axo,
        cvecuenta,
        monto,
        status
    ) VALUES (
        v_axo,
        v_cvecuenta,
        v_monto,
        v_status
    )
    RETURNING id INTO v_id;

    -- Retornar resultado exitoso
    RETURN QUERY
    SELECT
        TRUE,
        'Diferencia capturada exitosamente'::VARCHAR,
        v_id,
        v_axo,
        v_cvecuenta,
        v_monto;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('Error al guardar: ' || SQLERRM)::VARCHAR,
            NULL::INTEGER,
            NULL::SMALLINT,
            NULL::INTEGER,
            NULL::NUMERIC;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_captura_dif(TEXT)
IS 'Captura diferencias prediales desde datos en formato JSON. Campos requeridos: axo, cvecuenta, monto. Campo opcional: status (default: A)';
