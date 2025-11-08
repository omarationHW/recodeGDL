-- ============================================
-- STORED PROCEDURES PARA BLOQUEAR/DESBLOQUEAR LICENCIA
-- Componente: BloquearLicenciafrm.vue
-- Fecha: 2025-11-06
-- Descripción: Gestión de bloqueos de licencias comerciales
-- ============================================

-- NOTA: Requiere tabla bloqueos_licencias con estructura:
-- CREATE TABLE IF NOT EXISTS comun.bloqueos_licencias (
--     id_bloqueo SERIAL PRIMARY KEY,
--     licencia INTEGER NOT NULL,
--     tipo VARCHAR(50) NOT NULL,
--     motivo_bloqueo TEXT NOT NULL,
--     fecha_bloqueo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     usuario_bloqueo VARCHAR(50) NOT NULL,
--     motivo_desbloqueo TEXT,
--     fecha_desbloqueo TIMESTAMP,
--     usuario_desbloqueo VARCHAR(50),
--     activo BOOLEAN DEFAULT TRUE
-- );

-- ============================================
-- SP 1/4: sp_bloquearlicencia_get_licencia
-- Descripción: Obtiene información de la licencia
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloquearlicencia_get_licencia(
    p_licencia INTEGER
)
RETURNS TABLE (
    licencia INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    actividad VARCHAR,
    ubicacion VARCHAR,
    vigente CHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.licencia::INTEGER,
        TRIM(TRIM(COALESCE(l.primer_ap, '')) || ' ' ||
             TRIM(COALESCE(l.segundo_ap, '')) || ' ' ||
             TRIM(COALESCE(l.propietario, '')))::VARCHAR as propietario,
        TRIM(COALESCE(l.rfc, ''))::VARCHAR,
        TRIM(COALESCE(l.actividad, ''))::VARCHAR,
        TRIM(COALESCE(l.ubicacion, ''))::VARCHAR as ubicacion,
        COALESCE(l.vigente, 'N')::CHAR
    FROM comun.licencias l
    WHERE l.licencia = p_licencia
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/4: sp_bloquearlicencia_get_bloqueos
-- Descripción: Obtiene historial de bloqueos de la licencia
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloquearlicencia_get_bloqueos(
    p_licencia INTEGER
)
RETURNS TABLE (
    id_bloqueo INTEGER,
    licencia INTEGER,
    tipo VARCHAR,
    motivo_bloqueo TEXT,
    fecha_bloqueo TIMESTAMP,
    usuario_bloqueo VARCHAR,
    motivo_desbloqueo TEXT,
    fecha_desbloqueo TIMESTAMP,
    usuario_desbloqueo VARCHAR,
    activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.id_bloqueo::INTEGER,
        b.licencia::INTEGER,
        b.tipo::VARCHAR,
        b.motivo_bloqueo::TEXT,
        b.fecha_bloqueo::TIMESTAMP,
        b.usuario_bloqueo::VARCHAR,
        b.motivo_desbloqueo::TEXT,
        b.fecha_desbloqueo::TIMESTAMP,
        b.usuario_desbloqueo::VARCHAR,
        b.activo::BOOLEAN
    FROM comun.bloqueos_licencias b
    WHERE b.licencia = p_licencia
    ORDER BY b.fecha_bloqueo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/4: sp_bloquearlicencia_bloquear
-- Descripción: Registra un bloqueo en la licencia
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloquearlicencia_bloquear(
    p_licencia INTEGER,
    p_tipo VARCHAR,
    p_motivo TEXT,
    p_usuario VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_licencia_exists INTEGER;
    v_bloqueo_activo INTEGER;
BEGIN
    -- Verificar que la licencia existe
    SELECT COUNT(*) INTO v_licencia_exists
    FROM comun.licencias
    WHERE licencia = p_licencia;

    IF v_licencia_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La licencia no existe'::TEXT;
        RETURN;
    END IF;

    -- Verificar que no tenga un bloqueo activo
    SELECT COUNT(*) INTO v_bloqueo_activo
    FROM comun.bloqueos_licencias
    WHERE licencia = p_licencia AND activo = TRUE;

    IF v_bloqueo_activo > 0 THEN
        RETURN QUERY SELECT FALSE, 'La licencia ya tiene un bloqueo activo'::TEXT;
        RETURN;
    END IF;

    -- Insertar el bloqueo
    INSERT INTO comun.bloqueos_licencias (
        licencia,
        tipo,
        motivo_bloqueo,
        fecha_bloqueo,
        usuario_bloqueo,
        activo
    )
    VALUES (
        p_licencia,
        p_tipo,
        p_motivo,
        CURRENT_TIMESTAMP,
        p_usuario,
        TRUE
    );

    RETURN QUERY SELECT TRUE, 'Licencia bloqueada exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/4: sp_bloquearlicencia_desbloquear
-- Descripción: Desbloquea una licencia
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloquearlicencia_desbloquear(
    p_id_bloqueo INTEGER,
    p_motivo_desbloqueo TEXT,
    p_usuario VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_bloqueo_exists INTEGER;
    v_updated INTEGER;
BEGIN
    -- Verificar que el bloqueo existe y está activo
    SELECT COUNT(*) INTO v_bloqueo_exists
    FROM comun.bloqueos_licencias
    WHERE id_bloqueo = p_id_bloqueo AND activo = TRUE;

    IF v_bloqueo_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El bloqueo no existe o ya fue desbloqueado'::TEXT;
        RETURN;
    END IF;

    -- Actualizar el bloqueo
    UPDATE comun.bloqueos_licencias
    SET
        motivo_desbloqueo = p_motivo_desbloqueo,
        fecha_desbloqueo = CURRENT_TIMESTAMP,
        usuario_desbloqueo = p_usuario,
        activo = FALSE
    WHERE id_bloqueo = p_id_bloqueo AND activo = TRUE;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    IF v_updated > 0 THEN
        RETURN QUERY SELECT TRUE, 'Licencia desbloqueada exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Error al desbloquear la licencia'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
