-- =====================================================================================
-- SISTEMA MUNICIPAL DIGITAL - GOBIERNO DE GUADALAJARA
-- =====================================================================================
-- Descripción: Stored Procedures para CRUD de Firmas Digitales
-- Autor: Sistema de Refactorización Vue.js
-- Fecha: 2025-09-29
-- Versión: 1.0
-- =====================================================================================

-- =====================================================================================
-- CREACIÓN DE ESQUEMA Y TABLA FIRMAS
-- =====================================================================================

-- Crear esquema informix si no existe
CREATE SCHEMA IF NOT EXISTS informix;

-- Crear tabla firmas_digitales
DROP TABLE IF EXISTS informix.firmas_digitales CASCADE;

CREATE TABLE informix.firmas_digitales (
    id SERIAL PRIMARY KEY,
    usuario_id VARCHAR(50) NOT NULL,
    nombre_completo VARCHAR(255) NOT NULL,
    firma_path TEXT NOT NULL,
    firma_imagen BYTEA,
    hash_firma VARCHAR(255),
    tipo_firma VARCHAR(20) DEFAULT 'DIGITAL' CHECK (tipo_firma IN ('DIGITAL', 'ESCANEADA', 'MANUSCRITA')),
    estado CHAR(1) DEFAULT 'A' CHECK (estado IN ('A', 'I', 'S')), -- A=Activa, I=Inactiva, S=Suspendida
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_activacion TIMESTAMP,
    fecha_vencimiento TIMESTAMP,
    observaciones TEXT,
    usuario_creacion VARCHAR(50) DEFAULT 'sistema',
    usuario_modificacion VARCHAR(50) DEFAULT 'sistema',

    -- Constraints
    UNIQUE(usuario_id, estado) -- Solo una firma activa por usuario
);

-- Crear índices
CREATE INDEX idx_firmas_usuario_id ON informix.firmas_digitales(usuario_id);
CREATE INDEX idx_firmas_estado ON informix.firmas_digitales(estado);
CREATE INDEX idx_firmas_tipo ON informix.firmas_digitales(tipo_firma);
CREATE INDEX idx_firmas_hash ON informix.firmas_digitales(hash_firma);

-- Trigger para actualizar fecha_modificacion
CREATE OR REPLACE FUNCTION informix.update_firmas_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_modificacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS tr_firmas_update_timestamp ON informix.firmas_digitales;
CREATE TRIGGER tr_firmas_update_timestamp
    BEFORE UPDATE ON informix.firmas_digitales
    FOR EACH ROW
    EXECUTE FUNCTION informix.update_firmas_timestamp();

-- =====================================================================================
-- 1. SP_FIRMA_LIST - Listar firmas con filtros y paginación
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_firma_list(
    p_usuario_id VARCHAR(50) DEFAULT NULL,
    p_tipo_firma VARCHAR(20) DEFAULT NULL,
    p_estado CHAR(1) DEFAULT NULL,
    p_limite INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    usuario_id VARCHAR(50),
    nombre_completo VARCHAR(255),
    firma_path TEXT,
    hash_firma VARCHAR(255),
    tipo_firma VARCHAR(20),
    estado CHAR(1),
    fecha_creacion TIMESTAMP,
    fecha_modificacion TIMESTAMP,
    fecha_activacion TIMESTAMP,
    fecha_vencimiento TIMESTAMP,
    observaciones TEXT,
    total_registros BIGINT
) AS $$
DECLARE
    total_count BIGINT;
BEGIN
    -- Contar total de registros que coinciden con los filtros
    SELECT COUNT(*) INTO total_count
    FROM informix.firmas_digitales f
    WHERE (p_usuario_id IS NULL OR f.usuario_id ILIKE '%' || p_usuario_id || '%')
      AND (p_tipo_firma IS NULL OR f.tipo_firma = p_tipo_firma)
      AND (p_estado IS NULL OR f.estado = p_estado);

    -- Retornar resultados paginados
    RETURN QUERY
    SELECT
        f.id,
        f.usuario_id,
        f.nombre_completo,
        f.firma_path,
        f.hash_firma,
        f.tipo_firma,
        f.estado,
        f.fecha_creacion,
        f.fecha_modificacion,
        f.fecha_activacion,
        f.fecha_vencimiento,
        f.observaciones,
        total_count as total_registros
    FROM informix.firmas_digitales f
    WHERE (p_usuario_id IS NULL OR f.usuario_id ILIKE '%' || p_usuario_id || '%')
      AND (p_tipo_firma IS NULL OR f.tipo_firma = p_tipo_firma)
      AND (p_estado IS NULL OR f.estado = p_estado)
    ORDER BY f.fecha_creacion DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 2. SP_FIRMA_GET - Obtener firma por ID
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_firma_get(
    p_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    usuario_id VARCHAR(50),
    nombre_completo VARCHAR(255),
    firma_path TEXT,
    hash_firma VARCHAR(255),
    tipo_firma VARCHAR(20),
    estado CHAR(1),
    fecha_creacion TIMESTAMP,
    fecha_modificacion TIMESTAMP,
    fecha_activacion TIMESTAMP,
    fecha_vencimiento TIMESTAMP,
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.id,
        f.usuario_id,
        f.nombre_completo,
        f.firma_path,
        f.hash_firma,
        f.tipo_firma,
        f.estado,
        f.fecha_creacion,
        f.fecha_modificacion,
        f.fecha_activacion,
        f.fecha_vencimiento,
        f.observaciones
    FROM informix.firmas_digitales f
    WHERE f.id = p_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 3. SP_FIRMA_CREATE - Crear nueva firma
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_firma_create(
    p_usuario_id VARCHAR(50),
    p_nombre_completo VARCHAR(255),
    p_firma_path TEXT,
    p_hash_firma VARCHAR(255) DEFAULT NULL,
    p_tipo_firma VARCHAR(20) DEFAULT 'DIGITAL',
    p_fecha_vencimiento TIMESTAMP DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id INTEGER
) AS $$
DECLARE
    nuevo_id INTEGER;
    firma_existe BOOLEAN;
BEGIN
    -- Validar datos requeridos
    IF p_usuario_id IS NULL OR p_usuario_id = '' THEN
        RETURN QUERY SELECT FALSE, 'El ID de usuario es requerido'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_nombre_completo IS NULL OR p_nombre_completo = '' THEN
        RETURN QUERY SELECT FALSE, 'El nombre completo es requerido'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_firma_path IS NULL OR p_firma_path = '' THEN
        RETURN QUERY SELECT FALSE, 'La ruta de la firma es requerida'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar si el usuario ya tiene una firma activa
    SELECT EXISTS(
        SELECT 1 FROM informix.firmas_digitales
        WHERE usuario_id = p_usuario_id AND estado = 'A'
    ) INTO firma_existe;

    IF firma_existe THEN
        -- Desactivar firma anterior
        UPDATE informix.firmas_digitales
        SET estado = 'I', usuario_modificacion = 'sistema'
        WHERE usuario_id = p_usuario_id AND estado = 'A';
    END IF;

    -- Insertar nueva firma
    INSERT INTO informix.firmas_digitales (
        usuario_id,
        nombre_completo,
        firma_path,
        hash_firma,
        tipo_firma,
        estado,
        fecha_activacion,
        fecha_vencimiento,
        observaciones,
        usuario_creacion
    ) VALUES (
        p_usuario_id,
        p_nombre_completo,
        p_firma_path,
        p_hash_firma,
        p_tipo_firma,
        'A',
        CURRENT_TIMESTAMP,
        p_fecha_vencimiento,
        p_observaciones,
        'sistema'
    ) RETURNING id INTO nuevo_id;

    RETURN QUERY SELECT TRUE, 'Firma creada exitosamente'::TEXT, nuevo_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al crear firma: ' || SQLERRM)::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 4. SP_FIRMA_UPDATE - Actualizar firma existente
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_firma_update(
    p_id INTEGER,
    p_nombre_completo VARCHAR(255),
    p_firma_path TEXT DEFAULT NULL,
    p_hash_firma VARCHAR(255) DEFAULT NULL,
    p_tipo_firma VARCHAR(20) DEFAULT NULL,
    p_estado CHAR(1) DEFAULT NULL,
    p_fecha_vencimiento TIMESTAMP DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    firma_existe BOOLEAN;
BEGIN
    -- Verificar si la firma existe
    SELECT EXISTS(
        SELECT 1 FROM informix.firmas_digitales
        WHERE id = p_id
    ) INTO firma_existe;

    IF NOT firma_existe THEN
        RETURN QUERY SELECT FALSE, 'La firma no existe'::TEXT;
        RETURN;
    END IF;

    -- Actualizar firma (solo campos no nulos)
    UPDATE informix.firmas_digitales SET
        nombre_completo = COALESCE(p_nombre_completo, nombre_completo),
        firma_path = COALESCE(p_firma_path, firma_path),
        hash_firma = COALESCE(p_hash_firma, hash_firma),
        tipo_firma = COALESCE(p_tipo_firma, tipo_firma),
        estado = COALESCE(p_estado, estado),
        fecha_vencimiento = COALESCE(p_fecha_vencimiento, fecha_vencimiento),
        observaciones = COALESCE(p_observaciones, observaciones),
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Firma actualizada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al actualizar firma: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 5. SP_FIRMA_DELETE - Eliminar (inactivar) firma
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_firma_delete(
    p_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    firma_existe BOOLEAN;
BEGIN
    -- Verificar si la firma existe
    SELECT EXISTS(
        SELECT 1 FROM informix.firmas_digitales
        WHERE id = p_id AND estado != 'I'
    ) INTO firma_existe;

    IF NOT firma_existe THEN
        RETURN QUERY SELECT FALSE, 'La firma no existe o ya está inactiva'::TEXT;
        RETURN;
    END IF;

    -- Inactivar firma (soft delete)
    UPDATE informix.firmas_digitales SET
        estado = 'I',
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Firma eliminada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al eliminar firma: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 6. SP_FIRMA_VALIDATE - Validar firma por hash
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_firma_validate(
    p_hash_firma VARCHAR(255)
)
RETURNS TABLE(
    is_valid BOOLEAN,
    usuario_id VARCHAR(50),
    nombre_completo VARCHAR(255),
    fecha_vencimiento TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN f.id IS NOT NULL AND f.estado = 'A' AND
                 (f.fecha_vencimiento IS NULL OR f.fecha_vencimiento > CURRENT_TIMESTAMP)
            THEN TRUE
            ELSE FALSE
        END as is_valid,
        f.usuario_id,
        f.nombre_completo,
        f.fecha_vencimiento
    FROM informix.firmas_digitales f
    WHERE f.hash_firma = p_hash_firma
    ORDER BY f.fecha_creacion DESC
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL::VARCHAR(50), NULL::VARCHAR(255), NULL::TIMESTAMP;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- DATOS DE PRUEBA
-- =====================================================================================

-- Insertar datos de prueba
INSERT INTO informix.firmas_digitales (
    usuario_id, nombre_completo, firma_path, hash_firma, tipo_firma, estado,
    fecha_activacion, fecha_vencimiento, observaciones
) VALUES
    ('ADMIN', 'Administrador Sistema', '/firmas/admin_firma.png',
     'sha256_admin_hash_123', 'DIGITAL', 'A',
     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 year',
     'Firma digital del administrador del sistema'),

    ('USER01', 'Juan Pérez García', '/firmas/jperez_firma.png',
     'sha256_jperez_hash_456', 'DIGITAL', 'A',
     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '6 months',
     'Firma digital del usuario operativo'),

    ('USER02', 'María López Hernández', '/firmas/mlopez_firma.png',
     'sha256_mlopez_hash_789', 'ESCANEADA', 'A',
     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 year',
     'Firma escaneada de funcionaria'),

    ('USER03', 'Carlos Ruiz Sánchez', '/firmas/cruiz_firma.png',
     'sha256_cruiz_hash_321', 'DIGITAL', 'S',
     CURRENT_TIMESTAMP - INTERVAL '1 month', CURRENT_TIMESTAMP + INTERVAL '6 months',
     'Firma suspendida temporalmente'),

    ('USER04', 'Ana Martínez Torres', '/firmas/amartinez_firma.png',
     'sha256_amartinez_hash_654', 'MANUSCRITA', 'I',
     CURRENT_TIMESTAMP - INTERVAL '2 months', CURRENT_TIMESTAMP - INTERVAL '1 month',
     'Firma manuscrita digitalizada - inactiva');

-- =====================================================================================
-- PERMISOS Y COMENTARIOS
-- =====================================================================================

-- Comentarios en las tablas y funciones
COMMENT ON TABLE informix.firmas_digitales IS 'Tabla de firmas digitales para autorización municipal';
COMMENT ON FUNCTION informix.sp_firma_list IS 'Lista firmas con filtros y paginación';
COMMENT ON FUNCTION informix.sp_firma_get IS 'Obtiene una firma por ID';
COMMENT ON FUNCTION informix.sp_firma_create IS 'Crea una nueva firma';
COMMENT ON FUNCTION informix.sp_firma_update IS 'Actualiza una firma existente';
COMMENT ON FUNCTION informix.sp_firma_delete IS 'Elimina (inactiva) una firma';
COMMENT ON FUNCTION informix.sp_firma_validate IS 'Valida una firma por hash';

-- =====================================================================================
-- FIN DEL ARCHIVO
-- =====================================================================================