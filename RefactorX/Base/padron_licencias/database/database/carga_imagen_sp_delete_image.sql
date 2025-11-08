-- Stored Procedure: sp_delete_image
-- Tipo: CRUD
-- Descripción: Elimina una imagen/documento de un trámite
-- Generado para formulario: carga_imagen
-- Fecha: 2025-08-27 16:41:18

CREATE OR REPLACE FUNCTION sp_delete_image(p_id_imagen integer)
RETURNS void AS $$
BEGIN
  DELETE FROM tramitedocs WHERE id_imagen = p_id_imagen;
  DELETE FROM digital_docs WHERE id_imagen = p_id_imagen;
END;
$$ LANGUAGE plpgsql;