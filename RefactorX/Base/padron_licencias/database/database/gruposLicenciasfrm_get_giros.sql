-- Stored Procedure: get_giros
-- Tipo: Catalog
-- Descripción: Obtiene los giros de tipo 'L'.
-- Generado para formulario: gruposLicenciasfrm
-- Fecha: 2025-08-27 18:23:51

CREATE OR REPLACE FUNCTION get_giros()
RETURNS TABLE(id_giro INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_giro, descripcion FROM c_giros WHERE tipo = 'L' ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;