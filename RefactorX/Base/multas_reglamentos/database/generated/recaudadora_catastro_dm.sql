-- ================================================================
-- SP: recaudadora_catastro_dm
-- Módulo: multas_reglamentos
-- Descripción: Consulta catastral con paginación server-side
-- Tablas: controladora
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS public.recaudadora_catastro_dm(VARCHAR, INTEGER, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS comun.recaudadora_catastro_dm(VARCHAR, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.recaudadora_catastro_dm(
    p_query VARCHAR,
    p_year INTEGER,
    p_offset INTEGER,
    p_limit INTEGER
)
RETURNS TABLE(
    clave_cuenta VARCHAR,
    propietario VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    ejercicio INTEGER,
    total_count BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query_pattern VARCHAR;
    v_total_count BIGINT;
BEGIN
    -- Preparar patrón de búsqueda
    v_query_pattern := '%' || COALESCE(p_query, '') || '%';

    -- Asegurar límites razonables
    p_offset := COALESCE(p_offset, 0);
    p_limit := LEAST(COALESCE(p_limit, 10), 100);

    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM catastro_gdl.controladora ctrl
    LEFT JOIN catastro_gdl.cuentapublica cp ON ctrl.cvecuenta = cp.cvecuenta
    WHERE (
        p_query IS NULL OR p_query = '' OR
        ctrl.cuenta::TEXT ILIKE v_query_pattern OR
        ctrl.cvecuenta::TEXT ILIKE v_query_pattern OR
        ctrl.cvecatnva::TEXT ILIKE v_query_pattern OR
        cp.propietario::TEXT ILIKE v_query_pattern
    )
    AND (p_year IS NULL OR p_year = 0 OR cp.pago_axosal = p_year);

    -- Retornar registros paginados
    RETURN QUERY
    SELECT
        ctrl.cvecatnva::VARCHAR AS clave_cuenta,
        COALESCE(cp.propietario, 'Sin nombre')::VARCHAR AS propietario,
        COALESCE(cp.domicilio, 'Sin domicilio')::VARCHAR AS domicilio,
        COALESCE(TRIM(SPLIT_PART(cp.domicilio, ',', -1)), 'Sin colonia')::VARCHAR AS colonia,
        COALESCE(cp.pago_axosal, 0) AS ejercicio,
        v_total_count AS total_count
    FROM catastro_gdl.controladora ctrl
    LEFT JOIN catastro_gdl.cuentapublica cp ON ctrl.cvecuenta = cp.cvecuenta
    WHERE (
        p_query IS NULL OR p_query = '' OR
        ctrl.cuenta::TEXT ILIKE v_query_pattern OR
        ctrl.cvecuenta::TEXT ILIKE v_query_pattern OR
        ctrl.cvecatnva::TEXT ILIKE v_query_pattern OR
        cp.propietario::TEXT ILIKE v_query_pattern
    )
    AND (p_year IS NULL OR p_year = 0 OR cp.pago_axosal = p_year)
    ORDER BY ctrl.cvecuenta DESC
    OFFSET p_offset
    LIMIT p_limit;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en recaudadora_catastro_dm: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_catastro_dm(VARCHAR, INTEGER, INTEGER, INTEGER)
IS 'Consulta catastral con paginación server-side. Filtra por query de búsqueda y año.';
