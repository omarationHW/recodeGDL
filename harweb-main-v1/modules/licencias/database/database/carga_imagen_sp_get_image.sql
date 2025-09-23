-- Stored Procedure: sp_get_image
-- Tipo: Report
-- Descripción: Obtiene la imagen binaria asociada a un documento
-- Generado para formulario: carga_imagen
-- Fecha: 2025-08-27 16:41:18

CREATE OR REPLACE FUNCTION sp_get_image(p_id_imagen integer)
RETURNS bytea AS $$
DECLARE
  img bytea;
BEGIN
  SELECT imagen INTO img FROM digital_docs WHERE id_imagen = p_id_imagen;
  RETURN img;
END;
$$ LANGUAGE plpgsql;