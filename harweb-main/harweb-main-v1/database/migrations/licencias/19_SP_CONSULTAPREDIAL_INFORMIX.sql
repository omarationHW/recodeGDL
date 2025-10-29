-- =====================================================================================
-- SISTEMA MUNICIPAL DIGITAL - GOBIERNO DE GUADALAJARA
-- =====================================================================================
-- Descripción: Stored Procedures para Consulta Predial
-- Autor: Sistema de Refactorización Vue.js
-- Fecha: 2025-09-29
-- Versión: 1.0
-- =====================================================================================

-- =====================================================================================
-- CREACIÓN DE ESQUEMA Y TABLA PREDIAL
-- =====================================================================================

-- Crear esquema informix si no existe
CREATE SCHEMA IF NOT EXISTS informix;

-- Crear tabla predial_info
DROP TABLE IF EXISTS informix.predial_info CASCADE;

CREATE TABLE informix.predial_info (
    id SERIAL PRIMARY KEY,
    cuenta_predial VARCHAR(50) NOT NULL UNIQUE,
    propietario VARCHAR(255) NOT NULL,
    direccion TEXT NOT NULL,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno DECIMAL(12,2),
    superficie_construccion DECIMAL(12,2),
    uso_suelo VARCHAR(50),
    zona VARCHAR(50),
    valor_catastral DECIMAL(15,2),
    coordenada_x DECIMAL(10,6),
    coordenada_y DECIMAL(10,6),
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado CHAR(1) DEFAULT 'A' CHECK (estado IN ('A', 'I')),
    usuario_creacion VARCHAR(50) DEFAULT 'sistema',
    usuario_modificacion VARCHAR(50) DEFAULT 'sistema'
);

-- Crear índices
CREATE INDEX idx_predial_cuenta ON informix.predial_info(cuenta_predial);
CREATE INDEX idx_predial_propietario ON informix.predial_info(propietario);
CREATE INDEX idx_predial_direccion ON informix.predial_info(direccion);
CREATE INDEX idx_predial_colonia ON informix.predial_info(colonia);
CREATE INDEX idx_predial_uso_suelo ON informix.predial_info(uso_suelo);
CREATE INDEX idx_predial_estado ON informix.predial_info(estado);

-- Trigger para actualizar fecha_modificacion
CREATE OR REPLACE FUNCTION informix.update_predial_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_modificacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS tr_predial_update_timestamp ON informix.predial_info;
CREATE TRIGGER tr_predial_update_timestamp
    BEFORE UPDATE ON informix.predial_info
    FOR EACH ROW
    EXECUTE FUNCTION informix.update_predial_timestamp();

-- =====================================================================================
-- 1. SP_CONSULTAPREDIAL_LIST - Listar predios con filtros y paginación
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_consultapredial_list(
    p_cuenta_predial VARCHAR(50) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_direccion TEXT DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_limite INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno DECIMAL(12,2),
    superficie_construccion DECIMAL(12,2),
    uso_suelo VARCHAR(50),
    zona VARCHAR(50),
    valor_catastral DECIMAL(15,2),
    coordenada_x DECIMAL(10,6),
    coordenada_y DECIMAL(10,6),
    observaciones TEXT,
    fecha_registro TIMESTAMP,
    total_registros BIGINT
) AS $$
DECLARE
    total_count BIGINT;
BEGIN
    -- Contar total de registros que coinciden con los filtros
    SELECT COUNT(*) INTO total_count
    FROM informix.predial_info p
    WHERE p.estado = 'A'
      AND (p_cuenta_predial IS NULL OR p.cuenta_predial ILIKE '%' || p_cuenta_predial || '%')
      AND (p_propietario IS NULL OR p.propietario ILIKE '%' || p_propietario || '%')
      AND (p_direccion IS NULL OR p.direccion ILIKE '%' || p_direccion || '%')
      AND (p_colonia IS NULL OR p.colonia ILIKE '%' || p_colonia || '%');

    -- Retornar resultados paginados
    RETURN QUERY
    SELECT
        p.id,
        p.cuenta_predial,
        p.propietario,
        p.direccion,
        p.colonia,
        p.codigo_postal,
        p.superficie_terreno,
        p.superficie_construccion,
        p.uso_suelo,
        p.zona,
        p.valor_catastral,
        p.coordenada_x,
        p.coordenada_y,
        p.observaciones,
        p.fecha_registro,
        total_count as total_registros
    FROM informix.predial_info p
    WHERE p.estado = 'A'
      AND (p_cuenta_predial IS NULL OR p.cuenta_predial ILIKE '%' || p_cuenta_predial || '%')
      AND (p_propietario IS NULL OR p.propietario ILIKE '%' || p_propietario || '%')
      AND (p_direccion IS NULL OR p.direccion ILIKE '%' || p_direccion || '%')
      AND (p_colonia IS NULL OR p.colonia ILIKE '%' || p_colonia || '%')
    ORDER BY p.fecha_registro DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 2. SP_CONSULTAPREDIAL_GET - Obtener predio por ID
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_consultapredial_get(
    p_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno DECIMAL(12,2),
    superficie_construccion DECIMAL(12,2),
    uso_suelo VARCHAR(50),
    zona VARCHAR(50),
    valor_catastral DECIMAL(15,2),
    coordenada_x DECIMAL(10,6),
    coordenada_y DECIMAL(10,6),
    observaciones TEXT,
    fecha_registro TIMESTAMP,
    fecha_modificacion TIMESTAMP,
    estado CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.cuenta_predial,
        p.propietario,
        p.direccion,
        p.colonia,
        p.codigo_postal,
        p.superficie_terreno,
        p.superficie_construccion,
        p.uso_suelo,
        p.zona,
        p.valor_catastral,
        p.coordenada_x,
        p.coordenada_y,
        p.observaciones,
        p.fecha_registro,
        p.fecha_modificacion,
        p.estado
    FROM informix.predial_info p
    WHERE p.id = p_id AND p.estado = 'A';
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 3. SP_CONSULTAPREDIAL_CREATE - Crear nuevo predio
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_consultapredial_create(
    p_cuenta_predial VARCHAR(50),
    p_propietario VARCHAR(255),
    p_direccion TEXT,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_codigo_postal VARCHAR(10) DEFAULT NULL,
    p_superficie_terreno DECIMAL(12,2) DEFAULT NULL,
    p_superficie_construccion DECIMAL(12,2) DEFAULT NULL,
    p_uso_suelo VARCHAR(50) DEFAULT NULL,
    p_zona VARCHAR(50) DEFAULT NULL,
    p_valor_catastral DECIMAL(15,2) DEFAULT NULL,
    p_coordenada_x DECIMAL(10,6) DEFAULT NULL,
    p_coordenada_y DECIMAL(10,6) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id INTEGER
) AS $$
DECLARE
    nuevo_id INTEGER;
    cuenta_existe BOOLEAN;
BEGIN
    -- Validar datos requeridos
    IF p_cuenta_predial IS NULL OR p_cuenta_predial = '' THEN
        RETURN QUERY SELECT FALSE, 'La cuenta predial es requerida'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_propietario IS NULL OR p_propietario = '' THEN
        RETURN QUERY SELECT FALSE, 'El propietario es requerido'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_direccion IS NULL OR p_direccion = '' THEN
        RETURN QUERY SELECT FALSE, 'La dirección es requerida'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar si la cuenta predial ya existe
    SELECT EXISTS(
        SELECT 1 FROM informix.predial_info
        WHERE cuenta_predial = p_cuenta_predial AND estado = 'A'
    ) INTO cuenta_existe;

    IF cuenta_existe THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un predio con esta cuenta predial'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar nuevo predio
    INSERT INTO informix.predial_info (
        cuenta_predial,
        propietario,
        direccion,
        colonia,
        codigo_postal,
        superficie_terreno,
        superficie_construccion,
        uso_suelo,
        zona,
        valor_catastral,
        coordenada_x,
        coordenada_y,
        observaciones,
        estado,
        usuario_creacion
    ) VALUES (
        p_cuenta_predial,
        p_propietario,
        p_direccion,
        p_colonia,
        p_codigo_postal,
        p_superficie_terreno,
        p_superficie_construccion,
        p_uso_suelo,
        p_zona,
        p_valor_catastral,
        p_coordenada_x,
        p_coordenada_y,
        p_observaciones,
        'A',
        'sistema'
    ) RETURNING id INTO nuevo_id;

    RETURN QUERY SELECT TRUE, 'Predio creado exitosamente'::TEXT, nuevo_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al crear predio: ' || SQLERRM)::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 4. SP_CONSULTAPREDIAL_UPDATE - Actualizar predio existente
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_consultapredial_update(
    p_id INTEGER,
    p_propietario VARCHAR(255),
    p_direccion TEXT,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_codigo_postal VARCHAR(10) DEFAULT NULL,
    p_superficie_terreno DECIMAL(12,2) DEFAULT NULL,
    p_superficie_construccion DECIMAL(12,2) DEFAULT NULL,
    p_uso_suelo VARCHAR(50) DEFAULT NULL,
    p_zona VARCHAR(50) DEFAULT NULL,
    p_valor_catastral DECIMAL(15,2) DEFAULT NULL,
    p_coordenada_x DECIMAL(10,6) DEFAULT NULL,
    p_coordenada_y DECIMAL(10,6) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    predio_existe BOOLEAN;
BEGIN
    -- Validar datos requeridos
    IF p_propietario IS NULL OR p_propietario = '' THEN
        RETURN QUERY SELECT FALSE, 'El propietario es requerido'::TEXT;
        RETURN;
    END IF;

    IF p_direccion IS NULL OR p_direccion = '' THEN
        RETURN QUERY SELECT FALSE, 'La dirección es requerida'::TEXT;
        RETURN;
    END IF;

    -- Verificar si el predio existe
    SELECT EXISTS(
        SELECT 1 FROM informix.predial_info
        WHERE id = p_id AND estado = 'A'
    ) INTO predio_existe;

    IF NOT predio_existe THEN
        RETURN QUERY SELECT FALSE, 'El predio no existe o está inactivo'::TEXT;
        RETURN;
    END IF;

    -- Actualizar predio
    UPDATE informix.predial_info SET
        propietario = p_propietario,
        direccion = p_direccion,
        colonia = p_colonia,
        codigo_postal = p_codigo_postal,
        superficie_terreno = p_superficie_terreno,
        superficie_construccion = p_superficie_construccion,
        uso_suelo = p_uso_suelo,
        zona = p_zona,
        valor_catastral = p_valor_catastral,
        coordenada_x = p_coordenada_x,
        coordenada_y = p_coordenada_y,
        observaciones = p_observaciones,
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Predio actualizado exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al actualizar predio: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 5. SP_CONSULTAPREDIAL_DELETE - Eliminar (inactivar) predio
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_consultapredial_delete(
    p_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    predio_existe BOOLEAN;
BEGIN
    -- Verificar si el predio existe
    SELECT EXISTS(
        SELECT 1 FROM informix.predial_info
        WHERE id = p_id AND estado = 'A'
    ) INTO predio_existe;

    IF NOT predio_existe THEN
        RETURN QUERY SELECT FALSE, 'El predio no existe o ya está inactivo'::TEXT;
        RETURN;
    END IF;

    -- Inactivar predio (soft delete)
    UPDATE informix.predial_info SET
        estado = 'I',
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Predio eliminado exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al eliminar predio: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 6. SP_CONSULTAPREDIAL_SEARCH_BY_CUENTA - Buscar por cuenta predial exacta
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_consultapredial_search_by_cuenta(
    p_cuenta_predial VARCHAR(50)
)
RETURNS TABLE(
    id INTEGER,
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno DECIMAL(12,2),
    superficie_construccion DECIMAL(12,2),
    uso_suelo VARCHAR(50),
    zona VARCHAR(50),
    valor_catastral DECIMAL(15,2),
    coordenada_x DECIMAL(10,6),
    coordenada_y DECIMAL(10,6),
    observaciones TEXT,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.cuenta_predial,
        p.propietario,
        p.direccion,
        p.colonia,
        p.codigo_postal,
        p.superficie_terreno,
        p.superficie_construccion,
        p.uso_suelo,
        p.zona,
        p.valor_catastral,
        p.coordenada_x,
        p.coordenada_y,
        p.observaciones,
        p.fecha_registro
    FROM informix.predial_info p
    WHERE p.cuenta_predial = p_cuenta_predial AND p.estado = 'A';
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- DATOS DE PRUEBA
-- =====================================================================================

-- Insertar datos de prueba
INSERT INTO informix.predial_info (
    cuenta_predial, propietario, direccion, colonia, codigo_postal,
    superficie_terreno, superficie_construccion, uso_suelo, zona, valor_catastral,
    coordenada_x, coordenada_y, observaciones
) VALUES
    ('001-001-001-01', 'Juan Pérez García', 'Av. Revolución 1234', 'Centro', '44100',
     250.00, 180.00, 'COMERCIAL', 'ZONA A', 1250000.00,
     -103.350000, 20.676000, 'Predio comercial en zona centro'),

    ('001-001-002-01', 'María López Hernández', 'Calle Morelos 567', 'Americana', '44160',
     150.00, 120.00, 'HABITACIONAL', 'ZONA B', 850000.00,
     -103.360000, 20.686000, 'Casa habitación familiar'),

    ('001-002-001-01', 'Carlos Ruiz Sánchez', 'Av. Chapultepec 890', 'Chapultepec Norte', '44600',
     300.00, 250.00, 'MIXTO', 'ZONA A', 1800000.00,
     -103.340000, 20.696000, 'Uso mixto comercial y habitacional'),

    ('002-001-001-01', 'Ana Martínez Torres', 'Calle Independencia 345', 'San Juan de Dios', '44360',
     200.00, 160.00, 'COMERCIAL', 'ZONA C', 980000.00,
     -103.355000, 20.665000, 'Local comercial tradicional'),

    ('002-001-002-01', 'Roberto García Jiménez', 'Av. Federalismo 678', 'Mezquitán Country', '44260',
     400.00, 300.00, 'HABITACIONAL', 'ZONA A', 2200000.00,
     -103.370000, 20.706000, 'Casa residencial amplia');

-- =====================================================================================
-- PERMISOS Y COMENTARIOS
-- =====================================================================================

-- Comentarios en las tablas y funciones
COMMENT ON TABLE informix.predial_info IS 'Tabla de información predial para gestión municipal';
COMMENT ON FUNCTION informix.sp_consultapredial_list IS 'Lista predios con filtros y paginación';
COMMENT ON FUNCTION informix.sp_consultapredial_get IS 'Obtiene un predio por ID';
COMMENT ON FUNCTION informix.sp_consultapredial_create IS 'Crea un nuevo predio';
COMMENT ON FUNCTION informix.sp_consultapredial_update IS 'Actualiza un predio existente';
COMMENT ON FUNCTION informix.sp_consultapredial_delete IS 'Elimina (inactiva) un predio';
COMMENT ON FUNCTION informix.sp_consultapredial_search_by_cuenta IS 'Busca predio por cuenta exacta';

-- =====================================================================================
-- FIN DEL ARCHIVO
-- =====================================================================================