-- Stored Procedure: sp_doctos_list
-- Tipo: Catalog
-- Descripción: Lista los documentos de un trámite
-- Generado para formulario: doctosfrm
-- Fecha: 2025-08-26 16:10:05

CREATE OR REPLACE FUNCTION sp_doctos_list(
  p_tramite_id INTEGER
) RETURNS TABLE(id INTEGER, tramite_id INTEGER, documentos TEXT, otro BOOLEAN, otro_texto TEXT, created_at TIMESTAMP, updated_at TIMESTAMP) AS $$
BEGIN
  RETURN QUERY SELECT id, tramite_id, documentos, otro, otro_texto, created_at, updated_at FROM doctos WHERE tramite_id = p_tramite_id;
END;
$$ LANGUAGE plpgsql;