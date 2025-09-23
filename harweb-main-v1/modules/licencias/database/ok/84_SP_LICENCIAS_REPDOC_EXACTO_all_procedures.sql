-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: REPDOC (EXACTO del archivo original)
-- Archivo: 84_SP_LICENCIAS_REPDOC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_repdoc_get_requisitos_by_giro
-- Tipo: Report
-- Descripción: Obtiene los requisitos documentales para un giro específico
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_repdoc_get_requisitos_by_giro(p_id_giro INTEGER)
RETURNS TABLE(req INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT r.req, gr.descripcion
    FROM giro_req r
    JOIN c_girosreq gr ON gr.req = r.req
    WHERE r.id_giro = p_id_giro
    ORDER BY gr.req;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: REPDOC (EXACTO del archivo original)
-- Archivo: 84_SP_LICENCIAS_REPDOC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_repdoc_get_giro_by_id
-- Tipo: Catalog
-- Descripción: Obtiene la información de un giro por su ID
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_repdoc_get_giro_by_id(p_id_giro INTEGER)
RETURNS TABLE(id_giro INTEGER, descripcion TEXT, clasificacion TEXT, tipo TEXT, caracteristicas TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id_giro, descripcion, clasificacion, tipo, caracteristicas
    FROM c_giros
    WHERE id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

-- ============================================

