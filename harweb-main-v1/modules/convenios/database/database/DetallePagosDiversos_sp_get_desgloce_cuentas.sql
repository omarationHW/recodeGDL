-- Stored Procedure: sp_get_desgloce_cuentas
-- Tipo: Report
-- Descripción: Obtiene el desgloce de cuentas para un id_adeudo
-- Generado para formulario: DetallePagosDiversos
-- Fecha: 2025-08-27 14:22:21

CREATE OR REPLACE FUNCTION sp_get_desgloce_cuentas(p_id_adeudo INTEGER)
RETURNS TABLE (
    importe NUMERIC(18,2),
    cuenta_apl INTEGER,
    descripcion VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT importe, cuenta_apl, descripcion
    FROM ta_17_desg_parcial
    WHERE id_adeudo = p_id_adeudo;
END;
$$ LANGUAGE plpgsql;