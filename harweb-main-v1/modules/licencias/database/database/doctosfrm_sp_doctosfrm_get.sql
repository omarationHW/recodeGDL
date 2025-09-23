-- Stored Procedure: sp_doctosfrm_get
-- Tipo: CRUD
-- Descripción: Obtiene los documentos seleccionados para un trámite.
-- Generado para formulario: doctosfrm
-- Fecha: 2025-08-27 17:40:17

CREATE OR REPLACE FUNCTION sp_doctosfrm_get(p_tramite_id integer)
RETURNS TABLE(documentos text[], otro text) AS $$
BEGIN
  RETURN QUERY
    SELECT d.documentos, d.otro
    FROM doctosfrm_tramite d
    WHERE d.tramite_id = p_tramite_id;
END;
$$ LANGUAGE plpgsql;