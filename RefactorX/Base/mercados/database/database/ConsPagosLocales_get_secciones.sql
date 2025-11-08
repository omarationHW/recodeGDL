-- Stored Procedure: get_secciones
-- Tipo: Catalog
-- Descripción: Obtiene la lista de secciones
-- Generado para formulario: ConsPagosLocales
-- Fecha: 2025-08-26 23:21:11

CREATE OR REPLACE FUNCTION get_secciones() RETURNS TABLE(seccion text, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion;
END; $$ LANGUAGE plpgsql;