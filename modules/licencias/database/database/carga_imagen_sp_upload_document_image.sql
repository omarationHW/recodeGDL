-- Stored Procedure: sp_upload_document_image
-- Tipo: CRUD
-- Descripción: Agrega un documento (imagen) a un trámite.
-- Generado para formulario: carga_imagen
-- Fecha: 2025-08-26 15:09:29

-- NOTA: La carga de archivos binarios debe hacerse desde la aplicación, aquí solo la inserción.
CREATE OR REPLACE FUNCTION sp_upload_document_image(
  p_tramite_id integer,
  p_cvedocto integer,
  p_id_licencia integer,
  p_cvecuenta integer,
  p_imagen bytea,
  p_capturista text
) RETURNS integer AS $$
DECLARE
  v_id_imagen integer;
BEGIN
  INSERT INTO digital_docs (cvedocto, id_tramite, id_licencia, imagen, cvecuenta, feccap, capturista)
  VALUES (p_cvedocto, p_tramite_id, p_id_licencia, p_imagen, p_cvecuenta, now(), p_capturista)
  RETURNING id_imagen INTO v_id_imagen;
  INSERT INTO tramitedocs (id_tramite, id_licencia, id_imagen) VALUES (p_tramite_id, p_id_licencia, v_id_imagen);
  RETURN v_id_imagen;
END;
$$ LANGUAGE plpgsql;