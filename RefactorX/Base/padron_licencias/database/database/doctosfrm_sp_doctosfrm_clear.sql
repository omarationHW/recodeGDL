-- Stored Procedure: sp_doctosfrm_clear
-- Tipo: CRUD
-- Descripción: Limpia la selección de documentos para un trámite.
-- Generado para formulario: doctosfrm
-- Fecha: 2025-08-27 17:40:17

CREATE OR REPLACE FUNCTION sp_doctosfrm_clear(p_tramite_id integer)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  UPDATE doctosfrm_tramite SET documentos = ARRAY[]::text[], otro = NULL WHERE tramite_id = p_tramite_id;
  RETURN QUERY SELECT true, 'Selección limpiada';
END;
$$ LANGUAGE plpgsql;