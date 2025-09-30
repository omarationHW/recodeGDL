-- =====================================================================================
-- SISTEMA MUNICIPAL DIGITAL - GOBIERNO DE GUADALAJARA
-- =====================================================================================
-- Descripción: Stored Procedures para CRUD de Empresas del Sistema
-- Autor: Sistema de Refactorización Vue.js
-- Fecha: 2025-09-29
-- Versión: 1.0
-- =====================================================================================

-- =====================================================================================
-- CREACIÓN DE ESQUEMA Y TABLA EMPRESAS
-- =====================================================================================

-- Crear esquema informix si no existe
CREATE SCHEMA IF NOT EXISTS informix;

-- Crear tabla empresas
DROP TABLE IF EXISTS informix.empresas CASCADE;

CREATE TABLE informix.empresas (
    id SERIAL PRIMARY KEY,
    rfc VARCHAR(13) NOT NULL UNIQUE,
    razon_social VARCHAR(255) NOT NULL,
    nombre_comercial VARCHAR(255),
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    representante_legal VARCHAR(255),
    fecha_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado CHAR(1) DEFAULT 'A' CHECK (estado IN ('A', 'I')), -- A=Activa, I=Inactiva
    usuario_creacion VARCHAR(50) DEFAULT 'sistema',
    usuario_modificacion VARCHAR(50) DEFAULT 'sistema',

    -- Datos adicionales para el sistema municipal
    giro_empresarial VARCHAR(100),
    clasificacion VARCHAR(50) DEFAULT 'PRIVADA' CHECK (clasificacion IN ('PRIVADA', 'PUBLICA', 'MIXTA')),
    numero_empleados INTEGER DEFAULT 0,
    observaciones TEXT
);

-- Crear índices
CREATE INDEX idx_empresas_rfc ON informix.empresas(rfc);
CREATE INDEX idx_empresas_razon_social ON informix.empresas(razon_social);
CREATE INDEX idx_empresas_estado ON informix.empresas(estado);
CREATE INDEX idx_empresas_clasificacion ON informix.empresas(clasificacion);

-- Trigger para actualizar fecha_modificacion
CREATE OR REPLACE FUNCTION informix.update_empresas_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_modificacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS tr_empresas_update_timestamp ON informix.empresas;
CREATE TRIGGER tr_empresas_update_timestamp
    BEFORE UPDATE ON informix.empresas
    FOR EACH ROW
    EXECUTE FUNCTION informix.update_empresas_timestamp();

-- =====================================================================================
-- 1. SP_EMPRESAS_LIST - Listar empresas con filtros y paginación
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_empresas_list(
    p_rfc VARCHAR(13) DEFAULT NULL,
    p_razon_social VARCHAR(255) DEFAULT NULL,
    p_estado CHAR(1) DEFAULT NULL,
    p_clasificacion VARCHAR(50) DEFAULT NULL,
    p_limite INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    rfc VARCHAR(13),
    razon_social VARCHAR(255),
    nombre_comercial VARCHAR(255),
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    representante_legal VARCHAR(255),
    fecha_alta TIMESTAMP,
    fecha_modificacion TIMESTAMP,
    estado CHAR(1),
    giro_empresarial VARCHAR(100),
    clasificacion VARCHAR(50),
    numero_empleados INTEGER,
    observaciones TEXT,
    total_registros BIGINT
) AS $$
DECLARE
    total_count BIGINT;
BEGIN
    -- Contar total de registros que coinciden con los filtros
    SELECT COUNT(*) INTO total_count
    FROM informix.empresas e
    WHERE (p_rfc IS NULL OR e.rfc ILIKE '%' || p_rfc || '%')
      AND (p_razon_social IS NULL OR e.razon_social ILIKE '%' || p_razon_social || '%')
      AND (p_estado IS NULL OR e.estado = p_estado)
      AND (p_clasificacion IS NULL OR e.clasificacion = p_clasificacion);

    -- Retornar resultados paginados
    RETURN QUERY
    SELECT
        e.id,
        e.rfc,
        e.razon_social,
        e.nombre_comercial,
        e.direccion,
        e.telefono,
        e.email,
        e.representante_legal,
        e.fecha_alta,
        e.fecha_modificacion,
        e.estado,
        e.giro_empresarial,
        e.clasificacion,
        e.numero_empleados,
        e.observaciones,
        total_count as total_registros
    FROM informix.empresas e
    WHERE (p_rfc IS NULL OR e.rfc ILIKE '%' || p_rfc || '%')
      AND (p_razon_social IS NULL OR e.razon_social ILIKE '%' || p_razon_social || '%')
      AND (p_estado IS NULL OR e.estado = p_estado)
      AND (p_clasificacion IS NULL OR e.clasificacion = p_clasificacion)
    ORDER BY e.fecha_modificacion DESC, e.razon_social
    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 2. SP_EMPRESAS_GET - Obtener empresa por ID
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_empresas_get(
    p_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    rfc VARCHAR(13),
    razon_social VARCHAR(255),
    nombre_comercial VARCHAR(255),
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    representante_legal VARCHAR(255),
    fecha_alta TIMESTAMP,
    fecha_modificacion TIMESTAMP,
    estado CHAR(1),
    giro_empresarial VARCHAR(100),
    clasificacion VARCHAR(50),
    numero_empleados INTEGER,
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.rfc,
        e.razon_social,
        e.nombre_comercial,
        e.direccion,
        e.telefono,
        e.email,
        e.representante_legal,
        e.fecha_alta,
        e.fecha_modificacion,
        e.estado,
        e.giro_empresarial,
        e.clasificacion,
        e.numero_empleados,
        e.observaciones
    FROM informix.empresas e
    WHERE e.id = p_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 3. SP_EMPRESAS_CREATE - Crear nueva empresa
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_empresas_create(
    p_rfc VARCHAR(13),
    p_razon_social VARCHAR(255),
    p_nombre_comercial VARCHAR(255) DEFAULT NULL,
    p_direccion TEXT DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_representante_legal VARCHAR(255) DEFAULT NULL,
    p_giro_empresarial VARCHAR(100) DEFAULT NULL,
    p_clasificacion VARCHAR(50) DEFAULT 'PRIVADA',
    p_numero_empleados INTEGER DEFAULT 0,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id INTEGER
) AS $$
DECLARE
    nuevo_id INTEGER;
    rfc_existe BOOLEAN;
BEGIN
    -- Validar datos requeridos
    IF p_rfc IS NULL OR p_rfc = '' THEN
        RETURN QUERY SELECT FALSE, 'El RFC es requerido'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_razon_social IS NULL OR p_razon_social = '' THEN
        RETURN QUERY SELECT FALSE, 'La razón social es requerida'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar si el RFC ya existe
    SELECT EXISTS(
        SELECT 1 FROM informix.empresas
        WHERE rfc = UPPER(p_rfc) AND estado = 'A'
    ) INTO rfc_existe;

    IF rfc_existe THEN
        RETURN QUERY SELECT FALSE, 'El RFC ya está registrado en el sistema'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar nueva empresa
    INSERT INTO informix.empresas (
        rfc,
        razon_social,
        nombre_comercial,
        direccion,
        telefono,
        email,
        representante_legal,
        giro_empresarial,
        clasificacion,
        numero_empleados,
        observaciones,
        estado,
        usuario_creacion
    ) VALUES (
        UPPER(p_rfc),
        p_razon_social,
        p_nombre_comercial,
        p_direccion,
        p_telefono,
        p_email,
        p_representante_legal,
        p_giro_empresarial,
        p_clasificacion,
        p_numero_empleados,
        p_observaciones,
        'A',
        'sistema'
    ) RETURNING id INTO nuevo_id;

    RETURN QUERY SELECT TRUE, 'Empresa creada exitosamente'::TEXT, nuevo_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al crear empresa: ' || SQLERRM)::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 4. SP_EMPRESAS_UPDATE - Actualizar empresa existente
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_empresas_update(
    p_id INTEGER,
    p_rfc VARCHAR(13),
    p_razon_social VARCHAR(255),
    p_nombre_comercial VARCHAR(255) DEFAULT NULL,
    p_direccion TEXT DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_representante_legal VARCHAR(255) DEFAULT NULL,
    p_giro_empresarial VARCHAR(100) DEFAULT NULL,
    p_clasificacion VARCHAR(50) DEFAULT NULL,
    p_numero_empleados INTEGER DEFAULT NULL,
    p_estado CHAR(1) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    empresa_existe BOOLEAN;
    rfc_duplicado BOOLEAN;
BEGIN
    -- Verificar si la empresa existe
    SELECT EXISTS(
        SELECT 1 FROM informix.empresas
        WHERE id = p_id
    ) INTO empresa_existe;

    IF NOT empresa_existe THEN
        RETURN QUERY SELECT FALSE, 'La empresa no existe'::TEXT;
        RETURN;
    END IF;

    -- Verificar si el RFC ya existe en otra empresa
    SELECT EXISTS(
        SELECT 1 FROM informix.empresas
        WHERE rfc = UPPER(p_rfc) AND id != p_id AND estado = 'A'
    ) INTO rfc_duplicado;

    IF rfc_duplicado THEN
        RETURN QUERY SELECT FALSE, 'El RFC ya está registrado en otra empresa'::TEXT;
        RETURN;
    END IF;

    -- Actualizar empresa
    UPDATE informix.empresas SET
        rfc = UPPER(p_rfc),
        razon_social = p_razon_social,
        nombre_comercial = COALESCE(p_nombre_comercial, nombre_comercial),
        direccion = COALESCE(p_direccion, direccion),
        telefono = COALESCE(p_telefono, telefono),
        email = COALESCE(p_email, email),
        representante_legal = COALESCE(p_representante_legal, representante_legal),
        giro_empresarial = COALESCE(p_giro_empresarial, giro_empresarial),
        clasificacion = COALESCE(p_clasificacion, clasificacion),
        numero_empleados = COALESCE(p_numero_empleados, numero_empleados),
        estado = COALESCE(p_estado, estado),
        observaciones = COALESCE(p_observaciones, observaciones),
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Empresa actualizada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al actualizar empresa: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 5. SP_EMPRESAS_DELETE - Eliminar (inactivar) empresa
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_empresas_delete(
    p_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    empresa_existe BOOLEAN;
BEGIN
    -- Verificar si la empresa existe y está activa
    SELECT EXISTS(
        SELECT 1 FROM informix.empresas
        WHERE id = p_id AND estado = 'A'
    ) INTO empresa_existe;

    IF NOT empresa_existe THEN
        RETURN QUERY SELECT FALSE, 'La empresa no existe o ya está inactiva'::TEXT;
        RETURN;
    END IF;

    -- Inactivar empresa (soft delete)
    UPDATE informix.empresas SET
        estado = 'I',
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Empresa eliminada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al eliminar empresa: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 6. SP_EMPRESAS_SEARCH_BY_RFC - Buscar empresa por RFC
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_empresas_search_by_rfc(
    p_rfc VARCHAR(13)
)
RETURNS TABLE(
    id INTEGER,
    rfc VARCHAR(13),
    razon_social VARCHAR(255),
    nombre_comercial VARCHAR(255),
    estado CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.rfc,
        e.razon_social,
        e.nombre_comercial,
        e.estado
    FROM informix.empresas e
    WHERE e.rfc = UPPER(p_rfc)
    ORDER BY e.fecha_modificacion DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- DATOS DE PRUEBA
-- =====================================================================================

-- Insertar datos de prueba
INSERT INTO informix.empresas (
    rfc, razon_social, nombre_comercial, direccion, telefono, email,
    representante_legal, giro_empresarial, clasificacion, numero_empleados, observaciones
) VALUES
    ('AAA010101AAA', 'CONSTRUCTORA GUADALAJARA SA DE CV', 'Constructora GDL',
     'AV. REVOLUCIÓN 1234, COL. MODERNA, GUADALAJARA, JAL.', '33-1234-5678', 'contacto@constructoragdl.com',
     'JUAN PÉREZ LÓPEZ', 'CONSTRUCCIÓN', 'PRIVADA', 25,
     'Empresa constructora especializada en obra pública municipal'),

    ('BBB020202BBB', 'SERVICIOS MUNICIPALES DEL OCCIDENTE SC', 'ServiMuni Occidente',
     'CALLE INDEPENDENCIA 567, COL. CENTRO, GUADALAJARA, JAL.', '33-2345-6789', 'info@servimuni.com',
     'MARÍA GONZÁLEZ RUIZ', 'SERVICIOS MUNICIPALES', 'MIXTA', 45,
     'Prestación de servicios especializados para el gobierno municipal'),

    ('CCC030303CCC', 'TECNOLOGÍA E INNOVACIÓN URBANA SA', 'TecnoUrban',
     'AV. AMÉRICAS 890, COL. PROVIDENCIA, GUADALAJARA, JAL.', '33-3456-7890', 'ventas@tecnourban.mx',
     'CARLOS MARTÍNEZ TORRES', 'TECNOLOGÍA', 'PRIVADA', 15,
     'Desarrollo de soluciones tecnológicas para administración pública'),

    ('DDD040404DDD', 'LIMPIEZA Y MANTENIMIENTO INTEGRAL SA DE CV', 'LimpiezaTotal',
     'CALLE JUÁREZ 321, COL. AMERICANA, GUADALAJARA, JAL.', '33-4567-8901', 'admin@limpiezatotal.com',
     'ANA LÓPEZ HERNÁNDEZ', 'LIMPIEZA', 'PRIVADA', 80,
     'Servicios de limpieza y mantenimiento para espacios públicos'),

    ('EEE050505EEE', 'GOBIERNO MUNICIPAL DE GUADALAJARA', 'Ayuntamiento GDL',
     'AV. HIDALGO 400, COL. CENTRO, GUADALAJARA, JAL.', '33-3837-4300', 'transparencia@guadalajara.gob.mx',
     'PABLO LEMUS NAVARRO', 'ADMINISTRACIÓN PÚBLICA', 'PUBLICA', 2500,
     'Gobierno Municipal de Guadalajara - Entidad pública municipal');

-- =====================================================================================
-- PERMISOS Y COMENTARIOS
-- =====================================================================================

-- Comentarios en las tablas y funciones
COMMENT ON TABLE informix.empresas IS 'Catálogo de empresas del sistema municipal';
COMMENT ON FUNCTION informix.sp_empresas_list IS 'Lista empresas con filtros y paginación';
COMMENT ON FUNCTION informix.sp_empresas_get IS 'Obtiene una empresa por ID';
COMMENT ON FUNCTION informix.sp_empresas_create IS 'Crea una nueva empresa';
COMMENT ON FUNCTION informix.sp_empresas_update IS 'Actualiza una empresa existente';
COMMENT ON FUNCTION informix.sp_empresas_delete IS 'Elimina (inactiva) una empresa';
COMMENT ON FUNCTION informix.sp_empresas_search_by_rfc IS 'Busca empresa por RFC';

-- =====================================================================================
-- FIN DEL ARCHIVO
-- =====================================================================================