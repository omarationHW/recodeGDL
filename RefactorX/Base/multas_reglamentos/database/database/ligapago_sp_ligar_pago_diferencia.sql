-- Stored Procedure: sp_ligar_pago_diferencia
-- Tipo: CRUD
-- Descripción: Liga un pago a un folio de diferencia de transmisión patrimonial
-- Generado para formulario: ligapago
-- Fecha: 2025-08-27 12:41:30

CREATE OR REPLACE FUNCTION sp_ligar_pago_diferencia(
    p_cvepago INTEGER,
    p_cvecuenta INTEGER,
    p_usuario TEXT,
    p_folio INTEGER,
    p_fecha DATE DEFAULT NULL
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_exento TEXT;
    v_vigente TEXT;
BEGIN
    SELECT exento, vigente INTO v_exento, v_vigente FROM cuentas WHERE cvecuenta = p_cvecuenta;
    IF v_exento = 'S' THEN
        RETURN QUERY SELECT 'Cuenta exenta. No puede usar esta opción';
        RETURN;
    END IF;
    IF v_vigente = 'C' THEN
        RETURN QUERY SELECT 'Cuenta cancelada. No puede usar esta opción';
        RETURN;
    END IF;
    UPDATE diferencias SET cvepago = p_cvepago, usuario = p_usuario, fecha_pago = COALESCE(p_fecha, NOW())
    WHERE folio = p_folio AND cvecuenta = p_cvecuenta AND cvepago IS NULL;
    RETURN QUERY SELECT 'Pago ligado a diferencia de transmisión';
END;
$$ LANGUAGE plpgsql;