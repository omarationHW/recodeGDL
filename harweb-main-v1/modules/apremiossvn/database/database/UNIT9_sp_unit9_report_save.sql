-- Stored Procedure: sp_unit9_report_save
-- Tipo: CRUD
-- Descripción: Guarda el reporte actual en la tabla de archivos simulada.
-- Generado para formulario: UNIT9
-- Fecha: 2025-08-27 15:18:23

CREATE OR REPLACE FUNCTION sp_unit9_report_save(filename text, report_data text)
RETURNS TABLE(result text) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM unit9_reports WHERE file_name = filename) THEN
        UPDATE unit9_reports SET report_data = report_data, updated_at = NOW() WHERE file_name = filename;
        RETURN QUERY SELECT 'Reporte actualizado';
    ELSE
        INSERT INTO unit9_reports(file_name, report_data, created_at, updated_at) VALUES (filename, report_data, NOW(), NOW());
        RETURN QUERY SELECT 'Reporte guardado';
    END IF;
END;
$$ LANGUAGE plpgsql;