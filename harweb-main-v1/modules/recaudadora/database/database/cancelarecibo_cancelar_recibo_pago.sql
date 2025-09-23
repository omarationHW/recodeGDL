-- Stored Procedure: cancelar_recibo_pago
-- Tipo: CRUD
-- Descripción: Cancela un recibo de pago, ejecutando la lógica de negocio según el tipo de concepto y registrando la cancelación.
-- Generado para formulario: cancelarecibo
-- Fecha: 2025-08-26 23:05:38

CREATE OR REPLACE FUNCTION cancelar_recibo_pago(
    p_cvepago INTEGER,
    p_cvecuenta INTEGER,
    p_cveconcepto INTEGER,
    p_user_name TEXT,
    p_fecha_cancelacion DATE
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Si concepto = 6 o 7 (multas), actualizar reqmultas
    IF p_cveconcepto = 6 OR p_cveconcepto = 7 THEN
        UPDATE reqmultas SET vigencia = 'V', cvepago = NULL WHERE cvepago = p_cvepago;
    END IF;
    -- Si concepto = 8 (licencias), ejecutar procedimiento de cancelación de licencia
    IF p_cveconcepto = 8 THEN
        -- Suponiendo que existe un procedimiento similar en PostgreSQL
        PERFORM canc_plicencia(p_cvepago, p_cvecuenta);
    END IF;
    -- Registrar la cancelación en pagoscan
    INSERT INTO pagoscan (cvepago, autorizo, fechacan)
    VALUES (p_cvepago, p_user_name, p_fecha_cancelacion);
    -- Marcar el pago como cancelado (si aplica en la tabla pagos)
    UPDATE pagos SET cvecanc = (SELECT currval(pg_get_serial_sequence('pagoscan','cvecanc'))) WHERE cvepago = p_cvepago;
    RETURN QUERY SELECT TRUE, 'Recibo cancelado correctamente.';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al cancelar el recibo: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;