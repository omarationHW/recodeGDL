-- Stored Procedure: sp_doctosfrm_save
-- Tipo: CRUD
-- Descripción: Guarda los documentos seleccionados para un trámite.
-- Generado para formulario: doctosfrm
-- Fecha: 2025-08-27 17:40:17

CREATE OR REPLACE FUNCTION sp_doctosfrm_save(p_tramite_id integer, p_documentos json, p_otro text)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM doctosfrm_tramite WHERE tramite_id = p_tramite_id) THEN
    UPDATE doctosfrm_tramite
      SET documentos = ARRAY(SELECT json_array_elements_text(p_documentos)), otro = p_otro
      WHERE tramite_id = p_tramite_id;
  ELSE
    INSERT INTO doctosfrm_tramite(tramite_id, documentos, otro)
      VALUES (p_tramite_id, ARRAY(SELECT json_array_elements_text(p_documentos)), p_otro);
  END IF;
  RETURN QUERY SELECT true, 'Documentos guardados';
END;
$$ LANGUAGE plpgsql;