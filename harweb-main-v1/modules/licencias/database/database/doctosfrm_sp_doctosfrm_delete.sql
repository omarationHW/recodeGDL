-- Stored Procedure: sp_doctosfrm_delete
-- Tipo: CRUD
-- Descripción: Elimina un documento específico de la selección de un trámite.
-- Generado para formulario: doctosfrm
-- Fecha: 2025-08-27 17:40:17

CREATE OR REPLACE FUNCTION sp_doctosfrm_delete(p_tramite_id integer, p_documento text)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  UPDATE doctosfrm_tramite
    SET documentos = array_remove(documentos, p_documento)
    WHERE tramite_id = p_tramite_id;
  RETURN QUERY SELECT true, 'Documento eliminado';
END;
$$ LANGUAGE plpgsql;