-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: RFacturacion (EXACTO del archivo original)
-- Archivo: 22_SP_OTRASOBLIG_RFACTURACION_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: con34_gfact_02
-- Tipo: Report
-- Descripción: Genera el reporte de facturación del rastro filtrando por status de adeudo, recargos, año y mes.
-- --------------------------------------------

-- PostgreSQL stored procedure equivalent for con34_gfact_02
-- Parámetros:
--   p_adeudo_status: 'A' (Adeudos y Pagos), 'B' (Solo Adeudos), 'C' (Solo Pagados)
--   p_adeudo_recargo: 'S' (con recargo), 'N' (sin recargo)
--   p_year: año a consultar
--   p_month: mes a consultar

CREATE OR REPLACE FUNCTION con34_gfact_02(
    p_adeudo_status VARCHAR(1),
    p_adeudo_recargo VARCHAR(1),
    p_year INTEGER,
    p_month INTEGER
)
RETURNS TABLE(
    control VARCHAR,
    concesionario VARCHAR,
    superficie NUMERIC,
    tipo VARCHAR,
    licencia VARCHAR,
    importe NUMERIC
) AS $$
BEGIN
    -- Ejemplo: la lógica real debe ajustarse a la estructura de la base de datos destino
    RETURN QUERY
    SELECT
        a.control,
        a.concesionario,
        a.superficie,
        a.tipo,
        a.licencia,
        a.importe
    FROM
        otrasoblig.rastro_facturacion a
    WHERE
        (p_adeudo_status = 'A' OR (p_adeudo_status = 'B' AND a.pagado = false) OR (p_adeudo_status = 'C' AND a.pagado = true))
        AND (p_adeudo_recargo = 'N' OR (p_adeudo_recargo = 'S' AND a.recargo = true))
        AND a.anio = p_year
        AND a.mes = p_month;
END;
$$ LANGUAGE plpgsql;


-- ============================================