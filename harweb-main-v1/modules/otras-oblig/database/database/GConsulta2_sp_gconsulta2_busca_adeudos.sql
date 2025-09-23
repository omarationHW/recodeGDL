-- Stored Procedure: sp_gconsulta2_busca_adeudos
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos para un control
-- Generado para formulario: GConsulta2
-- Fecha: 2025-08-28 13:11:34

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_adeudos(
  par_tabla integer,
  par_id_datos integer,
  par_aso integer,
  par_mes integer
)
RETURNS TABLE (
  concepto varchar,
  axo integer,
  mes integer,
  importe_pagar numeric,
  recargos_pagar numeric,
  dscto_importe numeric,
  dscto_recargos numeric,
  actualizacion_pagar numeric
) AS $$
BEGIN
  RETURN QUERY SELECT concepto, axo, mes, importe_pagar, recargos_pagar, dscto_importe, dscto_recargos, actualizacion_pagar
  FROM cob34_gdetade_01(par_tabla::text, par_id_datos, par_aso, par_mes);
END;
$$ LANGUAGE plpgsql;