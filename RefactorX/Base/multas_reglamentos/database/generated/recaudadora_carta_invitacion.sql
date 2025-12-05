-- ================================================================
-- SP: recaudadora_carta_invitacion
-- Módulo: multas_reglamentos
-- Descripción: Genera/consulta cartas de invitación predial por cuenta y ejercicio
-- Tablas: cartainvpredial, controladora
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS public.recaudadora_carta_invitacion(VARCHAR, INTEGER);
DROP FUNCTION IF EXISTS comun.recaudadora_carta_invitacion(VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION public.recaudadora_carta_invitacion(
    p_clave_cuenta VARCHAR,
    p_ejercicio INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR,
    foliocarta INTEGER,
    cvecuenta INTEGER,
    cvecatnva VARCHAR,
    nombre VARCHAR,
    calle VARCHAR,
    exterior VARCHAR,
    colonia VARCHAR,
    total NUMERIC,
    impuesto NUMERIC,
    recargos NUMERIC,
    axoini INTEGER,
    axofin INTEGER,
    fecemi DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cvecuenta INTEGER;
    v_count INTEGER;
BEGIN
    -- Validar parámetros
    IF p_clave_cuenta IS NULL OR TRIM(p_clave_cuenta) = '' THEN
        RETURN QUERY
        SELECT
            FALSE,
            'Debe proporcionar una clave de cuenta'::VARCHAR,
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::DATE;
        RETURN;
    END IF;

    -- Convertir clave cuenta a entero
    BEGIN
        v_cvecuenta := p_clave_cuenta::INTEGER;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY
            SELECT
                FALSE,
                'La clave de cuenta debe ser un número válido'::VARCHAR,
                NULL::INTEGER,
                NULL::INTEGER,
                NULL::VARCHAR,
                NULL::VARCHAR,
                NULL::VARCHAR,
                NULL::VARCHAR,
                NULL::VARCHAR,
                NULL::NUMERIC,
                NULL::NUMERIC,
                NULL::NUMERIC,
                NULL::INTEGER,
                NULL::INTEGER,
                NULL::DATE;
            RETURN;
    END;

    -- Verificar si existe la cuenta
    SELECT COUNT(*) INTO v_count
    FROM catastro_gdl.controladora ctrl
    WHERE ctrl.cvecuenta = v_cvecuenta;

    IF v_count = 0 THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('No se encontró la cuenta: ' || p_clave_cuenta)::VARCHAR,
            NULL::INTEGER,
            v_cvecuenta,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::DATE;
        RETURN;
    END IF;

    -- Buscar cartas de invitación para esta cuenta y ejercicio
    RETURN QUERY
    SELECT
        TRUE,
        'Cartas de invitación encontradas'::VARCHAR,
        c.foliocarta,
        c.cvecuenta,
        c.cvecatnva::VARCHAR,
        c.nombre::VARCHAR,
        c.calle::VARCHAR,
        c.exterior::VARCHAR,
        c.colonia::VARCHAR,
        c.total,
        c.impuesto,
        c.recargos,
        c.axoini,
        c.axofin,
        c.fecemi
    FROM catastro_gdl.cartainvpredial c
    WHERE c.cvecuenta = v_cvecuenta
      AND (c.axocarta = p_ejercicio OR p_ejercicio IS NULL OR p_ejercicio = 0)
      AND c.vigencia = 'V'
    ORDER BY c.fecemi DESC, c.foliocarta DESC
    LIMIT 10;

    -- Si no se encontraron cartas, devolver información básica de la cuenta
    GET DIAGNOSTICS v_count = ROW_COUNT;

    IF v_count = 0 THEN
        RETURN QUERY
        SELECT
            TRUE,
            'No hay cartas de invitación registradas para esta cuenta. Información básica de la cuenta:'::VARCHAR,
            NULL::INTEGER,
            ctrl.cvecuenta,
            ctrl.cvecatnva::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            ctrl.saldo,
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::DATE
        FROM catastro_gdl.controladora ctrl
        WHERE ctrl.cvecuenta = v_cvecuenta
        LIMIT 1;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE,
            ('Error al consultar cartas: ' || SQLERRM)::VARCHAR,
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::DATE;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_carta_invitacion(VARCHAR, INTEGER)
IS 'Consulta cartas de invitación predial por cuenta y ejercicio. Si no hay cartas, devuelve información básica de la cuenta.';
