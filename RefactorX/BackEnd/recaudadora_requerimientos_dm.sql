DROP FUNCTION IF EXISTS recaudadora_requerimientos_dm(VARCHAR, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION recaudadora_requerimientos_dm(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    cvereq INTEGER,
    folio INTEGER,
    cuenta TEXT,
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
        COALESCE(r.cvecuenta::TEXT, '') as cuenta,
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
    WHERE 1=1
       AND (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
       AND (p_ejercicio IS NULL OR p_ejercicio = 0 OR r.axoreq = p_ejercicio)
    ORDER BY r.axoreq DESC, r.folioreq DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;
