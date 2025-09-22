-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CARGA_IMAGEN (EXACTO del archivo original)
-- Archivo: 46_SP_LICENCIAS_CARGA_IMAGEN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: sp_get_document_types
-- Tipo: Catalog
-- Descripción: Obtiene los tipos de documentos disponibles
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_document_types()
RETURNS TABLE(id integer, documento varchar) AS $$
BEGIN
  RETURN QUERY SELECT id, documento FROM c_doctos ORDER BY documento;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CARGA_IMAGEN (EXACTO del archivo original)
-- Archivo: 46_SP_LICENCIAS_CARGA_IMAGEN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: sp_get_image
-- Tipo: Report
-- Descripción: Obtiene la imagen binaria asociada a un documento
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_image(p_id_imagen integer)
RETURNS bytea AS $$
DECLARE
  img bytea;
BEGIN
  SELECT imagen INTO img FROM digital_docs WHERE id_imagen = p_id_imagen;
  RETURN img;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CARGA_IMAGEN (EXACTO del archivo original)
-- Archivo: 46_SP_LICENCIAS_CARGA_IMAGEN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: sp_delete_image
-- Tipo: CRUD
-- Descripción: Elimina una imagen/documento de un trámite
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_image(p_id_imagen integer)
RETURNS void AS $$
BEGIN
  DELETE FROM tramitedocs WHERE id_imagen = p_id_imagen;
  DELETE FROM digital_docs WHERE id_imagen = p_id_imagen;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CARGA_IMAGEN (EXACTO del archivo original)
-- Archivo: 46_SP_LICENCIAS_CARGA_IMAGEN_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

