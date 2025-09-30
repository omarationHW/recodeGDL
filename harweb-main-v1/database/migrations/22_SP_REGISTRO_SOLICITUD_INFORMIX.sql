-- =====================================================================================
-- SISTEMA MUNICIPAL DIGITAL - GOBIERNO DE GUADALAJARA
-- =====================================================================================
-- Descripción: Stored Procedures para Registro de Solicitudes de Licencias
-- Autor: Sistema de Refactorización Vue.js
-- Fecha: 2025-09-29
-- Versión: 1.0
-- =====================================================================================

-- =====================================================================================
-- CREACIÓN DE ESQUEMA Y TABLA REGISTRO_SOLICITUDES
-- =====================================================================================

-- Crear esquema informix si no existe
CREATE SCHEMA IF NOT EXISTS informix;

-- Crear tabla registro_solicitudes
DROP TABLE IF EXISTS informix.registro_solicitudes CASCADE;

CREATE TABLE informix.registro_solicitudes (
    id SERIAL PRIMARY KEY,
    folio_formulario VARCHAR(20) UNIQUE NOT NULL,
    folio_solicitud VARCHAR(20),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Datos del Solicitante
    nombre_solicitante VARCHAR(255) NOT NULL,
    rfc_solicitante VARCHAR(13),
    curp_solicitante VARCHAR(18),
    telefono_solicitante VARCHAR(20),
    email_solicitante VARCHAR(100),
    nacionalidad VARCHAR(50) DEFAULT 'MEXICANA',
    domicilio_solicitante TEXT,

    -- Datos del Negocio
    nombre_comercial VARCHAR(255) NOT NULL,
    giro VARCHAR(100) NOT NULL,
    direccion_negocio TEXT NOT NULL,
    superficie_m2 DECIMAL(10,2),
    numero_empleados INTEGER DEFAULT 0,
    horario_operacion VARCHAR(50),

    -- Datos Técnicos
    capacidad_instalada VARCHAR(100),
    maquinaria_principal TEXT,

    -- Documentos
    tiene_documentos BOOLEAN DEFAULT FALSE,
    documentos_json JSONB,

    -- Estado y Control
    estado VARCHAR(20) DEFAULT 'PENDIENTE' CHECK (estado IN ('PENDIENTE', 'REVISADO', 'APROBADO', 'RECHAZADO', 'CANCELADO')),
    observaciones TEXT,
    usuario_creacion VARCHAR(50) DEFAULT 'sistema',
    usuario_modificacion VARCHAR(50) DEFAULT 'sistema',

    -- Campos adicionales
    tipo_solicitud VARCHAR(50) DEFAULT 'NUEVA',
    prioridad VARCHAR(10) DEFAULT 'NORMAL' CHECK (prioridad IN ('BAJA', 'NORMAL', 'ALTA', 'URGENTE'))
);

-- Crear índices
CREATE INDEX idx_registro_folio_formulario ON informix.registro_solicitudes(folio_formulario);
CREATE INDEX idx_registro_folio_solicitud ON informix.registro_solicitudes(folio_solicitud);
CREATE INDEX idx_registro_estado ON informix.registro_solicitudes(estado);
CREATE INDEX idx_registro_fecha ON informix.registro_solicitudes(fecha_registro);
CREATE INDEX idx_registro_rfc ON informix.registro_solicitudes(rfc_solicitante);

-- Trigger para actualizar fecha_modificacion
CREATE OR REPLACE FUNCTION informix.update_registro_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_modificacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS tr_registro_update_timestamp ON informix.registro_solicitudes;
CREATE TRIGGER tr_registro_update_timestamp
    BEFORE UPDATE ON informix.registro_solicitudes
    FOR EACH ROW
    EXECUTE FUNCTION informix.update_registro_timestamp();

-- Función para generar folio automático
CREATE OR REPLACE FUNCTION informix.generar_folio_formulario()
RETURNS VARCHAR(20) AS $$
DECLARE
    nuevo_folio VARCHAR(20);
    anio_actual VARCHAR(4);
    consecutivo INTEGER;
BEGIN
    anio_actual := EXTRACT(YEAR FROM CURRENT_DATE)::VARCHAR;

    -- Obtener el último consecutivo del año
    SELECT COALESCE(MAX(CAST(SUBSTRING(folio_formulario FROM 10 FOR 6) AS INTEGER)), 0) + 1
    INTO consecutivo
    FROM informix.registro_solicitudes
    WHERE folio_formulario LIKE 'FORM-' || anio_actual || '-%';

    -- Formatear el nuevo folio
    nuevo_folio := 'FORM-' || anio_actual || '-' || LPAD(consecutivo::VARCHAR, 6, '0');

    RETURN nuevo_folio;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 1. SP_REGISTRO_SOLICITUD_LIST - Listar solicitudes con filtros y paginación
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_registro_solicitud_list(
    p_folio_formulario VARCHAR(20) DEFAULT NULL,
    p_folio_solicitud VARCHAR(20) DEFAULT NULL,
    p_estado VARCHAR(20) DEFAULT NULL,
    p_nombre_solicitante VARCHAR(255) DEFAULT NULL,
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_limite INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    folio_formulario VARCHAR(20),
    folio_solicitud VARCHAR(20),
    fecha_registro TIMESTAMP,
    nombre_solicitante VARCHAR(255),
    rfc_solicitante VARCHAR(13),
    telefono_solicitante VARCHAR(20),
    email_solicitante VARCHAR(100),
    nombre_comercial VARCHAR(255),
    giro VARCHAR(100),
    direccion_negocio TEXT,
    estado VARCHAR(20),
    tipo_solicitud VARCHAR(50),
    prioridad VARCHAR(10),
    observaciones TEXT,
    total_registros BIGINT
) AS $$
DECLARE
    total_count BIGINT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*) INTO total_count
    FROM informix.registro_solicitudes r
    WHERE (p_folio_formulario IS NULL OR r.folio_formulario ILIKE '%' || p_folio_formulario || '%')
      AND (p_folio_solicitud IS NULL OR r.folio_solicitud ILIKE '%' || p_folio_solicitud || '%')
      AND (p_estado IS NULL OR r.estado = p_estado)
      AND (p_nombre_solicitante IS NULL OR r.nombre_solicitante ILIKE '%' || p_nombre_solicitante || '%')
      AND (p_fecha_inicio IS NULL OR r.fecha_registro >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR r.fecha_registro <= p_fecha_fin + INTERVAL '1 day');

    -- Retornar resultados paginados
    RETURN QUERY
    SELECT
        r.id,
        r.folio_formulario,
        r.folio_solicitud,
        r.fecha_registro,
        r.nombre_solicitante,
        r.rfc_solicitante,
        r.telefono_solicitante,
        r.email_solicitante,
        r.nombre_comercial,
        r.giro,
        r.direccion_negocio,
        r.estado,
        r.tipo_solicitud,
        r.prioridad,
        r.observaciones,
        total_count as total_registros
    FROM informix.registro_solicitudes r
    WHERE (p_folio_formulario IS NULL OR r.folio_formulario ILIKE '%' || p_folio_formulario || '%')
      AND (p_folio_solicitud IS NULL OR r.folio_solicitud ILIKE '%' || p_folio_solicitud || '%')
      AND (p_estado IS NULL OR r.estado = p_estado)
      AND (p_nombre_solicitante IS NULL OR r.nombre_solicitante ILIKE '%' || p_nombre_solicitante || '%')
      AND (p_fecha_inicio IS NULL OR r.fecha_registro >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR r.fecha_registro <= p_fecha_fin + INTERVAL '1 day')
    ORDER BY r.fecha_registro DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 2. SP_REGISTRO_SOLICITUD_GET - Obtener solicitud completa por ID
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_registro_solicitud_get(
    p_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    folio_formulario VARCHAR(20),
    folio_solicitud VARCHAR(20),
    fecha_registro TIMESTAMP,
    fecha_modificacion TIMESTAMP,
    nombre_solicitante VARCHAR(255),
    rfc_solicitante VARCHAR(13),
    curp_solicitante VARCHAR(18),
    telefono_solicitante VARCHAR(20),
    email_solicitante VARCHAR(100),
    nacionalidad VARCHAR(50),
    domicilio_solicitante TEXT,
    nombre_comercial VARCHAR(255),
    giro VARCHAR(100),
    direccion_negocio TEXT,
    superficie_m2 DECIMAL(10,2),
    numero_empleados INTEGER,
    horario_operacion VARCHAR(50),
    capacidad_instalada VARCHAR(100),
    maquinaria_principal TEXT,
    tiene_documentos BOOLEAN,
    documentos_json JSONB,
    estado VARCHAR(20),
    tipo_solicitud VARCHAR(50),
    prioridad VARCHAR(10),
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id,
        r.folio_formulario,
        r.folio_solicitud,
        r.fecha_registro,
        r.fecha_modificacion,
        r.nombre_solicitante,
        r.rfc_solicitante,
        r.curp_solicitante,
        r.telefono_solicitante,
        r.email_solicitante,
        r.nacionalidad,
        r.domicilio_solicitante,
        r.nombre_comercial,
        r.giro,
        r.direccion_negocio,
        r.superficie_m2,
        r.numero_empleados,
        r.horario_operacion,
        r.capacidad_instalada,
        r.maquinaria_principal,
        r.tiene_documentos,
        r.documentos_json,
        r.estado,
        r.tipo_solicitud,
        r.prioridad,
        r.observaciones
    FROM informix.registro_solicitudes r
    WHERE r.id = p_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 3. SP_REGISTRO_SOLICITUD_CREATE - Crear nueva solicitud
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_registro_solicitud_create(
    p_nombre_solicitante VARCHAR(255),
    p_nombre_comercial VARCHAR(255),
    p_giro VARCHAR(100),
    p_direccion_negocio TEXT,
    p_rfc_solicitante VARCHAR(13) DEFAULT NULL,
    p_curp_solicitante VARCHAR(18) DEFAULT NULL,
    p_telefono_solicitante VARCHAR(20) DEFAULT NULL,
    p_email_solicitante VARCHAR(100) DEFAULT NULL,
    p_nacionalidad VARCHAR(50) DEFAULT 'MEXICANA',
    p_domicilio_solicitante TEXT DEFAULT NULL,
    p_superficie_m2 DECIMAL(10,2) DEFAULT NULL,
    p_numero_empleados INTEGER DEFAULT 0,
    p_horario_operacion VARCHAR(50) DEFAULT NULL,
    p_capacidad_instalada VARCHAR(100) DEFAULT NULL,
    p_maquinaria_principal TEXT DEFAULT NULL,
    p_tipo_solicitud VARCHAR(50) DEFAULT 'NUEVA',
    p_prioridad VARCHAR(10) DEFAULT 'NORMAL',
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id INTEGER,
    folio_formulario VARCHAR(20)
) AS $$
DECLARE
    nuevo_id INTEGER;
    nuevo_folio VARCHAR(20);
BEGIN
    -- Validar datos requeridos
    IF p_nombre_solicitante IS NULL OR p_nombre_solicitante = '' THEN
        RETURN QUERY SELECT FALSE, 'El nombre del solicitante es requerido'::TEXT, NULL::INTEGER, NULL::VARCHAR(20);
        RETURN;
    END IF;

    IF p_nombre_comercial IS NULL OR p_nombre_comercial = '' THEN
        RETURN QUERY SELECT FALSE, 'El nombre comercial es requerido'::TEXT, NULL::INTEGER, NULL::VARCHAR(20);
        RETURN;
    END IF;

    IF p_giro IS NULL OR p_giro = '' THEN
        RETURN QUERY SELECT FALSE, 'El giro del negocio es requerido'::TEXT, NULL::INTEGER, NULL::VARCHAR(20);
        RETURN;
    END IF;

    -- Generar folio automático
    nuevo_folio := informix.generar_folio_formulario();

    -- Insertar nueva solicitud
    INSERT INTO informix.registro_solicitudes (
        folio_formulario,
        nombre_solicitante,
        rfc_solicitante,
        curp_solicitante,
        telefono_solicitante,
        email_solicitante,
        nacionalidad,
        domicilio_solicitante,
        nombre_comercial,
        giro,
        direccion_negocio,
        superficie_m2,
        numero_empleados,
        horario_operacion,
        capacidad_instalada,
        maquinaria_principal,
        tipo_solicitud,
        prioridad,
        estado,
        observaciones,
        usuario_creacion
    ) VALUES (
        nuevo_folio,
        p_nombre_solicitante,
        UPPER(p_rfc_solicitante),
        UPPER(p_curp_solicitante),
        p_telefono_solicitante,
        LOWER(p_email_solicitante),
        p_nacionalidad,
        p_domicilio_solicitante,
        p_nombre_comercial,
        p_giro,
        p_direccion_negocio,
        p_superficie_m2,
        p_numero_empleados,
        p_horario_operacion,
        p_capacidad_instalada,
        p_maquinaria_principal,
        p_tipo_solicitud,
        p_prioridad,
        'PENDIENTE',
        p_observaciones,
        'sistema'
    ) RETURNING id INTO nuevo_id;

    RETURN QUERY SELECT TRUE, 'Solicitud creada exitosamente'::TEXT, nuevo_id, nuevo_folio;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al crear solicitud: ' || SQLERRM)::TEXT, NULL::INTEGER, NULL::VARCHAR(20);
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 4. SP_REGISTRO_SOLICITUD_UPDATE - Actualizar solicitud existente
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_registro_solicitud_update(
    p_id INTEGER,
    p_nombre_solicitante VARCHAR(255),
    p_nombre_comercial VARCHAR(255),
    p_giro VARCHAR(100),
    p_direccion_negocio TEXT,
    p_rfc_solicitante VARCHAR(13) DEFAULT NULL,
    p_curp_solicitante VARCHAR(18) DEFAULT NULL,
    p_telefono_solicitante VARCHAR(20) DEFAULT NULL,
    p_email_solicitante VARCHAR(100) DEFAULT NULL,
    p_nacionalidad VARCHAR(50) DEFAULT NULL,
    p_domicilio_solicitante TEXT DEFAULT NULL,
    p_superficie_m2 DECIMAL(10,2) DEFAULT NULL,
    p_numero_empleados INTEGER DEFAULT NULL,
    p_horario_operacion VARCHAR(50) DEFAULT NULL,
    p_capacidad_instalada VARCHAR(100) DEFAULT NULL,
    p_maquinaria_principal TEXT DEFAULT NULL,
    p_estado VARCHAR(20) DEFAULT NULL,
    p_prioridad VARCHAR(10) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    solicitud_existe BOOLEAN;
BEGIN
    -- Verificar si existe la solicitud
    SELECT EXISTS(
        SELECT 1 FROM informix.registro_solicitudes
        WHERE id = p_id
    ) INTO solicitud_existe;

    IF NOT solicitud_existe THEN
        RETURN QUERY SELECT FALSE, 'La solicitud no existe'::TEXT;
        RETURN;
    END IF;

    -- Actualizar solicitud
    UPDATE informix.registro_solicitudes SET
        nombre_solicitante = p_nombre_solicitante,
        rfc_solicitante = UPPER(COALESCE(p_rfc_solicitante, rfc_solicitante)),
        curp_solicitante = UPPER(COALESCE(p_curp_solicitante, curp_solicitante)),
        telefono_solicitante = COALESCE(p_telefono_solicitante, telefono_solicitante),
        email_solicitante = LOWER(COALESCE(p_email_solicitante, email_solicitante)),
        nacionalidad = COALESCE(p_nacionalidad, nacionalidad),
        domicilio_solicitante = COALESCE(p_domicilio_solicitante, domicilio_solicitante),
        nombre_comercial = p_nombre_comercial,
        giro = p_giro,
        direccion_negocio = p_direccion_negocio,
        superficie_m2 = COALESCE(p_superficie_m2, superficie_m2),
        numero_empleados = COALESCE(p_numero_empleados, numero_empleados),
        horario_operacion = COALESCE(p_horario_operacion, horario_operacion),
        capacidad_instalada = COALESCE(p_capacidad_instalada, capacidad_instalada),
        maquinaria_principal = COALESCE(p_maquinaria_principal, maquinaria_principal),
        estado = COALESCE(p_estado, estado),
        prioridad = COALESCE(p_prioridad, prioridad),
        observaciones = COALESCE(p_observaciones, observaciones),
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Solicitud actualizada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al actualizar solicitud: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 5. SP_REGISTRO_SOLICITUD_CAMBIAR_ESTADO - Cambiar estado de solicitud
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_registro_solicitud_cambiar_estado(
    p_id INTEGER,
    p_estado VARCHAR(20),
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    solicitud_existe BOOLEAN;
BEGIN
    -- Verificar si existe
    SELECT EXISTS(
        SELECT 1 FROM informix.registro_solicitudes
        WHERE id = p_id
    ) INTO solicitud_existe;

    IF NOT solicitud_existe THEN
        RETURN QUERY SELECT FALSE, 'La solicitud no existe'::TEXT;
        RETURN;
    END IF;

    -- Actualizar estado
    UPDATE informix.registro_solicitudes SET
        estado = p_estado,
        observaciones = COALESCE(p_observaciones, observaciones),
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    -- Si se aprueba, generar folio de solicitud
    IF p_estado = 'APROBADO' THEN
        UPDATE informix.registro_solicitudes SET
            folio_solicitud = 'SOL-' || EXTRACT(YEAR FROM CURRENT_DATE) || '-' || LPAD(id::VARCHAR, 6, '0')
        WHERE id = p_id AND folio_solicitud IS NULL;
    END IF;

    RETURN QUERY SELECT TRUE, ('Estado cambiado a: ' || p_estado)::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al cambiar estado: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 6. SP_REGISTRO_SOLICITUD_DELETE - Eliminar (cancelar) solicitud
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_registro_solicitud_delete(
    p_id INTEGER,
    p_motivo_cancelacion TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    solicitud_existe BOOLEAN;
    estado_actual VARCHAR(20);
BEGIN
    -- Verificar si existe y obtener estado actual
    SELECT estado INTO estado_actual
    FROM informix.registro_solicitudes
    WHERE id = p_id;

    IF estado_actual IS NULL THEN
        RETURN QUERY SELECT FALSE, 'La solicitud no existe'::TEXT;
        RETURN;
    END IF;

    IF estado_actual = 'CANCELADO' THEN
        RETURN QUERY SELECT FALSE, 'La solicitud ya está cancelada'::TEXT;
        RETURN;
    END IF;

    -- Cancelar solicitud
    UPDATE informix.registro_solicitudes SET
        estado = 'CANCELADO',
        observaciones = COALESCE(p_motivo_cancelacion, 'Cancelado por el usuario'),
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Solicitud cancelada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al cancelar solicitud: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- DATOS DE PRUEBA
-- =====================================================================================

-- Insertar datos de prueba
INSERT INTO informix.registro_solicitudes (
    folio_formulario, nombre_solicitante, rfc_solicitante, telefono_solicitante,
    email_solicitante, nombre_comercial, giro, direccion_negocio, estado, prioridad
) VALUES
    ('FORM-2025-000001', 'JUAN PÉREZ LÓPEZ', 'PELJ800515XXX', '33-1234-5678',
     'juan.perez@email.com', 'Abarrotes La Esperanza', 'ABARROTES',
     'AV. JUÁREZ 123, COL. CENTRO', 'PENDIENTE', 'NORMAL'),

    ('FORM-2025-000002', 'MARÍA GONZÁLEZ RUIZ', 'GORM900820XXX', '33-2345-6789',
     'maria.gonzalez@email.com', 'Farmacia Guadalajara', 'FARMACIA',
     'CALLE INDEPENDENCIA 456, COL. AMERICANA', 'REVISADO', 'ALTA'),

    ('FORM-2025-000003', 'CARLOS MARTÍNEZ TORRES', 'MATC750310XXX', '33-3456-7890',
     'carlos.martinez@email.com', 'Restaurante El Tapatío', 'RESTAURANTE',
     'AV. AMÉRICAS 789, COL. PROVIDENCIA', 'APROBADO', 'NORMAL'),

    ('FORM-2025-000004', 'ANA LÓPEZ HERNÁNDEZ', 'LOHA850925XXX', '33-4567-8901',
     'ana.lopez@email.com', 'Boutique Fashion', 'ROPA Y ACCESORIOS',
     'PLAZA DEL SOL LOCAL 234', 'PENDIENTE', 'BAJA');

-- =====================================================================================
-- PERMISOS Y COMENTARIOS
-- =====================================================================================

-- Comentarios en las tablas y funciones
COMMENT ON TABLE informix.registro_solicitudes IS 'Registro de solicitudes de licencias municipales';
COMMENT ON FUNCTION informix.sp_registro_solicitud_list IS 'Lista solicitudes con filtros y paginación';
COMMENT ON FUNCTION informix.sp_registro_solicitud_get IS 'Obtiene solicitud completa por ID';
COMMENT ON FUNCTION informix.sp_registro_solicitud_create IS 'Crea nueva solicitud de licencia';
COMMENT ON FUNCTION informix.sp_registro_solicitud_update IS 'Actualiza solicitud existente';
COMMENT ON FUNCTION informix.sp_registro_solicitud_cambiar_estado IS 'Cambia estado de solicitud';
COMMENT ON FUNCTION informix.sp_registro_solicitud_delete IS 'Cancela solicitud';

-- =====================================================================================
-- FIN DEL ARCHIVO
-- =====================================================================================