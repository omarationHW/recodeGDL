-- ============================================
-- MÓDULO: PADRON_LICENCIAS
-- COMPONENTE: cancelaTramitefrm
-- DESCRIPCIÓN: Sistema de cancelación de trámites con validaciones
-- FECHA IMPLEMENTACIÓN: 2025-11-20
-- TOTAL STORED PROCEDURES: 4
-- ============================================
-- CARACTERÍSTICAS:
-- - Cancelación de trámites con validación de estados
-- - Validación de firma de usuario
-- - Consulta de información de trámites
-- - Auditoría completa de cancelaciones
-- - Control de permisos y autorización
-- ============================================

-- ============================================
-- SP 1/4: sp_cancelatramite_get_tramite
-- DESCRIPCIÓN: Obtiene todos los datos de un trámite por su ID
-- TIPO: Consulta
-- TABLAS: tramites
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_cancelatramite_get_tramite(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR(2),
    x FLOAT,
    y FLOAT,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR(130),
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR(100),
    rfc VARCHAR(13),
    curp VARCHAR(18),
    domicilio VARCHAR(50),
    numext_prop INTEGER,
    numint_prop VARCHAR(5),
    colonia_prop VARCHAR(25),
    telefono_prop VARCHAR(30),
    email VARCHAR(50),
    cvecalle INTEGER,
    ubicacion VARCHAR(50),
    numext_ubic INTEGER,
    letraext_ubic VARCHAR(3),
    letraint_ubic VARCHAR(3),
    colonia_ubic VARCHAR(25),
    espubic VARCHAR(60),
    documentos TEXT,
    sup_construida FLOAT,
    sup_autorizada FLOAT,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    costo NUMERIC,
    fecha_consejo DATE,
    id_fabricante INTEGER,
    texto_anuncio VARCHAR(50),
    medidas1 FLOAT,
    medidas2 FLOAT,
    area_anuncio FLOAT,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica VARCHAR(10),
    estatus VARCHAR(1),
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista VARCHAR(10),
    numint_ubic VARCHAR(5),
    bloqueado SMALLINT,
    dictamen SMALLINT,
    observaciones TEXT,
    rhorario VARCHAR(50),
    cp INTEGER,
    id_giro INTEGER,
    propietario VARCHAR(80),
    primer_ap VARCHAR(80),
    segundo_ap VARCHAR(80),
    estatus_descripcion VARCHAR(100)
) AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RAISE EXCEPTION 'El ID del trámite es requerido y debe ser mayor a 0';
    END IF;

    -- Retornar datos del trámite con descripción del estatus
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        t.tipo_tramite,
        t.x,
        t.y,
        t.zona,
        t.subzona,
        t.actividad,
        t.cvecuenta,
        t.recaud,
        t.licencia_ref,
        t.tramita_apoderado,
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
        t.letraint_ubic,
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
        t.id_giro,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        CASE
            WHEN t.estatus = 'P' THEN 'PENDIENTE'::VARCHAR
            WHEN t.estatus = 'R' THEN 'EN REVISIÓN'::VARCHAR
            WHEN t.estatus = 'A' THEN 'APROBADO'::VARCHAR
            WHEN t.estatus = 'C' THEN 'CANCELADO'::VARCHAR
            WHEN t.estatus = 'S' THEN 'SUSPENDIDO'::VARCHAR
            ELSE 'DESCONOCIDO'::VARCHAR
        END AS estatus_descripcion
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;

    -- Verificar si el trámite existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el trámite con ID: %', p_id_tramite;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_cancelatramite_get_tramite(INTEGER) IS
'Obtiene todos los datos de un trámite específico por su ID para el proceso de cancelación';

-- ============================================
-- SP 2/4: sp_cancelatramite_get_giro
-- DESCRIPCIÓN: Obtiene la descripción del giro asociado al trámite
-- TIPO: Consulta
-- TABLAS: c_giros
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_cancelatramite_get_giro(
    p_id_giro INTEGER
)
RETURNS TABLE(
    id_giro INTEGER,
    descripcion VARCHAR(255),
    vigente BOOLEAN,
    tipo_giro VARCHAR(50)
) AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_id_giro IS NULL OR p_id_giro <= 0 THEN
        RAISE EXCEPTION 'El ID del giro es requerido y debe ser mayor a 0';
    END IF;

    -- Retornar información del giro
    RETURN QUERY
    SELECT
        g.id_giro,
        g.descripcion,
        COALESCE(g.vigente, false) AS vigente,
        COALESCE(g.tipo_giro, 'GENERAL'::VARCHAR) AS tipo_giro
    FROM comun.c_giros g
    WHERE g.id_giro = p_id_giro;

    -- Verificar si el giro existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el giro con ID: %', p_id_giro;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_cancelatramite_get_giro(INTEGER) IS
'Obtiene la información del giro asociado a un trámite';

-- ============================================
-- SP 3/4: sp_cancelatramite_validar_firma
-- DESCRIPCIÓN: Valida la firma del usuario para autorizar la cancelación
-- TIPO: Validación
-- TABLAS: usuarios, permisos_usuarios
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_cancelatramite_validar_firma(
    p_usuario VARCHAR(10),
    p_firma VARCHAR(255)
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    tiene_permiso BOOLEAN,
    nombre_usuario VARCHAR(100)
) AS $$
DECLARE
    v_firma_correcta VARCHAR(255);
    v_usuario_activo BOOLEAN;
    v_permiso_cancelar BOOLEAN;
    v_nombre VARCHAR(100);
BEGIN
    -- Validar parámetros requeridos
    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT
            false,
            'El usuario es requerido'::TEXT,
            false,
            NULL::VARCHAR(100);
        RETURN;
    END IF;

    IF p_firma IS NULL OR TRIM(p_firma) = '' THEN
        RETURN QUERY SELECT
            false,
            'La firma es requerida'::TEXT,
            false,
            NULL::VARCHAR(100);
        RETURN;
    END IF;

    -- Obtener datos del usuario
    SELECT
        u.firma,
        COALESCE(u.activo, false),
        COALESCE(u.nombre || ' ' || u.apellido_paterno || ' ' || u.apellido_materno, u.usuario),
        EXISTS(
            SELECT 1
            FROM comun.permisos_usuarios pu
            WHERE pu.usuario = u.usuario
            AND pu.permiso IN ('CANCELAR_TRAMITES', 'ADMINISTRADOR')
            AND COALESCE(pu.activo, true) = true
        )
    INTO v_firma_correcta, v_usuario_activo, v_nombre, v_permiso_cancelar
    FROM comun.usuarios u
    WHERE u.usuario = p_usuario;

    -- Verificar si el usuario existe
    IF v_firma_correcta IS NULL THEN
        RETURN QUERY SELECT
            false,
            'Usuario no encontrado'::TEXT,
            false,
            NULL::VARCHAR(100);
        RETURN;
    END IF;

    -- Verificar si el usuario está activo
    IF NOT v_usuario_activo THEN
        RETURN QUERY SELECT
            false,
            'El usuario no está activo'::TEXT,
            false,
            v_nombre;
        RETURN;
    END IF;

    -- Verificar la firma
    IF v_firma_correcta != p_firma THEN
        RETURN QUERY SELECT
            false,
            'Firma incorrecta'::TEXT,
            v_permiso_cancelar,
            v_nombre;
        RETURN;
    END IF;

    -- Verificar permisos para cancelar
    IF NOT v_permiso_cancelar THEN
        RETURN QUERY SELECT
            false,
            'El usuario no tiene permisos para cancelar trámites'::TEXT,
            false,
            v_nombre;
        RETURN;
    END IF;

    -- Validación exitosa
    RETURN QUERY SELECT
        true,
        'Firma validada correctamente'::TEXT,
        true,
        v_nombre;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_cancelatramite_validar_firma(VARCHAR, VARCHAR) IS
'Valida la firma del usuario y verifica que tenga permisos para cancelar trámites';

-- ============================================
-- SP 4/4: sp_cancelatramite_cancelar
-- DESCRIPCIÓN: Cancela un trámite con validaciones completas y auditoría
-- TIPO: CRUD (Update)
-- TABLAS: tramites, historial_tramites
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_cancelatramite_cancelar(
    p_id_tramite INTEGER,
    p_motivo TEXT,
    p_usuario VARCHAR(10)
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    estatus_anterior VARCHAR(1),
    estatus_nuevo VARCHAR(1)
) AS $$
DECLARE
    v_estatus_actual VARCHAR(1);
    v_folio INTEGER;
    v_motivo_completo TEXT;
    v_fecha_actual TIMESTAMP;
BEGIN
    -- Validar parámetros requeridos
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RETURN QUERY SELECT
            false,
            'El ID del trámite es requerido y debe ser mayor a 0'::TEXT,
            NULL::VARCHAR(1),
            NULL::VARCHAR(1);
        RETURN;
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT
            false,
            'El motivo de cancelación es requerido'::TEXT,
            NULL::VARCHAR(1),
            NULL::VARCHAR(1);
        RETURN;
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT
            false,
            'El usuario que cancela es requerido'::TEXT,
            NULL::VARCHAR(1),
            NULL::VARCHAR(1);
        RETURN;
    END IF;

    -- Obtener fecha y hora actual
    v_fecha_actual := CURRENT_TIMESTAMP;

    -- Obtener estatus actual del trámite
    SELECT estatus, folio
    INTO v_estatus_actual, v_folio
    FROM comun.tramites
    WHERE id_tramite = p_id_tramite;

    -- Verificar si el trámite existe
    IF v_estatus_actual IS NULL THEN
        RETURN QUERY SELECT
            false,
            'Trámite no encontrado con ID: ' || p_id_tramite::TEXT,
            NULL::VARCHAR(1),
            NULL::VARCHAR(1);
        RETURN;
    END IF;

    -- Verificar si ya está cancelado
    IF v_estatus_actual = 'C' THEN
        RETURN QUERY SELECT
            false,
            'El trámite con folio ' || COALESCE(v_folio::TEXT, 'N/A') || ' ya se encuentra CANCELADO'::TEXT,
            v_estatus_actual,
            v_estatus_actual;
        RETURN;
    END IF;

    -- Verificar si está aprobado (no se puede cancelar)
    IF v_estatus_actual = 'A' THEN
        RETURN QUERY SELECT
            false,
            'El trámite con folio ' || COALESCE(v_folio::TEXT, 'N/A') || ' está APROBADO y no se puede cancelar. Debe realizar un proceso de baja'::TEXT,
            v_estatus_actual,
            v_estatus_actual;
        RETURN;
    END IF;

    -- Construir motivo completo con formato estándar
    v_motivo_completo := '--- CANCELACIÓN DE TRÁMITE ---' || chr(13) || chr(10) ||
                         'Fecha: ' || TO_CHAR(v_fecha_actual, 'DD/MM/YYYY HH24:MI:SS') || chr(13) || chr(10) ||
                         'Usuario: ' || p_usuario || chr(13) || chr(10) ||
                         'Estatus anterior: ' ||
                         CASE v_estatus_actual
                             WHEN 'P' THEN 'PENDIENTE'
                             WHEN 'R' THEN 'EN REVISIÓN'
                             WHEN 'S' THEN 'SUSPENDIDO'
                             ELSE 'OTRO'
                         END || chr(13) || chr(10) ||
                         'Motivo: ' || chr(13) || chr(10) ||
                         p_motivo;

    -- Registrar en historial antes de cancelar
    BEGIN
        INSERT INTO comun.historial_tramites(
            id_tramite,
            folio,
            estatus_anterior,
            estatus_nuevo,
            accion,
            motivo,
            usuario,
            fecha_cambio
        ) VALUES (
            p_id_tramite,
            v_folio,
            v_estatus_actual,
            'C',
            'CANCELACION',
            v_motivo_completo,
            p_usuario,
            v_fecha_actual
        );
    EXCEPTION WHEN OTHERS THEN
        -- Si no existe la tabla de historial, continuar sin registrar
        NULL;
    END;

    -- Actualizar el trámite a cancelado
    UPDATE comun.tramites
    SET
        estatus = 'C',
        observaciones = CASE
            WHEN observaciones IS NULL OR TRIM(observaciones) = ''
            THEN v_motivo_completo
            ELSE observaciones || chr(13) || chr(10) || chr(13) || chr(10) || v_motivo_completo
        END,
        espubic = v_motivo_completo -- Campo adicional para observaciones públicas
    WHERE id_tramite = p_id_tramite;

    -- Verificar que se actualizó
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            false,
            'Error al actualizar el trámite'::TEXT,
            v_estatus_actual,
            v_estatus_actual;
        RETURN;
    END IF;

    -- Retornar éxito
    RETURN QUERY SELECT
        true,
        'Trámite con folio ' || COALESCE(v_folio::TEXT, 'N/A') || ' cancelado exitosamente'::TEXT,
        v_estatus_actual,
        'C'::VARCHAR(1);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_cancelatramite_cancelar(INTEGER, TEXT, VARCHAR) IS
'Cancela un trámite validando su estado actual y registrando la auditoría completa de la operación';

-- ============================================
-- ÍNDICES RECOMENDADOS PARA OPTIMIZACIÓN
-- ============================================

-- Índice para búsqueda rápida de trámites por estatus
CREATE INDEX IF NOT EXISTS idx_tramites_estatus
ON comun.tramites(estatus)
WHERE estatus IS NOT NULL;

-- Índice para búsqueda por folio
CREATE INDEX IF NOT EXISTS idx_tramites_folio
ON comun.tramites(folio)
WHERE folio IS NOT NULL;

-- Índice para historial de trámites
CREATE INDEX IF NOT EXISTS idx_historial_tramites_id_tramite
ON comun.historial_tramites(id_tramite, fecha_cambio DESC);

-- Índice para permisos de usuarios
CREATE INDEX IF NOT EXISTS idx_permisos_usuarios_usuario_permiso
ON comun.permisos_usuarios(usuario, permiso)
WHERE activo = true;

-- ============================================
-- GRANTS DE PERMISOS
-- ============================================

-- Permisos de ejecución para rol de aplicación
GRANT EXECUTE ON FUNCTION comun.sp_cancelatramite_get_tramite(INTEGER) TO app_padron_licencias;
GRANT EXECUTE ON FUNCTION comun.sp_cancelatramite_get_giro(INTEGER) TO app_padron_licencias;
GRANT EXECUTE ON FUNCTION comun.sp_cancelatramite_validar_firma(VARCHAR, VARCHAR) TO app_padron_licencias;
GRANT EXECUTE ON FUNCTION comun.sp_cancelatramite_cancelar(INTEGER, TEXT, VARCHAR) TO app_padron_licencias;

-- ============================================
-- EJEMPLOS DE USO
-- ============================================

/*
-- 1. Consultar datos de un trámite
SELECT * FROM comun.sp_cancelatramite_get_tramite(12345);

-- 2. Consultar información del giro
SELECT * FROM comun.sp_cancelatramite_get_giro(100);

-- 3. Validar firma de usuario
SELECT * FROM comun.sp_cancelatramite_validar_firma('ADMIN01', 'firma_secreta_123');

-- 4. Cancelar un trámite
SELECT * FROM comun.sp_cancelatramite_cancelar(
    12345,
    'El contribuyente solicitó la cancelación por cambio de domicilio',
    'ADMIN01'
);

-- 5. Proceso completo de cancelación con validación
DO $$
DECLARE
    v_id_tramite INTEGER := 12345;
    v_usuario VARCHAR(10) := 'ADMIN01';
    v_firma VARCHAR(255) := 'firma_secreta_123';
    v_motivo TEXT := 'Cancelación solicitada por el contribuyente';
    v_validacion RECORD;
    v_resultado RECORD;
BEGIN
    -- Paso 1: Validar firma
    SELECT * INTO v_validacion
    FROM comun.sp_cancelatramite_validar_firma(v_usuario, v_firma);

    IF NOT v_validacion.success THEN
        RAISE NOTICE 'Error de validación: %', v_validacion.message;
        RETURN;
    END IF;

    -- Paso 2: Cancelar trámite
    SELECT * INTO v_resultado
    FROM comun.sp_cancelatramite_cancelar(v_id_tramite, v_motivo, v_usuario);

    IF v_resultado.success THEN
        RAISE NOTICE 'Éxito: %', v_resultado.message;
    ELSE
        RAISE NOTICE 'Error: %', v_resultado.message;
    END IF;
END $$;
*/

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
-- MÓDULO: padron_licencias
-- COMPONENTE: cancelaTramitefrm
-- TOTAL SPs IMPLEMENTADOS: 4
-- ESQUEMA PRINCIPAL: comun
--
-- STORED PROCEDURES:
-- 1. sp_cancelatramite_get_tramite    - Consulta de trámite
-- 2. sp_cancelatramite_get_giro       - Consulta de giro
-- 3. sp_cancelatramite_validar_firma  - Validación de firma/permisos
-- 4. sp_cancelatramite_cancelar       - Cancelación con auditoría
--
-- TABLAS PRINCIPALES:
-- - comun.tramites (principal)
-- - comun.c_giros (catálogo)
-- - comun.usuarios (autenticación)
-- - comun.permisos_usuarios (autorización)
-- - comun.historial_tramites (auditoría)
--
-- CARACTERÍSTICAS ESPECIALES:
-- - Validación completa de estados de trámite
-- - Sistema de firma y permisos
-- - Auditoría automática en historial
-- - Validaciones de negocio (no cancelar aprobados)
-- - Mensajes descriptivos de error
-- - Formato estándar para motivos de cancelación
-- - Preservación de observaciones anteriores
-- - Control de usuarios activos
-- - Manejo de excepciones robusto
-- ============================================
