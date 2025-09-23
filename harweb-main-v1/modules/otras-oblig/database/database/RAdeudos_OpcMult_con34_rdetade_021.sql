-- Stored Procedure: con34_rdetade_021
-- Tipo: Report
-- Descripción: Obtiene los adeudos de un local por id_datos
-- Generado para formulario: RAdeudos_OpcMult
-- Fecha: 2025-08-28 13:32:20

CREATE OR REPLACE FUNCTION con34_rdetade_021(p_id_datos integer)
RETURNS TABLE(registro integer, axo integer, mes integer, periodo date, importe numeric, recargo numeric) AS $$
BEGIN
  RETURN QUERY
  SELECT id_adeudo, axo, mes, periodo, importe, recargo
  FROM t34_adeudos
  WHERE id_datos = p_id_datos AND status = 'V';
END;
$$ LANGUAGE plpgsql;