-- Stored Procedure: sp_adeudos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de un contrato (equivalente a cajero_exc_detalle).
-- Generado para formulario: SFRM_REPORTES_EXEC
-- Fecha: 2025-08-27 14:25:55

CREATE OR REPLACE FUNCTION sp_adeudos_detalle(p_contrato_id INT, p_axo INT, p_mes INT)
RETURNS TABLE(
    concepto VARCHAR,
    axo INT,
    mes INT,
    adeudo NUMERIC,
    recargos NUMERIC,
    descto_recgos NUMERIC,
    tipo INT,
    id_adeudo INT,
    total NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, axo, mes, adeudo, recargos, descto_recgos, tipo, id_adeudo, (adeudo + recargos) AS total
    FROM cajero_exc_detalle
    WHERE contrato_id = p_contrato_id
      AND axo = p_axo
      AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;