-- Stored Procedure: spcob34_gtotade_01
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos por concepto para una concesión y periodo
-- Generado para formulario: GBaja
-- Fecha: 2025-08-27 23:42:06

CREATE OR REPLACE FUNCTION spcob34_gtotade_01(par_tabla integer, par_id_datos integer, par_aso integer, par_mes integer)
RETURNS TABLE (
  cuenta integer,
  obliga text,
  concepto text,
  importe numeric
) AS $$
BEGIN
  RETURN QUERY
    SELECT c.cuenta, c.obliga, c.concepto, SUM(c.importe_pagar + c.recargos_pagar - c.dscto_importe - c.dscto_recargos) as importe
    FROM t34_conceptos c
    WHERE c.cve_tab = par_tabla AND c.id_datos = par_id_datos AND c.axo = par_aso AND c.mes = par_mes
    GROUP BY c.cuenta, c.obliga, c.concepto;
END;
$$ LANGUAGE plpgsql;