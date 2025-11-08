-- Stored Procedure: sp_doctos_create
-- Tipo: CRUD
-- Descripción: Crea o guarda los documentos seleccionados para un trámite
-- Generado para formulario: doctosfrm
-- Fecha: 2025-08-26 16:10:05

CREATE OR REPLACE FUNCTION sp_doctos_create(
  p_tramite_id INTEGER,
  p_documentos JSONB,
  p_otro BOOLEAN,
  p_otro_texto TEXT
) RETURNS TABLE(id INTEGER, tramite_id INTEGER, documentos TEXT, otro BOOLEAN, otro_texto TEXT, created_at TIMESTAMP) AS $$
DECLARE
  v_id INTEGER;
BEGIN
  INSERT INTO doctos (tramite_id, documentos, otro, otro_texto, created_at)
  VALUES (
    p_tramite_id,
    array_to_string(ARRAY(SELECT jsonb_array_elements_text(p_documentos)), ', '),
    p_otro,
    p_otro_texto,
    NOW()
  ) RETURNING id, tramite_id, documentos, otro, otro_texto, created_at INTO v_id, tramite_id, documentos, otro, otro_texto, created_at;
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;