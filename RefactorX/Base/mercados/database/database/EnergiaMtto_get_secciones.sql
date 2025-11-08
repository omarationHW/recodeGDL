-- Stored Procedure: get_secciones
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de secciones
-- Generado para formulario: EnergiaMtto
-- Fecha: 2025-08-26 23:57:51

CREATE OR REPLACE FUNCTION get_secciones() RETURNS TABLE(id text, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion;
END; $$ LANGUAGE plpgsql;