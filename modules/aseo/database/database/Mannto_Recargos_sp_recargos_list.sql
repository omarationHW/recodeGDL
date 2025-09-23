-- Stored Procedure: sp_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos de un año dado
-- Generado para formulario: Mannto_Recargos
-- Fecha: 2025-08-27 14:47:49

CREATE OR REPLACE FUNCTION sp_recargos_list(p_year INTEGER)
RETURNS TABLE(ano_mes TEXT, ano INTEGER, mes INTEGER, porc_recargo NUMERIC, porc_multa NUMERIC) AS $$
BEGIN
  RETURN QUERY
    SELECT TO_CHAR(aso_mes_recargo, 'YYYY-MM') AS ano_mes,
           EXTRACT(YEAR FROM aso_mes_recargo)::INTEGER AS ano,
           EXTRACT(MONTH FROM aso_mes_recargo)::INTEGER AS mes,
           porc_recargo, porc_multa
      FROM ta_16_recargos
     WHERE EXTRACT(YEAR FROM aso_mes_recargo) = p_year
     ORDER BY aso_mes_recargo;
END;
$$ LANGUAGE plpgsql;