-- ============================================
-- STORED PROCEDURES - BloquearTramitefrm
-- Módulo: padron_licencias
-- Base de Datos: padron_licencias
-- Esquemas: public, comun
-- Fecha: 2025-11-20
-- Total SPs: 5
-- ============================================

-- Tablas involucradas:
--   - tramites (comun)
--   - bloqueo (public)
--   - c_giros (comun)

-- ============================================
-- SP 1/5: sp_buscar_tramite
-- Tipo: Búsqueda
-- Descripción: Busca un trámite por ID
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_buscar_tramite(p_id_tramite INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    id_giro INTEGER,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR,
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    numint_ubic VARCHAR,
    letraext_ubic VARCHAR,
    letraint_ubic VARCHAR,
    estatus VARCHAR,
    bloqueado SMALLINT,
    feccap DATE,
    capturista VARCHAR,
    observaciones TEXT,
    domicilio_completo VARCHAR,
    propietario_completo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        t.tipo_tramite,
        t.id_giro,
        t.zona,
        t.subzona,
        t.actividad,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.rfc,
        t.curp,
        t.ubicacion,
        t.numext_ubic,
        t.numint_ubic,
        t.letraext_ubic,
        t.letraint_ubic,
        t.estatus,
        t.bloqueado,
        t.feccap,
        t.capturista,
        t.observaciones,
        TRIM(COALESCE(t.ubicacion, '')) || ' No. ext.:' || COALESCE(t.numext_ubic::TEXT, '') ||
        ' Letra ext. ' || COALESCE(t.letraext_ubic, '') ||
        ' No. int.' || COALESCE(t.numint_ubic, '') ||
        ' Letra int. ' || COALESCE(t.letraint_ubic, '') AS domicilio_completo,
        TRIM(COALESCE(t.primer_ap, '') || ' ' || COALESCE(t.segundo_ap, '') || ' ' || COALESCE(t.propietario, '')) AS propietario_completo
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/5: sp_get_giro_descripcion
-- Tipo: Catálogo
-- Descripción: Obtiene descripción del giro
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_get_giro_descripcion(p_id_giro INTEGER)
RETURNS TABLE (
    id_giro INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT g.id_giro, g.descripcion
    FROM comun.c_giros g
    WHERE g.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/5: sp_consultar_bloqueos_tramite
-- Tipo: Consulta
-- Descripción: Consulta historial de bloqueos de un trámite
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consultar_bloqueos_tramite(p_id_tramite INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    id_licencia INTEGER,
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
    WHERE b.id_tramite = p_id_tramite
    ORDER BY b.fecha_mov DESC, b.id_licencia DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/5: sp_bloquear_tramite
-- Tipo: ABC (Create/Update)
-- Descripción: Bloquea un trámite
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_bloquear_tramite(
    p_id_tramite INTEGER,
    p_observaciones VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE (success BOOLEAN, message VARCHAR) AS $$
DECLARE
    v_bloqueado SMALLINT;
BEGIN
    -- Verificar si existe el trámite
    SELECT t.bloqueado INTO v_bloqueado
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;

    IF v_bloqueado IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe el trámite especificado';
        RETURN;
    END IF;

    IF v_bloqueado > 0 THEN
        RETURN QUERY SELECT FALSE, 'El trámite ya está bloqueado';
        RETURN;
    END IF;

    -- Actualizar estado del trámite
    UPDATE comun.tramites
    SET bloqueado = 1
    WHERE id_tramite = p_id_tramite;

    -- Cancelar último bloqueo vigente
    UPDATE public.bloqueo
    SET vigente = 'C'
    WHERE id_tramite = p_id_tramite AND vigente = 'V';

    -- Registrar nuevo bloqueo
    INSERT INTO public.bloqueo (
        bloqueado,
        id_tramite,
        observa,
        capturista,
        fecha_mov,
        vigente
    )
    VALUES (
        1,
        p_id_tramite,
        p_observaciones,
        p_usuario,
        CURRENT_DATE,
        'V'
    );

    RETURN QUERY SELECT TRUE, 'Trámite bloqueado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 5/5: sp_desbloquear_tramite
-- Tipo: ABC (Update)
-- Descripción: Desbloquea un trámite
-- Esquema destino: public
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_desbloquear_tramite(
    p_id_tramite INTEGER,
    p_observaciones VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE (success BOOLEAN, message VARCHAR) AS $$
DECLARE
    v_bloqueado SMALLINT;
BEGIN
    -- Verificar si existe el trámite
    SELECT t.bloqueado INTO v_bloqueado
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;

    IF v_bloqueado IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe el trámite especificado';
        RETURN;
    END IF;

    IF v_bloqueado = 0 THEN
        RETURN QUERY SELECT FALSE, 'El trámite no está bloqueado';
        RETURN;
    END IF;

    -- Actualizar estado del trámite
    UPDATE comun.tramites
    SET bloqueado = 0
    WHERE id_tramite = p_id_tramite;

    -- Cancelar último bloqueo vigente
    UPDATE public.bloqueo
    SET vigente = 'C'
    WHERE id_tramite = p_id_tramite AND vigente = 'V';

    -- Registrar desbloqueo
    INSERT INTO public.bloqueo (
        bloqueado,
        id_tramite,
        observa,
        capturista,
        fecha_mov,
        vigente
    )
    VALUES (
        0,
        p_id_tramite,
        p_observaciones,
        p_usuario,
        CURRENT_DATE,
        'V'
    );

    RETURN QUERY SELECT TRUE, 'Trámite desbloqueado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VERIFICACIÓN
-- ============================================

SELECT 'Funciones creadas correctamente' as status;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
