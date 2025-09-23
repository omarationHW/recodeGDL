-- Stored Procedure: sp_cat_tipos_aseo_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de aseo.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_list()
RETURNS TABLE(id SERIAL, tipo_aseo VARCHAR, descripcion VARCHAR, cta_aplicacion INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT id, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipo_aseo ORDER BY id;
END;
$$ LANGUAGE plpgsql;