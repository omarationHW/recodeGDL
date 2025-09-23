-- Stored Procedure: sp_upload_image
-- Tipo: CRUD
-- Descripción: Guarda una imagen y la asocia a un trámite y tipo de documento
-- Generado para formulario: carga_imagen
-- Fecha: 2025-08-27 16:41:18

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