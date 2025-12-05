-- ================================================================
-- SP: recaudadora_consdesc
-- Módulo: multas_reglamentos
-- Descripción: Consulta descuentos prediales por cuenta
-- Tablas: descpred, c_descpred
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS public.recaudadora_consdesc(VARCHAR);
DROP FUNCTION IF EXISTS comun.recaudadora_consdesc(VARCHAR);

CREATE OR REPLACE FUNCTION public.recaudadora_consdesc(
    p_clave_cuenta VARCHAR
)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvedescuento SMALLINT,
    descripcion VARCHAR,
    bimini SMALLINT,
    bimfin SMALLINT,
    porcentaje NUMERIC,
    fecalta DATE,
    status CHAR,
    foliodesc INTEGER,
    propietario VARCHAR,
    observaciones VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    -- Convertir clave cuenta a entero
    v_cvecuenta := p_clave_cuenta::INTEGER;

    -- Consultar descuentos de la cuenta
    RETURN QUERY
    SELECT
        d.cvecuenta,
        d.cvedescuento,
        COALESCE(c.descripcion, 'Sin descripción')::VARCHAR,
        d.bimini,
        d.bimfin,
        COALESCE(c.porcentaje, 0)::NUMERIC,
        d.fecalta,
        COALESCE(d.status, ' ')::CHAR,
        d.foliodesc,
        COALESCE(d.propie, '')::VARCHAR,
        COALESCE(d.observaciones, '')::VARCHAR
    FROM catastro_gdl.descpred d
    LEFT JOIN catastro_gdl.c_descpred c ON d.cvedescuento = c.cvedescuento
    WHERE d.cvecuenta = v_cvecuenta
    ORDER BY d.fecalta DESC NULLS LAST, d.foliodesc DESC NULLS LAST;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en recaudadora_consdesc: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_consdesc(VARCHAR)
IS 'Consulta descuentos prediales aplicados a una cuenta específica.';
