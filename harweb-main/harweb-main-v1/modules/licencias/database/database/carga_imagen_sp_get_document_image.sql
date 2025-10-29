-- Stored Procedure: sp_get_document_image
-- Tipo: Report
-- Descripción: Obtiene la imagen (binario) de un documento por id_imagen.
-- Generado para formulario: carga_imagen
-- Fecha: 2025-08-26 15:09:29

CREATE OR REPLACE FUNCTION sp_get_document_image(p_id_imagen integer)
RETURNS bytea AS $$
DECLARE
  img bytea;
BEGIN
  SELECT imagen INTO img FROM digital_docs WHERE id_imagen = p_id_imagen;
  RETURN img;
END;
$$ LANGUAGE plpgsql;