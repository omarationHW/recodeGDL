-- Stored Procedure: sp_cat_empresas_list
-- Tipo: Catalog
-- Descripción: Lista todas las empresas.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_cat_empresas_list()
RETURNS TABLE(id SERIAL, num_empresa INTEGER, ctrol_emp INTEGER, descripcion VARCHAR, representante VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT id, num_empresa, ctrol_emp, descripcion, representante FROM ta_16_empresas ORDER BY id;
END;
$$ LANGUAGE plpgsql;