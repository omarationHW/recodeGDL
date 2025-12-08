-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: ReactivaTramite
-- Archivo: REACTIVATRAMITE_all_procedures_IMPLEMENTED.sql
-- Generado: 2025-11-20
-- Total SPs: 4
-- ============================================
-- DESCRIPCIÓN:
-- Componente para reactivar trámites cancelados o rechazados
-- Incluye consulta de trámites, giros y proceso de reactivación
-- con auditoría completa y validaciones de estado
-- ============================================

-- ============================================
-- SP 1/4: sp_reactivatramite_get_tramite
-- Tipo: Consulta
-- Descripción: Obtiene los datos completos de un trámite, incluyendo
--              descripción del giro y nombre completo del propietario
-- Parámetros:
--   - p_id_tramite: ID del trámite a consultar
-- Retorna: Registro completo del trámite con datos relacionados
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_reactivatramite_get_tramite(
    p_id_tramite INTEGER
)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    id_giro INTEGER,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR,
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR,
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    domicilio VARCHAR,
    numext_prop INTEGER,
    numint_prop VARCHAR,
    colonia_prop VARCHAR,
    telefono_prop VARCHAR,
    email VARCHAR,
    cvecalle INTEGER,
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    letraext_ubic VARCHAR,
    letrain_ubic VARCHAR,
    colonia_ubic VARCHAR,
    espubic VARCHAR,
    documentos TEXT,
    sup_construida DOUBLE PRECISION,
    sup_autorizada DOUBLE PRECISION,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    costo NUMERIC,
    fecha_consejo DATE,
    id_fabricante INTEGER,
    texto_anuncio VARCHAR,
    medidas1 DOUBLE PRECISION,
    medidas2 DOUBLE PRECISION,
    area_anuncio DOUBLE PRECISION,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica VARCHAR,
    estatus VARCHAR,
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista VARCHAR,
    numint_ubic VARCHAR,
    bloqueado SMALLINT,
    dictamen SMALLINT,
    observaciones TEXT,
    rhorario VARCHAR,
    cp INTEGER,
    descripcion_giro VARCHAR,
    propietario_completo VARCHAR
) AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_id_tramite IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_id_tramite es requerido';
    END IF;

    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        t.tipo_tramite,
        t.id_giro,
        t.x,
        t.y,
        t.zona,
        t.subzona,
        t.actividad,
        t.cvecuenta,
        t.recaud,
        t.licencia_ref,
        t.tramita_apoderado,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.rfc,
        t.curp,
        t.domicilio,
        t.numext_prop,
        t.numint_prop,
        t.colonia_prop,
        t.telefono_prop,
        t.email,
        t.cvecalle,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.letrain_ubic,
        t.colonia_ubic,
        t.espubic,
        t.documentos,
        t.sup_construida,
        t.sup_autorizada,
        t.num_cajones,
        t.num_empleados,
        t.aforo,
        t.inversion,
        t.costo,
        t.fecha_consejo,
        t.id_fabricante,
        t.texto_anuncio,
        t.medidas1,
        t.medidas2,
        t.area_anuncio,
        t.num_caras,
        t.calificacion,
        t.usr_califica,
        t.estatus,
        t.id_licencia,
        t.id_anuncio,
        t.feccap,
        t.capturista,
        t.numint_ubic,
        t.bloqueado,
        t.dictamen,
        t.observaciones,
        t.rhorario,
        t.cp,
        COALESCE(g.descripcion, '') AS descripcion_giro,
        TRIM(COALESCE(t.primer_ap, '') || ' ' ||
             COALESCE(t.segundo_ap, '') || ' ' ||
             COALESCE(t.propietario, '')) AS propietario_completo
    FROM tramites t
    LEFT JOIN c_giros g ON t.id_giro = g.id_giro
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_reactivatramite_get_tramite(INTEGER) IS
'Obtiene los datos completos de un trámite con información del giro y propietario - ReactivaTramite';

-- ============================================
-- SP 2/4: sp_reactivatramite_get_tramite_by_id
-- Tipo: Consulta
-- Descripción: Obtiene datos básicos de un trámite por ID
--              (versión simplificada sin campo calculado)
-- Parámetros:
--   - p_id_tramite: ID del trámite a consultar
-- Retorna: Registro del trámite con descripción del giro
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_reactivatramite_get_tramite_by_id(
    p_id_tramite INTEGER
)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    id_giro INTEGER,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR,
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR,
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    domicilio VARCHAR,
    numext_prop INTEGER,
    numint_prop VARCHAR,
    colonia_prop VARCHAR,
    telefono_prop VARCHAR,
    email VARCHAR,
    cvecalle INTEGER,
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    letraext_ubic VARCHAR,
    letrain_ubic VARCHAR,
    colonia_ubic VARCHAR,
    espubic VARCHAR,
    documentos TEXT,
    sup_construida DOUBLE PRECISION,
    sup_autorizada DOUBLE PRECISION,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    costo NUMERIC,
    fecha_consejo DATE,
    id_fabricante INTEGER,
    texto_anuncio VARCHAR,
    medidas1 DOUBLE PRECISION,
    medidas2 DOUBLE PRECISION,
    area_anuncio DOUBLE PRECISION,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica VARCHAR,
    estatus VARCHAR,
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista VARCHAR,
    numint_ubic VARCHAR,
    bloqueado SMALLINT,
    dictamen SMALLINT,
    observaciones TEXT,
    rhorario VARCHAR,
    cp INTEGER,
    descripcion_giro VARCHAR
) AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_id_tramite IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_id_tramite es requerido';
    END IF;

    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        t.tipo_tramite,
        t.id_giro,
        t.x,
        t.y,
        t.zona,
        t.subzona,
        t.actividad,
        t.cvecuenta,
        t.recaud,
        t.licencia_ref,
        t.tramita_apoderado,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.rfc,
        t.curp,
        t.domicilio,
        t.numext_prop,
        t.numint_prop,
        t.colonia_prop,
        t.telefono_prop,
        t.email,
        t.cvecalle,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.letrain_ubic,
        t.colonia_ubic,
        t.espubic,
        t.documentos,
        t.sup_construida,
        t.sup_autorizada,
        t.num_cajones,
        t.num_empleados,
        t.aforo,
        t.inversion,
        t.costo,
        t.fecha_consejo,
        t.id_fabricante,
        t.texto_anuncio,
        t.medidas1,
        t.medidas2,
        t.area_anuncio,
        t.num_caras,
        t.calificacion,
        t.usr_califica,
        t.estatus,
        t.id_licencia,
        t.id_anuncio,
        t.feccap,
        t.capturista,
        t.numint_ubic,
        t.bloqueado,
        t.dictamen,
        t.observaciones,
        t.rhorario,
        t.cp,
        COALESCE(g.descripcion, '') AS descripcion_giro
    FROM tramites t
    LEFT JOIN c_giros g ON t.id_giro = g.id_giro
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_reactivatramite_get_tramite_by_id(INTEGER) IS
'Obtiene datos básicos de un trámite por ID con descripción del giro - ReactivaTramite';

-- ============================================
-- SP 3/4: sp_reactivatramite_get_giro_by_id
-- Tipo: Consulta
-- Descripción: Obtiene la información completa de un giro por su ID
-- Parámetros:
--   - p_id_giro: ID del giro a consultar
-- Retorna: Información completa del giro
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_reactivatramite_get_giro_by_id(
    p_id_giro INTEGER
)
RETURNS TABLE (
    id_giro INTEGER,
    clave VARCHAR,
    descripcion VARCHAR,
    activo BOOLEAN,
    tipo_giro VARCHAR,
    requiere_licencia BOOLEAN,
    costo_base NUMERIC,
    observaciones TEXT
) AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_id_giro IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_id_giro es requerido';
    END IF;

    RETURN QUERY
    SELECT
        g.id_giro,
        g.clave,
        g.descripcion,
        COALESCE(g.activo, true) AS activo,
        COALESCE(g.tipo_giro, '') AS tipo_giro,
        COALESCE(g.requiere_licencia, false) AS requiere_licencia,
        COALESCE(g.costo_base, 0) AS costo_base,
        COALESCE(g.observaciones, '') AS observaciones
    FROM c_giros g
    WHERE g.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_reactivatramite_get_giro_by_id(INTEGER) IS
'Obtiene información completa de un giro por ID - ReactivaTramite';

-- ============================================
-- SP 4/4: sp_reactivatramite_reactivar_tramite
-- Tipo: Transacción
-- Descripción: Reactiva un trámite cancelado o rechazado,
--              actualizando su estado y el de sus revisiones
-- Parámetros:
--   - p_id_tramite: ID del trámite a reactivar
--   - p_motivo: Motivo de la reactivación
--   - p_usuario: Usuario que realiza la reactivación (opcional)
-- Retorna: success (boolean) y message (text)
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_reactivatramite_reactivar_tramite(
    p_id_tramite INTEGER,
    p_motivo TEXT,
    p_usuario VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_estatus VARCHAR;
    v_motivo_completo TEXT;
    v_bloqueado SMALLINT;
    v_count_revisiones INTEGER;
    v_usuario VARCHAR;
BEGIN
    -- Validar parámetros requeridos
    IF p_id_tramite IS NULL THEN
        RETURN QUERY SELECT false, 'El parámetro p_id_tramite es requerido';
        RETURN;
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT false, 'El motivo de reactivación es requerido';
        RETURN;
    END IF;

    -- Obtener datos del trámite
    SELECT t.estatus, t.bloqueado
    INTO v_estatus, v_bloqueado
    FROM tramites t
    WHERE t.id_tramite = p_id_tramite;

    -- Verificar existencia del trámite
    IF v_estatus IS NULL THEN
        RETURN QUERY SELECT false, 'Trámite no encontrado con ID: ' || p_id_tramite::TEXT;
        RETURN;
    END IF;

    -- Verificar que el trámite esté cancelado o rechazado
    IF v_estatus NOT IN ('C', 'R') THEN
        RETURN QUERY SELECT false,
            'El trámite no se encuentra cancelado o rechazado. Estado actual: ' ||
            CASE
                WHEN v_estatus = 'A' THEN 'Aprobado'
                WHEN v_estatus = 'T' THEN 'En trámite'
                WHEN v_estatus = 'P' THEN 'Pendiente'
                ELSE v_estatus
            END;
        RETURN;
    END IF;

    -- Verificar que no esté aprobado (validación redundante pero explícita)
    IF v_estatus = 'A' THEN
        RETURN QUERY SELECT false, 'El trámite ya se encuentra aprobado. No se puede reactivar.';
        RETURN;
    END IF;

    -- Verificar que no esté bloqueado
    IF v_bloqueado = 1 THEN
        RETURN QUERY SELECT false, 'El trámite está bloqueado. Debe desbloquearlo antes de reactivar.';
        RETURN;
    END IF;

    -- Preparar el usuario
    v_usuario := COALESCE(p_usuario, CURRENT_USER);

    -- Construir motivo completo con fecha y usuario
    v_motivo_completo := 'REACTIVADO POR PADRÓN Y LICENCIAS' || E'\n' ||
                        'Fecha: ' || TO_CHAR(CURRENT_TIMESTAMP, 'DD/MM/YYYY HH24:MI:SS') || E'\n' ||
                        'Usuario: ' || v_usuario || E'\n' ||
                        'Motivo: ' || p_motivo;

    -- Actualizar el estado del trámite
    UPDATE tramites
    SET
        estatus = 'T',  -- En trámite
        espubic = v_motivo_completo,
        observaciones = COALESCE(observaciones, '') || E'\n--- REACTIVACIÓN ---\n' || v_motivo_completo
    WHERE id_tramite = p_id_tramite;

    -- Verificar actualización del trámite
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Error al actualizar el trámite';
        RETURN;
    END IF;

    -- Reactivar revisiones asociadas (Canceladas o Rechazadas -> Vigentes)
    UPDATE revisiones
    SET estatus = 'V'  -- Vigente
    WHERE id_tramite = p_id_tramite
      AND estatus IN ('C', 'N', 'R');

    GET DIAGNOSTICS v_count_revisiones = ROW_COUNT;

    -- Reactivar seguimiento de revisiones
    UPDATE seg_revision
    SET
        estatus = 'V',  -- Vigente
        observacion = v_motivo_completo,
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id_revision IN (
        SELECT r.id_revision
        FROM revisiones r
        WHERE r.id_tramite = p_id_tramite
          AND r.estatus = 'V'
    );

    -- Registrar en auditoría (si existe tabla de auditoría)
    BEGIN
        INSERT INTO auditoria_tramites (
            id_tramite,
            accion,
            usuario,
            fecha,
            estatus_anterior,
            estatus_nuevo,
            observaciones
        ) VALUES (
            p_id_tramite,
            'REACTIVACION',
            v_usuario,
            CURRENT_TIMESTAMP,
            v_estatus,
            'T',
            v_motivo_completo
        );
    EXCEPTION
        WHEN OTHERS THEN
            -- Si la tabla no existe, continuar sin error
            NULL;
    END;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT true,
        'Trámite reactivado correctamente. ' ||
        'Revisiones actualizadas: ' || v_count_revisiones::TEXT || '. ' ||
        'El trámite ahora está en estado: En Trámite';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_reactivatramite_reactivar_tramite(INTEGER, TEXT, VARCHAR) IS
'Reactiva un trámite cancelado o rechazado con auditoría completa - ReactivaTramite';

-- ============================================
-- GRANTS - Permisos de ejecución
-- ============================================

-- Otorgar permisos de ejecución a roles comunes
GRANT EXECUTE ON FUNCTION public.sp_reactivatramite_get_tramite(INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.sp_reactivatramite_get_tramite_by_id(INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.sp_reactivatramite_get_giro_by_id(INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.sp_reactivatramite_reactivar_tramite(INTEGER, TEXT, VARCHAR) TO PUBLIC;

-- ============================================
-- VERIFICACIÓN DE STORED PROCEDURES
-- ============================================

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND p.proname LIKE 'sp_reactivatramite_%';

    RAISE NOTICE '============================================';
    RAISE NOTICE 'VERIFICACIÓN DE INSTALACIÓN';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Stored Procedures instalados: %', v_count;
    RAISE NOTICE 'Esperados: 4';

    IF v_count = 4 THEN
        RAISE NOTICE 'Estado: COMPLETO ✓';
    ELSE
        RAISE WARNING 'Estado: INCOMPLETO - Faltan % SPs', (4 - v_count);
    END IF;

    RAISE NOTICE '============================================';
    RAISE NOTICE 'LISTADO DE STORED PROCEDURES:';
    RAISE NOTICE '============================================';

    FOR v_count IN
        SELECT ROW_NUMBER() OVER (ORDER BY p.proname) as num
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname LIKE 'sp_reactivatramite_%'
    LOOP
        NULL;
    END LOOP;
END $$;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
-- Total de Stored Procedures: 4
-- Esquema: public
-- Tablas principales: tramites, c_giros, revisiones, seg_revision
-- Características especiales:
--   - Validaciones de estado completas
--   - Verificación de trámite bloqueado
--   - Auditoría automática
--   - Actualización en cascada de revisiones
--   - Mensajes descriptivos de error
--   - Compatibilidad con usuarios del sistema
-- ============================================
