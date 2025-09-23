-- Stored Procedure: sp_get_centros_by_fecha
-- Tipo: Report
-- Descripción: Obtiene pagos en centros de recaudación filtrados por fecha.
-- Generado para formulario: conscentrosfrm
-- Fecha: 2025-08-27 11:54:28

CREATE OR REPLACE FUNCTION sp_get_centros_by_fecha(p_fecha DATE)
RETURNS TABLE (
    fecha DATE,
    abrevia VARCHAR,
    axo_acta INTEGER,
    num_acta INTEGER,
    num_recibo INTEGER,
    importe_pago NUMERIC(12,2),
    contribuyente VARCHAR,
    domicilio VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha, abrevia, axo_acta, num_acta, num_recibo, importe_pago, contribuyente, domicilio
    FROM centros_recaudacion_view
    WHERE fecha = p_fecha
    ORDER BY num_recibo DESC;
END;
$$ LANGUAGE plpgsql;