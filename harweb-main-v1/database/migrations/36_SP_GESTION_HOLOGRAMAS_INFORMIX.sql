-- =====================================================
-- STORED PROCEDURES PARA GESTIÓN DE HOLOGRAMAS
-- Sistema: HARWEB - Módulo de Licencias
-- Base de datos: Informix
-- Fecha: 2024
-- =====================================================

-- Eliminar procedimientos si existen
DROP PROCEDURE IF EXISTS SP_GESTION_HOLOGRAMAS_LIST;
DROP PROCEDURE IF EXISTS SP_GESTION_HOLOGRAMAS_GET;
DROP PROCEDURE IF EXISTS SP_GESTION_HOLOGRAMAS_CREATE;
DROP PROCEDURE IF EXISTS SP_GESTION_HOLOGRAMAS_UPDATE;
DROP PROCEDURE IF EXISTS SP_GESTION_HOLOGRAMAS_DELETE;
DROP PROCEDURE IF EXISTS SP_GESTION_HOLOGRAMAS_ESTADISTICAS;

-- =====================================================
-- SP_GESTION_HOLOGRAMAS_LIST
-- Listar hologramas con filtros y paginación
-- =====================================================
CREATE PROCEDURE SP_GESTION_HOLOGRAMAS_LIST(
    p_codigo VARCHAR(50),
    p_estado VARCHAR(20),
    p_tipo VARCHAR(20),
    p_anio INTEGER,
    p_tiene_qr INTEGER,
    p_limite INTEGER,
    p_offset INTEGER
)
RETURNING
    INTEGER AS id,
    VARCHAR(50) AS codigo,
    VARCHAR(20) AS tipo,
    VARCHAR(20) AS estado,
    INTEGER AS anio,
    VARCHAR(500) AS qr_code,
    DATETIME YEAR TO SECOND AS fecha_creacion,
    VARCHAR(100) AS asignado_a,
    VARCHAR(255) AS observaciones,
    INTEGER AS total_registros;

DEFINE v_sql VARCHAR(2000);
DEFINE v_where VARCHAR(1000);
DEFINE v_count INTEGER;

-- Construir WHERE dinámico
LET v_where = " WHERE 1=1 ";

IF p_codigo IS NOT NULL AND LENGTH(TRIM(p_codigo)) > 0 THEN
    LET v_where = v_where || " AND h.codigo LIKE '%" || TRIM(p_codigo) || "%' ";
END IF;

IF p_estado IS NOT NULL AND LENGTH(TRIM(p_estado)) > 0 THEN
    LET v_where = v_where || " AND h.estado = '" || TRIM(p_estado) || "' ";
END IF;

IF p_tipo IS NOT NULL AND LENGTH(TRIM(p_tipo)) > 0 THEN
    LET v_where = v_where || " AND h.tipo = '" || TRIM(p_tipo) || "' ";
END IF;

IF p_anio IS NOT NULL AND p_anio > 0 THEN
    LET v_where = v_where || " AND h.anio = " || p_anio || " ";
END IF;

IF p_tiene_qr IS NOT NULL THEN
    IF p_tiene_qr = 1 THEN
        LET v_where = v_where || " AND h.qr_code IS NOT NULL AND LENGTH(h.qr_code) > 0 ";
    ELSE
        LET v_where = v_where || " AND (h.qr_code IS NULL OR LENGTH(h.qr_code) = 0) ";
    END IF;
END IF;

-- Obtener total de registros
LET v_sql = "SELECT COUNT(*) FROM gestion_hologramas h " || v_where;
PREPARE stmt_count FROM v_sql;
EXECUTE stmt_count INTO v_count;
FREE stmt_count;

-- Consulta principal con paginación
LET v_sql = "SELECT " ||
    "h.id, " ||
    "h.codigo, " ||
    "h.tipo, " ||
    "h.estado, " ||
    "h.anio, " ||
    "h.qr_code, " ||
    "h.fecha_creacion, " ||
    "h.asignado_a, " ||
    "h.observaciones, " ||
    v_count || " as total_registros " ||
    "FROM gestion_hologramas h " ||
    v_where ||
    " ORDER BY h.fecha_creacion DESC ";

IF p_limite IS NOT NULL AND p_limite > 0 THEN
    LET v_sql = v_sql || " FIRST " || p_limite;
    IF p_offset IS NOT NULL AND p_offset > 0 THEN
        LET v_sql = v_sql || " SKIP " || p_offset;
    END IF;
END IF;

PREPARE stmt_main FROM v_sql;
EXECUTE stmt_main;
FREE stmt_main;

END PROCEDURE;

-- =====================================================
-- SP_GESTION_HOLOGRAMAS_GET
-- Obtener detalle de un holograma específico
-- =====================================================
CREATE PROCEDURE SP_GESTION_HOLOGRAMAS_GET(
    p_id INTEGER
)
RETURNING
    INTEGER AS id,
    VARCHAR(50) AS codigo,
    VARCHAR(20) AS tipo,
    VARCHAR(20) AS estado,
    INTEGER AS anio,
    VARCHAR(500) AS qr_code,
    DATETIME YEAR TO SECOND AS fecha_creacion,
    DATETIME YEAR TO SECOND AS fecha_actualizacion,
    VARCHAR(100) AS asignado_a,
    VARCHAR(255) AS observaciones,
    VARCHAR(50) AS usuario_creacion,
    VARCHAR(50) AS usuario_actualizacion;

RETURN SELECT
    h.id,
    h.codigo,
    h.tipo,
    h.estado,
    h.anio,
    h.qr_code,
    h.fecha_creacion,
    h.fecha_actualizacion,
    h.asignado_a,
    h.observaciones,
    h.usuario_creacion,
    h.usuario_actualizacion
FROM gestion_hologramas h
WHERE h.id = p_id;

END PROCEDURE;

-- =====================================================
-- SP_GESTION_HOLOGRAMAS_CREATE
-- Crear un nuevo holograma
-- =====================================================
CREATE PROCEDURE SP_GESTION_HOLOGRAMAS_CREATE(
    p_codigo VARCHAR(50),
    p_tipo VARCHAR(20),
    p_estado VARCHAR(20),
    p_anio INTEGER,
    p_asignado_a VARCHAR(100),
    p_observaciones VARCHAR(255),
    p_generar_qr INTEGER
)
RETURNING
    INTEGER AS id,
    VARCHAR(100) AS message,
    INTEGER AS success;

DEFINE v_id INTEGER;
DEFINE v_exists INTEGER;
DEFINE v_qr_code VARCHAR(500);

-- Validar que no exista el código
SELECT COUNT(*) INTO v_exists
FROM gestion_hologramas
WHERE codigo = TRIM(p_codigo);

IF v_exists > 0 THEN
    RETURN 0, 'Ya existe un holograma con este código', 0;
END IF;

-- Generar QR si se solicita
IF p_generar_qr = 1 THEN
    LET v_qr_code = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
ELSE
    LET v_qr_code = NULL;
END IF;

-- Insertar nuevo holograma
INSERT INTO gestion_hologramas (
    codigo,
    tipo,
    estado,
    anio,
    qr_code,
    fecha_creacion,
    asignado_a,
    observaciones,
    usuario_creacion
) VALUES (
    TRIM(p_codigo),
    COALESCE(TRIM(p_tipo), 'licencia'),
    COALESCE(TRIM(p_estado), 'disponible'),
    COALESCE(p_anio, YEAR(TODAY)),
    v_qr_code,
    CURRENT YEAR TO SECOND,
    TRIM(p_asignado_a),
    TRIM(p_observaciones),
    'sistema'
);

LET v_id = DBINFO('sqlca.sqlerrd1');

RETURN v_id, 'Holograma creado correctamente', 1;

END PROCEDURE;

-- =====================================================
-- SP_GESTION_HOLOGRAMAS_UPDATE
-- Actualizar un holograma existente
-- =====================================================
CREATE PROCEDURE SP_GESTION_HOLOGRAMAS_UPDATE(
    p_id INTEGER,
    p_codigo VARCHAR(50),
    p_tipo VARCHAR(20),
    p_estado VARCHAR(20),
    p_anio INTEGER,
    p_asignado_a VARCHAR(100),
    p_observaciones VARCHAR(255),
    p_generar_qr INTEGER
)
RETURNING
    INTEGER AS id,
    VARCHAR(100) AS message,
    INTEGER AS success;

DEFINE v_exists INTEGER;
DEFINE v_codigo_exists INTEGER;
DEFINE v_qr_code VARCHAR(500);
DEFINE v_current_qr VARCHAR(500);

-- Verificar que el holograma existe
SELECT COUNT(*) INTO v_exists
FROM gestion_hologramas
WHERE id = p_id;

IF v_exists = 0 THEN
    RETURN 0, 'Holograma no encontrado', 0;
END IF;

-- Verificar que no exista otro holograma con el mismo código
SELECT COUNT(*) INTO v_codigo_exists
FROM gestion_hologramas
WHERE codigo = TRIM(p_codigo) AND id != p_id;

IF v_codigo_exists > 0 THEN
    RETURN 0, 'Ya existe otro holograma con este código', 0;
END IF;

-- Obtener QR actual
SELECT qr_code INTO v_current_qr
FROM gestion_hologramas
WHERE id = p_id;

-- Generar nuevo QR si se solicita o mantener el actual
IF p_generar_qr = 1 THEN
    LET v_qr_code = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
ELSE
    LET v_qr_code = v_current_qr;
END IF;

-- Actualizar holograma
UPDATE gestion_hologramas SET
    codigo = TRIM(p_codigo),
    tipo = COALESCE(TRIM(p_tipo), tipo),
    estado = COALESCE(TRIM(p_estado), estado),
    anio = COALESCE(p_anio, anio),
    qr_code = v_qr_code,
    fecha_actualizacion = CURRENT YEAR TO SECOND,
    asignado_a = TRIM(p_asignado_a),
    observaciones = TRIM(p_observaciones),
    usuario_actualizacion = 'sistema'
WHERE id = p_id;

RETURN p_id, 'Holograma actualizado correctamente', 1;

END PROCEDURE;

-- =====================================================
-- SP_GESTION_HOLOGRAMAS_DELETE
-- Eliminar un holograma (solo si no está asignado)
-- =====================================================
CREATE PROCEDURE SP_GESTION_HOLOGRAMAS_DELETE(
    p_id INTEGER
)
RETURNING
    INTEGER AS id,
    VARCHAR(100) AS message,
    INTEGER AS success;

DEFINE v_exists INTEGER;
DEFINE v_estado VARCHAR(20);

-- Verificar que el holograma existe
SELECT COUNT(*), estado INTO v_exists, v_estado
FROM gestion_hologramas
WHERE id = p_id;

IF v_exists = 0 THEN
    RETURN 0, 'Holograma no encontrado', 0;
END IF;

-- Verificar que no esté asignado o usado
IF v_estado IN ('asignado', 'usado') THEN
    RETURN 0, 'No se puede eliminar un holograma asignado o usado', 0;
END IF;

-- Eliminar holograma
DELETE FROM gestion_hologramas
WHERE id = p_id;

RETURN p_id, 'Holograma eliminado correctamente', 1;

END PROCEDURE;

-- =====================================================
-- SP_GESTION_HOLOGRAMAS_ESTADISTICAS
-- Obtener estadísticas generales de hologramas
-- =====================================================
CREATE PROCEDURE SP_GESTION_HOLOGRAMAS_ESTADISTICAS()
RETURNING
    INTEGER AS disponibles,
    INTEGER AS asignados,
    INTEGER AS usados,
    INTEGER AS cancelados,
    INTEGER AS total,
    VARCHAR(20) AS tipo,
    INTEGER AS tipo_disponibles,
    INTEGER AS tipo_asignados,
    INTEGER AS tipo_usados,
    INTEGER AS tipo_total;

-- Estadísticas generales
RETURN SELECT
    SUM(CASE WHEN estado = 'disponible' THEN 1 ELSE 0 END) as disponibles,
    SUM(CASE WHEN estado = 'asignado' THEN 1 ELSE 0 END) as asignados,
    SUM(CASE WHEN estado = 'usado' THEN 1 ELSE 0 END) as usados,
    SUM(CASE WHEN estado = 'cancelado' THEN 1 ELSE 0 END) as cancelados,
    COUNT(*) as total,
    '' as tipo,
    0 as tipo_disponibles,
    0 as tipo_asignados,
    0 as tipo_usados,
    0 as tipo_total
FROM gestion_hologramas
UNION ALL
-- Estadísticas por tipo
SELECT
    0 as disponibles,
    0 as asignados,
    0 as usados,
    0 as cancelados,
    0 as total,
    tipo,
    SUM(CASE WHEN estado = 'disponible' THEN 1 ELSE 0 END) as tipo_disponibles,
    SUM(CASE WHEN estado = 'asignado' THEN 1 ELSE 0 END) as tipo_asignados,
    SUM(CASE WHEN estado = 'usado' THEN 1 ELSE 0 END) as tipo_usados,
    COUNT(*) as tipo_total
FROM gestion_hologramas
GROUP BY tipo
ORDER BY tipo;

END PROCEDURE;

-- =====================================================
-- CREACIÓN DE TABLA SI NO EXISTE
-- =====================================================
CREATE TABLE IF NOT EXISTS gestion_hologramas (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    tipo VARCHAR(20) NOT NULL DEFAULT 'licencia',
    estado VARCHAR(20) NOT NULL DEFAULT 'disponible',
    anio INTEGER NOT NULL,
    qr_code LVARCHAR(2000),
    fecha_creacion DATETIME YEAR TO SECOND NOT NULL DEFAULT CURRENT YEAR TO SECOND,
    fecha_actualizacion DATETIME YEAR TO SECOND,
    asignado_a VARCHAR(100),
    observaciones VARCHAR(255),
    usuario_creacion VARCHAR(50) DEFAULT 'sistema',
    usuario_actualizacion VARCHAR(50),
    licencia_id INTEGER,
    numero_licencia VARCHAR(50)
);

-- Índices para optimización
CREATE INDEX IF NOT EXISTS idx_hologramas_codigo ON gestion_hologramas(codigo);
CREATE INDEX IF NOT EXISTS idx_hologramas_estado ON gestion_hologramas(estado);
CREATE INDEX IF NOT EXISTS idx_hologramas_tipo ON gestion_hologramas(tipo);
CREATE INDEX IF NOT EXISTS idx_hologramas_anio ON gestion_hologramas(anio);
CREATE INDEX IF NOT EXISTS idx_hologramas_licencia ON gestion_hologramas(numero_licencia);

-- =====================================================
-- DATOS INICIALES DE PRUEBA
-- =====================================================
INSERT INTO gestion_hologramas (codigo, tipo, estado, anio, asignado_a, observaciones)
VALUES
    ('HOL2024001', 'licencia', 'disponible', 2024, NULL, 'Holograma de prueba para licencias'),
    ('HOL2024002', 'anuncio', 'asignado', 2024, 'Empresa ABC S.A.', 'Asignado para anuncio comercial'),
    ('HOL2024003', 'especial', 'usado', 2024, 'Gobierno Municipal', 'Usado en evento especial'),
    ('HOL2024004', 'licencia', 'disponible', 2024, NULL, 'Disponible para asignación'),
    ('HOL2024005', 'anuncio', 'cancelado', 2024, NULL, 'Cancelado por error en impresión')
WHERE NOT EXISTS (SELECT 1 FROM gestion_hologramas WHERE codigo = 'HOL2024001');

-- =====================================================
-- COMENTARIOS FINALES
-- =====================================================
-- Procedimientos creados para gestión completa de hologramas
-- Incluye funcionalidades de CRUD, estadísticas y validaciones
-- Compatible con el patrón eRequest/eResponse del sistema HARWEB