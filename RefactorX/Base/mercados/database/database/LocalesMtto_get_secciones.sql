-- Stored Procedure: get_secciones
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de secciones
-- Generado para formulario: LocalesMtto
-- Fecha: 2025-08-27 00:12:40

CREATE OR REPLACE FUNCTION get_secciones() RETURNS TABLE(seccion text, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion;
END; $$ LANGUAGE plpgsql;