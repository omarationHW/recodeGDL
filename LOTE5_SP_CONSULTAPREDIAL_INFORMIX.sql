-- ============================================
-- LOTE 5 - CONSULTAPREDIAL (Consulta Predial)
-- STORED PROCEDURES MIGRADAS AL ESQUEMA INFORMIX
-- Base de datos: padron_licencias
-- Esquema: informix
-- Fecha: 2025-09-21
-- Crítico: Property lookup functionality
-- ============================================

\c padron_licencias;
SET search_path TO informix;

-- ============================================
-- TABLA: predial_info (esquema informix)
-- Tabla principal para información predial migrada de PostgreSQL a INFORMIX
-- ============================================

CREATE TABLE IF NOT EXISTS informix.predial_info (
    id SERIAL PRIMARY KEY,
    cuenta_predial VARCHAR(50) NOT NULL UNIQUE,
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno DECIMAL(10,2), -- INFORMIX: NUMERIC -> DECIMAL
    superficie_construccion DECIMAL(10,2),
    uso_suelo VARCHAR(100),
    zona VARCHAR(50),
    valor_catastral DECIMAL(15,2),
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    coordenada_x DECIMAL(12,6), -- INFORMIX: NUMERIC -> DECIMAL
    coordenada_y DECIMAL(12,6),
    observaciones TEXT,
    fecha_registro DATETIME YEAR TO FRACTION(3) DEFAULT CURRENT, -- INFORMIX: TIMESTAMP -> DATETIME
    fecha_actualizacion DATETIME YEAR TO FRACTION(3) DEFAULT CURRENT
);

-- Índices para optimización
CREATE INDEX IF NOT EXISTS idx_informix_predial_cuenta ON informix.predial_info(cuenta_predial);
CREATE INDEX IF NOT EXISTS idx_informix_predial_propietario ON informix.predial_info(propietario);
CREATE INDEX IF NOT EXISTS idx_informix_predial_direccion ON informix.predial_info(direccion);
CREATE INDEX IF NOT EXISTS idx_informix_predial_colonia ON informix.predial_info(colonia);
CREATE INDEX IF NOT EXISTS idx_informix_predial_estado ON informix.predial_info(estado);

-- ============================================
-- SP 1/4: SP_CONSULTAPREDIAL_LIST
-- Tipo: List/Read
-- Descripción: Lista información predial con filtros y paginación - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_CONSULTAPREDIAL_LIST(
    p_cuenta_predial VARCHAR(50) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_direccion TEXT DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno DECIMAL(10,2),
    superficie_construccion DECIMAL(10,2),
    uso_suelo VARCHAR(100),
    zona VARCHAR(50),
    valor_catastral DECIMAL(15,2),
    estado VARCHAR(20),
    coordenada_x DECIMAL(12,6),
    coordenada_y DECIMAL(12,6),
    observaciones TEXT,
    fecha_registro DATETIME YEAR TO FRACTION(3),
    fecha_actualizacion DATETIME YEAR TO FRACTION(3),
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM informix.predial_info pi
    WHERE (p_cuenta_predial IS NULL OR pi.cuenta_predial LIKE '%' || p_cuenta_predial || '%') -- INFORMIX: ILIKE -> LIKE
      AND (p_propietario IS NULL OR UPPER(pi.propietario) LIKE '%' || UPPER(p_propietario) || '%')
      AND (p_direccion IS NULL OR UPPER(pi.direccion) LIKE '%' || UPPER(p_direccion) || '%')
      AND (p_colonia IS NULL OR UPPER(pi.colonia) LIKE '%' || UPPER(p_colonia) || '%')
      AND pi.estado = 'ACTIVO';

    -- Retornar resultados paginados
    RETURN QUERY
    SELECT
        pi.id,
        pi.cuenta_predial,
        pi.propietario,
        pi.direccion,
        pi.colonia,
        pi.codigo_postal,
        pi.superficie_terreno,
        pi.superficie_construccion,
        pi.uso_suelo,
        pi.zona,
        pi.valor_catastral,
        pi.estado,
        pi.coordenada_x,
        pi.coordenada_y,
        pi.observaciones,
        pi.fecha_registro,
        pi.fecha_actualizacion,
        v_total_count as total_registros
    FROM informix.predial_info pi
    WHERE (p_cuenta_predial IS NULL OR pi.cuenta_predial LIKE '%' || p_cuenta_predial || '%')
      AND (p_propietario IS NULL OR UPPER(pi.propietario) LIKE '%' || UPPER(p_propietario) || '%')
      AND (p_direccion IS NULL OR UPPER(pi.direccion) LIKE '%' || UPPER(p_direccion) || '%')
      AND (p_colonia IS NULL OR UPPER(pi.colonia) LIKE '%' || UPPER(p_colonia) || '%')
      AND pi.estado = 'ACTIVO'
    ORDER BY pi.fecha_actualizacion DESC, pi.id DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================
-- SP 2/4: SP_CONSULTAPREDIAL_GET
-- Tipo: Read
-- Descripción: Obtiene detalle específico de un predio por cuenta predial - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_CONSULTAPREDIAL_GET(p_cuenta_predial VARCHAR(50))
RETURNS TABLE(
    id INTEGER,
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno DECIMAL(10,2),
    superficie_construccion DECIMAL(10,2),
    uso_suelo VARCHAR(100),
    zona VARCHAR(50),
    valor_catastral DECIMAL(15,2),
    estado VARCHAR(20),
    coordenada_x DECIMAL(12,6),
    coordenada_y DECIMAL(12,6),
    observaciones TEXT,
    fecha_registro DATETIME YEAR TO FRACTION(3),
    fecha_actualizacion DATETIME YEAR TO FRACTION(3)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que la cuenta predial existe
    SELECT COUNT(*) INTO v_exists
    FROM informix.predial_info
    WHERE cuenta_predial = p_cuenta_predial AND estado = 'ACTIVO';

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró información para la cuenta predial: %', p_cuenta_predial;
    END IF;

    -- Retornar el registro
    RETURN QUERY
    SELECT
        pi.id,
        pi.cuenta_predial,
        pi.propietario,
        pi.direccion,
        pi.colonia,
        pi.codigo_postal,
        pi.superficie_terreno,
        pi.superficie_construccion,
        pi.uso_suelo,
        pi.zona,
        pi.valor_catastral,
        pi.estado,
        pi.coordenada_x,
        pi.coordenada_y,
        pi.observaciones,
        pi.fecha_registro,
        pi.fecha_actualizacion
    FROM informix.predial_info pi
    WHERE pi.cuenta_predial = p_cuenta_predial
      AND pi.estado = 'ACTIVO';
END;
$$;

-- ============================================
-- SP 3/4: SP_CONSULTAPREDIAL_CREATE
-- Tipo: Create
-- Descripción: Crea un nuevo registro predial - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_CONSULTAPREDIAL_CREATE(
    p_cuenta_predial VARCHAR(50),
    p_propietario VARCHAR(255),
    p_direccion TEXT,
    p_colonia VARCHAR(100),
    p_codigo_postal VARCHAR(10) DEFAULT NULL,
    p_superficie_terreno DECIMAL(10,2) DEFAULT NULL,
    p_superficie_construccion DECIMAL(10,2) DEFAULT NULL,
    p_uso_suelo VARCHAR(100) DEFAULT NULL,
    p_zona VARCHAR(50) DEFAULT NULL,
    p_valor_catastral DECIMAL(15,2) DEFAULT NULL,
    p_coordenada_x DECIMAL(12,6) DEFAULT NULL,
    p_coordenada_y DECIMAL(12,6) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT, id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_exists INTEGER;
BEGIN
    -- Validar campos requeridos
    IF p_cuenta_predial IS NULL OR TRIM(p_cuenta_predial) = '' THEN
        RETURN QUERY SELECT FALSE, 'La cuenta predial es requerida.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_propietario IS NULL OR TRIM(p_propietario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El propietario es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_direccion IS NULL OR TRIM(p_direccion) = '' THEN
        RETURN QUERY SELECT FALSE, 'La dirección es requerida.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no exista la cuenta predial
    SELECT COUNT(*) INTO v_exists
    FROM informix.predial_info
    WHERE cuenta_predial = UPPER(TRIM(p_cuenta_predial));

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un registro con esa cuenta predial.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el nuevo registro
    INSERT INTO informix.predial_info (
        cuenta_predial, propietario, direccion, colonia, codigo_postal,
        superficie_terreno, superficie_construccion, uso_suelo, zona,
        valor_catastral, coordenada_x, coordenada_y, observaciones
    )
    VALUES (
        UPPER(TRIM(p_cuenta_predial)),
        UPPER(TRIM(p_propietario)),
        UPPER(TRIM(p_direccion)),
        UPPER(TRIM(p_colonia)),
        p_codigo_postal,
        p_superficie_terreno,
        p_superficie_construccion,
        UPPER(TRIM(p_uso_suelo)),
        UPPER(TRIM(p_zona)),
        p_valor_catastral,
        p_coordenada_x,
        p_coordenada_y,
        p_observaciones
    )
    RETURNING informix.predial_info.id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro predial creado correctamente.', v_new_id;
END;
$$;

-- ============================================
-- SP 4/4: SP_CONSULTAPREDIAL_UPDATE
-- Tipo: Update
-- Descripción: Actualiza información predial existente - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_CONSULTAPREDIAL_UPDATE(
    p_id INTEGER,
    p_propietario VARCHAR(255),
    p_direccion TEXT,
    p_colonia VARCHAR(100),
    p_codigo_postal VARCHAR(10) DEFAULT NULL,
    p_superficie_terreno DECIMAL(10,2) DEFAULT NULL,
    p_superficie_construccion DECIMAL(10,2) DEFAULT NULL,
    p_uso_suelo VARCHAR(100) DEFAULT NULL,
    p_zona VARCHAR(50) DEFAULT NULL,
    p_valor_catastral DECIMAL(15,2) DEFAULT NULL,
    p_coordenada_x DECIMAL(12,6) DEFAULT NULL,
    p_coordenada_y DECIMAL(12,6) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que el ID existe
    SELECT COUNT(*) INTO v_exists
    FROM informix.predial_info
    WHERE id = p_id AND estado = 'ACTIVO';

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El registro predial no existe o está inactivo.';
        RETURN;
    END IF;

    -- Validar campos requeridos
    IF p_propietario IS NULL OR TRIM(p_propietario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El propietario es requerido.';
        RETURN;
    END IF;

    IF p_direccion IS NULL OR TRIM(p_direccion) = '' THEN
        RETURN QUERY SELECT FALSE, 'La dirección es requerida.';
        RETURN;
    END IF;

    -- Actualizar el registro
    UPDATE informix.predial_info
    SET propietario = UPPER(TRIM(p_propietario)),
        direccion = UPPER(TRIM(p_direccion)),
        colonia = UPPER(TRIM(p_colonia)),
        codigo_postal = p_codigo_postal,
        superficie_terreno = p_superficie_terreno,
        superficie_construccion = p_superficie_construccion,
        uso_suelo = UPPER(TRIM(p_uso_suelo)),
        zona = UPPER(TRIM(p_zona)),
        valor_catastral = p_valor_catastral,
        coordenada_x = p_coordenada_x,
        coordenada_y = p_coordenada_y,
        observaciones = p_observaciones,
        fecha_actualizacion = CURRENT -- INFORMIX: CURRENT_TIMESTAMP -> CURRENT
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Registro predial actualizado correctamente.';
END;
$$;

-- ============================================
-- FUNCIÓN AUXILIAR PARA TRIGGER - INFORMIX Compatible
-- ============================================

CREATE OR REPLACE FUNCTION informix.actualizar_fecha_modificacion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT; -- INFORMIX: CURRENT_TIMESTAMP -> CURRENT
    RETURN NEW;
END;
$$;

-- Trigger para actualización automática de fecha
DROP TRIGGER IF EXISTS tr_actualizar_predial_fecha_informix ON informix.predial_info;
CREATE TRIGGER tr_actualizar_predial_fecha_informix
    BEFORE UPDATE ON informix.predial_info
    FOR EACH ROW
    EXECUTE FUNCTION informix.actualizar_fecha_modificacion();

-- ============================================
-- DATOS DE PRUEBA PARA INFORMIX SCHEMA
-- ============================================

INSERT INTO informix.predial_info (
    cuenta_predial, propietario, direccion, colonia, codigo_postal,
    superficie_terreno, superficie_construccion, uso_suelo, zona,
    valor_catastral, coordenada_x, coordenada_y, observaciones
) VALUES
    ('001-001-001-INF', 'JUAN PÉREZ GARCÍA', 'AV. JUÁREZ #123', 'CENTRO', '44100',
     150.00, 120.00, 'COMERCIAL', 'ZONA A', 250000.00,
     -103.350, 20.676, 'Predio para licencia comercial - INFORMIX'),
    ('001-001-002-INF', 'MARÍA LÓPEZ HERNÁNDEZ', 'CALLE MORELOS #456', 'REFORMA', '44200',
     200.00, 180.00, 'HABITACIONAL', 'ZONA B', 350000.00,
     -103.351, 20.677, 'Uso habitacional con potencial comercial - INFORMIX'),
    ('001-001-003-INF', 'EMPRESA CONSTRUCTORA SA', 'BLVD. UNIVERSIDAD #789', 'UNIVERSITARIA', '44300',
     500.00, 400.00, 'INDUSTRIAL', 'ZONA C', 1500000.00,
     -103.352, 20.678, 'Predio industrial para licencia de funcionamiento - INFORMIX'),
    ('001-001-004-INF', 'COMERCIAL GUADALAJARA SA', 'AV. REVOLUCIÓN #1010', 'AMERICANA', '44150',
     300.00, 250.00, 'COMERCIAL', 'ZONA A', 750000.00,
     -103.353, 20.679, 'Plaza comercial con múltiples locales - INFORMIX'),
    ('001-001-005-INF', 'SERVICIOS TÉCNICOS ESPECIALIZADOS SC', 'CALLE INDEPENDENCIA #2020', 'CENTRO', '44100',
     120.00, 100.00, 'SERVICIOS', 'ZONA A', 400000.00,
     -103.354, 20.680, 'Oficinas para servicios técnicos - INFORMIX')
ON CONFLICT (cuenta_predial) DO NOTHING;

-- ============================================
-- COMENTARIOS DE MIGRACIÓN INFORMIX
-- ============================================

/*
CAMBIOS ESPECÍFICOS PARA INFORMIX:

1. Tipos de datos:
   - NUMERIC -> DECIMAL
   - TIMESTAMP -> DATETIME YEAR TO FRACTION(3)
   - CURRENT_TIMESTAMP -> CURRENT

2. Funciones de cadena:
   - ILIKE -> LIKE con UPPER() para case insensitive
   - TRIM mantiene la misma sintaxis

3. Esquema:
   - Todas las funciones movidas al esquema informix
   - Índices ajustados con prefijo informix
   - Tablas referenciadas con esquema informix
   - Trigger renombrado con sufijo informix

4. Compatibilidad mantenida:
   - Misma estructura de parámetros
   - Mismos nombres de funciones con prefijo de esquema
   - Misma lógica de negocio
   - Validaciones idénticas

5. Datos de prueba:
   - Cuentas prediales específicas para INFORMIX (sufijo -INF)
   - Observaciones marcadas con INFORMIX para identificación
   - Mayor variedad de tipos de uso de suelo

VALIDACIONES IMPLEMENTADAS:
- Campos requeridos: cuenta_predial, propietario, direccion
- Cuenta predial única
- Registro activo para consultas
- Conversión automática a mayúsculas
- Control de estados (ACTIVO/INACTIVO)

ENDPOINTS SUGERIDOS:
- consultaPredialList -> informix.SP_CONSULTAPREDIAL_LIST(filtros, limite, offset)
- consultaPredialGet -> informix.SP_CONSULTAPREDIAL_GET(cuenta_predial)
- consultaPredialCreate -> informix.SP_CONSULTAPREDIAL_CREATE(datos completos)
- consultaPredialUpdate -> informix.SP_CONSULTAPREDIAL_UPDATE(id, datos)
*/