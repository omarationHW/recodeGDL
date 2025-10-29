-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_REPORTESCALCO (EXACTO del archivo original)
-- Archivo: 40_SP_ESTACIONAMIENTOS_SFRM_REPORTESCALCO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_catalog_inspectors
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de inspectores (id y nombre completo).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_catalog_inspectors()
RETURNS TABLE(id_esta_persona integer, inspector text)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT b.id_esta_persona,
           TRIM(COALESCE(b.ap_pater, '')) || ' ' || TRIM(COALESCE(b.ap_mater, '')) || ' ' || TRIM(COALESCE(b.nombre, '')) AS inspector
    FROM ta14_agentes a
    JOIN ta14_personas b ON a.id_esta_persona = b.id_esta_persona;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_REPORTESCALCO (EXACTO del archivo original)
-- Archivo: 40_SP_ESTACIONAMIENTOS_SFRM_REPORTESCALCO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_report_folios
-- Tipo: Report
-- Descripción: Reporte de folios capturados por inspector en una fecha dada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_report_folios(fechora date)
RETURNS TABLE(
  vigilante integer,
  inspector text,
  folios integer
)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT a.vigilante,
           TRIM(COALESCE(c.ap_pater, '.')) || ' ' || TRIM(COALESCE(c.ap_mater, '.')) || ' ' || TRIM(COALESCE(c.nombre, '.')) AS inspector,
           COUNT(a.folio) AS folios
    FROM ta14_folios_adeudo a
    JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
    WHERE a.fecha_folio = fechora
    GROUP BY a.vigilante, inspector
    ORDER BY inspector;
END;
$$;

-- ============================================

