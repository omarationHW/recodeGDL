-- ============================================
-- STORED PROCEDURES PARA BLOQUEO DE DOMICILIOS
-- Componente: bloqueoDomiciliosfrm.vue
-- Fecha: 2025-11-06
-- Descripción: Gestión de bloqueos de Licencias, Anuncios y Trámites
-- ============================================

-- ============================================
-- SP 1/4: sp_bloqueodomicilios_list
-- Descripción: Lista bloqueos con filtros y paginación
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 10,
    p_tipo VARCHAR DEFAULT NULL,
    p_estado VARCHAR DEFAULT NULL,
    p_vigente VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    tipo_registro VARCHAR,
    numero_registro INTEGER,
    bloqueado INTEGER,
    vigente VARCHAR,
    fecha_mov TIMESTAMP,
    capturista VARCHAR,
    observa VARCHAR,
    total_count BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    RETURN QUERY
    WITH bloqueos_unificados AS (
        -- Bloqueos de Licencias
        SELECT
            'Licencia'::VARCHAR as tipo_registro,
            id_licencia::INTEGER as numero_registro,
            CASE WHEN bloqueado = 'S' THEN 1 ELSE 0 END as bloqueado,
            vigente::VARCHAR,
            fecha::TIMESTAMP as fecha_mov,
            capturista::VARCHAR,
            observa::VARCHAR
        FROM comun.licencias
        WHERE bloqueado IS NOT NULL
            AND (p_tipo IS NULL OR p_tipo = '' OR p_tipo = 'Licencia')
            AND (p_vigente IS NULL OR p_vigente = '' OR vigente = p_vigente)
            AND (p_estado IS NULL OR p_estado = '' OR
                (p_estado = 'bloqueado' AND bloqueado = 'S') OR
                (p_estado = 'desbloqueado' AND bloqueado = 'N'))

        UNION ALL

        -- Bloqueos de Anuncios
        SELECT
            'Anuncio'::VARCHAR as tipo_registro,
            anuncio::INTEGER as numero_registro,
            CASE WHEN bloqueado = 'S' THEN 1 ELSE 0 END as bloqueado,
            vigente::VARCHAR,
            fecha::TIMESTAMP as fecha_mov,
            capturista::VARCHAR,
            observa::VARCHAR
        FROM comun.anuncios
        WHERE bloqueado IS NOT NULL
            AND (p_tipo IS NULL OR p_tipo = '' OR p_tipo = 'Anuncio')
            AND (p_vigente IS NULL OR p_vigente = '' OR vigente = p_vigente)
            AND (p_estado IS NULL OR p_estado = '' OR
                (p_estado = 'bloqueado' AND bloqueado = 'S') OR
                (p_estado = 'desbloqueado' AND bloqueado = 'N'))

        UNION ALL

        -- Bloqueos de Trámites
        SELECT
            'Tramite'::VARCHAR as tipo_registro,
            folio::INTEGER as numero_registro,
            CASE WHEN bloqueado = 'S' THEN 1 ELSE 0 END as bloqueado,
            vigente::VARCHAR,
            fecha::TIMESTAMP as fecha_mov,
            capturista::VARCHAR,
            observa::VARCHAR
        FROM comun.tramites
        WHERE bloqueado IS NOT NULL
            AND (p_tipo IS NULL OR p_tipo = '' OR p_tipo = 'Tramite')
            AND (p_vigente IS NULL OR p_vigente = '' OR vigente = p_vigente)
            AND (p_estado IS NULL OR p_estado = '' OR
                (p_estado = 'bloqueado' AND bloqueado = 'S') OR
                (p_estado = 'desbloqueado' AND bloqueado = 'N'))
    ),
    total AS (
        SELECT COUNT(*) as cnt FROM bloqueos_unificados
    )
    SELECT
        b.tipo_registro,
        b.numero_registro,
        b.bloqueado,
        b.vigente,
        b.fecha_mov,
        b.capturista,
        b.observa,
        t.cnt as total_count
    FROM bloqueos_unificados b
    CROSS JOIN total t
    ORDER BY b.fecha_mov DESC
    LIMIT p_page_size
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/4: sp_bloqueodomicilios_create
-- Descripción: Crear nuevo bloqueo
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_create(
    p_tipo VARCHAR,
    p_id_registro INTEGER,
    p_observa VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que el registro existe según el tipo
    IF p_tipo = 'Licencia' THEN
        SELECT COUNT(*) INTO v_exists FROM comun.licencias WHERE id_licencia = p_id_registro;
        IF v_exists = 0 THEN
            RETURN QUERY SELECT FALSE, 'La licencia no existe'::VARCHAR;
            RETURN;
        END IF;

        -- Actualizar bloqueo en licencias
        UPDATE comun.licencias
        SET bloqueado = 'S',
            observa = p_observa,
            capturista = p_usuario,
            fecha = CURRENT_TIMESTAMP
        WHERE id_licencia = p_id_registro;

    ELSIF p_tipo = 'Anuncio' THEN
        SELECT COUNT(*) INTO v_exists FROM comun.anuncios WHERE anuncio = p_id_registro;
        IF v_exists = 0 THEN
            RETURN QUERY SELECT FALSE, 'El anuncio no existe'::VARCHAR;
            RETURN;
        END IF;

        -- Actualizar bloqueo en anuncios
        UPDATE comun.anuncios
        SET bloqueado = 'S',
            observa = p_observa,
            capturista = p_usuario,
            fecha = CURRENT_TIMESTAMP
        WHERE anuncio = p_id_registro;

    ELSIF p_tipo = 'Tramite' THEN
        SELECT COUNT(*) INTO v_exists FROM comun.tramites WHERE folio = p_id_registro;
        IF v_exists = 0 THEN
            RETURN QUERY SELECT FALSE, 'El trámite no existe'::VARCHAR;
            RETURN;
        END IF;

        -- Actualizar bloqueo en trámites
        UPDATE comun.tramites
        SET bloqueado = 'S',
            observa = p_observa,
            capturista = p_usuario,
            fecha = CURRENT_TIMESTAMP
        WHERE folio = p_id_registro;

    ELSE
        RETURN QUERY SELECT FALSE, 'Tipo de registro inválido'::VARCHAR;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'Bloqueo registrado exitosamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/4: sp_bloqueodomicilios_update
-- Descripción: Actualizar bloqueo existente
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_update(
    p_tipo VARCHAR,
    p_id_registro INTEGER,
    p_bloqueado INTEGER,
    p_observa VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_exists INTEGER;
    v_bloqueado_char VARCHAR(1);
BEGIN
    -- Convertir el valor numérico a caracter
    v_bloqueado_char := CASE WHEN p_bloqueado = 1 THEN 'S' ELSE 'N' END;

    -- Actualizar según el tipo
    IF p_tipo = 'Licencia' THEN
        SELECT COUNT(*) INTO v_exists FROM comun.licencias WHERE id_licencia = p_id_registro;
        IF v_exists = 0 THEN
            RETURN QUERY SELECT FALSE, 'La licencia no existe'::VARCHAR;
            RETURN;
        END IF;

        UPDATE comun.licencias
        SET bloqueado = v_bloqueado_char,
            observa = p_observa,
            fecha = CURRENT_TIMESTAMP
        WHERE id_licencia = p_id_registro;

    ELSIF p_tipo = 'Anuncio' THEN
        SELECT COUNT(*) INTO v_exists FROM comun.anuncios WHERE anuncio = p_id_registro;
        IF v_exists = 0 THEN
            RETURN QUERY SELECT FALSE, 'El anuncio no existe'::VARCHAR;
            RETURN;
        END IF;

        UPDATE comun.anuncios
        SET bloqueado = v_bloqueado_char,
            observa = p_observa,
            fecha = CURRENT_TIMESTAMP
        WHERE anuncio = p_id_registro;

    ELSIF p_tipo = 'Tramite' THEN
        SELECT COUNT(*) INTO v_exists FROM comun.tramites WHERE folio = p_id_registro;
        IF v_exists = 0 THEN
            RETURN QUERY SELECT FALSE, 'El trámite no existe'::VARCHAR;
            RETURN;
        END IF;

        UPDATE comun.tramites
        SET bloqueado = v_bloqueado_char,
            observa = p_observa,
            fecha = CURRENT_TIMESTAMP
        WHERE folio = p_id_registro;

    ELSE
        RETURN QUERY SELECT FALSE, 'Tipo de registro inválido'::VARCHAR;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'Bloqueo actualizado exitosamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/4: sp_bloqueodomicilios_cancel
-- Descripción: Cancelar bloqueo (cambiar vigencia a 'C')
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_cancel(
    p_tipo VARCHAR,
    p_id_registro INTEGER,
    p_motivo VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Cancelar según el tipo
    IF p_tipo = 'Licencia' THEN
        SELECT COUNT(*) INTO v_exists FROM comun.licencias WHERE id_licencia = p_id_registro;
        IF v_exists = 0 THEN
            RETURN QUERY SELECT FALSE, 'La licencia no existe'::VARCHAR;
            RETURN;
        END IF;

        UPDATE comun.licencias
        SET vigente = 'C',
            observa = COALESCE(observa || ' | ', '') || 'CANCELADO: ' || p_motivo,
            fecha = CURRENT_TIMESTAMP
        WHERE id_licencia = p_id_registro;

    ELSIF p_tipo = 'Anuncio' THEN
        SELECT COUNT(*) INTO v_exists FROM comun.anuncios WHERE anuncio = p_id_registro;
        IF v_exists = 0 THEN
            RETURN QUERY SELECT FALSE, 'El anuncio no existe'::VARCHAR;
            RETURN;
        END IF;

        UPDATE comun.anuncios
        SET vigente = 'C',
            observa = COALESCE(observa || ' | ', '') || 'CANCELADO: ' || p_motivo,
            fecha = CURRENT_TIMESTAMP
        WHERE anuncio = p_id_registro;

    ELSIF p_tipo = 'Tramite' THEN
        SELECT COUNT(*) INTO v_exists FROM comun.tramites WHERE folio = p_id_registro;
        IF v_exists = 0 THEN
            RETURN QUERY SELECT FALSE, 'El trámite no existe'::VARCHAR;
            RETURN;
        END IF;

        UPDATE comun.tramites
        SET vigente = 'C',
            observa = COALESCE(observa || ' | ', '') || 'CANCELADO: ' || p_motivo,
            fecha = CURRENT_TIMESTAMP
        WHERE folio = p_id_registro;

    ELSE
        RETURN QUERY SELECT FALSE, 'Tipo de registro inválido'::VARCHAR;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'Bloqueo cancelado exitosamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
