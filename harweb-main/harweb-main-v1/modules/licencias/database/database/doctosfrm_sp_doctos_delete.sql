-- Stored Procedure: sp_doctos_delete
-- Tipo: CRUD
-- Descripción: Elimina el registro de documentos de un trámite
-- Generado para formulario: doctosfrm
-- Fecha: 2025-08-26 16:10:05

CREATE OR REPLACE FUNCTION sp_doctos_delete(
  p_id INTEGER
) RETURNS TABLE(id INTEGER, deleted BOOLEAN) AS $$
BEGIN
  DELETE FROM doctos WHERE id = p_id RETURNING id, TRUE;
END;
$$ LANGUAGE plpgsql;