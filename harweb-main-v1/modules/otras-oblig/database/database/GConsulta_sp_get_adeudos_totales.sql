-- Stored Procedure: sp_get_adeudos_totales
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos para un contrato/concesión y periodo.
-- Generado para formulario: GConsulta
-- Fecha: 2025-08-27 16:02:36

CREATE OR REPLACE FUNCTION sp_get_adeudos_totales(par_tabla integer, par_id_datos integer, par_aso integer, par_mes integer)
RETURNS TABLE (
    cuenta integer,
    obliga varchar,
    concepto varchar,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT cuenta, obliga, concepto, importe
    FROM t34_adeudos_totales
    WHERE cve_tab = par_tabla AND id_datos = par_id_datos AND axo = par_aso AND mes = par_mes;
END;
$$ LANGUAGE plpgsql;