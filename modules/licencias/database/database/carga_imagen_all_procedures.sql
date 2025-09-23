-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: carga_imagen
-- Generado: 2025-08-27 16:41:18
-- Total SPs: 6
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

-- SP 2/6: sp_get_tramite_docs
-- Tipo: Report
-- Descripción: Obtiene los documentos asociados a un trámite
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tramite_docs(p_tramite_id integer)
RETURNS TABLE(id_imagen integer, documento varchar, id_licencia integer) AS $$
BEGIN
  RETURN QUERY
    SELECT td.id_imagen, d.documento, td.id_licencia
    FROM tramitedocs td
    JOIN c_doctos d ON td.cvedocto = d.id
    WHERE td.id_tramite = p_tramite_id;
END;
$$ LANGUAGE plpgsql;

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

-- SP 4/6: sp_upload_image
-- Tipo: CRUD
-- Descripción: Guarda una imagen y la asocia a un trámite y tipo de documento
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_upload_image(
  p_tramite_id integer,
  p_document_type_id integer,
  p_id_licencia integer,
  p_file bytea,
  p_capturista varchar
) RETURNS integer AS $$
DECLARE
  new_id integer;
BEGIN
  INSERT INTO digital_docs (cvedocto, id_tramite, id_licencia, imagen, feccap, capturista)
  VALUES (p_document_type_id, p_tramite_id, p_id_licencia, p_file, NOW(), p_capturista)
  RETURNING id_imagen INTO new_id;

  INSERT INTO tramitedocs (id_tramite, id_imagen, id_licencia, cvedocto)
  VALUES (p_tramite_id, new_id, p_id_licencia, p_document_type_id);

  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

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

-- SP 6/6: sp_get_tramite_info
-- Tipo: Report
-- Descripción: Obtiene información básica de un trámite
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tramite_info(p_tramite_id integer)
RETURNS TABLE(id_tramite integer, cvecuenta integer, recaud integer) AS $$
BEGIN
  RETURN QUERY SELECT id_tramite, cvecuenta, recaud FROM tramites WHERE id_tramite = p_tramite_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

