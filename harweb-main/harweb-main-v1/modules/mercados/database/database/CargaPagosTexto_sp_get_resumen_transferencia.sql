-- Stored Procedure: sp_get_resumen_transferencia
-- Tipo: Report
-- Descripción: Devuelve el resumen de una transferencia de pagos (dummy, para ejemplo de endpoint)
-- Generado para formulario: CargaPagosTexto
-- Fecha: 2025-08-26 19:06:32

-- Dummy, para ejemplo
CREATE OR REPLACE FUNCTION sp_get_resumen_transferencia(resumen_id INT)
RETURNS TABLE(grabados INT, nograbados INT, borrados INT, total INT, importe NUMERIC) AS $$
BEGIN
    RETURN QUERY SELECT 10, 2, 8, 12, 12345.67;
END;
$$ LANGUAGE plpgsql;