-- Stored Procedure: sp_unit9_report_preview
-- Tipo: Report
-- Descripción: Devuelve los datos de la vista previa del reporte (simulado). Cada fila representa una página HTML.
-- Generado para formulario: UNIT9
-- Fecha: 2025-08-27 15:18:23

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