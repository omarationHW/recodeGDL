-- ================================================================
-- SP: recaudadora_conscentrosfrm
-- Módulo: multas_reglamentos
-- Descripción: Consulta catálogo de centros de recaudación
-- Tablas: ta_12_centrosrecaud
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS public.recaudadora_conscentrosfrm(VARCHAR);
DROP FUNCTION IF EXISTS comun.recaudadora_conscentrosfrm(VARCHAR);

CREATE OR REPLACE FUNCTION public.recaudadora_conscentrosfrm(
    p_query VARCHAR
)
RETURNS TABLE(
    id_centro INTEGER,
    id_recaudora INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    domicilio2 VARCHAR,
    horario VARCHAR,
    telefonos VARCHAR,
    cvecatastral VARCHAR,
    cajas SMALLINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_query_pattern VARCHAR;
BEGIN
    -- Preparar patrón de búsqueda
    v_query_pattern := '%' || COALESCE(p_query, '') || '%';

    -- Retornar centros de recaudación filtrados
    RETURN QUERY
    SELECT
        c.id_centro,
        c.id_recaudora,
        c.nombre::VARCHAR,
        c.domicilio::VARCHAR,
        c.domicilio2::VARCHAR,
        c.horario::VARCHAR,
        c.telefonos::VARCHAR,
        c.cvecatastral::VARCHAR,
        c.cajas
    FROM comun.ta_12_centrosrecaud c
    WHERE (
        p_query IS NULL OR p_query = '' OR
        c.nombre::TEXT ILIKE v_query_pattern OR
        c.domicilio::TEXT ILIKE v_query_pattern OR
        c.id_centro::TEXT ILIKE v_query_pattern OR
        c.telefonos::TEXT ILIKE v_query_pattern
    )
    ORDER BY c.id_centro ASC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en recaudadora_conscentrosfrm: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_conscentrosfrm(VARCHAR)
IS 'Consulta catálogo de centros de recaudación. Permite búsqueda por nombre, domicilio, id_centro o teléfonos.';
