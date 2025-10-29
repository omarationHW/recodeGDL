-- Stored Procedure: requerimientos.print_requerimientos
-- Tipo: Report
-- Descripción: Genera los datos para impresión de requerimientos según fecha, recaudadora, tipo de impresión y ejecutor.
-- Generado para formulario: ipor
-- Fecha: 2025-08-27 12:29:04

CREATE OR REPLACE FUNCTION requerimientos.print_requerimientos(fecha date, recaud integer, tipo_impresion text, ejecutor_id integer)
RETURNS TABLE(
    folioreq integer,
    cveejecut integer,
    datos jsonb
) AS $$
BEGIN
    IF tipo_impresion = 'notificacion' THEN
        RETURN QUERY
        SELECT folioreq, cveejecut, to_jsonb(reqpredial.*)
        FROM reqpredial
        WHERE fecejec = fecha AND recaud = recaud AND cveejecut = ejecutor_id AND secuencia = 3;
    ELSIF tipo_impresion = 'requerimiento' THEN
        RETURN QUERY
        SELECT folioreq, cveejecut, to_jsonb(reqpredial.*)
        FROM reqpredial
        WHERE fecejec = fecha AND recaud = recaud AND cveejecut = ejecutor_id AND secuencia = 0;
    ELSE
        RETURN QUERY SELECT NULL, NULL, NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;