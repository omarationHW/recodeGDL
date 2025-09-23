-- Stored Procedure: sp_get_recargos
-- Tipo: CRUD
-- Descripción: Calcula el porcentaje de recargos acumulados para un periodo
-- Generado para formulario: RptCaratulaDatos
-- Fecha: 2025-08-27 00:44:44

CREATE OR REPLACE FUNCTION sp_get_recargos(
  p_axo_adeudo SMALLINT,
  p_periodo_adeudo SMALLINT,
  p_axo_actual SMALLINT,
  p_mes_actual SMALLINT
) RETURNS NUMERIC AS $$
DECLARE
  porcentaje NUMERIC := 0;
BEGIN
  SELECT COALESCE(SUM(porcentaje_mes),0) INTO porcentaje
  FROM ta_12_recargos
  WHERE (axo = p_axo_adeudo AND mes >= p_periodo_adeudo)
    OR (axo = p_axo_actual AND mes <= p_mes_actual)
    OR (axo > p_axo_adeudo AND axo < p_axo_actual);
  RETURN porcentaje;
END;
$$ LANGUAGE plpgsql;