-- Stored Procedure: sp_get_adeudos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos para un contrato/concesión y periodo.
-- Generado para formulario: GConsulta
-- Fecha: 2025-08-27 16:02:36

CREATE OR REPLACE FUNCTION sp_get_adeudos_detalle(par_tabla integer, par_id_datos integer, par_aso integer, par_mes integer)
RETURNS TABLE (
    concepto varchar,
    axo integer,
    mes integer,
    importe_pagar numeric,
    recargos_pagar numeric,
    dscto_importe numeric,
    dscto_recargos numeric,
    actualizacion_pagar numeric,
    multa_pagar numeric,
    dscto_multa numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, axo, mes, importe_pagar, recargos_pagar, dscto_importe, dscto_recargos, actualizacion_pagar, multa_pagar, dscto_multa
    FROM t34_adeudos_detalle
    WHERE cve_tab = par_tabla AND id_datos = par_id_datos AND axo = par_aso AND mes = par_mes;
END;
$$ LANGUAGE plpgsql;