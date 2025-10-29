-- Stored Procedure: carga_predio_report
-- Tipo: Report
-- Descripción: Genera un reporte detallado del predio.
-- Generado para formulario: carga
-- Fecha: 2025-08-26 15:04:18

CREATE OR REPLACE FUNCTION carga_predio_report(p_cvecuenta INTEGER)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'predio', row_to_json(c),
        'avaluos', (SELECT json_agg(row_to_json(a)) FROM avaluos a WHERE a.cvecuenta = p_cvecuenta),
        'construcciones', (SELECT json_agg(row_to_json(con)) FROM construcciones con WHERE con.cvecuenta = p_cvecuenta)
    ) INTO result
    FROM convcta c WHERE c.cvecuenta = p_cvecuenta;
    RETURN result;
END;
$$ LANGUAGE plpgsql;