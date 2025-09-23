-- Stored Procedure: sp_cat_tipos_emp_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de empresa.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_cat_tipos_emp_list()
RETURNS TABLE(id SERIAL, tipo_empresa VARCHAR, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT id, tipo_empresa, descripcion FROM ta_16_tipos_emp ORDER BY id;
END;
$$ LANGUAGE plpgsql;