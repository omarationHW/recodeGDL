-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: reqctascanfrm
-- Generado: 2025-08-27 14:30:35
-- Total SPs: 2
-- ============================================

-- SP 1/2: report_reqctascanfrm
-- Tipo: Report
-- Descripción: Obtiene la lista de cuentas canceladas para una recaudadora y rango de fechas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION report_reqctascanfrm(
    p_recaud integer,
    p_fini date,
    p_ffin date
)
RETURNS TABLE (
    cvecuenta integer,
    recaud smallint,
    cuenta integer,
    cuenta_utm text
) AS $$
BEGIN
    RETURN QUERY
    SELECT c1.cvecuenta, c1.recaud, c1.cuenta,
           (c1.recaud::text || '-' || c1.urbrus::text || '-' || c1.cuenta::text) AS cuenta_utm
    FROM convcta c1
    JOIN catastro ct ON c1.cvecuenta = ct.cvecuenta
    JOIN reqpredial r ON r.cvecuenta = c1.cvecuenta
    WHERE c1.recaud = p_recaud
      AND ct.cvemov = 11
      AND ct.feccap BETWEEN p_fini AND p_ffin
      AND r.vigencia = 'V'
    GROUP BY c1.cvecuenta, c1.recaud, c1.cuenta, c1.urbrus
    ORDER BY c1.recaud, c1.cuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: report_reqctascanfrm_folios
-- Tipo: Report
-- Descripción: Obtiene los folios de requerimiento para una cuenta específica que no han sido cancelados y están vigentes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION report_reqctascanfrm_folios(
    p_cvecuenta integer
)
RETURNS TABLE (
    folioreq integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT folioreq
    FROM reqpredial
    WHERE cvecuenta = p_cvecuenta
      AND feccan IS NULL
      AND vigencia = 'V'
    ORDER BY folioreq;
END;
$$ LANGUAGE plpgsql;

-- ============================================

