-- Stored Procedure: sp_cob34_gtotade_01
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos de una concesión.
-- Generado para formulario: GBaja
-- Fecha: 2025-08-27 13:58:32

CREATE OR REPLACE FUNCTION sp_cob34_gtotade_01(par_tabla TEXT, par_id_datos INTEGER, par_aso INTEGER, par_mes INTEGER)
RETURNS TABLE (
    cuenta INTEGER,
    obliga TEXT,
    concepto TEXT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cuenta, c.obliga, c.concepto, SUM(c.importe_pagar + c.recargos_pagar - c.dscto_importe - c.dscto_recargos) AS importe
    FROM t34_conceptos c
    WHERE c.cve_tab = par_tabla AND c.id_datos = par_id_datos AND c.axo = par_aso AND c.mes = par_mes
    GROUP BY c.cuenta, c.obliga, c.concepto;
END;
$$ LANGUAGE plpgsql;