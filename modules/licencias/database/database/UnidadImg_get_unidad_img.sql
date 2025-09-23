-- Stored Procedure: get_unidad_img
-- Tipo: Catalog
-- Descripción: Obtiene la unidad de imágenes configurada en la tabla de configuración.
-- Generado para formulario: UnidadImg
-- Fecha: 2025-08-27 19:49:13

CREATE OR REPLACE FUNCTION get_unidad_img()
RETURNS TABLE(unidad_img VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT valor FROM configuracion WHERE clave = 'UnidadImg' LIMIT 1;
END;
$$ LANGUAGE plpgsql;