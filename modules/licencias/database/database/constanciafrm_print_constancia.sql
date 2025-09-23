-- Stored Procedure: print_constancia
-- Tipo: Report
-- Descripción: Genera el PDF de la constancia y retorna la URL o base64.
-- Generado para formulario: constanciafrm
-- Fecha: 2025-08-26 15:37:55

-- Este SP debe ser implementado con una herramienta de generación de PDF (ej. pg-pdfgen, o integración con Laravel). Ejemplo:
CREATE OR REPLACE FUNCTION print_constancia(p_axo integer, p_folio integer)
RETURNS TABLE(pdf_url text) AS $$
DECLARE
    v_url text;
BEGIN
    -- Aquí se debe generar el PDF y guardar en storage, luego devolver la URL
    v_url := '/storage/constancias/' || p_axo || '_' || p_folio || '.pdf';
    RETURN QUERY SELECT v_url;
END;
$$ LANGUAGE plpgsql;