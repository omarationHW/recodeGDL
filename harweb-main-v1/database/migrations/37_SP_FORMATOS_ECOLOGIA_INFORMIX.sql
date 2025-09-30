-- ================================================
-- Stored Procedures para Gestión de Formatos de Ecología
-- Sistema Municipal de Guadalajara - Licencias Ambientales
-- Base: padron_licencias
-- Fecha: 2024-12-30
-- ================================================

-- ================================================
-- SP_FORMATOSECOLOGIA_LIST
-- Búsqueda de formatos ecológicos con filtros y paginación
-- ================================================
CREATE PROCEDURE SP_FORMATOSECOLOGIA_LIST(
    p_nombre VARCHAR(255) DEFAULT NULL,
    p_tipo VARCHAR(50) DEFAULT NULL,
    p_activo CHAR(1) DEFAULT NULL,
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)

RETURNING
    id INTEGER,
    nombre VARCHAR(255),
    codigo VARCHAR(50),
    tipo VARCHAR(50),
    descripcion LVARCHAR(1000),
    observaciones LVARCHAR(500),
    vigencia_meses INTEGER,
    es_obligatorio CHAR(1),
    activo CHAR(1),
    archivo_path VARCHAR(500),
    fecha_creacion DATETIME YEAR TO SECOND,
    fecha_actualizacion DATETIME YEAR TO SECOND,
    usuario_creacion VARCHAR(100),
    total_registros INTEGER;

DEFINE v_sql LVARCHAR(3000);
DEFINE v_where LVARCHAR(1500);
DEFINE v_count_sql LVARCHAR(2000);
DEFINE v_total_count INTEGER DEFAULT 0;

-- Construir cláusula WHERE dinámicamente
LET v_where = " WHERE 1=1 ";

-- Filtro por nombre
IF p_nombre IS NOT NULL AND LENGTH(TRIM(p_nombre)) > 0 THEN
    LET v_where = v_where || " AND UPPER(f.nombre) LIKE '%" || UPPER(TRIM(p_nombre)) || "%' ";
END IF;

-- Filtro por tipo
IF p_tipo IS NOT NULL AND LENGTH(TRIM(p_tipo)) > 0 THEN
    LET v_where = v_where || " AND f.tipo = '" || TRIM(p_tipo) || "' ";
END IF;

-- Filtro por activo
IF p_activo IS NOT NULL THEN
    LET v_where = v_where || " AND f.activo = '" || p_activo || "' ";
END IF;

-- Contar total de registros
LET v_count_sql = "SELECT COUNT(*) FROM formato_ecologia f " || v_where;
PREPARE count_stmt FROM v_count_sql;
EXECUTE count_stmt INTO v_total_count;

-- Construir query principal con información de paginación
LET v_sql = "SELECT " ||
    "f.id, " ||
    "f.nombre, " ||
    "f.codigo, " ||
    "f.tipo, " ||
    "f.descripcion, " ||
    "f.observaciones, " ||
    "f.vigencia_meses, " ||
    "f.es_obligatorio, " ||
    "f.activo, " ||
    "f.archivo_path, " ||
    "f.fecha_creacion, " ||
    "f.fecha_actualizacion, " ||
    "f.usuario_creacion, " ||
    v_total_count || " as total_registros " ||
    "FROM formato_ecologia f " ||
    v_where ||
    "ORDER BY f.fecha_creacion DESC, f.nombre ASC " ||
    "LIMIT " || p_limite || " OFFSET " || p_offset;

-- Ejecutar query dinámico
PREPARE stmt FROM v_sql;
EXECUTE stmt;

END PROCEDURE;

-- ================================================
-- SP_FORMATOSECOLOGIA_GET
-- Obtener detalle completo de un formato ecológico
-- ================================================
CREATE PROCEDURE SP_FORMATOSECOLOGIA_GET(
    p_id INTEGER
)

RETURNING
    id INTEGER,
    nombre VARCHAR(255),
    codigo VARCHAR(50),
    tipo VARCHAR(50),
    descripcion LVARCHAR(1000),
    observaciones LVARCHAR(500),
    vigencia_meses INTEGER,
    es_obligatorio CHAR(1),
    activo CHAR(1),
    archivo_path VARCHAR(500),
    archivo_size INTEGER,
    fecha_creacion DATETIME YEAR TO SECOND,
    fecha_actualizacion DATETIME YEAR TO SECOND,
    usuario_creacion VARCHAR(100),
    usuario_actualizacion VARCHAR(100),
    total_usos INTEGER,
    ultima_revision DATE;

SELECT
    f.id,
    f.nombre,
    f.codigo,
    f.tipo,
    f.descripcion,
    f.observaciones,
    f.vigencia_meses,
    f.es_obligatorio,
    f.activo,
    f.archivo_path,
    f.archivo_size,
    f.fecha_creacion,
    f.fecha_actualizacion,
    f.usuario_creacion,
    f.usuario_actualizacion,
    COALESCE(uso_count.total, 0) as total_usos,
    f.ultima_revision
FROM formato_ecologia f
LEFT JOIN (
    SELECT formato_id, COUNT(*) as total
    FROM licencia_formato_ecologia
    WHERE formato_id = p_id
    GROUP BY formato_id
) uso_count ON f.id = uso_count.formato_id
WHERE f.id = p_id;

END PROCEDURE;

-- ================================================
-- SP_FORMATOSECOLOGIA_CREATE
-- Crear nuevo formato ecológico
-- ================================================
CREATE PROCEDURE SP_FORMATOSECOLOGIA_CREATE(
    p_nombre VARCHAR(255),
    p_codigo VARCHAR(50) DEFAULT NULL,
    p_tipo VARCHAR(50) DEFAULT NULL,
    p_descripcion LVARCHAR(1000) DEFAULT NULL,
    p_observaciones LVARCHAR(500) DEFAULT NULL,
    p_vigencia_meses INTEGER DEFAULT 12,
    p_es_obligatorio CHAR(1) DEFAULT 'N',
    p_activo CHAR(1) DEFAULT 'S',
    p_usuario_creacion VARCHAR(100) DEFAULT 'SISTEMA'
)

RETURNING
    id INTEGER,
    mensaje VARCHAR(200),
    success CHAR(1);

DEFINE v_id INTEGER;
DEFINE v_codigo_generado VARCHAR(50);
DEFINE v_mensaje VARCHAR(200);
DEFINE v_success CHAR(1) DEFAULT 'S';

-- Validaciones básicas
IF p_nombre IS NULL OR LENGTH(TRIM(p_nombre)) = 0 THEN
    LET v_mensaje = 'El nombre del formato es obligatorio';
    LET v_success = 'N';
    SELECT 0, v_mensaje, v_success;
    RETURN;
END IF;

-- Validar vigencia
IF p_vigencia_meses IS NULL OR p_vigencia_meses < 1 OR p_vigencia_meses > 120 THEN
    LET v_mensaje = 'La vigencia debe estar entre 1 y 120 meses';
    LET v_success = 'N';
    SELECT 0, v_mensaje, v_success;
    RETURN;
END IF;

-- Verificar que no exista un formato con el mismo nombre
IF EXISTS (SELECT 1 FROM formato_ecologia WHERE UPPER(nombre) = UPPER(TRIM(p_nombre))) THEN
    LET v_mensaje = 'Ya existe un formato con ese nombre';
    LET v_success = 'N';
    SELECT 0, v_mensaje, v_success;
    RETURN;
END IF;

-- Generar código automático si no se proporciona
IF p_codigo IS NULL OR LENGTH(TRIM(p_codigo)) = 0 THEN
    SELECT MAX(id) + 1 INTO v_id FROM formato_ecologia;
    IF v_id IS NULL THEN
        LET v_id = 1;
    END IF;
    LET v_codigo_generado = 'FE' || LPAD(v_id, 4, '0');
ELSE
    LET v_codigo_generado = TRIM(p_codigo);
    -- Verificar que el código no exista
    IF EXISTS (SELECT 1 FROM formato_ecologia WHERE codigo = v_codigo_generado) THEN
        LET v_mensaje = 'Ya existe un formato con ese código';
        LET v_success = 'N';
        SELECT 0, v_mensaje, v_success;
        RETURN;
    END IF;
END IF;

-- Insertar formato
INSERT INTO formato_ecologia (
    nombre,
    codigo,
    tipo,
    descripcion,
    observaciones,
    vigencia_meses,
    es_obligatorio,
    activo,
    fecha_creacion,
    fecha_actualizacion,
    usuario_creacion,
    usuario_actualizacion
) VALUES (
    TRIM(p_nombre),
    v_codigo_generado,
    p_tipo,
    p_descripcion,
    p_observaciones,
    p_vigencia_meses,
    COALESCE(p_es_obligatorio, 'N'),
    COALESCE(p_activo, 'S'),
    CURRENT,
    CURRENT,
    p_usuario_creacion,
    p_usuario_creacion
);

-- Obtener ID generado
SELECT MAX(id) INTO v_id FROM formato_ecologia
WHERE nombre = TRIM(p_nombre) AND codigo = v_codigo_generado;

LET v_mensaje = 'Formato ecológico creado exitosamente';

SELECT v_id, v_mensaje, v_success;

END PROCEDURE;

-- ================================================
-- SP_FORMATOSECOLOGIA_UPDATE
-- Actualizar formato ecológico existente
-- ================================================
CREATE PROCEDURE SP_FORMATOSECOLOGIA_UPDATE(
    p_id INTEGER,
    p_nombre VARCHAR(255),
    p_codigo VARCHAR(50) DEFAULT NULL,
    p_tipo VARCHAR(50) DEFAULT NULL,
    p_descripcion LVARCHAR(1000) DEFAULT NULL,
    p_observaciones LVARCHAR(500) DEFAULT NULL,
    p_vigencia_meses INTEGER DEFAULT 12,
    p_es_obligatorio CHAR(1) DEFAULT 'N',
    p_activo CHAR(1) DEFAULT 'S',
    p_usuario_actualizacion VARCHAR(100) DEFAULT 'SISTEMA'
)

RETURNING
    success CHAR(1),
    mensaje VARCHAR(200);

DEFINE v_mensaje VARCHAR(200);
DEFINE v_success CHAR(1) DEFAULT 'S';
DEFINE v_existe INTEGER DEFAULT 0;

-- Validaciones básicas
IF p_id IS NULL OR p_id <= 0 THEN
    LET v_mensaje = 'ID de formato inválido';
    LET v_success = 'N';
    SELECT v_success, v_mensaje;
    RETURN;
END IF;

-- Verificar que el formato existe
SELECT COUNT(*) INTO v_existe FROM formato_ecologia WHERE id = p_id;
IF v_existe = 0 THEN
    LET v_mensaje = 'El formato especificado no existe';
    LET v_success = 'N';
    SELECT v_success, v_mensaje;
    RETURN;
END IF;

IF p_nombre IS NULL OR LENGTH(TRIM(p_nombre)) = 0 THEN
    LET v_mensaje = 'El nombre del formato es obligatorio';
    LET v_success = 'N';
    SELECT v_success, v_mensaje;
    RETURN;
END IF;

-- Validar vigencia
IF p_vigencia_meses IS NULL OR p_vigencia_meses < 1 OR p_vigencia_meses > 120 THEN
    LET v_mensaje = 'La vigencia debe estar entre 1 y 120 meses';
    LET v_success = 'N';
    SELECT v_success, v_mensaje;
    RETURN;
END IF;

-- Verificar que no exista otro formato con el mismo nombre
IF EXISTS (SELECT 1 FROM formato_ecologia
           WHERE UPPER(nombre) = UPPER(TRIM(p_nombre)) AND id != p_id) THEN
    LET v_mensaje = 'Ya existe otro formato con ese nombre';
    LET v_success = 'N';
    SELECT v_success, v_mensaje;
    RETURN;
END IF;

-- Verificar código si se proporciona
IF p_codigo IS NOT NULL AND LENGTH(TRIM(p_codigo)) > 0 THEN
    IF EXISTS (SELECT 1 FROM formato_ecologia
               WHERE codigo = TRIM(p_codigo) AND id != p_id) THEN
        LET v_mensaje = 'Ya existe otro formato con ese código';
        LET v_success = 'N';
        SELECT v_success, v_mensaje;
        RETURN;
    END IF;
END IF;

-- Actualizar formato
UPDATE formato_ecologia SET
    nombre = TRIM(p_nombre),
    codigo = TRIM(p_codigo),
    tipo = p_tipo,
    descripcion = p_descripcion,
    observaciones = p_observaciones,
    vigencia_meses = p_vigencia_meses,
    es_obligatorio = COALESCE(p_es_obligatorio, 'N'),
    activo = COALESCE(p_activo, 'S'),
    fecha_actualizacion = CURRENT,
    usuario_actualizacion = p_usuario_actualizacion
WHERE id = p_id;

LET v_mensaje = 'Formato ecológico actualizado exitosamente';

SELECT v_success, v_mensaje;

END PROCEDURE;

-- ================================================
-- SP_FORMATOSECOLOGIA_CAMBIAR_ESTADO
-- Cambiar estado activo/inactivo de un formato
-- ================================================
CREATE PROCEDURE SP_FORMATOSECOLOGIA_CAMBIAR_ESTADO(
    p_id INTEGER,
    p_activo CHAR(1),
    p_usuario_actualizacion VARCHAR(100) DEFAULT 'SISTEMA'
)

RETURNING
    success CHAR(1),
    mensaje VARCHAR(200);

DEFINE v_mensaje VARCHAR(200);
DEFINE v_success CHAR(1) DEFAULT 'S';
DEFINE v_existe INTEGER DEFAULT 0;
DEFINE v_nombre VARCHAR(255);

-- Validaciones básicas
IF p_id IS NULL OR p_id <= 0 THEN
    LET v_mensaje = 'ID de formato inválido';
    LET v_success = 'N';
    SELECT v_success, v_mensaje;
    RETURN;
END IF;

-- Verificar que el formato existe
SELECT COUNT(*), MAX(nombre) INTO v_existe, v_nombre
FROM formato_ecologia WHERE id = p_id;

IF v_existe = 0 THEN
    LET v_mensaje = 'El formato especificado no existe';
    LET v_success = 'N';
    SELECT v_success, v_mensaje;
    RETURN;
END IF;

-- Actualizar estado
UPDATE formato_ecologia SET
    activo = COALESCE(p_activo, 'S'),
    fecha_actualizacion = CURRENT,
    usuario_actualizacion = p_usuario_actualizacion
WHERE id = p_id;

IF p_activo = 'S' THEN
    LET v_mensaje = 'Formato "' || v_nombre || '" activado exitosamente';
ELSE
    LET v_mensaje = 'Formato "' || v_nombre || '" desactivado exitosamente';
END IF;

SELECT v_success, v_mensaje;

END PROCEDURE;

-- ================================================
-- SP_FORMATOSECOLOGIA_DELETE
-- Eliminar formato ecológico (soft delete)
-- ================================================
CREATE PROCEDURE SP_FORMATOSECOLOGIA_DELETE(
    p_id INTEGER,
    p_usuario_actualizacion VARCHAR(100) DEFAULT 'SISTEMA'
)

RETURNING
    success CHAR(1),
    mensaje VARCHAR(200);

DEFINE v_mensaje VARCHAR(200);
DEFINE v_success CHAR(1) DEFAULT 'S';
DEFINE v_existe INTEGER DEFAULT 0;
DEFINE v_tiene_usos INTEGER DEFAULT 0;
DEFINE v_nombre VARCHAR(255);

-- Validaciones básicas
IF p_id IS NULL OR p_id <= 0 THEN
    LET v_mensaje = 'ID de formato inválido';
    LET v_success = 'N';
    SELECT v_success, v_mensaje;
    RETURN;
END IF;

-- Verificar que el formato existe
SELECT COUNT(*), MAX(nombre) INTO v_existe, v_nombre
FROM formato_ecologia WHERE id = p_id;

IF v_existe = 0 THEN
    LET v_mensaje = 'El formato especificado no existe';
    LET v_success = 'N';
    SELECT v_success, v_mensaje;
    RETURN;
END IF;

-- Verificar si tiene usos activos
SELECT COUNT(*) INTO v_tiene_usos
FROM licencia_formato_ecologia
WHERE formato_id = p_id;

IF v_tiene_usos > 0 THEN
    LET v_mensaje = 'No se puede eliminar el formato porque está siendo utilizado en ' || v_tiene_usos || ' licencias';
    LET v_success = 'N';
    SELECT v_success, v_mensaje;
    RETURN;
END IF;

-- Realizar soft delete
UPDATE formato_ecologia SET
    activo = 'N',
    fecha_actualizacion = CURRENT,
    usuario_actualizacion = p_usuario_actualizacion
WHERE id = p_id;

LET v_mensaje = 'Formato "' || v_nombre || '" eliminado exitosamente';

SELECT v_success, v_mensaje;

END PROCEDURE;

-- ================================================
-- SP_FORMATOSECOLOGIA_TIPOS
-- Obtener catálogo de tipos de formatos ecológicos
-- ================================================
CREATE PROCEDURE SP_FORMATOSECOLOGIA_TIPOS()

RETURNING
    tipo VARCHAR(50),
    descripcion VARCHAR(200),
    total_formatos INTEGER;

SELECT
    'IMPACTO_AMBIENTAL' as tipo,
    'Evaluaciones de Impacto Ambiental' as descripcion,
    (SELECT COUNT(*) FROM formato_ecologia WHERE tipo = 'IMPACTO_AMBIENTAL' AND activo = 'S') as total_formatos

UNION ALL

SELECT
    'RESIDUOS' as tipo,
    'Gestión y Manejo de Residuos' as descripcion,
    (SELECT COUNT(*) FROM formato_ecologia WHERE tipo = 'RESIDUOS' AND activo = 'S') as total_formatos

UNION ALL

SELECT
    'EMISIONES' as tipo,
    'Control de Emisiones a la Atmósfera' as descripcion,
    (SELECT COUNT(*) FROM formato_ecologia WHERE tipo = 'EMISIONES' AND activo = 'S') as total_formatos

UNION ALL

SELECT
    'AGUA' as tipo,
    'Uso y Aprovechamiento de Agua' as descripcion,
    (SELECT COUNT(*) FROM formato_ecologia WHERE tipo = 'AGUA' AND activo = 'S') as total_formatos

UNION ALL

SELECT
    'RUIDO' as tipo,
    'Control de Ruido y Contaminación Acústica' as descripcion,
    (SELECT COUNT(*) FROM formato_ecologia WHERE tipo = 'RUIDO' AND activo = 'S') as total_formatos

UNION ALL

SELECT
    'CERTIFICACION' as tipo,
    'Certificaciones Ambientales' as descripcion,
    (SELECT COUNT(*) FROM formato_ecologia WHERE tipo = 'CERTIFICACION' AND activo = 'S') as total_formatos

ORDER BY tipo;

END PROCEDURE;

-- ================================================
-- Crear tabla si no existe (DDL incluido para referencia)
-- ================================================
-- Esta sección es solo referencial para entender la estructura de la tabla

/*
CREATE TABLE IF NOT EXISTS formato_ecologia (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    codigo VARCHAR(50) UNIQUE,
    tipo VARCHAR(50) CHECK (tipo IN ('IMPACTO_AMBIENTAL', 'RESIDUOS', 'EMISIONES', 'AGUA', 'RUIDO', 'CERTIFICACION')),
    descripcion LVARCHAR(1000),
    observaciones LVARCHAR(500),
    vigencia_meses INTEGER DEFAULT 12 CHECK (vigencia_meses BETWEEN 1 AND 120),
    es_obligatorio CHAR(1) DEFAULT 'N' CHECK (es_obligatorio IN ('S', 'N')),
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    archivo_path VARCHAR(500),
    archivo_size INTEGER,
    fecha_creacion DATETIME YEAR TO SECOND DEFAULT CURRENT,
    fecha_actualizacion DATETIME YEAR TO SECOND DEFAULT CURRENT,
    usuario_creacion VARCHAR(100) DEFAULT 'SISTEMA',
    usuario_actualizacion VARCHAR(100) DEFAULT 'SISTEMA',
    ultima_revision DATE
);

CREATE INDEX IF NOT EXISTS idx_formato_ecologia_tipo ON formato_ecologia(tipo);
CREATE INDEX IF NOT EXISTS idx_formato_ecologia_activo ON formato_ecologia(activo);
CREATE INDEX IF NOT EXISTS idx_formato_ecologia_nombre ON formato_ecologia(nombre);
CREATE INDEX IF NOT EXISTS idx_formato_ecologia_codigo ON formato_ecologia(codigo);

-- Tabla de relación con licencias
CREATE TABLE IF NOT EXISTS licencia_formato_ecologia (
    id SERIAL PRIMARY KEY,
    licencia_id INTEGER NOT NULL,
    formato_id INTEGER NOT NULL,
    fecha_asignacion DATETIME YEAR TO SECOND DEFAULT CURRENT,
    fecha_cumplimiento DATE,
    estado VARCHAR(20) DEFAULT 'PENDIENTE' CHECK (estado IN ('PENDIENTE', 'CUMPLIDO', 'VENCIDO')),
    observaciones LVARCHAR(500),
    usuario_asignacion VARCHAR(100) DEFAULT 'SISTEMA',
    FOREIGN KEY (formato_id) REFERENCES formato_ecologia(id)
);

CREATE INDEX IF NOT EXISTS idx_licencia_formato_ecologia_licencia ON licencia_formato_ecologia(licencia_id);
CREATE INDEX IF NOT EXISTS idx_licencia_formato_ecologia_formato ON licencia_formato_ecologia(formato_id);
CREATE INDEX IF NOT EXISTS idx_licencia_formato_ecologia_estado ON licencia_formato_ecologia(estado);
*/

-- ================================================
-- RESUMEN DE STORED PROCEDURES IMPLEMENTADOS:
--
-- 1. SP_FORMATOSECOLOGIA_LIST - Búsqueda con filtros y paginación
-- 2. SP_FORMATOSECOLOGIA_GET - Obtener detalle completo
-- 3. SP_FORMATOSECOLOGIA_CREATE - Crear nuevo formato
-- 4. SP_FORMATOSECOLOGIA_UPDATE - Actualizar formato existente
-- 5. SP_FORMATOSECOLOGIA_CAMBIAR_ESTADO - Cambiar estado activo/inactivo
-- 6. SP_FORMATOSECOLOGIA_DELETE - Eliminación lógica (soft delete)
-- 7. SP_FORMATOSECOLOGIA_TIPOS - Catálogo de tipos disponibles
--
-- Características implementadas:
-- - Validaciones completas de datos de entrada
-- - Generación automática de códigos únicos
-- - Manejo de errores con mensajes descriptivos
-- - Soporte para paginación eficiente
-- - Búsqueda flexible por múltiples criterios
-- - Auditoría completa con fechas y usuarios
-- - Eliminación segura con verificación de dependencias
--
-- Base de datos: padron_licencias
-- Tenant: public
-- Versión: 1.0.0
-- Fecha: 2024-12-30
-- ================================================