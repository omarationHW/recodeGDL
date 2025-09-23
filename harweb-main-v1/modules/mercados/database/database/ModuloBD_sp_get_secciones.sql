-- Stored Procedure: sp_get_secciones
-- Tipo: Catalog
-- Descripción: Obtiene todas las secciones
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

CREATE OR REPLACE FUNCTION sp_get_secciones()
RETURNS TABLE(seccion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion;
END; $$;