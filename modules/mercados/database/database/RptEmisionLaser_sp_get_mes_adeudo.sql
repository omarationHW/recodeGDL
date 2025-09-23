-- Stored Procedure: sp_get_mes_adeudo
-- Tipo: Report
-- Descripción: Obtiene los meses de adeudo de un local para un año.
-- Generado para formulario: RptEmisionLaser
-- Fecha: 2025-08-27 20:48:44

CREATE OR REPLACE FUNCTION sp_get_mes_adeudo(p_id_local integer, p_axo integer)
RETURNS TABLE(
  id_adeudo_local integer,
  axo smallint,
  periodo smallint,
  importe numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_adeudo_local, axo, periodo, importe
  FROM ta_11_adeudo_local
  WHERE id_local = p_id_local AND axo = p_axo
  ORDER BY axo, periodo;
END;
$$ LANGUAGE plpgsql;