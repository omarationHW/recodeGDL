-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_REP_FOLIO (EXACTO del archivo original)
-- Archivo: 38_SP_ESTACIONAMIENTOS_SFRM_REP_FOLIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_get_inspectors
-- Tipo: Catalog
-- Descripción: Obtiene la lista de inspectores/vigilantes disponibles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_inspectors()
RETURNS TABLE(id_esta_persona INTEGER, inspector TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT b.id_esta_persona,
           TRIM(b.ap_pater) || ' ' || TRIM(b.ap_mater) || ' ' || TRIM(b.nombre) AS inspector
      FROM ta14_agentes a
      JOIN ta14_personas b ON a.id_esta_persona = b.id_esta_persona;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_REP_FOLIO (EXACTO del archivo original)
-- Archivo: 38_SP_ESTACIONAMIENTOS_SFRM_REP_FOLIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_get_folios_by_inspector
-- Tipo: Report
-- Descripción: Obtiene el conteo de folios hechos por cada inspector en una fecha dada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_folios_by_inspector(p_fecha DATE)
RETURNS TABLE(
  vigilante INTEGER,
  inspector TEXT,
  folios INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.vigilante,
           TRIM(COALESCE(c.ap_pater, '.')) || ' ' || TRIM(COALESCE(c.ap_mater, '.')) || ' ' || TRIM(COALESCE(c.nombre, '.')) AS inspector,
           COUNT(a.folio) AS folios
      FROM ta14_folios_adeudo a
      JOIN ta14_personas c ON a.vigilante = c.id_esta_persona
      WHERE a.fecha_folio = p_fecha
      GROUP BY a.vigilante, inspector
      ORDER BY inspector;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_REP_FOLIO (EXACTO del archivo original)
-- Archivo: 38_SP_ESTACIONAMIENTOS_SFRM_REP_FOLIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

