-- ============================================
-- LOTE 4 - REGISTROSOLICITUDFORM (Formulario Registro Solicitud)
-- STORED PROCEDURES MIGRADAS AL ESQUEMA INFORMIX
-- Base de datos: padron_licencias
-- Esquema: informix
-- Fecha: 2025-09-21
-- ============================================

\c padron_licencias;
SET search_path TO informix;

-- ============================================
-- TABLA: formularios_solicitud (esquema informix)
-- Tabla específica para formularios de solicitud detallados
-- ============================================

CREATE TABLE IF NOT EXISTS informix.formularios_solicitud (
    id SERIAL PRIMARY KEY,
    folio_formulario VARCHAR(100) NOT NULL UNIQUE,
    folio_solicitud VARCHAR(100) NOT NULL, -- FK a solicitudes_licencias
    tipo_formulario VARCHAR(50) NOT NULL, -- 'INICIAL', 'MODIFICACION', 'ACTUALIZACION'
    datos_solicitante JSONB NOT NULL, -- Datos completos del solicitante
    datos_negocio JSONB NOT NULL, -- Datos completos del negocio
    datos_tecnicos JSONB, -- Datos técnicos específicos
    documentos_anexos JSONB, -- Lista de documentos anexos
    requisitos_cumplidos JSONB, -- Requisitos cumplidos por tipo
    firmas_autorizadas JSONB, -- Firmas autorizadas
    fecha_creacion DATE DEFAULT CURRENT_DATE,
    fecha_presentacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_validacion DATE,
    fecha_completado DATE,
    estado_formulario VARCHAR(30) DEFAULT 'BORRADOR', -- 'BORRADOR', 'PRESENTADO', 'VALIDADO', 'COMPLETADO', 'RECHAZADO'
    validador_asignado VARCHAR(100),
    observaciones_validacion TEXT,
    version_formulario INTEGER DEFAULT 1,
    formulario_padre_id INTEGER, -- Para versiones/modificaciones
    usuario_creacion VARCHAR(100),
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT true,

    -- Foreign key constraint
    CONSTRAINT fk_formulario_solicitud FOREIGN KEY (folio_solicitud)
    REFERENCES informix.solicitudes_licencias(folio_solicitud) ON DELETE CASCADE
);

-- Índices para consultas optimizadas
CREATE INDEX IF NOT EXISTS idx_informix_form_folio ON informix.formularios_solicitud(folio_formulario);
CREATE INDEX IF NOT EXISTS idx_informix_form_solicitud ON informix.formularios_solicitud(folio_solicitud);
CREATE INDEX IF NOT EXISTS idx_informix_form_tipo ON informix.formularios_solicitud(tipo_formulario);
CREATE INDEX IF NOT EXISTS idx_informix_form_estado ON informix.formularios_solicitud(estado_formulario);
CREATE INDEX IF NOT EXISTS idx_informix_form_validador ON informix.formularios_solicitud(validador_asignado);
CREATE INDEX IF NOT EXISTS idx_informix_form_fecha ON informix.formularios_solicitud(fecha_presentacion);
CREATE INDEX IF NOT EXISTS idx_informix_form_activo ON informix.formularios_solicitud(activo);

-- ============================================
-- SP 1/8: SP_REGSOLFORM_LIST
-- Tipo: List/Read
-- Descripción: Lista formularios con filtros y paginación
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLFORM_LIST(
    p_folio_formulario VARCHAR(100) DEFAULT NULL,
    p_folio_solicitud VARCHAR(100) DEFAULT NULL,
    p_tipo_formulario VARCHAR(50) DEFAULT NULL,
    p_estado_formulario VARCHAR(30) DEFAULT NULL,
    p_validador_asignado VARCHAR(100) DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_activo BOOLEAN DEFAULT true,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    folio_formulario VARCHAR(100),
    folio_solicitud VARCHAR(100),
    tipo_formulario VARCHAR(50),
    estado_formulario VARCHAR(30),
    fecha_presentacion TIMESTAMP,
    fecha_validacion DATE,
    validador_asignado VARCHAR(100),
    version_formulario INTEGER,
    usuario_creacion VARCHAR(100),
    datos_solicitante_nombre TEXT,
    datos_negocio_giro TEXT,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM informix.formularios_solicitud fs
    WHERE (p_folio_formulario IS NULL OR fs.folio_formulario ILIKE '%' || p_folio_formulario || '%')
      AND (p_folio_solicitud IS NULL OR fs.folio_solicitud = p_folio_solicitud)
      AND (p_tipo_formulario IS NULL OR fs.tipo_formulario = upper(p_tipo_formulario))
      AND (p_estado_formulario IS NULL OR fs.estado_formulario = upper(p_estado_formulario))
      AND (p_validador_asignado IS NULL OR fs.validador_asignado ILIKE '%' || p_validador_asignado || '%')
      AND (p_fecha_desde IS NULL OR fs.fecha_presentacion::date >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR fs.fecha_presentacion::date <= p_fecha_hasta)
      AND fs.activo = p_activo;

    -- Retornar resultados
    RETURN QUERY
    SELECT
        fs.id,
        fs.folio_formulario,
        fs.folio_solicitud,
        fs.tipo_formulario,
        fs.estado_formulario,
        fs.fecha_presentacion,
        fs.fecha_validacion,
        fs.validador_asignado,
        fs.version_formulario,
        fs.usuario_creacion,
        COALESCE((fs.datos_solicitante->>'nombre_completo')::TEXT, '') as datos_solicitante_nombre,
        COALESCE((fs.datos_negocio->>'giro')::TEXT, '') as datos_negocio_giro,
        v_total_count as total_registros
    FROM informix.formularios_solicitud fs
    WHERE (p_folio_formulario IS NULL OR fs.folio_formulario ILIKE '%' || p_folio_formulario || '%')
      AND (p_folio_solicitud IS NULL OR fs.folio_solicitud = p_folio_solicitud)
      AND (p_tipo_formulario IS NULL OR fs.tipo_formulario = upper(p_tipo_formulario))
      AND (p_estado_formulario IS NULL OR fs.estado_formulario = upper(p_estado_formulario))
      AND (p_validador_asignado IS NULL OR fs.validador_asignado ILIKE '%' || p_validador_asignado || '%')
      AND (p_fecha_desde IS NULL OR fs.fecha_presentacion::date >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR fs.fecha_presentacion::date <= p_fecha_hasta)
      AND fs.activo = p_activo
    ORDER BY fs.fecha_presentacion DESC, fs.id DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================
-- SP 2/8: SP_REGSOLFORM_DETAIL
-- Tipo: Read
-- Descripción: Obtener detalle completo de un formulario
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLFORM_DETAIL(
    p_folio_formulario VARCHAR(100)
)
RETURNS TABLE(
    id INTEGER,
    folio_formulario VARCHAR(100),
    folio_solicitud VARCHAR(100),
    tipo_formulario VARCHAR(50),
    datos_solicitante JSONB,
    datos_negocio JSONB,
    datos_tecnicos JSONB,
    documentos_anexos JSONB,
    requisitos_cumplidos JSONB,
    firmas_autorizadas JSONB,
    fecha_creacion DATE,
    fecha_presentacion TIMESTAMP,
    fecha_validacion DATE,
    fecha_completado DATE,
    estado_formulario VARCHAR(30),
    validador_asignado VARCHAR(100),
    observaciones_validacion TEXT,
    version_formulario INTEGER,
    formulario_padre_id INTEGER,
    usuario_creacion VARCHAR(100),
    fecha_actualizacion TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar que existe el formulario
    SELECT COUNT(*) INTO v_exists
    FROM informix.formularios_solicitud
    WHERE folio_formulario = p_folio_formulario AND activo = true;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró el formulario: %', p_folio_formulario;
    END IF;

    -- Retornar el registro completo
    RETURN QUERY
    SELECT
        fs.id,
        fs.folio_formulario,
        fs.folio_solicitud,
        fs.tipo_formulario,
        fs.datos_solicitante,
        fs.datos_negocio,
        fs.datos_tecnicos,
        fs.documentos_anexos,
        fs.requisitos_cumplidos,
        fs.firmas_autorizadas,
        fs.fecha_creacion,
        fs.fecha_presentacion,
        fs.fecha_validacion,
        fs.fecha_completado,
        fs.estado_formulario,
        fs.validador_asignado,
        fs.observaciones_validacion,
        fs.version_formulario,
        fs.formulario_padre_id,
        fs.usuario_creacion,
        fs.fecha_actualizacion
    FROM informix.formularios_solicitud fs
    WHERE fs.folio_formulario = p_folio_formulario AND fs.activo = true;
END;
$$;

-- ============================================
-- SP 3/8: SP_REGSOLFORM_CREATE
-- Tipo: Create
-- Descripción: Crear nuevo formulario
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLFORM_CREATE(
    p_folio_formulario VARCHAR(100),
    p_folio_solicitud VARCHAR(100),
    p_tipo_formulario VARCHAR(50),
    p_datos_solicitante JSONB,
    p_datos_negocio JSONB,
    p_datos_tecnicos JSONB DEFAULT NULL,
    p_documentos_anexos JSONB DEFAULT NULL,
    p_requisitos_cumplidos JSONB DEFAULT NULL,
    p_firmas_autorizadas JSONB DEFAULT NULL,
    p_usuario_creacion VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT, id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_exists INTEGER;
    v_solicitud_exists INTEGER;
BEGIN
    -- Validar campos requeridos
    IF p_folio_formulario IS NULL OR trim(p_folio_formulario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El folio del formulario es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_folio_solicitud IS NULL OR trim(p_folio_solicitud) = '' THEN
        RETURN QUERY SELECT FALSE, 'El folio de solicitud es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_datos_solicitante IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Los datos del solicitante son requeridos.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_datos_negocio IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Los datos del negocio son requeridos.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar que no existe duplicado
    SELECT COUNT(*) INTO v_exists
    FROM informix.formularios_solicitud
    WHERE folio_formulario = p_folio_formulario AND activo = true;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un formulario con ese folio.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar que existe la solicitud referenciada
    SELECT COUNT(*) INTO v_solicitud_exists
    FROM informix.solicitudes_licencias
    WHERE folio_solicitud = p_folio_solicitud;

    IF v_solicitud_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe la solicitud referenciada.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar nuevo formulario
    INSERT INTO informix.formularios_solicitud (
        folio_formulario,
        folio_solicitud,
        tipo_formulario,
        datos_solicitante,
        datos_negocio,
        datos_tecnicos,
        documentos_anexos,
        requisitos_cumplidos,
        firmas_autorizadas,
        usuario_creacion
    ) VALUES (
        p_folio_formulario,
        p_folio_solicitud,
        upper(p_tipo_formulario),
        p_datos_solicitante,
        p_datos_negocio,
        p_datos_tecnicos,
        p_documentos_anexos,
        p_requisitos_cumplidos,
        p_firmas_autorizadas,
        p_usuario_creacion
    ) RETURNING id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Formulario creado exitosamente.', v_new_id;
END;
$$;

-- ============================================
-- SP 4/8: SP_REGSOLFORM_UPDATE
-- Tipo: Update
-- Descripción: Actualizar un formulario existente
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLFORM_UPDATE(
    p_id INTEGER,
    p_datos_solicitante JSONB,
    p_datos_negocio JSONB,
    p_datos_tecnicos JSONB DEFAULT NULL,
    p_documentos_anexos JSONB DEFAULT NULL,
    p_requisitos_cumplidos JSONB DEFAULT NULL,
    p_firmas_autorizadas JSONB DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_estado VARCHAR(30);
BEGIN
    -- Verificar que existe el formulario
    SELECT COUNT(*), estado_formulario INTO v_exists, v_estado
    FROM informix.formularios_solicitud
    WHERE id = p_id AND activo = true
    GROUP BY estado_formulario;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No se encontró el formulario a actualizar.';
        RETURN;
    END IF;

    -- Verificar que el formulario puede ser modificado
    IF v_estado IN ('COMPLETADO', 'RECHAZADO') THEN
        RETURN QUERY SELECT FALSE, 'No se puede modificar un formulario completado o rechazado.';
        RETURN;
    END IF;

    -- Actualizar formulario
    UPDATE informix.formularios_solicitud
    SET datos_solicitante = p_datos_solicitante,
        datos_negocio = p_datos_negocio,
        datos_tecnicos = COALESCE(p_datos_tecnicos, datos_tecnicos),
        documentos_anexos = COALESCE(p_documentos_anexos, documentos_anexos),
        requisitos_cumplidos = COALESCE(p_requisitos_cumplidos, requisitos_cumplidos),
        firmas_autorizadas = COALESCE(p_firmas_autorizadas, firmas_autorizadas),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Formulario actualizado exitosamente.';
END;
$$;

-- ============================================
-- SP 5/8: SP_REGSOLFORM_UPDATE_STATUS
-- Tipo: Update
-- Descripción: Actualizar estado de un formulario
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLFORM_UPDATE_STATUS(
    p_folio_formulario VARCHAR(100),
    p_estado_formulario VARCHAR(30),
    p_validador_asignado VARCHAR(100) DEFAULT NULL,
    p_observaciones_validacion TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_fecha_validacion DATE;
    v_fecha_completado DATE;
BEGIN
    -- Verificar que existe el formulario
    SELECT COUNT(*) INTO v_exists
    FROM informix.formularios_solicitud
    WHERE folio_formulario = p_folio_formulario AND activo = true;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No se encontró el formulario especificado.';
        RETURN;
    END IF;

    -- Establecer fechas según el estado
    IF upper(p_estado_formulario) = 'VALIDADO' THEN
        v_fecha_validacion := CURRENT_DATE;
    END IF;

    IF upper(p_estado_formulario) = 'COMPLETADO' THEN
        v_fecha_completado := CURRENT_DATE;
    END IF;

    -- Actualizar estado y datos relacionados
    UPDATE informix.formularios_solicitud
    SET estado_formulario = upper(p_estado_formulario),
        validador_asignado = COALESCE(p_validador_asignado, validador_asignado),
        observaciones_validacion = COALESCE(p_observaciones_validacion, observaciones_validacion),
        fecha_validacion = COALESCE(v_fecha_validacion, fecha_validacion),
        fecha_completado = COALESCE(v_fecha_completado, fecha_completado),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE folio_formulario = p_folio_formulario;

    RETURN QUERY SELECT TRUE, 'Estado del formulario actualizado exitosamente.';
END;
$$;

-- ============================================
-- SP 6/8: SP_REGSOLFORM_PRESENTAR
-- Tipo: Update
-- Descripción: Presentar formulario (cambiar de borrador a presentado)
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLFORM_PRESENTAR(
    p_folio_formulario VARCHAR(100)
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_estado VARCHAR(30);
BEGIN
    -- Verificar que existe el formulario
    SELECT COUNT(*), estado_formulario INTO v_exists, v_estado
    FROM informix.formularios_solicitud
    WHERE folio_formulario = p_folio_formulario AND activo = true
    GROUP BY estado_formulario;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No se encontró el formulario especificado.';
        RETURN;
    END IF;

    -- Verificar que está en borrador
    IF v_estado != 'BORRADOR' THEN
        RETURN QUERY SELECT FALSE, 'Solo se pueden presentar formularios en estado borrador.';
        RETURN;
    END IF;

    -- Cambiar estado a presentado
    UPDATE informix.formularios_solicitud
    SET estado_formulario = 'PRESENTADO',
        fecha_presentacion = CURRENT_TIMESTAMP,
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE folio_formulario = p_folio_formulario;

    RETURN QUERY SELECT TRUE, 'Formulario presentado exitosamente.';
END;
$$;

-- ============================================
-- SP 7/8: SP_REGSOLFORM_CREAR_VERSION
-- Tipo: Create
-- Descripción: Crear nueva versión de un formulario
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLFORM_CREAR_VERSION(
    p_folio_formulario_original VARCHAR(100),
    p_nuevo_folio VARCHAR(100),
    p_usuario_creacion VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT, id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_original_id INTEGER;
    v_nueva_version INTEGER;
    v_formulario_original RECORD;
BEGIN
    -- Obtener datos del formulario original
    SELECT * INTO v_formulario_original
    FROM informix.formularios_solicitud
    WHERE folio_formulario = p_folio_formulario_original AND activo = true;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'No se encontró el formulario original.', NULL::INTEGER;
        RETURN;
    END IF;

    v_original_id := v_formulario_original.id;
    v_nueva_version := v_formulario_original.version_formulario + 1;

    -- Verificar que no existe el nuevo folio
    IF EXISTS (SELECT 1 FROM informix.formularios_solicitud WHERE folio_formulario = p_nuevo_folio AND activo = true) THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un formulario con el nuevo folio.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Crear nueva versión
    INSERT INTO informix.formularios_solicitud (
        folio_formulario,
        folio_solicitud,
        tipo_formulario,
        datos_solicitante,
        datos_negocio,
        datos_tecnicos,
        documentos_anexos,
        requisitos_cumplidos,
        firmas_autorizadas,
        version_formulario,
        formulario_padre_id,
        usuario_creacion
    ) VALUES (
        p_nuevo_folio,
        v_formulario_original.folio_solicitud,
        v_formulario_original.tipo_formulario,
        v_formulario_original.datos_solicitante,
        v_formulario_original.datos_negocio,
        v_formulario_original.datos_tecnicos,
        v_formulario_original.documentos_anexos,
        v_formulario_original.requisitos_cumplidos,
        v_formulario_original.firmas_autorizadas,
        v_nueva_version,
        v_original_id,
        p_usuario_creacion
    ) RETURNING id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Nueva versión del formulario creada exitosamente.', v_new_id;
END;
$$;

-- ============================================
-- SP 8/8: SP_REGSOLFORM_ESTADISTICAS
-- Tipo: Report
-- Descripción: Estadísticas de formularios
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_REGSOLFORM_ESTADISTICAS(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
)
RETURNS TABLE(
    total_formularios BIGINT,
    formularios_borrador BIGINT,
    formularios_presentados BIGINT,
    formularios_validados BIGINT,
    formularios_completados BIGINT,
    formularios_rechazados BIGINT,
    tiempo_promedio_validacion NUMERIC,
    formularios_pendientes BIGINT
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
        COUNT(*) as total_formularios,
        COUNT(CASE WHEN estado_formulario = 'BORRADOR' THEN 1 END) as formularios_borrador,
        COUNT(CASE WHEN estado_formulario = 'PRESENTADO' THEN 1 END) as formularios_presentados,
        COUNT(CASE WHEN estado_formulario = 'VALIDADO' THEN 1 END) as formularios_validados,
        COUNT(CASE WHEN estado_formulario = 'COMPLETADO' THEN 1 END) as formularios_completados,
        COUNT(CASE WHEN estado_formulario = 'RECHAZADO' THEN 1 END) as formularios_rechazados,
        AVG(CASE
            WHEN fecha_validacion IS NOT NULL THEN
                EXTRACT(days FROM fecha_validacion - fecha_presentacion::date)
            ELSE NULL
        END) as tiempo_promedio_validacion,
        COUNT(CASE WHEN estado_formulario IN ('BORRADOR', 'PRESENTADO', 'VALIDADO') THEN 1 END) as formularios_pendientes
    FROM informix.formularios_solicitud
    WHERE fecha_presentacion::date BETWEEN v_fecha_desde AND v_fecha_hasta
      AND activo = true;
END;
$$;

-- ============================================
-- PERMISOS Y COMENTARIOS
-- ============================================

-- Comentarios en tabla
COMMENT ON TABLE informix.formularios_solicitud IS 'Tabla para formularios detallados de solicitudes de licencias';
COMMENT ON COLUMN informix.formularios_solicitud.folio_formulario IS 'Folio único de identificación del formulario';
COMMENT ON COLUMN informix.formularios_solicitud.datos_solicitante IS 'Datos completos del solicitante en formato JSON';
COMMENT ON COLUMN informix.formularios_solicitud.datos_negocio IS 'Datos completos del negocio en formato JSON';
COMMENT ON COLUMN informix.formularios_solicitud.estado_formulario IS 'Estado actual: BORRADOR, PRESENTADO, VALIDADO, COMPLETADO, RECHAZADO';

-- Comentarios en funciones
COMMENT ON FUNCTION informix.SP_REGSOLFORM_LIST IS 'Lista formularios con filtros y paginación';
COMMENT ON FUNCTION informix.SP_REGSOLFORM_DETAIL IS 'Obtiene detalle completo de un formulario';
COMMENT ON FUNCTION informix.SP_REGSOLFORM_CREATE IS 'Crea nuevo formulario de solicitud';
COMMENT ON FUNCTION informix.SP_REGSOLFORM_UPDATE IS 'Actualiza datos de un formulario existente';
COMMENT ON FUNCTION informix.SP_REGSOLFORM_UPDATE_STATUS IS 'Actualiza estado de un formulario';
COMMENT ON FUNCTION informix.SP_REGSOLFORM_PRESENTAR IS 'Presenta un formulario (cambia de borrador a presentado)';
COMMENT ON FUNCTION informix.SP_REGSOLFORM_CREAR_VERSION IS 'Crea nueva versión de un formulario';
COMMENT ON FUNCTION informix.SP_REGSOLFORM_ESTADISTICAS IS 'Obtiene estadísticas de formularios';

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================