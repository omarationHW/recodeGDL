-- Stored Procedure: sp_cat_operaciones_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de operación.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_cat_operaciones_list()
RETURNS TABLE(id SERIAL, cve_operacion VARCHAR, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT id, cve_operacion, descripcion FROM ta_16_operacion ORDER BY id;
END;
$$ LANGUAGE plpgsql;