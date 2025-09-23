-- Stored Procedure: get_adeudos_condonados_by_contrato
-- Tipo: Report
-- Descripción: Devuelve los adeudos condonados (status 'S') para un contrato.
-- Generado para formulario: Rep_AdeudCond
-- Fecha: 2025-08-27 15:05:40

CREATE OR REPLACE FUNCTION get_adeudos_condonados_by_contrato(
    p_control_contrato integer
)
RETURNS SETOF ta_16_pagos AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND status_vigencia = 'S';
END;
$$ LANGUAGE plpgsql;