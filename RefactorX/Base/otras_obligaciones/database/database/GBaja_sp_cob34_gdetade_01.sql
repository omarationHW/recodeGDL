-- Stored Procedure: sp_cob34_gdetade_01
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de una concesión.
-- Generado para formulario: GBaja
-- Fecha: 2025-08-27 13:58:32

CREATE OR REPLACE FUNCTION sp_cob34_gdetade_01(par_tabla TEXT, par_id_datos INTEGER, par_aso INTEGER, par_mes INTEGER)
RETURNS TABLE (
    concepto TEXT,
    axo INTEGER,
    mes INTEGER,
    importe_pagar NUMERIC,
    recargos_pagar NUMERIC,
    dscto_importe NUMERIC,
    dscto_recargos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.concepto, c.axo, c.mes, c.importe_pagar, c.recargos_pagar, c.dscto_importe, c.dscto_recargos
    FROM t34_conceptos c
    WHERE c.cve_tab = par_tabla AND c.id_datos = par_id_datos AND c.axo = par_aso AND c.mes = par_mes;
END;
$$ LANGUAGE plpgsql;