-- Stored Procedure: sp_get_centros_list
-- Tipo: Report
-- Descripción: Obtiene el listado general de pagos en centros de recaudación.
-- Generado para formulario: conscentrosfrm
-- Fecha: 2025-08-27 11:54:28

CREATE OR REPLACE FUNCTION sp_get_centros_list()
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
    ORDER BY fecha DESC, num_recibo DESC;
END;
$$ LANGUAGE plpgsql;