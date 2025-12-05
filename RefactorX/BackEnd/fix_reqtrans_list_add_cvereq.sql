DROP FUNCTION IF EXISTS recaudadora_reqtrans_list(VARCHAR, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION recaudadora_reqtrans_list(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    cvereq INTEGER,
    clave_cuenta TEXT,
    folio INTEGER,
    ejercicio INTEGER,
    estatus TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.cvereq::INTEGER,
        COALESCE(r.cvecuenta::TEXT, '')::TEXT as clave_cuenta,
        COALESCE(r.foliotransm, 0)::INTEGER as folio,
        COALESCE(r.axoreq, 0)::INTEGER as ejercicio,
        CASE
            WHEN r.vigencia = '1' OR r.vigencia = 'A' THEN 'Activo'
            WHEN r.vigencia = '0' OR r.vigencia = 'I' THEN 'Inactivo'
            ELSE 'Pendiente'
        END::TEXT as estatus
    FROM catastro_gdl.reqdiftransmision r
    WHERE 1=1
       AND (p_clave_cuenta IS NULL OR p_clave_cuenta = '' OR r.cvecuenta::TEXT ILIKE '%' || p_clave_cuenta || '%')
       AND (p_ejercicio IS NULL OR p_ejercicio = 0 OR r.axoreq = p_ejercicio)
    ORDER BY r.axoreq DESC, r.foliotransm DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;
