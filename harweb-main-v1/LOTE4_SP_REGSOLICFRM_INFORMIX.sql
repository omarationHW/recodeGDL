-- ============================================
-- LOTE 4 - REGSOLICFRM (Registro Solicitudes)
-- STORED PROCEDURES MIGRADAS AL ESQUEMA INFORMIX
-- Base de datos: padron_licencias
-- Esquema: informix
-- Fecha: 2025-09-21
-- ============================================

\c padron_licencias;
SET search_path TO informix;

-- ============================================
-- TABLA: solicitudes_licencias (esquema informix)
-- ============================================

CREATE TABLE IF NOT EXISTS informix.solicitudes_licencias (
    id SERIAL PRIMARY KEY,
    folio_solicitud VARCHAR(100) NOT NULL UNIQUE,
    tipo_solicitud VARCHAR(50) NOT NULL, -- 'LICENCIA_NUEVA', 'RENOVACION', 'MODIFICACION', 'ANUNCIO_NUEVO'
    numero_tramite VARCHAR(100),
    cuenta_predial VARCHAR(50),
    solicitante VARCHAR(255) NOT NULL,
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    curp VARCHAR(20),
    direccion_solicitante TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion_negocio TEXT NOT NULL,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    giro_solicitado VARCHAR(255) NOT NULL,
    actividad_especifica TEXT,
    superficie_solicitada NUMERIC(10,2),
    numero_empleados_estimado INTEGER,
    horario_propuesto VARCHAR(100),
    inversion_estimada NUMERIC(12,2),
    fecha_solicitud DATE DEFAULT CURRENT_DATE,
    fecha_recepcion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_revision DATE,
    fecha_respuesta DATE,
    estado VARCHAR(30) DEFAULT 'RECIBIDA', -- 'RECIBIDA', 'EN_REVISION', 'OBSERVACIONES', 'APROBADA', 'RECHAZADA', 'CANCELADA'
    dictamen TEXT,
    observaciones TEXT,
    documentos_entregados TEXT, -- JSON o lista de documentos
    funcionario_revisor VARCHAR(100),
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para consultas optimizadas
CREATE INDEX IF NOT EXISTS idx_informix_sol_folio ON informix.solicitudes_licencias(folio_solicitud);
CREATE INDEX IF NOT EXISTS idx_informix_sol_tipo ON informix.solicitudes_licencias(tipo_solicitud);
CREATE INDEX IF NOT EXISTS idx_informix_sol_solicitante ON informix.solicitudes_licencias(solicitante);
CREATE INDEX IF NOT EXISTS idx_informix_sol_rfc ON informix.solicitudes_licencias(rfc);
CREATE INDEX IF NOT EXISTS idx_informix_sol_estado ON informix.solicitudes_licencias(estado);
CREATE INDEX IF NOT EXISTS idx_informix_sol_fecha_sol ON informix.solicitudes_licencias(fecha_solicitud);
CREATE INDEX IF NOT EXISTS idx_informix_sol_giro ON informix.solicitudes_licencias(giro_solicitado);
CREATE INDEX IF NOT EXISTS idx_informix_sol_funcionario ON informix.solicitudes_licencias(funcionario_revisor);

-- ============================================
-- SP 1/7: SP_REGSOLIC_LIST
-- Tipo: List/Read
-- Descripción: Lista solicitudes con filtros y paginación
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLIC_LIST(
    p_folio_solicitud VARCHAR(100) DEFAULT NULL,
    p_solicitante VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_tipo_solicitud VARCHAR(50) DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL,
    p_giro VARCHAR(255) DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_funcionario_revisor VARCHAR(100) DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    folio_solicitud VARCHAR(100),
    tipo_solicitud VARCHAR(50),
    numero_tramite VARCHAR(100),
    solicitante VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    direccion_negocio TEXT,
    giro_solicitado VARCHAR(255),
    fecha_solicitud DATE,
    fecha_recepcion TIMESTAMP,
    estado VARCHAR(30),
    funcionario_revisor VARCHAR(100),
    dias_transcurridos INTEGER,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM informix.solicitudes_licencias sl
    WHERE (p_folio_solicitud IS NULL OR sl.folio_solicitud ILIKE '%' || p_folio_solicitud || '%')
      AND (p_solicitante IS NULL OR sl.solicitante ILIKE '%' || p_solicitante || '%')
      AND (p_rfc IS NULL OR sl.rfc ILIKE '%' || p_rfc || '%')
      AND (p_tipo_solicitud IS NULL OR sl.tipo_solicitud = upper(p_tipo_solicitud))
      AND (p_estado IS NULL OR sl.estado = upper(p_estado))
      AND (p_giro IS NULL OR sl.giro_solicitado ILIKE '%' || p_giro || '%')
      AND (p_fecha_desde IS NULL OR sl.fecha_solicitud >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR sl.fecha_solicitud <= p_fecha_hasta)
      AND (p_funcionario_revisor IS NULL OR sl.funcionario_revisor ILIKE '%' || p_funcionario_revisor || '%');

    -- Retornar resultados
    RETURN QUERY
    SELECT
        sl.id,
        sl.folio_solicitud,
        sl.tipo_solicitud,
        sl.numero_tramite,
        sl.solicitante,
        sl.razon_social,
        sl.rfc,
        sl.direccion_negocio,
        sl.giro_solicitado,
        sl.fecha_solicitud,
        sl.fecha_recepcion,
        sl.estado,
        sl.funcionario_revisor,
        (CURRENT_DATE - sl.fecha_solicitud)::INTEGER as dias_transcurridos,
        v_total_count as total_registros
    FROM informix.solicitudes_licencias sl
    WHERE (p_folio_solicitud IS NULL OR sl.folio_solicitud ILIKE '%' || p_folio_solicitud || '%')
      AND (p_solicitante IS NULL OR sl.solicitante ILIKE '%' || p_solicitante || '%')
      AND (p_rfc IS NULL OR sl.rfc ILIKE '%' || p_rfc || '%')
      AND (p_tipo_solicitud IS NULL OR sl.tipo_solicitud = upper(p_tipo_solicitud))
      AND (p_estado IS NULL OR sl.estado = upper(p_estado))
      AND (p_giro IS NULL OR sl.giro_solicitado ILIKE '%' || p_giro || '%')
      AND (p_fecha_desde IS NULL OR sl.fecha_solicitud >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR sl.fecha_solicitud <= p_fecha_hasta)
      AND (p_funcionario_revisor IS NULL OR sl.funcionario_revisor ILIKE '%' || p_funcionario_revisor || '%')
    ORDER BY sl.fecha_recepcion DESC, sl.id DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================
-- SP 2/7: SP_REGSOLIC_DETAIL
-- Tipo: Read
-- Descripción: Obtener detalle completo de una solicitud
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLIC_DETAIL(
    p_folio_solicitud VARCHAR(100)
)
RETURNS TABLE(
    id INTEGER,
    folio_solicitud VARCHAR(100),
    tipo_solicitud VARCHAR(50),
    numero_tramite VARCHAR(100),
    cuenta_predial VARCHAR(50),
    solicitante VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    curp VARCHAR(20),
    direccion_solicitante TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion_negocio TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    giro_solicitado VARCHAR(255),
    actividad_especifica TEXT,
    superficie_solicitada NUMERIC(10,2),
    numero_empleados_estimado INTEGER,
    horario_propuesto VARCHAR(100),
    inversion_estimada NUMERIC(12,2),
    fecha_solicitud DATE,
    fecha_recepcion TIMESTAMP,
    fecha_revision DATE,
    fecha_respuesta DATE,
    estado VARCHAR(30),
    dictamen TEXT,
    observaciones TEXT,
    documentos_entregados TEXT,
    funcionario_revisor VARCHAR(100),
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP,
    dias_transcurridos INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar que existe la solicitud
    SELECT COUNT(*) INTO v_exists
    FROM informix.solicitudes_licencias
    WHERE folio_solicitud = p_folio_solicitud;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró la solicitud: %', p_folio_solicitud;
    END IF;

    -- Retornar el registro completo
    RETURN QUERY
    SELECT
        sl.id,
        sl.folio_solicitud,
        sl.tipo_solicitud,
        sl.numero_tramite,
        sl.cuenta_predial,
        sl.solicitante,
        sl.razon_social,
        sl.rfc,
        sl.curp,
        sl.direccion_solicitante,
        sl.telefono,
        sl.email,
        sl.direccion_negocio,
        sl.colonia,
        sl.codigo_postal,
        sl.giro_solicitado,
        sl.actividad_especifica,
        sl.superficie_solicitada,
        sl.numero_empleados_estimado,
        sl.horario_propuesto,
        sl.inversion_estimada,
        sl.fecha_solicitud,
        sl.fecha_recepcion,
        sl.fecha_revision,
        sl.fecha_respuesta,
        sl.estado,
        sl.dictamen,
        sl.observaciones,
        sl.documentos_entregados,
        sl.funcionario_revisor,
        sl.usuario_registro,
        sl.fecha_registro,
        (CURRENT_DATE - sl.fecha_solicitud)::INTEGER as dias_transcurridos
    FROM informix.solicitudes_licencias sl
    WHERE sl.folio_solicitud = p_folio_solicitud;
END;
$$;

-- ============================================
-- SP 3/7: SP_REGSOLIC_CREATE
-- Tipo: Create
-- Descripción: Crear nueva solicitud
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLIC_CREATE(
    p_folio_solicitud VARCHAR(100),
    p_tipo_solicitud VARCHAR(50),
    p_solicitante VARCHAR(255),
    p_direccion_negocio TEXT,
    p_giro_solicitado VARCHAR(255),
    p_razon_social VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_curp VARCHAR(20) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_actividad_especifica TEXT DEFAULT NULL,
    p_superficie_solicitada NUMERIC(10,2) DEFAULT NULL,
    p_inversion_estimada NUMERIC(12,2) DEFAULT NULL,
    p_usuario_registro VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT, id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_exists INTEGER;
BEGIN
    -- Validar campos requeridos
    IF p_folio_solicitud IS NULL OR trim(p_folio_solicitud) = '' THEN
        RETURN QUERY SELECT FALSE, 'El folio de solicitud es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_solicitante IS NULL OR trim(p_solicitante) = '' THEN
        RETURN QUERY SELECT FALSE, 'El nombre del solicitante es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_direccion_negocio IS NULL OR trim(p_direccion_negocio) = '' THEN
        RETURN QUERY SELECT FALSE, 'La dirección del negocio es requerida.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_giro_solicitado IS NULL OR trim(p_giro_solicitado) = '' THEN
        RETURN QUERY SELECT FALSE, 'El giro solicitado es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar que no existe duplicado
    SELECT COUNT(*) INTO v_exists
    FROM informix.solicitudes_licencias
    WHERE folio_solicitud = p_folio_solicitud;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una solicitud con ese folio.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar nueva solicitud
    INSERT INTO informix.solicitudes_licencias (
        folio_solicitud,
        tipo_solicitud,
        solicitante,
        direccion_negocio,
        giro_solicitado,
        razon_social,
        rfc,
        curp,
        telefono,
        email,
        colonia,
        actividad_especifica,
        superficie_solicitada,
        inversion_estimada,
        usuario_registro
    ) VALUES (
        p_folio_solicitud,
        upper(p_tipo_solicitud),
        p_solicitante,
        p_direccion_negocio,
        p_giro_solicitado,
        p_razon_social,
        p_rfc,
        p_curp,
        p_telefono,
        p_email,
        p_colonia,
        p_actividad_especifica,
        p_superficie_solicitada,
        p_inversion_estimada,
        p_usuario_registro
    ) RETURNING id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Solicitud creada exitosamente.', v_new_id;
END;
$$;

-- ============================================
-- SP 4/7: SP_REGSOLIC_UPDATE
-- Tipo: Update
-- Descripción: Actualizar una solicitud existente
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLIC_UPDATE(
    p_id INTEGER,
    p_solicitante VARCHAR(255),
    p_direccion_negocio TEXT,
    p_giro_solicitado VARCHAR(255),
    p_razon_social VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_curp VARCHAR(20) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_actividad_especifica TEXT DEFAULT NULL,
    p_superficie_solicitada NUMERIC(10,2) DEFAULT NULL,
    p_inversion_estimada NUMERIC(12,2) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar que existe la solicitud
    SELECT COUNT(*) INTO v_exists
    FROM informix.solicitudes_licencias
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No se encontró la solicitud a actualizar.';
        RETURN;
    END IF;

    -- Actualizar solicitud
    UPDATE informix.solicitudes_licencias
    SET solicitante = p_solicitante,
        direccion_negocio = p_direccion_negocio,
        giro_solicitado = p_giro_solicitado,
        razon_social = p_razon_social,
        rfc = p_rfc,
        curp = p_curp,
        telefono = p_telefono,
        email = p_email,
        colonia = p_colonia,
        actividad_especifica = p_actividad_especifica,
        superficie_solicitada = p_superficie_solicitada,
        inversion_estimada = p_inversion_estimada,
        observaciones = p_observaciones,
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Solicitud actualizada exitosamente.';
END;
$$;

-- ============================================
-- SP 5/7: SP_REGSOLIC_UPDATE_STATUS
-- Tipo: Update
-- Descripción: Actualizar estado de una solicitud
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLIC_UPDATE_STATUS(
    p_folio_solicitud VARCHAR(100),
    p_estado VARCHAR(30),
    p_dictamen TEXT DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_funcionario_revisor VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_fecha_revision DATE;
    v_fecha_respuesta DATE;
BEGIN
    -- Verificar que existe la solicitud
    SELECT COUNT(*) INTO v_exists
    FROM informix.solicitudes_licencias
    WHERE folio_solicitud = p_folio_solicitud;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No se encontró la solicitud especificada.';
        RETURN;
    END IF;

    -- Establecer fechas según el estado
    IF upper(p_estado) = 'EN_REVISION' THEN
        v_fecha_revision := CURRENT_DATE;
    END IF;

    IF upper(p_estado) IN ('APROBADA', 'RECHAZADA') THEN
        v_fecha_respuesta := CURRENT_DATE;
    END IF;

    -- Actualizar estado y datos relacionados
    UPDATE informix.solicitudes_licencias
    SET estado = upper(p_estado),
        dictamen = COALESCE(p_dictamen, dictamen),
        observaciones = COALESCE(p_observaciones, observaciones),
        funcionario_revisor = COALESCE(p_funcionario_revisor, funcionario_revisor),
        fecha_revision = COALESCE(v_fecha_revision, fecha_revision),
        fecha_respuesta = COALESCE(v_fecha_respuesta, fecha_respuesta),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE folio_solicitud = p_folio_solicitud;

    RETURN QUERY SELECT TRUE, 'Estado de solicitud actualizado exitosamente.';
END;
$$;

-- ============================================
-- SP 6/7: SP_REGSOLIC_DELETE
-- Tipo: Delete
-- Descripción: Eliminar una solicitud (soft delete)
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLIC_DELETE(
    p_folio_solicitud VARCHAR(100),
    p_motivo TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar que existe la solicitud
    SELECT COUNT(*) INTO v_exists
    FROM informix.solicitudes_licencias
    WHERE folio_solicitud = p_folio_solicitud AND estado != 'CANCELADA';

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No se encontró la solicitud o ya está cancelada.';
        RETURN;
    END IF;

    -- Cancelar solicitud (soft delete)
    UPDATE informix.solicitudes_licencias
    SET estado = 'CANCELADA',
        observaciones = COALESCE(observaciones || ' | CANCELADA: ' || p_motivo, 'CANCELADA: ' || COALESCE(p_motivo, 'Sin motivo especificado')),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE folio_solicitud = p_folio_solicitud;

    RETURN QUERY SELECT TRUE, 'Solicitud cancelada exitosamente.';
END;
$$;

-- ============================================
-- SP 7/7: SP_REGSOLIC_ESTADISTICAS
-- Tipo: Report
-- Descripción: Estadísticas de solicitudes
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLIC_ESTADISTICAS(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
)
RETURNS TABLE(
    total_solicitudes BIGINT,
    solicitudes_recibidas BIGINT,
    solicitudes_en_revision BIGINT,
    solicitudes_con_observaciones BIGINT,
    solicitudes_aprobadas BIGINT,
    solicitudes_rechazadas BIGINT,
    solicitudes_canceladas BIGINT,
    tiempo_promedio_revision NUMERIC,
    solicitudes_pendientes BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_fecha_desde DATE;
    v_fecha_hasta DATE;
BEGIN
    -- Establecer fechas por defecto
    v_fecha_desde := COALESCE(p_fecha_desde, CURRENT_DATE - INTERVAL '30 days');
    v_fecha_hasta := COALESCE(p_fecha_hasta, CURRENT_DATE);

    RETURN QUERY
    SELECT
        COUNT(*) as total_solicitudes,
        COUNT(CASE WHEN estado = 'RECIBIDA' THEN 1 END) as solicitudes_recibidas,
        COUNT(CASE WHEN estado = 'EN_REVISION' THEN 1 END) as solicitudes_en_revision,
        COUNT(CASE WHEN estado = 'OBSERVACIONES' THEN 1 END) as solicitudes_con_observaciones,
        COUNT(CASE WHEN estado = 'APROBADA' THEN 1 END) as solicitudes_aprobadas,
        COUNT(CASE WHEN estado = 'RECHAZADA' THEN 1 END) as solicitudes_rechazadas,
        COUNT(CASE WHEN estado = 'CANCELADA' THEN 1 END) as solicitudes_canceladas,
        AVG(CASE
            WHEN fecha_respuesta IS NOT NULL THEN
                EXTRACT(days FROM fecha_respuesta - fecha_solicitud)
            ELSE NULL
        END) as tiempo_promedio_revision,
        COUNT(CASE WHEN estado IN ('RECIBIDA', 'EN_REVISION', 'OBSERVACIONES') THEN 1 END) as solicitudes_pendientes
    FROM informix.solicitudes_licencias
    WHERE fecha_solicitud BETWEEN v_fecha_desde AND v_fecha_hasta;
END;
$$;

-- ============================================
-- PERMISOS Y COMENTARIOS
-- ============================================

-- Comentarios en tabla
COMMENT ON TABLE informix.solicitudes_licencias IS 'Tabla para el registro de solicitudes de licencias y trámites';
COMMENT ON COLUMN informix.solicitudes_licencias.folio_solicitud IS 'Folio único de identificación de la solicitud';
COMMENT ON COLUMN informix.solicitudes_licencias.tipo_solicitud IS 'Tipo de solicitud: LICENCIA_NUEVA, RENOVACION, MODIFICACION, ANUNCIO_NUEVO';
COMMENT ON COLUMN informix.solicitudes_licencias.estado IS 'Estado actual: RECIBIDA, EN_REVISION, OBSERVACIONES, APROBADA, RECHAZADA, CANCELADA';

-- Comentarios en funciones
COMMENT ON FUNCTION informix.SP_REGSOLIC_LIST IS 'Lista solicitudes con filtros y paginación';
COMMENT ON FUNCTION informix.SP_REGSOLIC_DETAIL IS 'Obtiene detalle completo de una solicitud';
COMMENT ON FUNCTION informix.SP_REGSOLIC_CREATE IS 'Crea nueva solicitud de licencia';
COMMENT ON FUNCTION informix.SP_REGSOLIC_UPDATE IS 'Actualiza datos de una solicitud existente';
COMMENT ON FUNCTION informix.SP_REGSOLIC_UPDATE_STATUS IS 'Actualiza estado de una solicitud';
COMMENT ON FUNCTION informix.SP_REGSOLIC_DELETE IS 'Cancela una solicitud (soft delete)';
COMMENT ON FUNCTION informix.SP_REGSOLIC_ESTADISTICAS IS 'Obtiene estadísticas de solicitudes';

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================