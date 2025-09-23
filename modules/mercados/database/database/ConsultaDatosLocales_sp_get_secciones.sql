-- Stored Procedure: sp_get_secciones
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de secciones
-- Generado para formulario: ConsultaDatosLocales
-- Fecha: 2025-08-26 23:26:39

CREATE OR REPLACE FUNCTION sp_get_secciones()
RETURNS TABLE(seccion text) AS $$
BEGIN
  RETURN QUERY SELECT seccion FROM ta_11_secciones ORDER BY seccion;
END; $$ LANGUAGE plpgsql;