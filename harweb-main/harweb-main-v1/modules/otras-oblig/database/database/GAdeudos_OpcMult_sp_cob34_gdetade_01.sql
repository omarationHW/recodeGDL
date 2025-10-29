-- Stored Procedure: sp_cob34_gdetade_01
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos para un dato/concesión.
-- Generado para formulario: GAdeudos_OpcMult
-- Fecha: 2025-08-27 20:44:01

CREATE OR REPLACE FUNCTION sp_cob34_gdetade_01(par_tabla integer, par_id_datos integer, par_aso integer, par_mes integer)
RETURNS TABLE(
    concepto text,
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
    SELECT c.concepto, c.axo, c.mes, c.importe_pagar, c.recargos_pagar, c.dscto_importe, c.dscto_recargos, c.actualizacion_pagar, c.multa_pagar, c.dscto_multa
    FROM t34_conceptos c
    WHERE c.cve_tab = par_tabla AND c.id_datos = par_id_datos AND c.axo = par_aso AND c.mes = par_mes;
END;
$$ LANGUAGE plpgsql;