-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: UNIT1 (EXACTO del archivo original)
-- Archivo: 23_SP_ESTACIONAMIENTOS_UNIT1_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: report_unit1
-- Tipo: Report
-- Descripción: Genera el reporte de folios para una fecha/hora específica, uniendo ta_14_folios y TA_14_CVE_IMPORTe.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION report_unit1(fechora timestamp)
RETURNS TABLE (
    aso varchar,
    folio varchar,
    placa varchar,
    fecha_hora timestamp,
    estado varchar,
    clave varchar,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.aso, a.folio, a.placa, a.fecha_hora, a.estado, a.clave, b.importe
    FROM public.ta_14_folios a
    JOIN public.ta_14_cve_importe b ON a.aso = b.aso AND a.clave = b.num_clave
    WHERE a.fecha_hora = fechora
      AND a.fecha_baja = fechora
    ORDER BY a.aso, a.placa, a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

