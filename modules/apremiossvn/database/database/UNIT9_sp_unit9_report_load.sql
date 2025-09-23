-- Stored Procedure: sp_unit9_report_load
-- Tipo: CRUD
-- Descripción: Carga un reporte guardado desde la tabla de archivos simulada.
-- Generado para formulario: UNIT9
-- Fecha: 2025-08-27 15:18:23

CREATE OR REPLACE FUNCTION sp_unit9_report_load(filename text)
RETURNS TABLE(page_num integer, content text) AS $$
DECLARE
    report_json text;
BEGIN
    SELECT report_data INTO report_json FROM unit9_reports WHERE file_name = filename;
    IF report_json IS NULL THEN
        RAISE EXCEPTION 'Archivo no encontrado';
    END IF;
    RETURN QUERY
    SELECT (row_number() OVER()), page->>'content'
    FROM jsonb_array_elements(report_json::jsonb) AS page;
END;
$$ LANGUAGE plpgsql;