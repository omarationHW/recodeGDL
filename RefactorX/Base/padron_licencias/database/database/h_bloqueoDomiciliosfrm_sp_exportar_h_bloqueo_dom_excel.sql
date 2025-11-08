-- Stored Procedure: sp_exportar_h_bloqueo_dom_excel
-- Tipo: Report
-- Descripción: Genera un archivo Excel con el histórico de domicilios bloqueados según los filtros y devuelve la URL de descarga.
-- Generado para formulario: h_bloqueoDomiciliosfrm
-- Fecha: 2025-08-26 16:58:17

CREATE OR REPLACE FUNCTION sp_exportar_h_bloqueo_dom_excel(p_json JSON)
RETURNS TEXT AS $$
DECLARE
    v_file TEXT;
    -- Aquí se implementaría la lógica para generar el archivo Excel
BEGIN
    -- Lógica de generación de Excel (usando un lenguaje externo o extensión)
    -- Por ejemplo, llamar a un procedimiento que exporte la consulta a un archivo y devuelva la URL
    v_file := '/descargas/h_bloqueo_dom_' || to_char(now(), 'YYYYMMDD_HH24MISS') || '.xlsx';
    -- ...
    RETURN v_file;
END;
$$ LANGUAGE plpgsql;