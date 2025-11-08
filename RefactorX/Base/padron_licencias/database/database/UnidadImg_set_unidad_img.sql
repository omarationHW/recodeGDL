-- Stored Procedure: set_unidad_img
-- Tipo: CRUD
-- Descripción: Guarda o actualiza la unidad de imágenes en la tabla de configuración.
-- Generado para formulario: UnidadImg
-- Fecha: 2025-08-27 19:49:13

CREATE OR REPLACE FUNCTION set_unidad_img(p_unidad VARCHAR)
RETURNS TABLE(success BOOLEAN, msg TEXT) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM configuracion WHERE clave = 'UnidadImg') THEN
    UPDATE configuracion SET valor = TRIM(p_unidad) WHERE clave = 'UnidadImg';
    RETURN QUERY SELECT TRUE, 'Actualizado correctamente';
  ELSE
    INSERT INTO configuracion(clave, valor) VALUES ('UnidadImg', TRIM(p_unidad));
    RETURN QUERY SELECT TRUE, 'Insertado correctamente';
  END IF;
END;
$$ LANGUAGE plpgsql;