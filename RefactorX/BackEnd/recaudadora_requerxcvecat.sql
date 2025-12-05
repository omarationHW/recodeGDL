DROP FUNCTION IF EXISTS recaudadora_requerxcvecat(VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION recaudadora_requerxcvecat(
    p_cvecat VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    cvereq INTEGER,
    folio INTEGER,
    cuenta INTEGER,
    clave_catastral TEXT,
    ejercicio SMALLINT,
    fecha_emision DATE,
    fecha_entrega DATE,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    multas NUMERIC,
    total NUMERIC,
    vigencia TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.cvereq,
        r.folioreq as folio,
        r.cvecuenta as cuenta,
        COALESCE(c.cvecatnva::TEXT, '') as clave_catastral,
        r.axoreq as ejercicio,
        r.fecemi as fecha_emision,
        r.fecent as fecha_entrega,
        COALESCE(r.impuesto::NUMERIC, 0) as impuesto,
        COALESCE(r.recargos::NUMERIC, 0) as recargos,
        COALESCE(r.gastos::NUMERIC, 0) as gastos,
        COALESCE(r.multas::NUMERIC, 0) as multas,
        COALESCE(r.total::NUMERIC, 0) as total,
        CASE
            WHEN r.vigencia = 'P' THEN 'Pendiente'::TEXT
            WHEN r.vigencia = 'C' THEN 'Cancelado'::TEXT
            WHEN r.vigencia = 'E' THEN 'Entregado'::TEXT
            ELSE COALESCE(r.vigencia::TEXT, 'Sin estatus')
        END as vigencia
    FROM catastro_gdl.h_reqpredial r
    LEFT JOIN catastro_gdl.controladora c ON c.cvecuenta = r.cvecuenta
    WHERE 1=1
       AND (p_cvecat IS NULL OR p_cvecat = '' OR c.cvecatnva::TEXT ILIKE '%' || p_cvecat || '%')
    ORDER BY r.axoreq DESC, r.folioreq DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;
