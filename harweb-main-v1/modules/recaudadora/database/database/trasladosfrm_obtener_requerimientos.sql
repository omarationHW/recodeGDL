-- Stored Procedure: obtener_requerimientos
-- Tipo: Catalog
-- Descripción: Obtiene los requerimientos asociados a un pago.
-- Generado para formulario: trasladosfrm
-- Fecha: 2025-08-27 15:54:53

CREATE OR REPLACE FUNCTION obtener_requerimientos(
    pago_id BIGINT
) RETURNS TABLE(
    id BIGINT,
    concepto TEXT,
    importe NUMERIC,
    estado TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.concepto, r.importe, r.estado
    FROM requerimientos r
    WHERE r.pago_id = pago_id;
END;
$$ LANGUAGE plpgsql;