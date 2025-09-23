-- Stored Procedure: get_contrarecibos_by_date
-- Tipo: Report
-- Descripción: Obtiene listado de contrarecibos por fecha de ingreso
-- Generado para formulario: DM_Crbos
-- Fecha: 2025-08-27 13:33:33

-- PostgreSQL function for contrarecibos by date
CREATE OR REPLACE FUNCTION get_contrarecibos_by_date(p_fecha DATE)
RETURNS TABLE (
    ejercicio SMALLINT,
    procedencia SMALLINT,
    contrarecibo INTEGER,
    denominacion TEXT,
    importe NUMERIC(18,2),
    fecha_contrarecibo DATE,
    concepto TEXT,
    notas TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.ejercicio, a.procedencia, a.contrarecibo, b.denominacion, a.importe, a.fecha_contrarecibo, a.concepto, a.notas
    FROM ta_contrarecibos a
    JOIN ta_proveedores b ON a.id_proveedor = b.id_proveedor
    WHERE a.fecha_ingreso = p_fecha
    ORDER BY a.ejercicio, a.procedencia, a.contrarecibo;
END;
$$ LANGUAGE plpgsql;