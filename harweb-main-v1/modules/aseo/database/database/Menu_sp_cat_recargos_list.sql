-- Stored Procedure: sp_cat_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos de un ejercicio.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_cat_recargos_list(p_ejercicio INTEGER)
RETURNS TABLE(id SERIAL, aso_mes_recargo DATE, porc_recargo NUMERIC, porc_multa NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT id, aso_mes_recargo, porc_recargo, porc_multa FROM ta_16_recargos WHERE EXTRACT(YEAR FROM aso_mes_recargo) = p_ejercicio ORDER BY aso_mes_recargo;
END;
$$ LANGUAGE plpgsql;