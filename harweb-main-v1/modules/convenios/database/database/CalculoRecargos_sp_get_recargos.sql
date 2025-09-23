-- Stored Procedure: sp_get_recargos
-- Tipo: CRUD
-- Descripción: Obtiene el porcentaje de recargos acumulado para el periodo dado
-- Generado para formulario: CalculoRecargos
-- Fecha: 2025-08-27 13:55:28

CREATE OR REPLACE FUNCTION sp_get_recargos(
    p_alov INTEGER, p_mesv INTEGER, p_alo INTEGER, p_mes INTEGER, p_dia INTEGER, p_diav INTEGER
) RETURNS NUMERIC AS $$
DECLARE
    mes_limit INTEGER;
    porcentaje NUMERIC;
BEGIN
    IF p_dia <= p_diav THEN
        mes_limit := p_mes - 1;
    ELSE
        mes_limit := p_mes;
    END IF;
    SELECT SUM(porcentaje_parcial) INTO porcentaje
    FROM ta_13_recargosrcm
    WHERE (axo = p_alov AND mes >= p_mesv)
      OR (axo = p_alo AND mes <= mes_limit)
      OR (axo > p_alov AND axo < p_alo);
    RETURN COALESCE(porcentaje, 0);
END;
$$ LANGUAGE plpgsql;