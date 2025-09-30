-- =====================================================================================
-- SISTEMA MUNICIPAL DIGITAL - GOBIERNO DE GUADALAJARA
-- =====================================================================================
-- Descripción: Stored Procedures para Búsqueda General Catastral y Municipal
-- Autor: Sistema de Refactorización Vue.js
-- Fecha: 2025-09-29
-- Versión: 1.0
-- =====================================================================================

-- =====================================================================================
-- CREACIÓN DE ESQUEMA Y TABLAS DE BÚSQUEDA
-- =====================================================================================

-- Crear esquema informix si no existe
CREATE SCHEMA IF NOT EXISTS informix;

-- Tabla para búsquedas catastrales unificadas
DROP TABLE IF EXISTS informix.busqueda_catastral CASCADE;

CREATE TABLE informix.busqueda_catastral (
    id SERIAL PRIMARY KEY,

    -- Identificadores
    clave_catastral VARCHAR(20),
    zona VARCHAR(5),
    manzana VARCHAR(3),
    predio VARCHAR(4),
    subpredio VARCHAR(3),

    -- Cuenta predial
    recaudadora INTEGER,
    urbano_rustico CHAR(1) CHECK (urbano_rustico IN ('U', 'R')),
    cuenta_predial BIGINT,

    -- Propietario
    nombre_propietario VARCHAR(255),
    rfc_propietario VARCHAR(13),

    -- Ubicación
    calle VARCHAR(255),
    numero_exterior VARCHAR(10),
    numero_interior VARCHAR(10),
    colonia VARCHAR(100),
    codigo_postal VARCHAR(5),

    -- Datos del predio
    superficie_terreno DECIMAL(10,2),
    superficie_construccion DECIMAL(10,2),
    valor_catastral DECIMAL(12,2),
    valor_fiscal DECIMAL(12,2),

    -- Estado
    estado VARCHAR(20) DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO', 'INACTIVO', 'SUSPENDIDO')),

    -- Control
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para búsquedas optimizadas
CREATE INDEX idx_busqueda_clave ON informix.busqueda_catastral(clave_catastral);
CREATE INDEX idx_busqueda_zona_manzana ON informix.busqueda_catastral(zona, manzana, predio);
CREATE INDEX idx_busqueda_cuenta ON informix.busqueda_catastral(recaudadora, urbano_rustico, cuenta_predial);
CREATE INDEX idx_busqueda_propietario ON informix.busqueda_catastral(nombre_propietario);
CREATE INDEX idx_busqueda_rfc ON informix.busqueda_catastral(rfc_propietario);
CREATE INDEX idx_busqueda_calle ON informix.busqueda_catastral(calle);

-- =====================================================================================
-- 1. SP_BUSQUEDA_POR_NOMBRE - Búsqueda por nombre del propietario
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_busqueda_por_nombre(
    p_nombre_propietario VARCHAR(255)
)
RETURNS TABLE(
    clave_catastral VARCHAR(20),
    zona VARCHAR(5),
    manzana VARCHAR(3),
    predio VARCHAR(4),
    cuenta_predial BIGINT,
    nombre_propietario VARCHAR(255),
    rfc_propietario VARCHAR(13),
    calle VARCHAR(255),
    numero_exterior VARCHAR(10),
    colonia VARCHAR(100),
    valor_catastral DECIMAL(12,2),
    estado VARCHAR(20)
) AS $$
BEGIN
    IF p_nombre_propietario IS NULL OR LENGTH(TRIM(p_nombre_propietario)) < 3 THEN
        RAISE EXCEPTION 'El nombre debe tener al menos 3 caracteres';
    END IF;

    RETURN QUERY
    SELECT
        bc.clave_catastral,
        bc.zona,
        bc.manzana,
        bc.predio,
        bc.cuenta_predial,
        bc.nombre_propietario,
        bc.rfc_propietario,
        bc.calle,
        bc.numero_exterior,
        bc.colonia,
        bc.valor_catastral,
        bc.estado
    FROM informix.busqueda_catastral bc
    WHERE bc.nombre_propietario ILIKE '%' || UPPER(TRIM(p_nombre_propietario)) || '%'
      AND bc.estado = 'ACTIVO'
    ORDER BY bc.nombre_propietario
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 2. SP_BUSQUEDA_POR_UBICACION - Búsqueda por dirección
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_busqueda_por_ubicacion(
    p_calle VARCHAR(255),
    p_numero_exterior VARCHAR(10) DEFAULT NULL
)
RETURNS TABLE(
    clave_catastral VARCHAR(20),
    zona VARCHAR(5),
    manzana VARCHAR(3),
    predio VARCHAR(4),
    cuenta_predial BIGINT,
    nombre_propietario VARCHAR(255),
    calle VARCHAR(255),
    numero_exterior VARCHAR(10),
    numero_interior VARCHAR(10),
    colonia VARCHAR(100),
    valor_catastral DECIMAL(12,2)
) AS $$
BEGIN
    IF p_calle IS NULL OR LENGTH(TRIM(p_calle)) < 3 THEN
        RAISE EXCEPTION 'El nombre de la calle debe tener al menos 3 caracteres';
    END IF;

    RETURN QUERY
    SELECT
        bc.clave_catastral,
        bc.zona,
        bc.manzana,
        bc.predio,
        bc.cuenta_predial,
        bc.nombre_propietario,
        bc.calle,
        bc.numero_exterior,
        bc.numero_interior,
        bc.colonia,
        bc.valor_catastral
    FROM informix.busqueda_catastral bc
    WHERE bc.calle ILIKE '%' || UPPER(TRIM(p_calle)) || '%'
      AND (p_numero_exterior IS NULL OR bc.numero_exterior = p_numero_exterior)
      AND bc.estado = 'ACTIVO'
    ORDER BY bc.calle, bc.numero_exterior
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 3. SP_BUSQUEDA_POR_CLAVE_CATASTRAL - Búsqueda por clave catastral
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_busqueda_por_clave_catastral(
    p_zona VARCHAR(5),
    p_manzana VARCHAR(3),
    p_predio VARCHAR(4) DEFAULT NULL,
    p_subpredio VARCHAR(3) DEFAULT NULL
)
RETURNS TABLE(
    clave_catastral VARCHAR(20),
    zona VARCHAR(5),
    manzana VARCHAR(3),
    predio VARCHAR(4),
    subpredio VARCHAR(3),
    cuenta_predial BIGINT,
    nombre_propietario VARCHAR(255),
    rfc_propietario VARCHAR(13),
    calle VARCHAR(255),
    numero_exterior VARCHAR(10),
    colonia VARCHAR(100),
    superficie_terreno DECIMAL(10,2),
    superficie_construccion DECIMAL(10,2),
    valor_catastral DECIMAL(12,2),
    valor_fiscal DECIMAL(12,2)
) AS $$
BEGIN
    IF p_zona IS NULL OR p_manzana IS NULL THEN
        RAISE EXCEPTION 'Zona y manzana son requeridos';
    END IF;

    RETURN QUERY
    SELECT
        bc.clave_catastral,
        bc.zona,
        bc.manzana,
        bc.predio,
        bc.subpredio,
        bc.cuenta_predial,
        bc.nombre_propietario,
        bc.rfc_propietario,
        bc.calle,
        bc.numero_exterior,
        bc.colonia,
        bc.superficie_terreno,
        bc.superficie_construccion,
        bc.valor_catastral,
        bc.valor_fiscal
    FROM informix.busqueda_catastral bc
    WHERE bc.zona = p_zona
      AND bc.manzana = p_manzana
      AND (p_predio IS NULL OR bc.predio = p_predio)
      AND (p_subpredio IS NULL OR bc.subpredio = p_subpredio)
      AND bc.estado = 'ACTIVO'
    ORDER BY bc.predio, bc.subpredio
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 4. SP_BUSQUEDA_POR_RFC - Búsqueda por RFC
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_busqueda_por_rfc(
    p_rfc_propietario VARCHAR(13)
)
RETURNS TABLE(
    clave_catastral VARCHAR(20),
    zona VARCHAR(5),
    manzana VARCHAR(3),
    predio VARCHAR(4),
    cuenta_predial BIGINT,
    nombre_propietario VARCHAR(255),
    rfc_propietario VARCHAR(13),
    calle VARCHAR(255),
    numero_exterior VARCHAR(10),
    colonia VARCHAR(100),
    valor_catastral DECIMAL(12,2),
    total_propiedades BIGINT
) AS $$
DECLARE
    total_count BIGINT;
BEGIN
    IF p_rfc_propietario IS NULL OR LENGTH(TRIM(p_rfc_propietario)) < 10 THEN
        RAISE EXCEPTION 'RFC debe tener al menos 10 caracteres';
    END IF;

    -- Contar total de propiedades para este RFC
    SELECT COUNT(*) INTO total_count
    FROM informix.busqueda_catastral
    WHERE rfc_propietario = UPPER(TRIM(p_rfc_propietario))
      AND estado = 'ACTIVO';

    RETURN QUERY
    SELECT
        bc.clave_catastral,
        bc.zona,
        bc.manzana,
        bc.predio,
        bc.cuenta_predial,
        bc.nombre_propietario,
        bc.rfc_propietario,
        bc.calle,
        bc.numero_exterior,
        bc.colonia,
        bc.valor_catastral,
        total_count as total_propiedades
    FROM informix.busqueda_catastral bc
    WHERE bc.rfc_propietario = UPPER(TRIM(p_rfc_propietario))
      AND bc.estado = 'ACTIVO'
    ORDER BY bc.valor_catastral DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 5. SP_BUSQUEDA_POR_CUENTA - Búsqueda por cuenta predial
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_busqueda_por_cuenta(
    p_recaudadora INTEGER,
    p_urbano_rustico CHAR(1),
    p_cuenta_predial BIGINT
)
RETURNS TABLE(
    clave_catastral VARCHAR(20),
    zona VARCHAR(5),
    manzana VARCHAR(3),
    predio VARCHAR(4),
    subpredio VARCHAR(3),
    recaudadora INTEGER,
    urbano_rustico CHAR(1),
    cuenta_predial BIGINT,
    nombre_propietario VARCHAR(255),
    rfc_propietario VARCHAR(13),
    calle VARCHAR(255),
    numero_exterior VARCHAR(10),
    colonia VARCHAR(100),
    superficie_terreno DECIMAL(10,2),
    superficie_construccion DECIMAL(10,2),
    valor_catastral DECIMAL(12,2),
    valor_fiscal DECIMAL(12,2),
    codigo_postal VARCHAR(5)
) AS $$
BEGIN
    IF p_recaudadora IS NULL OR p_urbano_rustico IS NULL OR p_cuenta_predial IS NULL THEN
        RAISE EXCEPTION 'Recaudadora, tipo y cuenta son requeridos';
    END IF;

    RETURN QUERY
    SELECT
        bc.clave_catastral,
        bc.zona,
        bc.manzana,
        bc.predio,
        bc.subpredio,
        bc.recaudadora,
        bc.urbano_rustico,
        bc.cuenta_predial,
        bc.nombre_propietario,
        bc.rfc_propietario,
        bc.calle,
        bc.numero_exterior,
        bc.colonia,
        bc.superficie_terreno,
        bc.superficie_construccion,
        bc.valor_catastral,
        bc.valor_fiscal,
        bc.codigo_postal
    FROM informix.busqueda_catastral bc
    WHERE bc.recaudadora = p_recaudadora
      AND bc.urbano_rustico = UPPER(p_urbano_rustico)
      AND bc.cuenta_predial = p_cuenta_predial
      AND bc.estado = 'ACTIVO'
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 6. SP_BUSQUEDA_AVANZADA - Búsqueda combinada con múltiples criterios
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_busqueda_avanzada(
    p_nombre_propietario VARCHAR(255) DEFAULT NULL,
    p_rfc_propietario VARCHAR(13) DEFAULT NULL,
    p_calle VARCHAR(255) DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_zona VARCHAR(5) DEFAULT NULL,
    p_valor_minimo DECIMAL(12,2) DEFAULT NULL,
    p_valor_maximo DECIMAL(12,2) DEFAULT NULL,
    p_limite INTEGER DEFAULT 50
)
RETURNS TABLE(
    clave_catastral VARCHAR(20),
    cuenta_predial BIGINT,
    nombre_propietario VARCHAR(255),
    rfc_propietario VARCHAR(13),
    direccion_completa TEXT,
    valor_catastral DECIMAL(12,2),
    superficie_total DECIMAL(10,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        bc.clave_catastral,
        bc.cuenta_predial,
        bc.nombre_propietario,
        bc.rfc_propietario,
        (bc.calle || ' ' || COALESCE(bc.numero_exterior, '') ||
         ', COL. ' || COALESCE(bc.colonia, '')) as direccion_completa,
        bc.valor_catastral,
        (COALESCE(bc.superficie_terreno, 0) + COALESCE(bc.superficie_construccion, 0)) as superficie_total
    FROM informix.busqueda_catastral bc
    WHERE (p_nombre_propietario IS NULL OR bc.nombre_propietario ILIKE '%' || p_nombre_propietario || '%')
      AND (p_rfc_propietario IS NULL OR bc.rfc_propietario = UPPER(p_rfc_propietario))
      AND (p_calle IS NULL OR bc.calle ILIKE '%' || p_calle || '%')
      AND (p_colonia IS NULL OR bc.colonia ILIKE '%' || p_colonia || '%')
      AND (p_zona IS NULL OR bc.zona = p_zona)
      AND (p_valor_minimo IS NULL OR bc.valor_catastral >= p_valor_minimo)
      AND (p_valor_maximo IS NULL OR bc.valor_catastral <= p_valor_maximo)
      AND bc.estado = 'ACTIVO'
    ORDER BY bc.valor_catastral DESC
    LIMIT p_limite;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- DATOS DE PRUEBA
-- =====================================================================================

-- Insertar datos de prueba
INSERT INTO informix.busqueda_catastral (
    clave_catastral, zona, manzana, predio, subpredio,
    recaudadora, urbano_rustico, cuenta_predial,
    nombre_propietario, rfc_propietario,
    calle, numero_exterior, colonia, codigo_postal,
    superficie_terreno, superficie_construccion,
    valor_catastral, valor_fiscal, estado
) VALUES
    ('01001001000', '01', '001', '001', '000', 1, 'U', 1001001000,
     'JUAN PÉREZ LÓPEZ', 'PELJ800515XXX',
     'AV. JUÁREZ', '123', 'CENTRO', '44100',
     120.50, 85.30, 450000.00, 420000.00, 'ACTIVO'),

    ('01001002000', '01', '001', '002', '000', 1, 'U', 1001002000,
     'MARÍA GONZÁLEZ RUIZ', 'GORM900820XXX',
     'CALLE INDEPENDENCIA', '456', 'AMERICANA', '44160',
     200.75, 150.25, 780000.00, 720000.00, 'ACTIVO'),

    ('01002001000', '01', '002', '001', '000', 1, 'U', 1002001000,
     'CARLOS MARTÍNEZ TORRES', 'MATC750310XXX',
     'AV. AMÉRICAS', '789', 'PROVIDENCIA', '44630',
     300.00, 250.50, 1200000.00, 1100000.00, 'ACTIVO'),

    ('02001001000', '02', '001', '001', '000', 1, 'U', 2001001000,
     'ANA LÓPEZ HERNÁNDEZ', 'LOHA850925XXX',
     'CALLE MORELOS', '321', 'ANALCO', '44450',
     95.25, 75.80, 320000.00, 295000.00, 'ACTIVO'),

    ('02001002000', '02', '001', '002', '000', 1, 'U', 2001002000,
     'ROBERTO SÁNCHEZ DÍAZ', 'SADR700215XXX',
     'AV. REVOLUCIÓN', '654', 'MODERNA', '44190',
     180.40, 130.60, 650000.00, 590000.00, 'ACTIVO');

-- =====================================================================================
-- PERMISOS Y COMENTARIOS
-- =====================================================================================

-- Comentarios en las tablas y funciones
COMMENT ON TABLE informix.busqueda_catastral IS 'Datos catastrales unificados para búsquedas';
COMMENT ON FUNCTION informix.sp_busqueda_por_nombre IS 'Búsqueda por nombre del propietario';
COMMENT ON FUNCTION informix.sp_busqueda_por_ubicacion IS 'Búsqueda por dirección';
COMMENT ON FUNCTION informix.sp_busqueda_por_clave_catastral IS 'Búsqueda por clave catastral';
COMMENT ON FUNCTION informix.sp_busqueda_por_rfc IS 'Búsqueda por RFC del propietario';
COMMENT ON FUNCTION informix.sp_busqueda_por_cuenta IS 'Búsqueda por cuenta predial';
COMMENT ON FUNCTION informix.sp_busqueda_avanzada IS 'Búsqueda avanzada con múltiples criterios';

-- =====================================================================================
-- FIN DEL ARCHIVO
-- =====================================================================================