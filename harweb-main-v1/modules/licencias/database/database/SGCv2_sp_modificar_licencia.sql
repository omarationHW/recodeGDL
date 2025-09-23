-- Stored Procedure: sp_modificar_licencia
-- Tipo: CRUD
-- Descripción: Modifica los datos de una licencia/trámite
-- Generado para formulario: SGCv2
-- Fecha: 2025-08-26 18:12:43

CREATE OR REPLACE FUNCTION sp_modificar_licencia(
    p_id_tramite integer,
    p_propietario text DEFAULT NULL,
    p_actividad text DEFAULT NULL,
    p_email text DEFAULT NULL
) RETURNS boolean AS $$
BEGIN
    UPDATE tramites SET
        propietario = COALESCE(p_propietario, propietario),
        actividad = COALESCE(p_actividad, actividad),
        email = COALESCE(p_email, email)
    WHERE id_tramite = p_id_tramite;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;