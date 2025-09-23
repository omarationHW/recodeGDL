-- Stored Procedure: sp34_adeudototal
-- Tipo: Report
-- Descripción: Obtiene el resumen total de adeudos por tabla y periodo (año-mes).
-- Generado para formulario: GAdeudosGral
-- Fecha: 2025-08-28 12:53:29

CREATE OR REPLACE FUNCTION sp34_adeudototal(par_tabla integer, par_fecha varchar)
RETURNS TABLE(
  control varchar,
  nombre varchar,
  superficie numeric,
  periodos varchar,
  adeudo numeric,
  recargos numeric,
  desc_recargos numeric,
  multa numeric,
  desc_multa numeric,
  actualizacion numeric,
  gastos numeric,
  forma numeric,
  autorizacion numeric,
  total numeric,
  ubicacion varchar,
  tipo varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.control, d.nombre, d.superficie, d.periodos, d.adeudo, d.recargos, d.desc_recargos, d.multa, d.desc_multa, d.actualizacion, d.gastos, d.forma, d.autorizacion, d.total, d.ubicacion, d.tipo
  FROM adeudos_totales d
  WHERE d.cve_tab = par_tabla
    AND d.periodo = par_fecha;
END;
$$ LANGUAGE plpgsql;