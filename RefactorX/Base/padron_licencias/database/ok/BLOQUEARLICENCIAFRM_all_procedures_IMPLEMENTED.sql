-- =============================================
-- COMPONENTE: BloquearLicenciafrm
-- MÓDULO: padron_licencias
-- DESCRIPCIÓN: Sistema de bloqueo/desbloqueo de licencias
-- FECHA: 2025-11-20
-- =============================================
-- STORED PROCEDURES IMPLEMENTADOS:
--   1. sp_bloquear_licencia_get_licencia
--   2. sp_bloquear_licencia_get_bloqueos
--   3. sp_bloquear_licencia_bloquear
--   4. sp_bloquear_licencia_desbloquear
-- =============================================

-- =============================================
-- 1. sp_bloquear_licencia_get_licencia
-- Descripción: Obtiene información completa de una licencia por número
-- Parámetros: p_numero_licencia
-- Retorna: Información de la licencia con validaciones de bloqueo
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_licencia_get_licencia(
    p_numero_licencia VARCHAR
)
RETURNS TABLE(
    id_licencia INTEGER,
    numero_licencia VARCHAR,
    razon_social VARCHAR,
    nombre_comercial VARCHAR,
    rfc VARCHAR,
    id_giro INTEGER,
    giro VARCHAR,
    domicilio TEXT,
    colonia VARCHAR,
    codigo_postal VARCHAR,
    ubicacion_completa TEXT,
    vigente VARCHAR,
    bloqueado INTEGER,
    fecha_bloqueo TIMESTAMP,
    usuario_bloqueo VARCHAR,
    fecha_desbloqueo TIMESTAMP,
    usuario_desbloqueo VARCHAR,
    total_anuncios INTEGER,
    anuncios_vigentes INTEGER,
    tiene_adeudos BOOLEAN,
    monto_adeudo NUMERIC(10,2),
    puede_bloquearse BOOLEAN,
    puede_desbloquearse BOOLEAN,
    mensaje_validacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_licencia,
        l.numero_licencia,
        COALESCE(e.razon_social, '') as razon_social,
        COALESCE(e.nombre_comercial, '') as nombre_comercial,
        COALESCE(e.rfc, '') as rfc,
        l.id_giro,
        COALESCE(g.descripcion, '') as giro,
        TRIM(COALESCE(l.ubicacion, '') || ' #' || COALESCE(l.numext_ubic::TEXT, '')) as domicilio,
        COALESCE(l.colonia_ubic, '') as colonia,
        COALESCE(l.cp_ubic, '') as codigo_postal,
        TRIM(COALESCE(l.ubicacion, '') || ' #' || COALESCE(l.numext_ubic::TEXT, '') ||
             ', Col. ' || COALESCE(l.colonia_ubic, '') ||
             ', CP ' || COALESCE(l.cp_ubic, '')) as ubicacion_completa,
        l.vigente,
        COALESCE(l.bloqueado, 0) as bloqueado,
        l.fecha_bloqueo,
        l.usuario_bloqueo,
        l.fecha_desbloqueo,
        l.usuario_desbloqueo,
        (SELECT COUNT(*)::INTEGER
         FROM comun.anuncios
         WHERE id_licencia = l.id_licencia) as total_anuncios,
        (SELECT COUNT(*)::INTEGER
         FROM comun.anuncios
         WHERE id_licencia = l.id_licencia
         AND vigente = 'V') as anuncios_vigentes,
        CASE
            WHEN EXISTS (
                SELECT 1 FROM comun.adeudos
                WHERE id_licencia = l.id_licencia
                AND vigente = 'V'
            ) THEN TRUE
            ELSE FALSE
        END as tiene_adeudos,
        COALESCE((
            SELECT SUM(monto)
            FROM comun.adeudos
            WHERE id_licencia = l.id_licencia
            AND vigente = 'V'
        ), 0.00) as monto_adeudo,
        CASE
            WHEN l.vigente != 'V' THEN FALSE
            WHEN COALESCE(l.bloqueado, 0) > 0 THEN FALSE
            ELSE TRUE
        END as puede_bloquearse,
        CASE
            WHEN COALESCE(l.bloqueado, 0) > 0 THEN TRUE
            ELSE FALSE
        END as puede_desbloquearse,
        CASE
            WHEN l.id_licencia IS NULL THEN 'Licencia no encontrada'
            WHEN l.vigente != 'V' THEN 'Licencia no está vigente'
            WHEN COALESCE(l.bloqueado, 0) > 0 THEN 'Licencia está bloqueada (' || l.bloqueado::TEXT || ' bloqueos activos)'
            ELSE 'Licencia puede bloquearse'
        END as mensaje_validacion
    FROM comun.licencias l
    LEFT JOIN comun.empresas e ON l.id_empresa = e.id_empresa
    LEFT JOIN comun.c_giros g ON l.id_giro = g.id_giro
    WHERE UPPER(TRIM(l.numero_licencia)) = UPPER(TRIM(p_numero_licencia));
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_licencia_get_licencia(VARCHAR) IS
'Obtiene información completa de una licencia para el proceso de bloqueo/desbloqueo';


-- =============================================
-- 2. sp_bloquear_licencia_get_bloqueos
-- Descripción: Obtiene el historial de bloqueos de una licencia
-- Parámetros: p_numero_licencia, p_solo_vigentes (opcional)
-- Retorna: Lista de bloqueos con información detallada
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_licencia_get_bloqueos(
    p_numero_licencia VARCHAR,
    p_solo_vigentes BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
    id_bloqueo INTEGER,
    licencia VARCHAR,
    tipo_bloqueo VARCHAR,
    descripcion_tipo VARCHAR,
    motivo TEXT,
    fecha_alta TIMESTAMP,
    vigente VARCHAR,
    usuario VARCHAR,
    fecha_bloqueo TIMESTAMP,
    usuario_bloqueo VARCHAR,
    fecha_desbloqueo TIMESTAMP,
    usuario_desbloqueo VARCHAR,
    dias_bloqueado INTEGER,
    esta_activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.id_bloqueo,
        b.licencia,
        COALESCE(b.tipo, '') as tipo_bloqueo,
        COALESCE(tb.descripcion, '') as descripcion_tipo,
        COALESCE(b.motivo, '') as motivo,
        b.fecalta as fecha_alta,
        b.vigente,
        COALESCE(b.usuario, '') as usuario,
        b.fecha_bloqueo,
        COALESCE(b.usuario_bloqueo, '') as usuario_bloqueo,
        b.fecha_desbloqueo,
        COALESCE(b.usuario_desbloqueo, '') as usuario_desbloqueo,
        CASE
            WHEN b.vigente = 'V' AND b.fecha_bloqueo IS NOT NULL THEN
                EXTRACT(DAY FROM (NOW() - b.fecha_bloqueo))::INTEGER
            WHEN b.vigente = 'C' AND b.fecha_bloqueo IS NOT NULL AND b.fecha_desbloqueo IS NOT NULL THEN
                EXTRACT(DAY FROM (b.fecha_desbloqueo - b.fecha_bloqueo))::INTEGER
            ELSE 0
        END as dias_bloqueado,
        CASE
            WHEN b.vigente = 'V' THEN TRUE
            ELSE FALSE
        END as esta_activo
    FROM comun.bloqueo b
    LEFT JOIN comun.c_tipobloqueo tb ON b.tipo = tb.tipo
    WHERE UPPER(TRIM(b.licencia)) = UPPER(TRIM(p_numero_licencia))
    AND (p_solo_vigentes = FALSE OR b.vigente = 'V')
    ORDER BY b.fecalta DESC, b.id_bloqueo DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_licencia_get_bloqueos(VARCHAR, BOOLEAN) IS
'Obtiene el historial de bloqueos de una licencia específica';


-- =============================================
-- 3. sp_bloquear_licencia_bloquear
-- Descripción: Bloquea una licencia con motivo y tipo
-- Parámetros: p_numero_licencia, p_tipo_bloqueo, p_motivo, p_usuario
-- Retorna: JSON con resultado de la operación
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_licencia_bloquear(
    p_numero_licencia VARCHAR,
    p_tipo_bloqueo VARCHAR,
    p_motivo TEXT,
    p_usuario VARCHAR
)
RETURNS JSONB AS $$
DECLARE
    v_id_licencia INTEGER;
    v_vigente VARCHAR;
    v_bloqueado INTEGER;
    v_razon_social VARCHAR;
    v_tipo_existe BOOLEAN;
    v_id_bloqueo INTEGER;
    v_result JSONB;
BEGIN
    -- Validar parámetros obligatorios
    IF TRIM(COALESCE(p_numero_licencia, '')) = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Número de licencia es obligatorio',
            'data', NULL
        );
    END IF;

    IF TRIM(COALESCE(p_tipo_bloqueo, '')) = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Tipo de bloqueo es obligatorio',
            'data', NULL
        );
    END IF;

    IF TRIM(COALESCE(p_motivo, '')) = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Motivo de bloqueo es obligatorio',
            'data', NULL
        );
    END IF;

    IF TRIM(COALESCE(p_usuario, '')) = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Usuario es obligatorio',
            'data', NULL
        );
    END IF;

    -- Validar que existe el tipo de bloqueo
    SELECT EXISTS(
        SELECT 1 FROM comun.c_tipobloqueo
        WHERE tipo = p_tipo_bloqueo
    ) INTO v_tipo_existe;

    IF NOT v_tipo_existe THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Tipo de bloqueo no válido',
            'data', NULL
        );
    END IF;

    -- Obtener información de la licencia
    SELECT
        l.id_licencia,
        l.vigente,
        COALESCE(l.bloqueado, 0),
        COALESCE(e.razon_social, '')
    INTO
        v_id_licencia,
        v_vigente,
        v_bloqueado,
        v_razon_social
    FROM comun.licencias l
    LEFT JOIN comun.empresas e ON l.id_empresa = e.id_empresa
    WHERE UPPER(TRIM(l.numero_licencia)) = UPPER(TRIM(p_numero_licencia));

    -- Validar que existe la licencia
    IF v_id_licencia IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Licencia no encontrada',
            'data', NULL
        );
    END IF;

    -- Validar que la licencia está vigente
    IF v_vigente != 'V' THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'La licencia no está vigente. Solo se pueden bloquear licencias vigentes',
            'data', jsonb_build_object(
                'numero_licencia', p_numero_licencia,
                'razon_social', v_razon_social,
                'vigente', v_vigente
            )
        );
    END IF;

    -- Validar que no tiene bloqueos previos del mismo tipo vigente
    IF EXISTS(
        SELECT 1 FROM comun.bloqueo
        WHERE licencia = p_numero_licencia
        AND tipo = p_tipo_bloqueo
        AND vigente = 'V'
    ) THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'La licencia ya tiene un bloqueo vigente de este tipo',
            'data', jsonb_build_object(
                'numero_licencia', p_numero_licencia,
                'tipo_bloqueo', p_tipo_bloqueo
            )
        );
    END IF;

    -- Actualizar contador de bloqueo en licencias
    UPDATE comun.licencias
    SET bloqueado = COALESCE(bloqueado, 0) + 1,
        fecha_bloqueo = NOW(),
        usuario_bloqueo = p_usuario
    WHERE id_licencia = v_id_licencia;

    -- Registrar en tabla bloqueo
    INSERT INTO comun.bloqueo (
        licencia,
        tipo,
        motivo,
        fecalta,
        vigente,
        usuario,
        fecha_bloqueo,
        usuario_bloqueo
    ) VALUES (
        UPPER(TRIM(p_numero_licencia)),
        p_tipo_bloqueo,
        p_motivo,
        NOW(),
        'V',
        p_usuario,
        NOW(),
        p_usuario
    )
    RETURNING id_bloqueo INTO v_id_bloqueo;

    -- Construir respuesta exitosa
    v_result := jsonb_build_object(
        'success', true,
        'message', 'Licencia bloqueada correctamente',
        'data', jsonb_build_object(
            'id_bloqueo', v_id_bloqueo,
            'numero_licencia', p_numero_licencia,
            'razon_social', v_razon_social,
            'tipo_bloqueo', p_tipo_bloqueo,
            'motivo', p_motivo,
            'total_bloqueos', v_bloqueado + 1,
            'fecha_bloqueo', NOW(),
            'usuario', p_usuario
        )
    );

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Error al bloquear licencia: ' || SQLERRM,
            'data', NULL
        );
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_licencia_bloquear(VARCHAR, VARCHAR, TEXT, VARCHAR) IS
'Bloquea una licencia vigente registrando el motivo y tipo de bloqueo';


-- =============================================
-- 4. sp_bloquear_licencia_desbloquear
-- Descripción: Desbloquea una licencia específica
-- Parámetros: p_numero_licencia, p_tipo_bloqueo, p_usuario
-- Retorna: JSON con resultado de la operación
-- =============================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_licencia_desbloquear(
    p_numero_licencia VARCHAR,
    p_tipo_bloqueo VARCHAR,
    p_usuario VARCHAR
)
RETURNS JSONB AS $$
DECLARE
    v_id_licencia INTEGER;
    v_bloqueado INTEGER;
    v_razon_social VARCHAR;
    v_id_bloqueo INTEGER;
    v_motivo_original TEXT;
    v_fecha_bloqueo_original TIMESTAMP;
    v_result JSONB;
    v_bloqueo_existe BOOLEAN;
BEGIN
    -- Validar parámetros obligatorios
    IF TRIM(COALESCE(p_numero_licencia, '')) = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Número de licencia es obligatorio',
            'data', NULL
        );
    END IF;

    IF TRIM(COALESCE(p_tipo_bloqueo, '')) = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Tipo de bloqueo es obligatorio',
            'data', NULL
        );
    END IF;

    IF TRIM(COALESCE(p_usuario, '')) = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Usuario es obligatorio',
            'data', NULL
        );
    END IF;

    -- Obtener información de la licencia
    SELECT
        l.id_licencia,
        COALESCE(l.bloqueado, 0),
        COALESCE(e.razon_social, '')
    INTO
        v_id_licencia,
        v_bloqueado,
        v_razon_social
    FROM comun.licencias l
    LEFT JOIN comun.empresas e ON l.id_empresa = e.id_empresa
    WHERE UPPER(TRIM(l.numero_licencia)) = UPPER(TRIM(p_numero_licencia));

    -- Validar que existe la licencia
    IF v_id_licencia IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Licencia no encontrada',
            'data', NULL
        );
    END IF;

    -- Validar que la licencia tiene bloqueos
    IF v_bloqueado <= 0 THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'La licencia no tiene bloqueos activos',
            'data', jsonb_build_object(
                'numero_licencia', p_numero_licencia,
                'razon_social', v_razon_social,
                'bloqueado', v_bloqueado
            )
        );
    END IF;

    -- Verificar que existe el bloqueo específico vigente
    SELECT EXISTS(
        SELECT 1 FROM comun.bloqueo
        WHERE licencia = p_numero_licencia
        AND tipo = p_tipo_bloqueo
        AND vigente = 'V'
    ) INTO v_bloqueo_existe;

    IF NOT v_bloqueo_existe THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'No existe un bloqueo vigente de este tipo para la licencia',
            'data', jsonb_build_object(
                'numero_licencia', p_numero_licencia,
                'tipo_bloqueo', p_tipo_bloqueo
            )
        );
    END IF;

    -- Obtener información del bloqueo a desbloquear
    SELECT
        id_bloqueo,
        motivo,
        fecha_bloqueo
    INTO
        v_id_bloqueo,
        v_motivo_original,
        v_fecha_bloqueo_original
    FROM comun.bloqueo
    WHERE licencia = p_numero_licencia
    AND tipo = p_tipo_bloqueo
    AND vigente = 'V'
    ORDER BY fecalta DESC
    LIMIT 1;

    -- Actualizar registro de bloqueo (marcar como cancelado)
    UPDATE comun.bloqueo
    SET vigente = 'C',
        fecha_desbloqueo = NOW(),
        usuario_desbloqueo = p_usuario
    WHERE id_bloqueo = v_id_bloqueo;

    -- Decrementar contador de bloqueo en licencias (mínimo 0)
    UPDATE comun.licencias
    SET bloqueado = GREATEST(COALESCE(bloqueado, 0) - 1, 0),
        fecha_desbloqueo = NOW(),
        usuario_desbloqueo = p_usuario
    WHERE id_licencia = v_id_licencia;

    -- Construir respuesta exitosa
    v_result := jsonb_build_object(
        'success', true,
        'message', 'Licencia desbloqueada correctamente',
        'data', jsonb_build_object(
            'id_bloqueo', v_id_bloqueo,
            'numero_licencia', p_numero_licencia,
            'razon_social', v_razon_social,
            'tipo_bloqueo', p_tipo_bloqueo,
            'motivo_original', v_motivo_original,
            'fecha_bloqueo_original', v_fecha_bloqueo_original,
            'fecha_desbloqueo', NOW(),
            'total_bloqueos_restantes', GREATEST(v_bloqueado - 1, 0),
            'usuario_desbloqueo', p_usuario
        )
    );

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Error al desbloquear licencia: ' || SQLERRM,
            'data', NULL
        );
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_licencia_desbloquear(VARCHAR, VARCHAR, VARCHAR) IS
'Desbloquea una licencia específica según el tipo de bloqueo indicado';


-- =============================================
-- FIN DE IMPLEMENTACIÓN: BloquearLicenciafrm
-- =============================================
-- Total Stored Procedures: 4
-- Schema: comun
-- Prefijo: sp_bloquear_licencia_*
-- Estado: COMPLETAMENTE IMPLEMENTADO
-- =============================================
