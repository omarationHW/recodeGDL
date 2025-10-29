-- Stored Procedure: dictamenusodesuelo_print
-- Tipo: Report
-- Descripción: Genera el PDF de la constancia (devuelve URL o base64)
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-27 17:38:15

CREATE OR REPLACE FUNCTION dictamenusodesuelo_print(
  p_axo INTEGER,
  p_folio INTEGER
)
RETURNS TABLE(pdf_url TEXT) AS $$
DECLARE
  url TEXT;
BEGIN
  -- Aquí se debe implementar la generación del PDF y devolver la URL o base64
  url := '/storage/constancias/' || p_axo || '-' || p_folio || '.pdf';
  RETURN QUERY SELECT url;
END;
$$ LANGUAGE plpgsql;