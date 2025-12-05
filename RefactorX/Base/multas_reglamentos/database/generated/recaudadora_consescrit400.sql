-- ================================================================
-- SP: recaudadora_consescrit400
-- Módulo: multas_reglamentos
-- Descripción: Consulta escrituras/requerimientos forma 400 por cuenta
-- Tablas: reqdiftransmision
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS public.recaudadora_consescrit400(VARCHAR);
DROP FUNCTION IF EXISTS comun.recaudadora_consescrit400(VARCHAR);

CREATE OR REPLACE FUNCTION public.recaudadora_consescrit400(
    p_clave_cuenta VARCHAR
)
RETURNS TABLE(
    cvereq INTEGER,
    axoreq INTEGER,
    folioreq INTEGER,
    cvecuenta INTEGER,
    total NUMERIC,
    vigencia CHAR,
    fecemi DATE,
    feccap DATE,
    estado VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    -- Convertir clave cuenta a entero (o buscar por cualquier patrón si no es numérico)
    BEGIN
        v_cvecuenta := p_clave_cuenta::INTEGER;
    EXCEPTION WHEN OTHERS THEN
        v_cvecuenta := NULL;
    END;

    -- Retornar requerimientos/escrituras de la cuenta
    RETURN QUERY
    SELECT
        r.cvereq,
        r.axoreq,
        r.folioreq,
        r.cvecuenta,
        COALESCE(r.total, 0)::NUMERIC,
        COALESCE(r.vigencia, ' ')::CHAR,
        r.fecemi,
        r.feccap,
        CASE
            WHEN r.vigencia = 'V' THEN 'Vigente'
            WHEN r.vigencia = 'C' THEN 'Cancelado'
            WHEN r.vigencia = 'P' THEN 'Pagado'
            ELSE 'Desconocido'
        END::VARCHAR AS estado
    FROM catastro_gdl.reqdiftransmision r
    WHERE (
        v_cvecuenta IS NULL OR
        r.cvecuenta = v_cvecuenta OR
        r.cvereq::TEXT ILIKE '%' || p_clave_cuenta || '%' OR
        r.folioreq::TEXT ILIKE '%' || p_clave_cuenta || '%'
    )
    ORDER BY r.axoreq DESC NULLS LAST, r.fecemi DESC NULLS LAST, r.cvereq DESC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en recaudadora_consescrit400: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_consescrit400(VARCHAR)
IS 'Consulta escrituras/requerimientos forma 400 por cuenta. Busca por cvecuenta, cvereq o folioreq.';
