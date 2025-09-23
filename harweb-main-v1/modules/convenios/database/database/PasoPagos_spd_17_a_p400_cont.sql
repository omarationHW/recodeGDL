-- Stored Procedure: spd_17_a_p400_cont
-- Tipo: Report
-- Descripción: Devuelve el conteo de pagos grabados, modificados y totales para usuario
-- Generado para formulario: PasoPagos
-- Fecha: 2025-08-27 15:14:09

CREATE OR REPLACE FUNCTION spd_17_a_p400_cont(parm_id_usuario integer)
RETURNS TABLE(expression integer, expression_1 integer) AS $$
BEGIN
  RETURN QUERY
    SELECT COUNT(*) AS expression, 0 AS expression_1
    FROM ta_17_paso_p_400
    WHERE usuario = parm_id_usuario;
END;
$$ LANGUAGE plpgsql;