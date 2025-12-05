CREATE OR REPLACE FUNCTION recaudadora_sfrm_chgpass(
    p_usuario VARCHAR,
    p_password VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    usuario TEXT
) AS $$
DECLARE
    v_exists BOOLEAN;
    v_usuario_trimmed VARCHAR;
    v_updated_count INTEGER := 0;
BEGIN
    -- Trim espacios del usuario
    v_usuario_trimmed := TRIM(p_usuario);

    -- Verificar que los parámetros no estén vacíos
    IF v_usuario_trimmed IS NULL OR v_usuario_trimmed = '' THEN
        RETURN QUERY SELECT false, 'El nombre de usuario es requerido'::TEXT, ''::TEXT;
        RETURN;
    END IF;

    IF p_password IS NULL OR p_password = '' THEN
        RETURN QUERY SELECT false, 'El nuevo password es requerido'::TEXT, v_usuario_trimmed::TEXT;
        RETURN;
    END IF;

    -- Verificar si el usuario existe en comun.usuarios
    SELECT EXISTS(
        SELECT 1 FROM comun.usuarios u WHERE TRIM(u.usuario) = v_usuario_trimmed
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN QUERY SELECT false, 'El usuario no existe en el sistema'::TEXT, v_usuario_trimmed::TEXT;
        RETURN;
    END IF;

    -- Actualizar password en comun.usuarios (columna clave)
    UPDATE comun.usuarios u
    SET clave = TRIM(p_password)
    WHERE TRIM(u.usuario) = v_usuario_trimmed;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    -- También actualizar en catastro_gdl.usuarios si existe
    UPDATE catastro_gdl.usuarios u2
    SET clave = TRIM(p_password)
    WHERE TRIM(u2.usuario) = v_usuario_trimmed;

    -- Registrar éxito
    IF v_updated_count > 0 THEN
        RETURN QUERY SELECT
            true,
            'Password actualizado exitosamente para el usuario ' || v_usuario_trimmed::TEXT,
            v_usuario_trimmed::TEXT;
    ELSE
        RETURN QUERY SELECT
            false,
            'No se pudo actualizar el password. Contacte al administrador.'::TEXT,
            v_usuario_trimmed::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            false,
            'Error al actualizar password: ' || SQLERRM,
            v_usuario_trimmed::TEXT;
END;
$$ LANGUAGE plpgsql;
