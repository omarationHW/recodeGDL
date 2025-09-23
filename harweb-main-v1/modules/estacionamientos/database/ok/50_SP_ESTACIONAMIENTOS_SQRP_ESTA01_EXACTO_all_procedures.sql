-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SQRP_ESTA01 (EXACTO del archivo original)
-- Archivo: 50_SP_ESTACIONAMIENTOS_SQRP_ESTA01_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
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

