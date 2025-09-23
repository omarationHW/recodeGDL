-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sqrp_esta01
-- Generado: 2025-08-27 14:53:52
-- Total SPs: 1
-- ============================================

-- SP 1/1: sqrp_esta01_report
-- Tipo: Report
-- Descripción: Obtiene el informe concentrado de multas de estacionómetros agrupado por año y tipo de infracción, con totales de folios e importes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sqrp_esta01_report(axo_from integer DEFAULT NULL, axo_to integer DEFAULT NULL)
RETURNS TABLE(
    axo smallint,
    totfol bigint,
    infraccion smallint,
    totimp numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.axo,
        COUNT(a.folio) AS totfol,
        a.infraccion,
        SUM(b.tarifa) AS totimp
    FROM ta14_folios_adeudo a
    JOIN ta14_tarifas b
      ON a.infraccion = b.num_clave
     AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
    WHERE (axo_from IS NULL OR a.axo >= axo_from)
      AND (axo_to IS NULL OR a.axo <= axo_to)
    GROUP BY a.axo, a.infraccion
    ORDER BY a.axo, a.infraccion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

