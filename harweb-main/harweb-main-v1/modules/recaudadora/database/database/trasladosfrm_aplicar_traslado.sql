-- Stored Procedure: aplicar_traslado
-- Tipo: CRUD
-- Descripción: Aplica el traslado de un pago según el tipo de aplicación.
-- Generado para formulario: trasladosfrm
-- Fecha: 2025-08-27 15:54:53

CREATE OR REPLACE FUNCTION aplicar_traslado(
    pago_id BIGINT,
    tipo_aplicacion TEXT,
    usuario TEXT
) RETURNS TABLE(
    resultado TEXT
) AS $$
DECLARE
    msg TEXT;
BEGIN
    -- Lógica de aplicación según tipo_aplicacion
    IF tipo_aplicacion = 'futuros' THEN
        -- Marcar pago para futuros pagos
        UPDATE pagos SET estado = 'aplicado_futuros', usuario_aplica = usuario, fecha_aplica = NOW()
        WHERE id = pago_id;
        msg := 'Aplicado a futuros pagos';
    ELSIF tipo_aplicacion = 'saldar' THEN
        -- Saldar adeudos
        UPDATE pagos SET estado = 'saldado', usuario_aplica = usuario, fecha_aplica = NOW()
        WHERE id = pago_id;
        msg := 'Adeudos saldados';
    ELSIF tipo_aplicacion = 'devolucion' THEN
        -- Marcar para devolución
        UPDATE pagos SET estado = 'devolucion', usuario_aplica = usuario, fecha_aplica = NOW()
        WHERE id = pago_id;
        msg := 'Marcado para devolución';
    ELSE
        msg := 'Tipo de aplicación no válido';
    END IF;
    RETURN QUERY SELECT msg;
END;
$$ LANGUAGE plpgsql;