-- Stored Procedure: sp_cat_zonas_list
-- Tipo: Catalog
-- Descripción: Lista todas las zonas.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_cat_zonas_list()
RETURNS TABLE(id SERIAL, zona INTEGER, sub_zona INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT id, zona, sub_zona, descripcion FROM ta_16_zonas ORDER BY id;
END;
$$ LANGUAGE plpgsql;