-- Stored Procedure: psplash_get_splash_data
-- Tipo: Catalog
-- Descripción: Devuelve los textos y la imagen base64 para el splash principal.
-- Generado para formulario: psplash
-- Fecha: 2025-08-27 19:01:21

CREATE OR REPLACE FUNCTION psplash_get_splash_data()
RETURNS TABLE(message TEXT, label_effect TEXT, image_base64 TEXT) AS $$
BEGIN
  message := 'Cargando Aplicación';
  label_effect := 'Padrón y Licencias';
  -- Imagen base64: aquí se puede almacenar en una tabla o archivo, para ejemplo se deja NULL
  image_base64 := NULL; -- O cargar desde tabla/configuración
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;