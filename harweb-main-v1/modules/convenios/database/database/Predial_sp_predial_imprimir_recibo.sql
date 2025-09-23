-- Stored Procedure: sp_predial_imprimir_recibo
-- Tipo: Report
-- Descripción: Obtiene los datos necesarios para imprimir el recibo de pago de predial
-- Generado para formulario: Predial
-- Fecha: 2025-08-27 15:16:35

CREATE OR REPLACE FUNCTION sp_predial_imprimir_recibo(
    p_cvepago INTEGER
) RETURNS TABLE (
    cvepago INTEGER,
    datos JSONB
) AS $$
DECLARE
    v_json JSONB;
BEGIN
    -- Simulación: devolver datos del pago y detalle
    SELECT row_to_json(p) INTO v_json FROM (
        SELECT * FROM pagos WHERE cvepago = p_cvepago
    ) p;
    RETURN QUERY SELECT p_cvepago, v_json;
END;
$$ LANGUAGE plpgsql;