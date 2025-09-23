-- Stored Procedure: liquidar_pago
-- Tipo: CRUD
-- Descripción: Liquida el pago seleccionado.
-- Generado para formulario: trasladosfrm
-- Fecha: 2025-08-27 15:54:53

CREATE OR REPLACE FUNCTION liquidar_pago(
    pago_id BIGINT,
    usuario TEXT
) RETURNS TABLE(
    resultado TEXT
) AS $$
DECLARE
    msg TEXT;
BEGIN
    UPDATE pagos SET estado = 'liquidado', usuario_liquida = usuario, fecha_liquida = NOW()
    WHERE id = pago_id;
    msg := 'Pago liquidado correctamente';
    RETURN QUERY SELECT msg;
END;
$$ LANGUAGE plpgsql;