-- Stored Procedure: sp_individual_diversos_referencias
-- Tipo: Report
-- Descripción: Devuelve las referencias asociadas a un convenio diverso
-- Generado para formulario: IndividualDiversos
-- Fecha: 2025-08-27 20:47:46

CREATE OR REPLACE FUNCTION sp_individual_diversos_referencias(p_id_conv_resto integer)
RETURNS TABLE(
  id_control integer,
  id_referencia integer,
  modulo smallint,
  referencia varchar,
  axo_desde smallint,
  mes_desde smallint,
  axo_hasta smallint,
  mes_hasta smallint,
  impuesto numeric,
  recargos numeric,
  gastos numeric,
  multa numeric,
  periodos varchar
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      id_control,
      id_referencia,
      modulo,
      referencia,
      axo_desde,
      mes_desde,
      axo_hasta,
      mes_hasta,
      impuesto,
      recargos,
      gastos,
      multa,
      CONCAT(mes_desde, '/', axo_desde, ' - ', mes_hasta, '/', axo_hasta) AS periodos
    FROM ta_17_referencia
    WHERE id_conv_resto = p_id_conv_resto
    ORDER BY id_control;
END;
$$ LANGUAGE plpgsql;