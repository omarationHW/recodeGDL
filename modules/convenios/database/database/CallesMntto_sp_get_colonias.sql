-- Stored Procedure: sp_get_colonias
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de colonias
-- Generado para formulario: CallesMntto
-- Fecha: 2025-08-27 13:59:54

CREATE OR REPLACE FUNCTION sp_get_colonias() RETURNS TABLE(colonia smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT colonia, descripcion FROM ta_17_colonias ORDER BY colonia;
END;
$$ LANGUAGE plpgsql;