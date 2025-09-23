-- Stored Procedure: bloquear_licencia
-- Tipo: CRUD
-- Descripción: Registra el bloqueo de una licencia con tipo y motivo.
-- Generado para formulario: tipobloqueofrm
-- Fecha: 2025-08-27 19:43:00

CREATE OR REPLACE FUNCTION bloquear_licencia(
    p_tipo_bloqueo_id integer,
    p_motivo varchar,
    p_usuario_id integer,
    p_licencia_id integer
) RETURNS TABLE(success boolean, message text)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists integer;
BEGIN
    -- Validar existencia de licencia
    SELECT COUNT(*) INTO v_exists FROM licencias WHERE id = p_licencia_id;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'Licencia no encontrada.';
        RETURN;
    END IF;
    -- Validar tipo de bloqueo
    SELECT COUNT(*) INTO v_exists FROM c_tipobloqueo WHERE id = p_tipo_bloqueo_id AND sel_cons = 'S';
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'Tipo de bloqueo inválido.';
        RETURN;
    END IF;
    -- Registrar bloqueo (tabla ejemplo: bloqueos_licencia)
    INSERT INTO bloqueos_licencia (licencia_id, tipo_bloqueo_id, motivo, usuario_id, fecha)
    VALUES (p_licencia_id, p_tipo_bloqueo_id, upper(p_motivo), p_usuario_id, now());
    RETURN QUERY SELECT true, 'Bloqueo registrado correctamente.';
END;
$$;