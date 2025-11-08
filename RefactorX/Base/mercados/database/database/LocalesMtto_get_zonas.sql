-- Stored Procedure: get_zonas
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de zonas
-- Generado para formulario: LocalesMtto
-- Fecha: 2025-08-27 00:12:40

CREATE OR REPLACE FUNCTION get_zonas() RETURNS TABLE(id_zona integer, zona text) AS $$
BEGIN
  RETURN QUERY SELECT id_zona, zona FROM ta_12_zonas ORDER BY id_zona;
END; $$ LANGUAGE plpgsql;