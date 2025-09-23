-- Stored Procedure: sp_get_centros_by_acta
-- Tipo: Report
-- Descripción: Obtiene pagos en centros de recaudación filtrados por año y número de acta.
-- Generado para formulario: conscentrosfrm
-- Fecha: 2025-08-27 11:54:28

CREATE OR REPLACE FUNCTION sp_get_centros_by_acta(p_axo_acta INTEGER, p_num_acta INTEGER)
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
    WHERE axo_acta = p_axo_acta AND num_acta = p_num_acta
    ORDER BY fecha DESC, num_recibo DESC;
END;
$$ LANGUAGE plpgsql;