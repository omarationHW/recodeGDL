-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CERTIFICACIONESFRM (EXACTO del archivo original)
-- Archivo: 49_SP_LICENCIAS_CERTIFICACIONESFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: sp_certificaciones_list
-- Tipo: Report
-- Descripción: Obtiene listado de certificaciones por tipo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_certificaciones_list(p_tipo TEXT)
RETURNS TABLE(id INT, axo INT, folio INT, id_licencia INT, partidapago TEXT, observacion TEXT, vigente TEXT, feccap DATE, capturista TEXT, tipo TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id, axo, folio, id_licencia, partidapago, observacion, vigente, feccap, capturista, tipo FROM certificaciones WHERE tipo = p_tipo ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CERTIFICACIONESFRM (EXACTO del archivo original)
-- Archivo: 49_SP_LICENCIAS_CERTIFICACIONESFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: sp_certificaciones_update
-- Tipo: CRUD
-- Descripción: Actualiza una certificación existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_certificaciones_update(p_id INT, p_observacion TEXT, p_partidapago TEXT, p_capturista TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE certificaciones SET observacion = p_observacion, partidapago = p_partidapago, capturista = p_capturista WHERE id = p_id;
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CERTIFICACIONESFRM (EXACTO del archivo original)
-- Archivo: 49_SP_LICENCIAS_CERTIFICACIONESFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: sp_certificaciones_search
-- Tipo: Report
-- Descripción: Búsqueda avanzada de certificaciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_certificaciones_search(
  p_axo INT DEFAULT NULL, p_folio INT DEFAULT NULL, p_id_licencia INT DEFAULT NULL, p_feccap_ini DATE DEFAULT NULL, p_feccap_fin DATE DEFAULT NULL, p_tipo TEXT DEFAULT NULL
) RETURNS TABLE(id INT, axo INT, folio INT, id_licencia INT, partidapago TEXT, observacion TEXT, vigente TEXT, feccap DATE, capturista TEXT, tipo TEXT) AS $$
BEGIN
  RETURN QUERY SELECT * FROM certificaciones
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_folio IS NULL OR folio = p_folio)
      AND (p_id_licencia IS NULL OR id_licencia = p_id_licencia)
      AND (p_feccap_ini IS NULL OR feccap >= p_feccap_ini)
      AND (p_feccap_fin IS NULL OR feccap <= p_feccap_fin)
      AND (p_tipo IS NULL OR tipo = p_tipo)
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CERTIFICACIONESFRM (EXACTO del archivo original)
-- Archivo: 49_SP_LICENCIAS_CERTIFICACIONESFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

