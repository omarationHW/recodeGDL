-- Stored Procedure: sp_consulta_licencia
-- Tipo: Catalog
-- Descripción: Consulta de licencia por número
-- Generado para formulario: SGCv2
-- Fecha: 2025-08-27 19:38:17

CREATE OR REPLACE FUNCTION sp_consulta_licencia(p_licencia INTEGER)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT row_to_json(t) INTO v_result
    FROM (
        SELECT * FROM licencias WHERE licencia = p_licencia
    ) t;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;