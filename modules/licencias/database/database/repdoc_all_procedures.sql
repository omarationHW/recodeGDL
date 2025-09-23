-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: repdoc
-- Generado: 2025-08-27 19:18:22
-- Total SPs: 3
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

-- SP 2/3: sp_repdoc_get_giros
-- Tipo: Catalog
-- Descripción: Obtiene todos los giros vigentes de un tipo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_repdoc_get_giros(p_tipo TEXT)
RETURNS TABLE(id_giro INTEGER, descripcion TEXT, clasificacion TEXT, tipo TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id_giro, descripcion, clasificacion, tipo
    FROM c_giros
    WHERE tipo = p_tipo AND vigente = 'V'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

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

