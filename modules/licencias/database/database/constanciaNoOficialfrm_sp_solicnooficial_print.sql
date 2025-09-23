-- Stored Procedure: sp_solicnooficial_print
-- Tipo: Report
-- Descripción: Genera los datos necesarios para imprimir la solicitud (puede devolver URL de PDF generado).
-- Generado para formulario: constanciaNoOficialfrm
-- Fecha: 2025-08-27 17:19:01

CREATE OR REPLACE FUNCTION sp_solicnooficial_print(
    p_axo INT,
    p_folio INT
) RETURNS TABLE(pdf_url TEXT) AS $$
DECLARE
    v_pdf_url TEXT;
BEGIN
    -- Aquí se debe implementar la lógica para generar el PDF y devolver la URL
    -- Por ejemplo, llamar a un microservicio o función interna
    v_pdf_url := '/pdf/solicnooficial/' || p_axo || '-' || p_folio || '.pdf';
    RETURN QUERY SELECT v_pdf_url;
END;
$$ LANGUAGE plpgsql;