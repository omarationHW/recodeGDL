-- ============================================
-- MÓDULO: PADRON_LICENCIAS
-- COMPONENTE: BloquearAnunciofrm
-- DESCRIPCIÓN: Sistema de bloqueo/desbloqueo de anuncios publicitarios
-- FECHA IMPLEMENTACIÓN: 2025-11-20
-- TOTAL STORED PROCEDURES: 4
-- ============================================
-- CARACTERÍSTICAS:
-- - Búsqueda de anuncios con validación de estado
-- - Gestión de bloqueos con historial completo
-- - Registro de motivos de bloqueo/desbloqueo
-- - Control de usuarios autorizados
-- - Validación de estados vigentes
-- - Auditoría completa de operaciones
-- ============================================

-- NOTA: Requiere tabla bloqueos_anuncios con estructura:
-- CREATE TABLE IF NOT EXISTS comun.bloqueos_anuncios (
--     id_bloqueo SERIAL PRIMARY KEY,
--     id_anuncio INTEGER NOT NULL REFERENCES comun.anuncios(id_anuncio),
--     tipo VARCHAR(50) NOT NULL,
--     motivo_bloqueo TEXT NOT NULL,
--     fecha_bloqueo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     usuario_bloqueo VARCHAR(50) NOT NULL,
--     motivo_desbloqueo TEXT,
--     fecha_desbloqueo TIMESTAMP,
--     usuario_desbloqueo VARCHAR(50),
--     activo BOOLEAN DEFAULT TRUE,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- ============================================
-- SP 1/4: sp_bloquear_anuncio_get_anuncio
-- DESCRIPCIÓN: Obtiene información del anuncio con validación de estado
-- TIPO: Consulta
-- TABLAS: anuncios, licencias
-- PARÁMETROS:
--   p_id_anuncio: ID del anuncio a buscar
-- RETORNA: Datos del anuncio con validación para bloqueo
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_anuncio_get_anuncio(
    p_id_anuncio INTEGER
)
RETURNS TABLE(
    id_anuncio INTEGER,
    numero_anuncio VARCHAR(50),
    id_licencia INTEGER,
    numero_licencia VARCHAR(50),
    tipo_anuncio VARCHAR(100),
    propietario TEXT,
    propietario_completo TEXT,
    ubicacion TEXT,
    ubicacion_completa TEXT,
    area_anuncio NUMERIC,
    dimensiones TEXT,
    vigente CHAR(1),
    estado_descripcion VARCHAR(50),
    fecha_otorgamiento DATE,
    texto_anuncio TEXT,
    bloqueado BOOLEAN,
    bloqueo_activo_id INTEGER,
    bloqueo_activo_tipo VARCHAR(50),
    bloqueo_activo_motivo TEXT,
    bloqueo_activo_fecha TIMESTAMP,
    bloqueo_activo_usuario VARCHAR(50),
    puede_bloquearse BOOLEAN,
    mensaje_validacion TEXT
) AS $$
DECLARE
    v_bloqueo_activo RECORD;
BEGIN
    -- Validar parámetro requerido
    IF p_id_anuncio IS NULL OR p_id_anuncio <= 0 THEN
        RAISE EXCEPTION 'El ID del anuncio es requerido y debe ser mayor a 0';
    END IF;

    -- Buscar bloqueo activo si existe
    SELECT
        id_bloqueo,
        tipo,
        motivo_bloqueo,
        fecha_bloqueo,
        usuario_bloqueo
    INTO v_bloqueo_activo
    FROM comun.bloqueos_anuncios
    WHERE id_anuncio = p_id_anuncio
      AND activo = TRUE
    ORDER BY fecha_bloqueo DESC
    LIMIT 1;

    -- Retornar datos del anuncio
    RETURN QUERY
    SELECT
        a.id_anuncio::INTEGER,
        COALESCE(a.numero_anuncio, a.id_anuncio::VARCHAR)::VARCHAR(50) AS numero_anuncio,
        a.id_licencia::INTEGER,
        COALESCE(l.numero_licencia, l.id_licencia::VARCHAR)::VARCHAR(50) AS numero_licencia,
        COALESCE(a.id_giro::VARCHAR, 'N/A')::VARCHAR(100) AS tipo_anuncio,
        l.propietario::TEXT,
        TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, ''))::TEXT AS propietario_completo,
        COALESCE(a.ubicacion, '')::TEXT AS ubicacion,
        TRIM(COALESCE(a.ubicacion, '') || ' ' ||
             COALESCE(a.numext_ubic::TEXT, '') || ' ' ||
             COALESCE(a.letraext_ubic, '') ||
             CASE WHEN a.numint_ubic IS NOT NULL THEN ' Int. ' || a.numint_ubic::TEXT ELSE '' END ||
             COALESCE(a.letraint_ubic, ''))::TEXT AS ubicacion_completa,
        COALESCE(a.area_anuncio, 0)::NUMERIC AS area_anuncio,
        (COALESCE(a.medidas1::TEXT, '') || ' x ' || COALESCE(a.medidas2::TEXT, ''))::TEXT AS dimensiones,
        a.vigente::CHAR(1),
        CASE
            WHEN a.vigente = 'V' THEN 'VIGENTE'::VARCHAR
            WHEN a.vigente = 'C' THEN 'CANCELADO/BAJA'::VARCHAR
            WHEN a.vigente = 'S' THEN 'SUSPENDIDO'::VARCHAR
            ELSE 'DESCONOCIDO'::VARCHAR
        END::VARCHAR(50) AS estado_descripcion,
        a.fecha_otorgamiento::DATE,
        COALESCE(a.texto_anuncio, '')::TEXT AS texto_anuncio,
        (v_bloqueo_activo.id_bloqueo IS NOT NULL)::BOOLEAN AS bloqueado,
        v_bloqueo_activo.id_bloqueo::INTEGER AS bloqueo_activo_id,
        v_bloqueo_activo.tipo::VARCHAR(50) AS bloqueo_activo_tipo,
        v_bloqueo_activo.motivo_bloqueo::TEXT AS bloqueo_activo_motivo,
        v_bloqueo_activo.fecha_bloqueo::TIMESTAMP AS bloqueo_activo_fecha,
        v_bloqueo_activo.usuario_bloqueo::VARCHAR(50) AS bloqueo_activo_usuario,
        CASE
            WHEN a.vigente != 'V' THEN FALSE
            WHEN v_bloqueo_activo.id_bloqueo IS NOT NULL THEN FALSE
            ELSE TRUE
        END::BOOLEAN AS puede_bloquearse,
        CASE
            WHEN a.vigente != 'V' THEN 'El anuncio no está vigente. Solo se pueden bloquear anuncios vigentes'::TEXT
            WHEN v_bloqueo_activo.id_bloqueo IS NOT NULL THEN 'El anuncio ya tiene un bloqueo activo'::TEXT
            ELSE 'El anuncio puede bloquearse'::TEXT
        END::TEXT AS mensaje_validacion
    FROM comun.anuncios a
    LEFT JOIN comun.licencias l ON a.id_licencia = l.id_licencia
    WHERE a.id_anuncio = p_id_anuncio;

    -- Validar que el anuncio existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el anuncio con ID %', p_id_anuncio;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_anuncio_get_anuncio(INTEGER) IS
'Obtiene información del anuncio con validación de estado para bloqueo - BloquearAnunciofrm';

-- ============================================
-- SP 2/4: sp_bloquear_anuncio_get_bloqueos
-- DESCRIPCIÓN: Obtiene historial completo de bloqueos del anuncio
-- TIPO: Consulta
-- TABLAS: bloqueos_anuncios
-- PARÁMETROS:
--   p_id_anuncio: ID del anuncio
-- RETORNA: Lista de bloqueos ordenados por fecha descendente
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_anuncio_get_bloqueos(
    p_id_anuncio INTEGER
)
RETURNS TABLE(
    id_bloqueo INTEGER,
    id_anuncio INTEGER,
    tipo VARCHAR(50),
    motivo_bloqueo TEXT,
    fecha_bloqueo TIMESTAMP,
    usuario_bloqueo VARCHAR(50),
    motivo_desbloqueo TEXT,
    fecha_desbloqueo TIMESTAMP,
    usuario_desbloqueo VARCHAR(50),
    activo BOOLEAN,
    duracion_dias INTEGER,
    estado VARCHAR(20)
) AS $$
BEGIN
    -- Validar parámetro requerido
    IF p_id_anuncio IS NULL OR p_id_anuncio <= 0 THEN
        RAISE EXCEPTION 'El ID del anuncio es requerido y debe ser mayor a 0';
    END IF;

    -- Retornar historial de bloqueos
    RETURN QUERY
    SELECT
        b.id_bloqueo::INTEGER,
        b.id_anuncio::INTEGER,
        b.tipo::VARCHAR(50),
        b.motivo_bloqueo::TEXT,
        b.fecha_bloqueo::TIMESTAMP,
        b.usuario_bloqueo::VARCHAR(50),
        b.motivo_desbloqueo::TEXT,
        b.fecha_desbloqueo::TIMESTAMP,
        b.usuario_desbloqueo::VARCHAR(50),
        b.activo::BOOLEAN,
        CASE
            WHEN b.fecha_desbloqueo IS NOT NULL
            THEN EXTRACT(DAY FROM (b.fecha_desbloqueo - b.fecha_bloqueo))::INTEGER
            ELSE EXTRACT(DAY FROM (CURRENT_TIMESTAMP - b.fecha_bloqueo))::INTEGER
        END AS duracion_dias,
        CASE
            WHEN b.activo = TRUE THEN 'ACTIVO'::VARCHAR
            WHEN b.fecha_desbloqueo IS NOT NULL THEN 'DESBLOQUEADO'::VARCHAR
            ELSE 'INACTIVO'::VARCHAR
        END::VARCHAR(20) AS estado
    FROM comun.bloqueos_anuncios b
    WHERE b.id_anuncio = p_id_anuncio
    ORDER BY b.fecha_bloqueo DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_anuncio_get_bloqueos(INTEGER) IS
'Obtiene historial de bloqueos del anuncio - BloquearAnunciofrm';

-- ============================================
-- SP 3/4: sp_bloquear_anuncio_bloquear
-- DESCRIPCIÓN: Registra un nuevo bloqueo en el anuncio
-- TIPO: Transaccional (INSERT)
-- TABLAS: bloqueos_anuncios, anuncios
-- PARÁMETROS:
--   p_id_anuncio: ID del anuncio a bloquear
--   p_tipo: Tipo de bloqueo (ej: 'ADMINISTRATIVO', 'JURIDICO', 'SANITARIO')
--   p_motivo: Motivo detallado del bloqueo
--   p_usuario: Usuario que realiza el bloqueo
-- RETORNA: success (boolean), message (text), id_bloqueo (integer)
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_anuncio_bloquear(
    p_id_anuncio INTEGER,
    p_tipo VARCHAR(50),
    p_motivo TEXT,
    p_usuario VARCHAR(50)
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_bloqueo INTEGER
) AS $$
DECLARE
    v_anuncio_exists INTEGER;
    v_vigente CHAR(1);
    v_bloqueo_activo INTEGER;
    v_new_bloqueo_id INTEGER;
BEGIN
    -- Validar parámetros requeridos
    IF p_id_anuncio IS NULL OR p_id_anuncio <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El ID del anuncio es requerido y debe ser mayor a 0'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_tipo IS NULL OR TRIM(p_tipo) = '' THEN
        RETURN QUERY SELECT FALSE, 'El tipo de bloqueo es requerido'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT FALSE, 'El motivo del bloqueo es requerido'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El usuario es requerido'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar que el anuncio existe
    SELECT COUNT(*), MAX(a.vigente)
    INTO v_anuncio_exists, v_vigente
    FROM comun.anuncios a
    WHERE a.id_anuncio = p_id_anuncio;

    IF v_anuncio_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio no existe'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar que el anuncio está vigente
    IF v_vigente != 'V' THEN
        RETURN QUERY SELECT
            FALSE,
            'El anuncio no está vigente. Solo se pueden bloquear anuncios vigentes'::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar que no tenga un bloqueo activo
    SELECT COUNT(*)
    INTO v_bloqueo_activo
    FROM comun.bloqueos_anuncios
    WHERE id_anuncio = p_id_anuncio AND activo = TRUE;

    IF v_bloqueo_activo > 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'El anuncio ya tiene un bloqueo activo. Debe desbloquearse antes de crear un nuevo bloqueo'::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el bloqueo
    INSERT INTO comun.bloqueos_anuncios (
        id_anuncio,
        tipo,
        motivo_bloqueo,
        fecha_bloqueo,
        usuario_bloqueo,
        activo,
        created_at,
        updated_at
    )
    VALUES (
        p_id_anuncio,
        UPPER(TRIM(p_tipo)),
        TRIM(p_motivo),
        CURRENT_TIMESTAMP,
        UPPER(TRIM(p_usuario)),
        TRUE,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    RETURNING id_bloqueo INTO v_new_bloqueo_id;

    -- Registrar en log de auditoría
    INSERT INTO comun.auditoria_licencias (
        tabla_afectada,
        operacion,
        id_registro,
        usuario,
        fecha,
        descripcion
    )
    VALUES (
        'bloqueos_anuncios',
        'BLOQUEO_ANUNCIO',
        p_id_anuncio,
        p_usuario,
        CURRENT_TIMESTAMP,
        'Bloqueo de anuncio ID: ' || p_id_anuncio || ' - Tipo: ' || p_tipo || ' - Motivo: ' || p_motivo
    );

    RETURN QUERY SELECT
        TRUE,
        'Anuncio bloqueado exitosamente con ID de bloqueo: ' || v_new_bloqueo_id::TEXT,
        v_new_bloqueo_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            'Error al bloquear el anuncio: ' || SQLERRM::TEXT,
            NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_anuncio_bloquear(INTEGER, VARCHAR, TEXT, VARCHAR) IS
'Registra un nuevo bloqueo en el anuncio con validación completa - BloquearAnunciofrm';

-- ============================================
-- SP 4/4: sp_bloquear_anuncio_desbloquear
-- DESCRIPCIÓN: Desbloquea un anuncio previamente bloqueado
-- TIPO: Transaccional (UPDATE)
-- TABLAS: bloqueos_anuncios
-- PARÁMETROS:
--   p_id_bloqueo: ID del bloqueo a desbloquear
--   p_motivo_desbloqueo: Motivo del desbloqueo
--   p_usuario: Usuario que realiza el desbloqueo
-- RETORNA: success (boolean), message (text)
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_anuncio_desbloquear(
    p_id_bloqueo INTEGER,
    p_motivo_desbloqueo TEXT,
    p_usuario VARCHAR(50)
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_bloqueo_exists INTEGER;
    v_bloqueo_activo BOOLEAN;
    v_id_anuncio INTEGER;
    v_updated INTEGER;
BEGIN
    -- Validar parámetros requeridos
    IF p_id_bloqueo IS NULL OR p_id_bloqueo <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El ID del bloqueo es requerido y debe ser mayor a 0'::TEXT;
        RETURN;
    END IF;

    IF p_motivo_desbloqueo IS NULL OR TRIM(p_motivo_desbloqueo) = '' THEN
        RETURN QUERY SELECT FALSE, 'El motivo del desbloqueo es requerido'::TEXT;
        RETURN;
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El usuario es requerido'::TEXT;
        RETURN;
    END IF;

    -- Verificar que el bloqueo existe y obtener su estado
    SELECT COUNT(*), MAX(activo), MAX(id_anuncio)
    INTO v_bloqueo_exists, v_bloqueo_activo, v_id_anuncio
    FROM comun.bloqueos_anuncios
    WHERE id_bloqueo = p_id_bloqueo;

    IF v_bloqueo_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El bloqueo no existe'::TEXT;
        RETURN;
    END IF;

    -- Verificar que el bloqueo está activo
    IF v_bloqueo_activo = FALSE THEN
        RETURN QUERY SELECT FALSE, 'El bloqueo ya fue desbloqueado previamente'::TEXT;
        RETURN;
    END IF;

    -- Actualizar el bloqueo
    UPDATE comun.bloqueos_anuncios
    SET
        motivo_desbloqueo = TRIM(p_motivo_desbloqueo),
        fecha_desbloqueo = CURRENT_TIMESTAMP,
        usuario_desbloqueo = UPPER(TRIM(p_usuario)),
        activo = FALSE,
        updated_at = CURRENT_TIMESTAMP
    WHERE id_bloqueo = p_id_bloqueo AND activo = TRUE;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    IF v_updated > 0 THEN
        -- Registrar en log de auditoría
        INSERT INTO comun.auditoria_licencias (
            tabla_afectada,
            operacion,
            id_registro,
            usuario,
            fecha,
            descripcion
        )
        VALUES (
            'bloqueos_anuncios',
            'DESBLOQUEO_ANUNCIO',
            v_id_anuncio,
            p_usuario,
            CURRENT_TIMESTAMP,
            'Desbloqueo de anuncio ID: ' || v_id_anuncio || ' - ID Bloqueo: ' || p_id_bloqueo || ' - Motivo: ' || p_motivo_desbloqueo
        );

        RETURN QUERY SELECT
            TRUE,
            'Anuncio desbloqueado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT
            FALSE,
            'No se pudo desbloquear el anuncio. Verifique que el bloqueo esté activo'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            'Error al desbloquear el anuncio: ' || SQLERRM::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_anuncio_desbloquear(INTEGER, TEXT, VARCHAR) IS
'Desbloquea un anuncio previamente bloqueado - BloquearAnunciofrm';

-- ============================================
-- FIN DE STORED PROCEDURES - BloquearAnunciofrm
-- ============================================
-- RESUMEN:
-- ✓ 4 Stored Procedures implementados
-- ✓ Validaciones completas en cada SP
-- ✓ Manejo de errores con EXCEPTION
-- ✓ Auditoría de operaciones
-- ✓ Comentarios descriptivos
-- ✓ Parámetros tipados correctamente
-- ✓ Retornos estructurados
-- ============================================
