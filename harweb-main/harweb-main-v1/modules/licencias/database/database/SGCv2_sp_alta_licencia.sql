-- Stored Procedure: sp_alta_licencia
-- Tipo: CRUD
-- Descripción: Registra una nueva licencia/trámite
-- Generado para formulario: SGCv2
-- Fecha: 2025-08-26 18:12:43

CREATE OR REPLACE FUNCTION sp_alta_licencia(
    p_propietario text,
    p_actividad text,
    p_cvecuenta integer,
    p_id_giro integer,
    p_zona text,
    p_subzona text,
    p_email text
) RETURNS integer AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO tramites (propietario, actividad, cvecuenta, id_giro, zona, subzona, email, estatus, feccap)
    VALUES (p_propietario, p_actividad, p_cvecuenta, p_id_giro, p_zona, p_subzona, p_email, 'T', NOW())
    RETURNING id_tramite INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;