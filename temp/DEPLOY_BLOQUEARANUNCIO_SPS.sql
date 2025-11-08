-- ============================================
-- STORED PROCEDURES PARA BLOQUEAR/DESBLOQUEAR ANUNCIO
-- Componente: BloquearAnunciorm.vue
-- Fecha: 2025-11-06
-- Descripción: Gestión de bloqueos de anuncios publicitarios
-- ============================================

-- NOTA: Requiere tabla bloqueos_anuncios con estructura:
-- CREATE TABLE IF NOT EXISTS comun.bloqueos_anuncios (
--     id_bloqueo SERIAL PRIMARY KEY,
--     anuncio INTEGER NOT NULL,
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
-- SP 1/4: sp_bloquearanuncio_get_anuncio
-- Descripción: Obtiene información del anuncio
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloquearanuncio_get_anuncio(
    p_anuncio INTEGER
)
RETURNS TABLE (
    anuncio INTEGER,
    licencia INTEGER,
    tipo_anuncio VARCHAR,
    dimensiones NUMERIC,
    ubicacion VARCHAR,
    vigente BOOLEAN,
    propietario VARCHAR,
    fecha_alta DATE,
    fecha_vencimiento DATE,
    descripcion TEXT,
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.anuncio::INTEGER,
        a.id_licencia::INTEGER as licencia,
        COALESCE(a.id_giro::VARCHAR, 'N/A')::VARCHAR as tipo_anuncio,
        COALESCE(a.area_anuncio, 0)::NUMERIC as dimensiones,
        TRIM(COALESCE(a.ubicacion, ''))::VARCHAR,
        COALESCE(a.vigente = 'V', FALSE)::BOOLEAN,
        TRIM(TRIM(COALESCE(l.primer_ap, '')) || ' ' ||
             TRIM(COALESCE(l.segundo_ap, '')) || ' ' ||
             TRIM(COALESCE(l.propietario, '')))::VARCHAR as propietario,
        a.fecha_otorgamiento::DATE as fecha_alta,
        NULL::DATE as fecha_vencimiento,
        TRIM(COALESCE(a.texto_anuncio, ''))::TEXT as descripcion,
        ''::TEXT as observaciones
    FROM comun.anuncios a
    LEFT JOIN comun.licencias l ON a.id_licencia = l.licencia
    WHERE a.anuncio = p_anuncio
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/4: sp_bloquearanuncio_get_bloqueos
-- Descripción: Obtiene historial de bloqueos del anuncio
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloquearanuncio_get_bloqueos(
    p_anuncio INTEGER
)
RETURNS TABLE (
    id_bloqueo INTEGER,
    anuncio INTEGER,
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
        b.anuncio::INTEGER,
        b.tipo::VARCHAR,
        b.motivo_bloqueo::TEXT,
        b.fecha_bloqueo::TIMESTAMP,
        b.usuario_bloqueo::VARCHAR,
        b.motivo_desbloqueo::TEXT,
        b.fecha_desbloqueo::TIMESTAMP,
        b.usuario_desbloqueo::VARCHAR,
        b.activo::BOOLEAN
    FROM comun.bloqueos_anuncios b
    WHERE b.anuncio = p_anuncio
    ORDER BY b.fecha_bloqueo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/4: sp_bloquearanuncio_bloquear
-- Descripción: Registra un bloqueo en el anuncio
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloquearanuncio_bloquear(
    p_anuncio INTEGER,
    p_tipo VARCHAR,
    p_motivo TEXT,
    p_usuario VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_anuncio_exists INTEGER;
    v_bloqueo_activo INTEGER;
BEGIN
    -- Verificar que el anuncio existe
    SELECT COUNT(*) INTO v_anuncio_exists
    FROM comun.anuncios
    WHERE anuncio = p_anuncio;

    IF v_anuncio_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio no existe'::TEXT;
        RETURN;
    END IF;

    -- Verificar que no tenga un bloqueo activo
    SELECT COUNT(*) INTO v_bloqueo_activo
    FROM comun.bloqueos_anuncios
    WHERE anuncio = p_anuncio AND activo = TRUE;

    IF v_bloqueo_activo > 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio ya tiene un bloqueo activo'::TEXT;
        RETURN;
    END IF;

    -- Insertar el bloqueo
    INSERT INTO comun.bloqueos_anuncios (
        anuncio,
        tipo,
        motivo_bloqueo,
        fecha_bloqueo,
        usuario_bloqueo,
        activo
    )
    VALUES (
        p_anuncio,
        p_tipo,
        p_motivo,
        CURRENT_TIMESTAMP,
        p_usuario,
        TRUE
    );

    RETURN QUERY SELECT TRUE, 'Anuncio bloqueado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/4: sp_bloquearanuncio_desbloquear
-- Descripción: Desbloquea un anuncio
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloquearanuncio_desbloquear(
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
    FROM comun.bloqueos_anuncios
    WHERE id_bloqueo = p_id_bloqueo AND activo = TRUE;

    IF v_bloqueo_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El bloqueo no existe o ya fue desbloqueado'::TEXT;
        RETURN;
    END IF;

    -- Actualizar el bloqueo
    UPDATE comun.bloqueos_anuncios
    SET
        motivo_desbloqueo = p_motivo_desbloqueo,
        fecha_desbloqueo = CURRENT_TIMESTAMP,
        usuario_desbloqueo = p_usuario,
        activo = FALSE
    WHERE id_bloqueo = p_id_bloqueo AND activo = TRUE;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    IF v_updated > 0 THEN
        RETURN QUERY SELECT TRUE, 'Anuncio desbloqueado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Error al desbloquear el anuncio'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
