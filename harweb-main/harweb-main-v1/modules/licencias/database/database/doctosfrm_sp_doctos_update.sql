-- Stored Procedure: sp_doctos_update
-- Tipo: CRUD
-- Descripción: Actualiza los documentos de un trámite
-- Generado para formulario: doctosfrm
-- Fecha: 2025-08-26 16:10:05

CREATE OR REPLACE FUNCTION sp_doctos_update(
  p_id INTEGER,
  p_documentos JSONB,
  p_otro BOOLEAN,
  p_otro_texto TEXT
) RETURNS TABLE(id INTEGER, tramite_id INTEGER, documentos TEXT, otro BOOLEAN, otro_texto TEXT, updated_at TIMESTAMP) AS $$
BEGIN
  UPDATE doctos
  SET documentos = array_to_string(ARRAY(SELECT jsonb_array_elements_text(p_documentos)), ', '),
      otro = p_otro,
      otro_texto = p_otro_texto,
      updated_at = NOW()
  WHERE id = p_id
  RETURNING id, tramite_id, documentos, otro, otro_texto, updated_at;
END;
$$ LANGUAGE plpgsql;