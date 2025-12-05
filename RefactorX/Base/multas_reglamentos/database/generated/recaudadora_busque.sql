-- ================================================================
-- SP: recaudadora_busque
-- Módulo: multas_reglamentos
-- Descripción: Búsqueda general en el padrón predial
-- Tablas: controladora
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS public.recaudadora_busque(VARCHAR);
DROP FUNCTION IF EXISTS comun.recaudadora_busque(VARCHAR);

CREATE OR REPLACE FUNCTION public.recaudadora_busque(
    p_query VARCHAR
)
RETURNS TABLE(
    cvecuenta INTEGER,
    cuenta INTEGER,
    cvecatnva CHARACTER(11),
    saldo NUMERIC(16),
    axoadeudo INTEGER,
    vigente CHARACTER(1),
    exenta CHARACTER(1),
    descuento INTEGER,
    urbrus CHARACTER(1),
    recaud SMALLINT,
    bloqmov CHARACTER(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Búsqueda general por cuenta o cvecuenta
    RETURN QUERY
    SELECT
        c.cvecuenta,
        c.cuenta,
        c.cvecatnva,
        c.saldo,
        c.axoadeudo,
        c.vigente,
        c.exenta,
        c.descuento,
        c.urbrus,
        c.recaud,
        c.bloqmov
    FROM catastro_gdl.controladora c
    WHERE
        c.cuenta::TEXT ILIKE '%' || p_query || '%'
        OR c.cvecuenta::TEXT ILIKE '%' || p_query || '%'
        OR c.cvecatnva::TEXT ILIKE '%' || p_query || '%'
    ORDER BY c.cvecuenta DESC
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en búsqueda: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_busque(VARCHAR)
IS 'Búsqueda general en el padrón predial por cuenta, cvecuenta o clave catastral';
