-- Stored Procedure: sp_get_tipos_aseo
-- Tipo: Catalog
-- Descripción: Obtiene los tipos de aseo disponibles.
-- Generado para formulario: Requerimientos
-- Fecha: 2025-08-27 14:28:57

CREATE OR REPLACE FUNCTION sp_get_tipos_aseo()
RETURNS TABLE(ctrol_aseo INT, tipo_aseo TEXT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion FROM tipos_aseo ORDER BY ctrol_aseo DESC;
END;
$$ LANGUAGE plpgsql;