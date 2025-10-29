-- Stored Procedure: sp_alta_tramite_licencia
-- Tipo: CRUD
-- Descripción: Alta de trámite de licencia, recibe JSON con todos los datos y realiza inserción y lógica de negocio
-- Generado para formulario: SGCv2
-- Fecha: 2025-08-27 19:38:17

CREATE OR REPLACE FUNCTION sp_alta_tramite_licencia(p_json JSON)
RETURNS JSON AS $$
DECLARE
    v_id_tramite INTEGER;
    v_result JSON;
BEGIN
    -- Extraer campos del JSON y realizar inserciones en tramites, licencias, etc.
    -- Ejemplo (simplificado):
    INSERT INTO tramites (tipo_tramite, id_giro, propietario, rfc, curp, domicilio, telefono_prop, email, feccap)
    VALUES (
        (p_json->>'tipo_tramite')::INTEGER,
        (p_json->>'id_giro')::INTEGER,
        p_json->>'propietario',
        p_json->>'rfc',
        p_json->>'curp',
        p_json->>'domicilio',
        p_json->>'telefono_prop',
        p_json->>'email',
        NOW()
    ) RETURNING id_tramite INTO v_id_tramite;
    -- ... lógica adicional ...
    v_result := json_build_object('id_tramite', v_id_tramite, 'status', 'ok');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;