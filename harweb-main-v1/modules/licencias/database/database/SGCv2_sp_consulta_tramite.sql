-- Stored Procedure: sp_consulta_tramite
-- Tipo: Catalog
-- Descripción: Consulta de trámite por número
-- Generado para formulario: SGCv2
-- Fecha: 2025-08-27 19:38:17

CREATE OR REPLACE FUNCTION sp_consulta_tramite(p_tramite INTEGER)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT row_to_json(t) INTO v_result
    FROM (
        SELECT * FROM tramites WHERE id_tramite = p_tramite
    ) t;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;