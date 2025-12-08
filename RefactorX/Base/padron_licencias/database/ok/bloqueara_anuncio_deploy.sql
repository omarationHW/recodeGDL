-- ============================================
-- STORED PROCEDURES - BloquearAnunciorm
-- Módulo: padron_licencias
-- Base de Datos: padron_licencias
-- Esquemas: public, comun
-- Fecha: 2025-11-20
-- Total SPs: 4
-- ============================================

-- NOTA: Ejecutar en orden
-- Tablas involucradas:
--   - anuncios (comun)
--   - bloqueo (public)

-- ============================================
-- SP 1/4: sp_buscar_anuncio
-- Tipo: Búsqueda
-- Descripción: Busca un anuncio por su número
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_buscar_anuncio(p_numero_anuncio INTEGER)
RETURNS TABLE (
    id_anuncio INTEGER,
    anuncio INTEGER,
    id_licencia INTEGER,
    fecha_otorgamiento DATE,
    medidas1 VARCHAR,
    medidas2 VARCHAR,
    area_anuncio NUMERIC,
    ubicacion VARCHAR,
    numext_ubic VARCHAR,
    letraext_ubic VARCHAR,
    numint_ubic VARCHAR,
    letraint_ubic VARCHAR,
    bloqueado SMALLINT,
    domicilio_completo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_anuncio,
        a.anuncio,
        a.id_licencia,
        a.fecha_otorgamiento,
        a.medidas1,
        a.medidas2,
        a.area_anuncio,
        a.ubicacion,
        a.numext_ubic,
        a.letraext_ubic,
        a.numint_ubic,
        a.letraint_ubic,
        a.bloqueado,
        TRIM(COALESCE(a.ubicacion, '')) || ' No. ext.:' || COALESCE(a.numext_ubic, '') ||
        ' Letra ext. ' || COALESCE(a.letraext_ubic, '') ||
        ' No. int.' || COALESCE(a.numint_ubic, '') ||
        ' Letra int. ' || COALESCE(a.letraint_ubic, '') AS domicilio_completo
    FROM comun.anuncios a
    WHERE a.anuncio = p_numero_anuncio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/4: sp_consultar_bloqueos_anuncio
-- Tipo: Consulta
-- Descripción: Consulta historial de bloqueos de un anuncio
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consultar_bloqueos_anuncio(p_id_anuncio INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    id_licencia INTEGER,
    id_anuncio INTEGER,
    bloqueado SMALLINT,
    capturista VARCHAR,
    fecha_mov DATE,
    observa VARCHAR,
    vigente CHAR,
    estado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.id_tramite,
        b.id_licencia,
        b.id_anuncio,
        b.bloqueado,
        b.capturista,
        b.fecha_mov,
        b.observa,
        b.vigente,
        CASE
            WHEN b.bloqueado = 1 THEN 'BLOQUEADO'
            ELSE 'DESBLOQUEADO'
        END AS estado
    FROM public.bloqueo b
    WHERE b.id_anuncio = p_id_anuncio
    ORDER BY b.fecha_mov DESC, b.id_tramite DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/4: sp_bloquear_anuncio
-- Tipo: ABC (Create/Update)
-- Descripción: Bloquea un anuncio
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_bloquear_anuncio(
    p_id_anuncio INTEGER,
    p_observaciones VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE (success BOOLEAN, message VARCHAR) AS $$
DECLARE
    v_bloqueado SMALLINT;
BEGIN
    -- Verificar si existe el anuncio
    SELECT a.bloqueado INTO v_bloqueado
    FROM comun.anuncios a
    WHERE a.id_anuncio = p_id_anuncio;

    IF v_bloqueado IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe el anuncio especificado';
        RETURN;
    END IF;

    IF v_bloqueado > 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio ya está bloqueado';
        RETURN;
    END IF;

    -- Actualizar estado del anuncio
    UPDATE comun.anuncios
    SET bloqueado = 1
    WHERE id_anuncio = p_id_anuncio;

    -- Cancelar último registro vigente
    UPDATE public.bloqueo
    SET vigente = 'C'
    WHERE id_anuncio = p_id_anuncio AND vigente = 'V';

    -- Registrar nuevo bloqueo
    INSERT INTO public.bloqueo (
        bloqueado,
        id_anuncio,
        observa,
        capturista,
        fecha_mov,
        vigente
    )
    VALUES (
        1,
        p_id_anuncio,
        p_observaciones,
        p_usuario,
        CURRENT_DATE,
        'V'
    );

    RETURN QUERY SELECT TRUE, 'Anuncio bloqueado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/4: sp_desbloquear_anuncio
-- Tipo: ABC (Update)
-- Descripción: Desbloquea un anuncio
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_desbloquear_anuncio(
    p_id_anuncio INTEGER,
    p_observaciones VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE (success BOOLEAN, message VARCHAR) AS $$
DECLARE
    v_bloqueado SMALLINT;
BEGIN
    -- Verificar si existe el anuncio
    SELECT a.bloqueado INTO v_bloqueado
    FROM comun.anuncios a
    WHERE a.id_anuncio = p_id_anuncio;

    IF v_bloqueado IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe el anuncio especificado';
        RETURN;
    END IF;

    IF v_bloqueado = 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio no está bloqueado';
        RETURN;
    END IF;

    -- Actualizar estado del anuncio
    UPDATE comun.anuncios
    SET bloqueado = 0
    WHERE id_anuncio = p_id_anuncio;

    -- Cancelar último registro vigente
    UPDATE public.bloqueo
    SET vigente = 'C'
    WHERE id_anuncio = p_id_anuncio AND vigente = 'V';

    -- Registrar desbloqueo
    INSERT INTO public.bloqueo (
        bloqueado,
        id_anuncio,
        observa,
        capturista,
        fecha_mov,
        vigente
    )
    VALUES (
        0,
        p_id_anuncio,
        p_observaciones,
        p_usuario,
        CURRENT_DATE,
        'V'
    );

    RETURN QUERY SELECT TRUE, 'Anuncio desbloqueado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Verificar funciones creadas
SELECT 'Funciones creadas correctamente' as status;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
