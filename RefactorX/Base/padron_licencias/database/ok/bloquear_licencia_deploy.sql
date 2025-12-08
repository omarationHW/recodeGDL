-- ============================================
-- STORED PROCEDURES - BloquearLicenciafrm
-- Módulo: padron_licencias
-- Base de Datos: padron_licencias
-- Esquemas: public, comun
-- Fecha: 2025-11-20
-- Total SPs: 4
-- ============================================

-- Tablas involucradas:
--   - licencias (comun)
--   - bloqueo (public)
--   - bloqueo_dom (public)
--   - h_bloqueo_dom (public)

-- ============================================
-- SP 1/4: sp_buscar_licencia
-- Tipo: Búsqueda
-- Descripción: Busca una licencia por su número
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_buscar_licencia(p_numero_licencia INTEGER)
RETURNS TABLE (
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    ubicacion VARCHAR,
    numext_ubic VARCHAR,
    letraext_ubic VARCHAR,
    numint_ubic VARCHAR,
    letraint_ubic VARCHAR,
    cvecalle INTEGER,
    bloqueado SMALLINT,
    vigente CHAR,
    fecha_otorgamiento DATE,
    domicilio_completo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_licencia,
        l.licencia,
        l.propietario,
        l.rfc,
        l.ubicacion,
        l.numext_ubic,
        l.letraext_ubic,
        l.numint_ubic,
        l.letraint_ubic,
        l.cvecalle,
        l.bloqueado,
        l.vigente,
        l.fecha_otorgamiento,
        TRIM(COALESCE(l.ubicacion, '')) || ' No. ext.:' || COALESCE(l.numext_ubic, '') ||
        ' Letra ext. ' || COALESCE(l.letraext_ubic, '') ||
        ' No. int.' || COALESCE(l.numint_ubic, '') ||
        ' Letra int. ' || COALESCE(l.letraint_ubic, '') AS domicilio_completo
    FROM comun.licencias l
    WHERE l.licencia = p_numero_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/4: sp_consultar_bloqueos_licencia
-- Tipo: Consulta
-- Descripción: Consulta historial de bloqueos de una licencia
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consultar_bloqueos_licencia(p_id_licencia INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    id_licencia INTEGER,
    bloqueado SMALLINT,
    capturista VARCHAR,
    fecha_mov DATE,
    observa VARCHAR,
    vigente CHAR,
    tipo_bloqueo VARCHAR,
    estado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.id_tramite,
        b.id_licencia,
        b.bloqueado,
        b.capturista,
        b.fecha_mov,
        b.observa,
        b.vigente,
        CASE
            WHEN b.bloqueado = 1 THEN 'ADMINISTRATIVO'
            WHEN b.bloqueado = 2 THEN 'JURIDICO'
            WHEN b.bloqueado = 3 THEN 'FISCAL'
            WHEN b.bloqueado = 4 THEN 'TECNICO'
            WHEN b.bloqueado = 5 THEN 'RESPONSIVA'
            WHEN b.bloqueado = 0 THEN 'DESBLOQUEADO'
            ELSE 'OTRO'
        END AS tipo_bloqueo,
        CASE
            WHEN b.vigente = 'V' AND b.bloqueado > 0 THEN 'BLOQUEADO'
            WHEN b.vigente = 'C' THEN 'CANCELADO'
            ELSE 'DESBLOQUEADO'
        END AS estado
    FROM public.bloqueo b
    WHERE b.id_licencia = p_id_licencia
    ORDER BY b.fecha_mov DESC, b.id_tramite DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/4: sp_bloquear_licencia
-- Tipo: ABC (Create/Update)
-- Descripción: Bloquea una licencia y registra el movimiento
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_bloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo SMALLINT,
    p_observaciones VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE (success BOOLEAN, message VARCHAR) AS $$
DECLARE
    v_bloqueado SMALLINT;
    v_ubicacion VARCHAR;
    v_cvecalle INTEGER;
    v_numext VARCHAR;
    v_numint VARCHAR;
    v_letext VARCHAR;
    v_letint VARCHAR;
    v_count_bloqueos INTEGER;
BEGIN
    -- Verificar si existe la licencia
    SELECT l.bloqueado, l.ubicacion, l.cvecalle, l.numext_ubic, l.numint_ubic, l.letraext_ubic, l.letraint_ubic
    INTO v_bloqueado, v_ubicacion, v_cvecalle, v_numext, v_numint, v_letext, v_letint
    FROM comun.licencias l
    WHERE l.id_licencia = p_id_licencia;

    IF v_bloqueado IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe la licencia especificada';
        RETURN;
    END IF;

    IF v_bloqueado > 0 THEN
        RETURN QUERY SELECT FALSE, 'La licencia ya está bloqueada';
        RETURN;
    END IF;

    -- Actualizar estado de la licencia
    UPDATE comun.licencias
    SET bloqueado = p_tipo_bloqueo
    WHERE id_licencia = p_id_licencia;

    -- Cancelar bloqueos vigentes del mismo tipo
    UPDATE public.bloqueo
    SET vigente = 'C'
    WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado = p_tipo_bloqueo;

    -- Registrar nuevo bloqueo
    INSERT INTO public.bloqueo (
        bloqueado,
        id_licencia,
        observa,
        capturista,
        fecha_mov,
        vigente
    )
    VALUES (
        p_tipo_bloqueo,
        p_id_licencia,
        p_observaciones,
        p_usuario,
        CURRENT_DATE,
        'V'
    );

    -- Si no es responsiva (5), bloquear domicilio si es el primer bloqueo
    IF p_tipo_bloqueo <> 5 THEN
        SELECT COUNT(*) INTO v_count_bloqueos
        FROM public.bloqueo
        WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado > 0;

        IF v_count_bloqueos = 1 THEN
            INSERT INTO public.bloqueo_dom (
                calle, cvecalle, num_ext, let_ext, num_int, let_int,
                observacion, vig, fecha, capturista
            )
            VALUES (
                v_ubicacion, v_cvecalle, v_numext, v_letext, v_numint, v_letint,
                p_observaciones, 'V', CURRENT_DATE, p_usuario
            );
        END IF;
    END IF;

    RETURN QUERY SELECT TRUE, 'Licencia bloqueada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/4: sp_desbloquear_licencia
-- Tipo: ABC (Update)
-- Descripción: Desbloquea una licencia
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_desbloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo SMALLINT,
    p_observaciones VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE (success BOOLEAN, message VARCHAR) AS $$
DECLARE
    v_bloqueado SMALLINT;
    v_ubicacion VARCHAR;
    v_numext VARCHAR;
    v_letext VARCHAR;
    v_numint VARCHAR;
    v_letint VARCHAR;
    v_count_bloqueos INTEGER;
    v_ultimo_bloqueo SMALLINT;
BEGIN
    -- Verificar si existe la licencia
    SELECT l.bloqueado, l.ubicacion, l.numext_ubic, l.letraext_ubic, l.numint_ubic, l.letraint_ubic
    INTO v_bloqueado, v_ubicacion, v_numext, v_letext, v_numint, v_letint
    FROM comun.licencias l
    WHERE l.id_licencia = p_id_licencia;

    IF v_bloqueado IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe la licencia especificada';
        RETURN;
    END IF;

    IF v_bloqueado = 0 THEN
        RETURN QUERY SELECT FALSE, 'La licencia no está bloqueada';
        RETURN;
    END IF;

    -- Cancelar el bloqueo vigente de ese tipo
    UPDATE public.bloqueo
    SET vigente = 'C'
    WHERE id_licencia = p_id_licencia AND bloqueado = p_tipo_bloqueo AND vigente = 'V';

    -- Verificar si quedan bloqueos activos
    SELECT COUNT(*) INTO v_count_bloqueos
    FROM public.bloqueo
    WHERE id_licencia = p_id_licencia AND vigente = 'V' AND bloqueado > 0;

    IF v_count_bloqueos = 0 THEN
        -- No quedan bloqueos, desbloquear completamente
        UPDATE comun.licencias SET bloqueado = 0 WHERE id_licencia = p_id_licencia;
    ELSE
        -- Quedan bloqueos, actualizar al último bloqueo vigente
        SELECT bloqueado INTO v_ultimo_bloqueo
        FROM public.bloqueo
        WHERE id_licencia = p_id_licencia AND vigente = 'V'
        ORDER BY fecha_mov DESC LIMIT 1;

        UPDATE comun.licencias SET bloqueado = v_ultimo_bloqueo WHERE id_licencia = p_id_licencia;
    END IF;

    -- Registrar desbloqueo
    INSERT INTO public.bloqueo (
        bloqueado,
        id_licencia,
        observa,
        capturista,
        fecha_mov,
        vigente
    )
    VALUES (
        0,
        p_id_licencia,
        p_observaciones,
        p_usuario,
        CURRENT_DATE,
        'V'
    );

    -- Si no quedan bloqueos, eliminar domicilio bloqueado
    IF v_count_bloqueos = 0 THEN
        -- Guardar histórico
        INSERT INTO public.h_bloqueo_dom
        SELECT bd.*, CURRENT_DATE, p_observaciones, 'EL', p_usuario
        FROM public.bloqueo_dom bd
        WHERE bd.calle = v_ubicacion
        AND (bd.num_ext = v_numext OR (bd.num_ext IS NULL AND v_numext IS NULL))
        AND (bd.let_ext = v_letext OR (bd.let_ext IS NULL AND v_letext IS NULL))
        AND (bd.num_int = v_numint OR (bd.num_int IS NULL AND v_numint IS NULL))
        AND (bd.let_int = v_letint OR (bd.let_int IS NULL AND v_letint IS NULL));

        -- Eliminar
        DELETE FROM public.bloqueo_dom
        WHERE calle = v_ubicacion
        AND (num_ext = v_numext OR (num_ext IS NULL AND v_numext IS NULL))
        AND (let_ext = v_letext OR (let_ext IS NULL AND v_letext IS NULL))
        AND (num_int = v_numint OR (num_int IS NULL AND v_numint IS NULL))
        AND (let_int = v_letint OR (let_int IS NULL AND v_letint IS NULL));
    END IF;

    RETURN QUERY SELECT TRUE, 'Licencia desbloqueada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VERIFICACIÓN
-- ============================================

SELECT 'Funciones creadas correctamente' as status;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
