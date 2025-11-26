-- ================================================================
-- SP: recaudadora_consulta_sdos_favor
-- Descripción: Consulta saldos a favor por cuenta, ejercicio y folio
-- Tablas: solic_sdosfavor, sdosfavor
-- ================================================================

CREATE OR REPLACE FUNCTION recaudadora_consulta_sdos_favor(
    p_clave_cuenta VARCHAR DEFAULT NULL,
    p_ejercicio INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL
)
RETURNS TABLE(
    clave_cuenta INTEGER,
    folio INTEGER,
    ejercicio INTEGER,
    saldo NUMERIC,
    aplicable BOOLEAN,
    id_solic INTEGER,
    status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Consultar saldos a favor
    -- Se busca en catastro_gdl.solic_sdosfavor y se obtiene el saldo de catastro_gdl.sdosfavor
    RETURN QUERY
    SELECT
        s.cvecuenta::INTEGER as clave_cuenta,
        s.folio::INTEGER as folio,
        s.axofol::INTEGER as ejercicio,
        COALESCE(SUM(sd.saldo_favor), s.inconf::NUMERIC) as saldo,
        CASE
            WHEN COALESCE(SUM(sd.saldo_favor), s.inconf::NUMERIC) > 0 THEN TRUE
            ELSE FALSE
        END as aplicable,
        s.id_solic::INTEGER as id_solic,
        s.status::VARCHAR as status
    FROM catastro_gdl.solic_sdosfavor s
    LEFT JOIN catastro_gdl.sdosfavor sd ON s.id_solic = sd.id_solic
    WHERE (p_clave_cuenta IS NULL OR s.cvecuenta::TEXT = p_clave_cuenta)
      AND (p_ejercicio IS NULL OR s.axofol = p_ejercicio)
      AND (p_folio IS NULL OR s.folio = p_folio)
    GROUP BY s.id_solic, s.cvecuenta, s.folio, s.axofol, s.inconf, s.status
    ORDER BY s.id_solic DESC
    LIMIT 100;
END;
$$;

COMMENT ON FUNCTION recaudadora_consulta_sdos_favor(VARCHAR, INTEGER, INTEGER)
IS 'Consulta saldos a favor por cuenta, ejercicio y folio';
