-- Stored Procedure: sp_gconsulta2_busca_totales
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos para un control
-- Generado para formulario: GConsulta2
-- Fecha: 2025-08-28 13:11:34

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_totales(
  par_tabla integer,
  par_id_datos integer,
  par_aso integer,
  par_mes integer
)
RETURNS TABLE (
  cuenta integer,
  obliga varchar,
  concepto varchar,
  importe numeric
) AS $$
BEGIN
  RETURN QUERY SELECT cuenta, obliga, concepto, importe
  FROM cob34_gtotade_01(par_tabla::text, par_id_datos, par_aso, par_mes);
END;
$$ LANGUAGE plpgsql;