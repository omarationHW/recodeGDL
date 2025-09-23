-- Stored Procedure: sp_calcula_recargos
-- Tipo: CRUD
-- Descripción: Calcula el porcentaje de recargos para un periodo dado.
-- Generado para formulario: RptEdoCuenta
-- Fecha: 2025-08-27 15:37:22

CREATE OR REPLACE FUNCTION sp_calcula_recargos(alov INT, mesv INT, alo INT, mes INT, dia INT, diav INT)
RETURNS FLOAT AS $$
DECLARE
  porc FLOAT;
BEGIN
  SELECT COALESCE(SUM(porcentaje_parcial),0) INTO porc FROM ta_13_recargosrcm
    WHERE (axo = alov AND mes >= mesv)
      AND ((alov >= alo AND axo = alo AND mes <= (CASE WHEN dia <= diav THEN mes-1 ELSE mes END))
           OR (axo > alov AND axo < alo));
  RETURN porc;
END;
$$ LANGUAGE plpgsql;