-- Stored Procedure: sp_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos, opcionalmente por año.
-- Generado para formulario: ABC_Recargos
-- Fecha: 2025-08-27 13:25:47

CREATE OR REPLACE FUNCTION sp_recargos_list(p_year integer DEFAULT NULL)
RETURNS TABLE (
    aso_mes_recargo date,
    porc_recargo float,
    porc_multa float
) AS $$
BEGIN
    RETURN QUERY
    SELECT aso_mes_recargo, porc_recargo, porc_multa
    FROM ta_16_recargos
    WHERE (p_year IS NULL OR EXTRACT(YEAR FROM aso_mes_recargo) = p_year)
    ORDER BY aso_mes_recargo;
END;
$$ LANGUAGE plpgsql;