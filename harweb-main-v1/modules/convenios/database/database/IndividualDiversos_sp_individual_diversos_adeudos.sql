-- Stored Procedure: sp_individual_diversos_adeudos
-- Tipo: Report
-- Descripción: Devuelve el detalle de adeudos de un convenio diverso
-- Generado para formulario: IndividualDiversos
-- Fecha: 2025-08-27 20:47:46

CREATE OR REPLACE FUNCTION sp_individual_diversos_adeudos(p_id_conv_resto integer)
RETURNS TABLE(
  id_adeudo integer,
  pago_parcial smallint,
  importe numeric,
  fecha_venc date,
  recargos numeric,
  interes numeric,
  total numeric,
  cve_parcialidad varchar,
  axo_desde smallint,
  mes_desde smallint,
  axo_hasta smallint,
  mes_hasta smallint
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      id_adeudo,
      pago_parcial,
      importe,
      fecha_venc,
      recargos,
      interes,
      importe + recargos + interes AS total,
      cve_parcialidad,
      axo_desde,
      mes_desde,
      axo_hasta,
      mes_hasta
    FROM ta_17_adeudos_div
    WHERE id_conv_resto = p_id_conv_resto
    ORDER BY pago_parcial;
END;
$$ LANGUAGE plpgsql;