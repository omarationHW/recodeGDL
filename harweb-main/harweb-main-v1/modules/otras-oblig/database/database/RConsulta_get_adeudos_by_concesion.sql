-- Stored Procedure: get_adeudos_by_concesion
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de un local/concesión hasta un periodo (año/mes).
-- Generado para formulario: RConsulta
-- Fecha: 2025-08-28 13:38:15

CREATE OR REPLACE FUNCTION get_adeudos_by_concesion(p_id_34_datos INTEGER, p_aso INTEGER, p_mes INTEGER)
RETURNS TABLE(
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
    SELECT concepto, axo, mes, importe_pagar, recargos_pagar, dscto_importe, dscto_recargos
    FROM cob34_rdetade_01(p_id_34_datos, p_aso, p_mes);
END;
$$ LANGUAGE plpgsql;