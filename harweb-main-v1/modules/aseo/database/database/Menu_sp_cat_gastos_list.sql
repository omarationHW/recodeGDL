-- Stored Procedure: sp_cat_gastos_list
-- Tipo: Catalog
-- Descripción: Lista todos los gastos.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_cat_gastos_list()
RETURNS TABLE(id SERIAL, sdzmg NUMERIC, porc1_req NUMERIC, porc2_embargo NUMERIC, porc3_secuestro NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT id, sdzmg, porc1_req, porc2_embargo, porc3_secuestro FROM ta_16_gastos ORDER BY id;
END;
$$ LANGUAGE plpgsql;