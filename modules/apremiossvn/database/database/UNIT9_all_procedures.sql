-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: UNIT9
-- Generado: 2025-08-27 15:18:23
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_unit9_report_preview
-- Tipo: Report
-- Descripción: Devuelve los datos de la vista previa del reporte (simulado). Cada fila representa una página HTML.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_unit9_report_preview()
RETURNS TABLE(page_num integer, content text) AS $$
BEGIN
    -- Simulación: Devuelve 3 páginas de ejemplo
    RETURN QUERY
    SELECT 1, '<h2>Reporte de Ejemplo - Página 1</h2><p>Contenido de la página 1.</p>'
    UNION ALL
    SELECT 2, '<h2>Reporte de Ejemplo - Página 2</h2><p>Contenido de la página 2.</p>'
    UNION ALL
    SELECT 3, '<h2>Reporte de Ejemplo - Página 3</h2><p>Contenido de la página 3.</p>';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_unit9_report_load
-- Tipo: CRUD
-- Descripción: Carga un reporte guardado desde la tabla de archivos simulada.
-- --------------------------------------------

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

-- ============================================

-- SP 3/4: sp_unit9_report_save
-- Tipo: CRUD
-- Descripción: Guarda el reporte actual en la tabla de archivos simulada.
-- --------------------------------------------

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

-- ============================================

-- SP 4/4: sp_unit9_report_print
-- Tipo: CRUD
-- Descripción: Simula la impresión del reporte actual.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_unit9_report_print()
RETURNS TABLE(result text) AS $$
BEGIN
    RETURN QUERY SELECT 'Impresión enviada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

