-- ============================================
-- INSTALACIÓN COMPLETA DE STORED PROCEDURES
-- MÓDULO: LICENCIAS
-- BASE DE DATOS: padron_licencias
-- ESQUEMA: informix
-- FECHA: 2025-09-17
-- ============================================

-- Conectar a la base de datos
\c padron_licencias;

-- Crear esquema informix si no existe
CREATE SCHEMA IF NOT EXISTS informix;

-- Configurar búsqueda en esquema informix
SET search_path TO informix;

-- ============================================
-- 1. CREAR TABLAS BASE NECESARIAS
-- ============================================

-- Tabla constancias
CREATE TABLE IF NOT EXISTS informix.constancias (
    id SERIAL PRIMARY KEY,
    axo INTEGER NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
    folio INTEGER NOT NULL,
    tipo INTEGER NOT NULL CHECK (tipo IN (1, 2, 3)),
    solicita VARCHAR(255) NOT NULL,
    partidapago VARCHAR(50) NULL,
    observacion TEXT NULL,
    domicilio TEXT NULL,
    id_licencia INTEGER NULL,
    capturista VARCHAR(100) NOT NULL,
    feccap TIMESTAMP NOT NULL DEFAULT NOW(),
    vigente CHAR(1) DEFAULT 'V' CHECK (vigente IN ('V', 'C')),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(axo, folio)
);

-- Tabla licencias principales
CREATE TABLE IF NOT EXISTS informix.licencias (
    id SERIAL PRIMARY KEY,
    numero_licencia VARCHAR(50) UNIQUE NOT NULL,
    nombre_comercial VARCHAR(255) NOT NULL,
    propietario VARCHAR(255) NOT NULL,
    domicilio TEXT NOT NULL,
    giro VARCHAR(100),
    tipo_licencia VARCHAR(50),
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(20) DEFAULT 'ACTIVA',
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla anuncios publicitarios
CREATE TABLE IF NOT EXISTS informix.anuncios (
    id SERIAL PRIMARY KEY,
    numero_anuncio VARCHAR(50) UNIQUE NOT NULL,
    licencia_id INTEGER REFERENCES informix.licencias(id),
    tipo_anuncio VARCHAR(100),
    ubicacion TEXT,
    dimensiones VARCHAR(100),
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    fecha_alta DATE,
    fecha_baja DATE,
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla tramites
CREATE TABLE IF NOT EXISTS informix.tramites (
    id SERIAL PRIMARY KEY,
    numero_tramite VARCHAR(100) UNIQUE NOT NULL,
    tipo_tramite VARCHAR(50) NOT NULL,
    solicitante VARCHAR(255) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado VARCHAR(30) DEFAULT 'EN_PROCESO',
    licencia_id INTEGER REFERENCES informix.licencias(id),
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla predial_info
CREATE TABLE IF NOT EXISTS informix.predial_info (
    id SERIAL PRIMARY KEY,
    cuenta_predial VARCHAR(50) NOT NULL UNIQUE,
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno NUMERIC(10,2),
    superficie_construccion NUMERIC(10,2),
    uso_suelo VARCHAR(100),
    zona VARCHAR(50),
    valor_catastral NUMERIC(15,2),
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    coordenada_x NUMERIC(12,6),
    coordenada_y NUMERIC(12,6),
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablas de catálogos
CREATE TABLE IF NOT EXISTS informix.catalogo_giros (
    id SERIAL PRIMARY KEY,
    codigo_giro VARCHAR(20) UNIQUE,
    descripcion VARCHAR(255) NOT NULL,
    categoria VARCHAR(100),
    activo BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS informix.catalogo_actividades (
    id SERIAL PRIMARY KEY,
    codigo_actividad VARCHAR(20) UNIQUE,
    descripcion VARCHAR(255) NOT NULL,
    giro_id INTEGER REFERENCES informix.catalogo_giros(id),
    activo BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS informix.catalogo_requisitos (
    id SERIAL PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    tipo_tramite VARCHAR(50),
    obligatorio BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS informix.liga_requisitos (
    id SERIAL PRIMARY KEY,
    tramite_id INTEGER REFERENCES informix.tramites(id),
    requisito_id INTEGER REFERENCES informix.catalogo_requisitos(id),
    obligatorio BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS informix.catalogo_estatus (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE,
    descripcion VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS informix.catalogo_scian (
    id SERIAL PRIMARY KEY,
    codigo_scian VARCHAR(20) UNIQUE,
    descripcion VARCHAR(500) NOT NULL,
    sector VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS informix.empleados (
    id SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(255) NOT NULL,
    puesto VARCHAR(100),
    departamento VARCHAR(100),
    activo BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS informix.usuarios (
    id SERIAL PRIMARY KEY,
    usuario VARCHAR(100) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    perfil VARCHAR(50),
    activo BOOLEAN DEFAULT true
);

-- ============================================
-- 2. CREAR ÍNDICES PARA OPTIMIZACIÓN
-- ============================================

-- Índices para constancias
CREATE INDEX IF NOT EXISTS idx_constancias_axo_folio ON informix.constancias(axo, folio);
CREATE INDEX IF NOT EXISTS idx_constancias_tipo ON informix.constancias(tipo);
CREATE INDEX IF NOT EXISTS idx_constancias_solicita ON informix.constancias(solicita);
CREATE INDEX IF NOT EXISTS idx_constancias_feccap ON informix.constancias(feccap);
CREATE INDEX IF NOT EXISTS idx_constancias_id_licencia ON informix.constancias(id_licencia);
CREATE INDEX IF NOT EXISTS idx_constancias_vigente ON informix.constancias(vigente);

-- Índices para licencias
CREATE INDEX IF NOT EXISTS idx_licencias_numero ON informix.licencias(numero_licencia);
CREATE INDEX IF NOT EXISTS idx_licencias_propietario ON informix.licencias(propietario);
CREATE INDEX IF NOT EXISTS idx_licencias_estado ON informix.licencias(estado);

-- Índices para predial
CREATE INDEX IF NOT EXISTS idx_predial_cuenta ON informix.predial_info(cuenta_predial);
CREATE INDEX IF NOT EXISTS idx_predial_propietario ON informix.predial_info(propietario);
CREATE INDEX IF NOT EXISTS idx_predial_direccion ON informix.predial_info(direccion);
CREATE INDEX IF NOT EXISTS idx_predial_colonia ON informix.predial_info(colonia);
CREATE INDEX IF NOT EXISTS idx_predial_estado ON informix.predial_info(estado);

-- ============================================
-- 3. FUNCIONES AUXILIARES
-- ============================================

-- Función para obtener siguiente folio
CREATE OR REPLACE FUNCTION get_next_folio(p_axo INTEGER)
RETURNS INTEGER AS $$
DECLARE
    next_folio INTEGER;
BEGIN
    SELECT COALESCE(MAX(folio), 0) + 1 INTO next_folio
    FROM informix.constancias
    WHERE axo = p_axo;

    RETURN next_folio;
END;
$$ LANGUAGE plpgsql;

-- Función para trigger de actualización de fecha
CREATE OR REPLACE FUNCTION informix.actualizar_fecha_modificacion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- ============================================
-- 4. STORED PROCEDURES PRINCIPALES
-- ============================================

-- ============================================
-- CONSTANCIAFRM - STORED PROCEDURES
-- ============================================

-- SP_constancia_list - Listar constancias
CREATE OR REPLACE FUNCTION SP_constancia_list()
RETURNS TABLE(
    id INTEGER,
    axo INTEGER,
    folio INTEGER,
    tipo INTEGER,
    solicita VARCHAR(255),
    partidapago VARCHAR(50),
    observacion TEXT,
    domicilio TEXT,
    id_licencia INTEGER,
    capturista VARCHAR(100),
    feccap TIMESTAMP,
    vigente CHAR(1)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.axo,
        c.folio,
        c.tipo,
        c.solicita,
        c.partidapago,
        c.observacion,
        c.domicilio,
        c.id_licencia,
        c.capturista,
        c.feccap,
        c.vigente
    FROM informix.constancias c
    WHERE c.vigente = 'V'
    ORDER BY c.axo DESC, c.folio DESC;
END;
$$;

-- SP_constancia_search - Buscar con filtros
CREATE OR REPLACE FUNCTION SP_constancia_search(
    p_axo INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_feccap DATE DEFAULT NULL
)
RETURNS TABLE(
    id INTEGER,
    axo INTEGER,
    folio INTEGER,
    tipo INTEGER,
    solicita VARCHAR(255),
    partidapago VARCHAR(50),
    observacion TEXT,
    domicilio TEXT,
    id_licencia INTEGER,
    capturista VARCHAR(100),
    feccap TIMESTAMP,
    vigente CHAR(1)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.axo,
        c.folio,
        c.tipo,
        c.solicita,
        c.partidapago,
        c.observacion,
        c.domicilio,
        c.id_licencia,
        c.capturista,
        c.feccap,
        c.vigente
    FROM informix.constancias c
    WHERE c.vigente = 'V'
    AND (p_axo IS NULL OR c.axo = p_axo)
    AND (p_folio IS NULL OR c.folio = p_folio)
    AND (p_id_licencia IS NULL OR c.id_licencia = p_id_licencia)
    AND (p_feccap IS NULL OR c.feccap::date = p_feccap)
    ORDER BY c.axo DESC, c.folio DESC;
END;
$$;

-- SP_constancia_create - Crear nueva constancia
CREATE OR REPLACE FUNCTION SP_constancia_create(
    p_tipo INTEGER,
    p_solicita VARCHAR(255),
    p_partidapago VARCHAR(50) DEFAULT NULL,
    p_observacion TEXT DEFAULT NULL,
    p_domicilio TEXT DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_capturista VARCHAR(100) DEFAULT 'usuario_sistema'
)
RETURNS TABLE(success BOOLEAN, message TEXT, axo INTEGER, folio INTEGER, id INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
    v_axo INTEGER;
    v_folio INTEGER;
    v_new_id INTEGER;
BEGIN
    -- Obtener año actual
    v_axo := EXTRACT(YEAR FROM CURRENT_DATE);

    -- Obtener siguiente folio para el año
    SELECT get_next_folio(v_axo) INTO v_folio;

    -- Insertar nueva constancia
    INSERT INTO informix.constancias (
        axo, folio, tipo, solicita, partidapago,
        observacion, domicilio, id_licencia, capturista, feccap, vigente
    ) VALUES (
        v_axo, v_folio, p_tipo, p_solicita, p_partidapago,
        p_observacion, p_domicilio, p_id_licencia, p_capturista, NOW(), 'V'
    ) RETURNING id INTO v_new_id;

    RETURN QUERY SELECT
        TRUE as success,
        'Constancia creada exitosamente: ' || v_axo || '-' || v_folio as message,
        v_axo,
        v_folio,
        v_new_id;
END;
$$;

-- ============================================
-- CONSULTAPREDIAL - STORED PROCEDURES
-- ============================================

-- SP_CONSULTAPREDIAL_LIST
CREATE OR REPLACE FUNCTION SP_CONSULTAPREDIAL_LIST(
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
    superficie_terreno NUMERIC(10,2),
    superficie_construccion NUMERIC(10,2),
    uso_suelo VARCHAR(100),
    zona VARCHAR(50),
    valor_catastral NUMERIC(15,2),
    estado VARCHAR(20),
    coordenada_x NUMERIC(12,6),
    coordenada_y NUMERIC(12,6),
    observaciones TEXT,
    fecha_registro TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
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
    WHERE (p_cuenta_predial IS NULL OR pi.cuenta_predial ILIKE '%' || p_cuenta_predial || '%')
      AND (p_propietario IS NULL OR pi.propietario ILIKE '%' || p_propietario || '%')
      AND (p_direccion IS NULL OR pi.direccion ILIKE '%' || p_direccion || '%')
      AND (p_colonia IS NULL OR pi.colonia ILIKE '%' || p_colonia || '%')
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
    WHERE (p_cuenta_predial IS NULL OR pi.cuenta_predial ILIKE '%' || p_cuenta_predial || '%')
      AND (p_propietario IS NULL OR pi.propietario ILIKE '%' || p_propietario || '%')
      AND (p_direccion IS NULL OR pi.direccion ILIKE '%' || p_direccion || '%')
      AND (p_colonia IS NULL OR pi.colonia ILIKE '%' || p_colonia || '%')
      AND pi.estado = 'ACTIVO'
    ORDER BY pi.fecha_actualizacion DESC, pi.id DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- SP_CONSULTAPREDIAL_GET
CREATE OR REPLACE FUNCTION SP_CONSULTAPREDIAL_GET(p_cuenta_predial VARCHAR(50))
RETURNS TABLE(
    id INTEGER,
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno NUMERIC(10,2),
    superficie_construccion NUMERIC(10,2),
    uso_suelo VARCHAR(100),
    zona VARCHAR(50),
    valor_catastral NUMERIC(15,2),
    estado VARCHAR(20),
    coordenada_x NUMERIC(12,6),
    coordenada_y NUMERIC(12,6),
    observaciones TEXT,
    fecha_registro TIMESTAMP,
    fecha_actualizacion TIMESTAMP
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
-- LICENCIAS - STORED PROCEDURES
-- ============================================

-- SP_licencias_list - Listar licencias
CREATE OR REPLACE FUNCTION SP_licencias_list(
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0,
    p_estado VARCHAR(20) DEFAULT NULL
)
RETURNS TABLE(
    id INTEGER,
    numero_licencia VARCHAR(50),
    nombre_comercial VARCHAR(255),
    propietario VARCHAR(255),
    domicilio TEXT,
    giro VARCHAR(100),
    tipo_licencia VARCHAR(50),
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(20),
    observaciones TEXT,
    total_registros BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM informix.licencias l
    WHERE (p_estado IS NULL OR l.estado = p_estado);

    RETURN QUERY
    SELECT
        l.id,
        l.numero_licencia,
        l.nombre_comercial,
        l.propietario,
        l.domicilio,
        l.giro,
        l.tipo_licencia,
        l.fecha_expedicion,
        l.fecha_vencimiento,
        l.estado,
        l.observaciones,
        v_total_count as total_registros
    FROM informix.licencias l
    WHERE (p_estado IS NULL OR l.estado = p_estado)
    ORDER BY l.created_at DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- SP_licencias_search - Buscar licencias
CREATE OR REPLACE FUNCTION SP_licencias_search(
    p_numero_licencia VARCHAR(50) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_nombre_comercial VARCHAR(255) DEFAULT NULL
)
RETURNS TABLE(
    id INTEGER,
    numero_licencia VARCHAR(50),
    nombre_comercial VARCHAR(255),
    propietario VARCHAR(255),
    domicilio TEXT,
    giro VARCHAR(100),
    tipo_licencia VARCHAR(50),
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(20),
    observaciones TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id,
        l.numero_licencia,
        l.nombre_comercial,
        l.propietario,
        l.domicilio,
        l.giro,
        l.tipo_licencia,
        l.fecha_expedicion,
        l.fecha_vencimiento,
        l.estado,
        l.observaciones
    FROM informix.licencias l
    WHERE (p_numero_licencia IS NULL OR l.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR l.propietario ILIKE '%' || p_propietario || '%')
      AND (p_nombre_comercial IS NULL OR l.nombre_comercial ILIKE '%' || p_nombre_comercial || '%')
    ORDER BY l.created_at DESC;
END;
$$;

-- ============================================
-- CATÁLOGOS - STORED PROCEDURES
-- ============================================

-- SP_CATREQUISITOS_LIST
CREATE OR REPLACE FUNCTION SP_CATREQUISITOS_LIST()
RETURNS TABLE(id INTEGER, descripcion VARCHAR(255), tipo_tramite VARCHAR(50))
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.descripcion, r.tipo_tramite
    FROM informix.catalogo_requisitos r
    ORDER BY r.tipo_tramite, r.descripcion;
END;
$$;

-- SP_BUSCAGIRO_SEARCH
CREATE OR REPLACE FUNCTION SP_BUSCAGIRO_SEARCH(p_termino VARCHAR(255))
RETURNS TABLE(id INTEGER, codigo VARCHAR(20), descripcion VARCHAR(255), categoria VARCHAR(100))
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT g.id, g.codigo_giro, g.descripcion, g.categoria
    FROM informix.catalogo_giros g
    WHERE g.descripcion ILIKE '%' || p_termino || '%'
       OR g.codigo_giro ILIKE '%' || p_termino || '%'
       OR g.categoria ILIKE '%' || p_termino || '%';
END;
$$;

-- SP_BUSQUEDAACTIVIDAD_SEARCH
CREATE OR REPLACE FUNCTION SP_BUSQUEDAACTIVIDAD_SEARCH(p_termino VARCHAR(255))
RETURNS TABLE(id INTEGER, codigo VARCHAR(20), descripcion VARCHAR(255), giro VARCHAR(100))
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.codigo_actividad, a.descripcion, g.descripcion as giro
    FROM informix.catalogo_actividades a
    JOIN informix.catalogo_giros g ON a.giro_id = g.id
    WHERE a.descripcion ILIKE '%' || p_termino || '%'
       OR a.codigo_actividad ILIKE '%' || p_termino || '%';
END;
$$;

-- SP_EMPLEADOS_LIST
CREATE OR REPLACE FUNCTION SP_EMPLEADOS_LIST()
RETURNS TABLE(id INTEGER, nombre_completo VARCHAR(255), puesto VARCHAR(100), departamento VARCHAR(100))
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT e.id, e.nombre_completo, e.puesto, e.departamento
    FROM informix.empleados e
    WHERE e.activo = true
    ORDER BY e.nombre_completo;
END;
$$;

-- SP_CONSULTAUSUARIOS_LIST
CREATE OR REPLACE FUNCTION SP_CONSULTAUSUARIOS_LIST()
RETURNS TABLE(id INTEGER, usuario VARCHAR(100), nombre VARCHAR(255), perfil VARCHAR(50), activo BOOLEAN)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.usuario, u.nombre, u.perfil, u.activo
    FROM informix.usuarios u
    ORDER BY u.nombre;
END;
$$;

-- SP_CONSULTATRAMITE_LIST
CREATE OR REPLACE FUNCTION SP_CONSULTATRAMITE_LIST(
    p_numero_tramite VARCHAR(100) DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL
)
RETURNS TABLE(
    numero_tramite VARCHAR(100),
    tipo_tramite VARCHAR(50),
    solicitante VARCHAR(255),
    fecha_inicio DATE,
    estado VARCHAR(30)
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT t.numero_tramite, t.tipo_tramite, t.solicitante, t.fecha_inicio, t.estado
    FROM informix.tramites t
    WHERE (p_numero_tramite IS NULL OR t.numero_tramite ILIKE '%' || p_numero_tramite || '%')
      AND (p_estado IS NULL OR t.estado = p_estado)
    ORDER BY t.fecha_inicio DESC;
END;
$$;

-- ============================================
-- 5. CREAR TRIGGERS
-- ============================================

-- Trigger para actualización automática de fecha en predial_info
DROP TRIGGER IF EXISTS tr_actualizar_predial_fecha ON informix.predial_info;
CREATE TRIGGER tr_actualizar_predial_fecha
    BEFORE UPDATE ON informix.predial_info
    FOR EACH ROW
    EXECUTE FUNCTION informix.actualizar_fecha_modificacion();

-- ============================================
-- 6. INSERTAR DATOS DE PRUEBA
-- ============================================

-- Datos para constancias (ya incluidos en create_padron_licencias_db.sql)

-- Datos para predial_info
INSERT INTO informix.predial_info (
    cuenta_predial, propietario, direccion, colonia, codigo_postal,
    superficie_terreno, superficie_construccion, uso_suelo, zona,
    valor_catastral, coordenada_x, coordenada_y, observaciones
) VALUES
    ('001-001-001-01', 'JUAN PÉREZ GARCÍA', 'AV. JUÁREZ #123', 'CENTRO', '44100',
     150.00, 120.00, 'COMERCIAL', 'ZONA A', 250000.00,
     -103.350, 20.676, 'Predio para licencia comercial'),
    ('001-001-002-01', 'MARÍA LÓPEZ HERNÁNDEZ', 'CALLE MORELOS #456', 'REFORMA', '44200',
     200.00, 180.00, 'HABITACIONAL', 'ZONA B', 350000.00,
     -103.351, 20.677, 'Uso habitacional con potencial comercial'),
    ('001-001-003-01', 'EMPRESA CONSTRUCTORA SA', 'BLVD. UNIVERSIDAD #789', 'UNIVERSITARIA', '44300',
     500.00, 400.00, 'INDUSTRIAL', 'ZONA C', 1500000.00,
     -103.352, 20.678, 'Predio industrial para licencia de funcionamiento')
ON CONFLICT (cuenta_predial) DO NOTHING;

-- Datos para licencias
INSERT INTO informix.licencias (
    numero_licencia, nombre_comercial, propietario, domicilio, giro, tipo_licencia,
    fecha_expedicion, fecha_vencimiento, estado, observaciones
) VALUES
    ('LIC-2024-001', 'RESTAURANTE EL BUEN SABOR', 'JUAN PÉREZ GARCÍA', 'AV. JUÁREZ #123', 'RESTAURANTE', 'FUNCIONAMIENTO',
     '2024-01-15', '2025-01-15', 'ACTIVA', 'Licencia para restaurante'),
    ('LIC-2024-002', 'FARMACIA GUADALAJARA', 'MARÍA LÓPEZ HERNÁNDEZ', 'CALLE MORELOS #456', 'FARMACIA', 'FUNCIONAMIENTO',
     '2024-01-16', '2025-01-16', 'ACTIVA', 'Licencia para farmacia'),
    ('LIC-2024-003', 'CONSTRUCTORA ESPECIALIZADA', 'EMPRESA CONSTRUCTORA SA', 'BLVD. UNIVERSIDAD #789', 'CONSTRUCCIÓN', 'INDUSTRIAL',
     '2024-01-17', '2025-01-17', 'ACTIVA', 'Licencia para empresa constructora')
ON CONFLICT (numero_licencia) DO NOTHING;

-- Datos para catálogos
INSERT INTO informix.catalogo_giros (codigo_giro, descripcion, categoria) VALUES
    ('REST', 'RESTAURANTE', 'ALIMENTOS Y BEBIDAS'),
    ('FARM', 'FARMACIA', 'SALUD'),
    ('CONST', 'CONSTRUCCIÓN', 'INDUSTRIA'),
    ('COMR', 'COMERCIO GENERAL', 'COMERCIO'),
    ('SERV', 'SERVICIOS PROFESIONALES', 'SERVICIOS')
ON CONFLICT (codigo_giro) DO NOTHING;

INSERT INTO informix.catalogo_actividades (codigo_actividad, descripcion, giro_id) VALUES
    ('ACT-001', 'PREPARACIÓN DE ALIMENTOS', 1),
    ('ACT-002', 'VENTA DE MEDICAMENTOS', 2),
    ('ACT-003', 'CONSTRUCCIÓN DE EDIFICIOS', 3),
    ('ACT-004', 'VENTA AL POR MENOR', 4),
    ('ACT-005', 'CONSULTORÍA PROFESIONAL', 5)
ON CONFLICT (codigo_actividad) DO NOTHING;

INSERT INTO informix.empleados (nombre_completo, puesto, departamento) VALUES
    ('CARLOS ADMINISTRADOR', 'ADMINISTRADOR', 'SISTEMAS'),
    ('ANA OPERADORA', 'OPERADOR', 'LICENCIAS'),
    ('LUIS SUPERVISOR', 'SUPERVISOR', 'OPERACIONES')
ON CONFLICT DO NOTHING;

INSERT INTO informix.usuarios (usuario, nombre, perfil) VALUES
    ('admin', 'ADMINISTRADOR SISTEMA', 'ADMINISTRADOR'),
    ('operador01', 'OPERADOR LICENCIAS', 'OPERADOR'),
    ('supervisor01', 'SUPERVISOR GENERAL', 'SUPERVISOR')
ON CONFLICT (usuario) DO NOTHING;

-- ============================================
-- 7. VERIFICACIÓN FINAL
-- ============================================

SELECT 'INSTALACIÓN COMPLETA DE STORED PROCEDURES DE LICENCIAS - EXITOSA' as resultado;

-- Mostrar resumen de tablas creadas
SELECT
    'TABLAS CREADAS:' as tipo,
    COUNT(*) as cantidad
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('constancias', 'licencias', 'anuncios', 'tramites', 'predial_info',
                     'catalogo_giros', 'catalogo_actividades', 'catalogo_requisitos',
                     'liga_requisitos', 'catalogo_estatus', 'catalogo_scian', 'empleados', 'usuarios');

-- Mostrar resumen de stored procedures creados
SELECT
    'STORED PROCEDURES CREADOS:' as tipo,
    COUNT(*) as cantidad
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
  AND routine_name LIKE 'sp_%';

-- ============================================
-- FIN DE LA INSTALACIÓN
-- ============================================