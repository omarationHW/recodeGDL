-- =============================================
-- Archivo: 30_SP_PRIVILEGIOS_INFORMIX.sql
-- Descripción: Stored Procedures para gestión de privilegios y permisos de usuarios
-- Módulo: LICENCIAS - Sistema de Control de Privilegios
-- Autor: Sistema de Migración
-- Fecha: 2025-09-30
-- =============================================

-- =============================================
-- SP_PRIVILEGIOS_LIST: Listar usuarios con información de privilegios
-- =============================================
DROP PROCEDURE IF EXISTS SP_PRIVILEGIOS_LIST;

CREATE PROCEDURE SP_PRIVILEGIOS_LIST(
    p_filtro_usuario VARCHAR(50),
    p_filtro_departamento VARCHAR(50),
    p_filtro_estado SMALLINT,
    p_campo_orden VARCHAR(50),
    p_direccion_orden VARCHAR(4),
    p_limite_pag INTEGER,
    p_offset_pag INTEGER
)

RETURNING
    VARCHAR(50) AS usuario,
    VARCHAR(150) AS nombres,
    VARCHAR(100) AS nombredepto,
    SMALLINT AS baja,
    INTEGER AS total_permisos,
    INTEGER AS total_registros;

DEFINE v_sql_query VARCHAR(2000);
DEFINE v_where_clause VARCHAR(500);
DEFINE v_order_clause VARCHAR(100);
DEFINE v_limit_clause VARCHAR(50);

-- Construir cláusula WHERE
LET v_where_clause = " WHERE 1=1 ";

IF p_filtro_usuario IS NOT NULL AND LENGTH(TRIM(p_filtro_usuario)) > 0 THEN
    LET v_where_clause = v_where_clause ||
        " AND (u.usuario LIKE '%" || TRIM(p_filtro_usuario) || "%' OR u.nombres LIKE '%" || TRIM(p_filtro_usuario) || "%') ";
END IF;

IF p_filtro_departamento IS NOT NULL AND LENGTH(TRIM(p_filtro_departamento)) > 0 THEN
    LET v_where_clause = v_where_clause ||
        " AND u.nombredepto = '" || TRIM(p_filtro_departamento) || "' ";
END IF;

IF p_filtro_estado IS NOT NULL THEN
    LET v_where_clause = v_where_clause ||
        " AND u.baja = " || p_filtro_estado || " ";
END IF;

-- Construir cláusula ORDER BY
LET v_order_clause = " ORDER BY ";
IF p_campo_orden IS NOT NULL AND LENGTH(TRIM(p_campo_orden)) > 0 THEN
    LET v_order_clause = v_order_clause || "u." || TRIM(p_campo_orden);
ELSE
    LET v_order_clause = v_order_clause || "u.usuario";
END IF;

IF p_direccion_orden IS NOT NULL AND UPPER(TRIM(p_direccion_orden)) = 'DESC' THEN
    LET v_order_clause = v_order_clause || " DESC";
ELSE
    LET v_order_clause = v_order_clause || " ASC";
END IF;

-- Construir cláusula LIMIT
LET v_limit_clause = "";
IF p_limite_pag IS NOT NULL AND p_limite_pag > 0 THEN
    LET v_limit_clause = " FIRST " || p_limite_pag;
    IF p_offset_pag IS NOT NULL AND p_offset_pag > 0 THEN
        LET v_limit_clause = " SKIP " || p_offset_pag || v_limit_clause;
    END IF;
END IF;

-- Construir consulta principal
LET v_sql_query = "SELECT " || v_limit_clause || "
    u.usuario,
    u.nombres,
    u.nombredepto,
    u.baja,
    COALESCE(p.total_permisos, 0) AS total_permisos,
    (SELECT COUNT(*) FROM usuarios u2 " || v_where_clause || ") AS total_registros
FROM usuarios u
LEFT JOIN (
    SELECT usuario, COUNT(*) AS total_permisos
    FROM privilegios
    WHERE fecha_revocacion IS NULL
    GROUP BY usuario
) p ON u.usuario = p.usuario " ||
v_where_clause || v_order_clause;

-- Ejecutar consulta usando PREPARE y EXECUTE
PREPARE stmt FROM v_sql_query;
EXECUTE stmt;

END PROCEDURE;

-- =============================================
-- SP_PRIVILEGIOS_GET: Obtener privilegios específicos de un usuario
-- =============================================
DROP PROCEDURE IF EXISTS SP_PRIVILEGIOS_GET;

CREATE PROCEDURE SP_PRIVILEGIOS_GET(
    p_usuario_buscar VARCHAR(50)
)

RETURNING
    INTEGER AS id,
    VARCHAR(50) AS usuario,
    INTEGER AS num_tag,
    VARCHAR(200) AS descripcion,
    DATE AS fecha_asignacion,
    DATE AS fecha_inicio,
    DATE AS fecha_fin,
    DATE AS fecha_revocacion,
    VARCHAR(50) AS usuario_asigna,
    VARCHAR(50) AS usuario_revoca,
    VARCHAR(500) AS observaciones;

-- Validar parámetros
IF p_usuario_buscar IS NULL OR LENGTH(TRIM(p_usuario_buscar)) = 0 THEN
    RAISE EXCEPTION -746, 0, "El usuario es requerido";
END IF;

-- Obtener privilegios activos del usuario
FOREACH
    SELECT
        id,
        usuario,
        num_tag,
        descripcion,
        fecha_asignacion,
        fecha_inicio,
        fecha_fin,
        fecha_revocacion,
        usuario_asigna,
        usuario_revoca,
        observaciones
    INTO
        id,
        usuario,
        num_tag,
        descripcion,
        fecha_asignacion,
        fecha_inicio,
        fecha_fin,
        fecha_revocacion,
        usuario_asigna,
        usuario_revoca,
        observaciones
    FROM privilegios
    WHERE usuario = TRIM(p_usuario_buscar)
      AND fecha_revocacion IS NULL
      AND (fecha_inicio IS NULL OR fecha_inicio <= TODAY)
      AND (fecha_fin IS NULL OR fecha_fin >= TODAY)
    ORDER BY num_tag, fecha_asignacion DESC

    RETURN
        id,
        usuario,
        num_tag,
        descripcion,
        fecha_asignacion,
        fecha_inicio,
        fecha_fin,
        fecha_revocacion,
        usuario_asigna,
        usuario_revoca,
        observaciones;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_PRIVILEGIOS_CREATE: Crear nuevo registro de privilegio (base)
-- =============================================
DROP PROCEDURE IF EXISTS SP_PRIVILEGIOS_CREATE;

CREATE PROCEDURE SP_PRIVILEGIOS_CREATE(
    p_usuario VARCHAR(50),
    p_num_tag INTEGER,
    p_descripcion VARCHAR(200),
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_usuario_asigna VARCHAR(50),
    p_observaciones VARCHAR(500)
)

RETURNING INTEGER AS nuevo_id;

DEFINE v_nuevo_id INTEGER;
DEFINE v_existe_usuario SMALLINT;
DEFINE v_existe_privilegio SMALLINT;

-- Validar parámetros obligatorios
IF p_usuario IS NULL OR LENGTH(TRIM(p_usuario)) = 0 THEN
    RAISE EXCEPTION -746, 0, "El usuario es requerido";
END IF;

IF p_num_tag IS NULL OR p_num_tag <= 0 THEN
    RAISE EXCEPTION -746, 0, "El número de tag es requerido y debe ser mayor a 0";
END IF;

IF p_descripcion IS NULL OR LENGTH(TRIM(p_descripcion)) = 0 THEN
    RAISE EXCEPTION -746, 0, "La descripción del privilegio es requerida";
END IF;

-- Verificar que el usuario existe
SELECT COUNT(*) INTO v_existe_usuario
FROM usuarios
WHERE usuario = TRIM(p_usuario) AND baja = 0;

IF v_existe_usuario = 0 THEN
    RAISE EXCEPTION -746, 0, "El usuario especificado no existe o está dado de baja";
END IF;

-- Verificar si ya existe un privilegio activo para el usuario y tag
SELECT COUNT(*) INTO v_existe_privilegio
FROM privilegios
WHERE usuario = TRIM(p_usuario)
  AND num_tag = p_num_tag
  AND fecha_revocacion IS NULL;

IF v_existe_privilegio > 0 THEN
    RAISE EXCEPTION -746, 0, "El usuario ya tiene asignado este privilegio";
END IF;

-- Insertar nuevo privilegio
INSERT INTO privilegios (
    usuario,
    num_tag,
    descripcion,
    fecha_asignacion,
    fecha_inicio,
    fecha_fin,
    usuario_asigna,
    observaciones
) VALUES (
    TRIM(p_usuario),
    p_num_tag,
    TRIM(p_descripcion),
    TODAY,
    p_fecha_inicio,
    p_fecha_fin,
    TRIM(p_usuario_asigna),
    TRIM(p_observaciones)
);

-- Obtener el ID generado
LET v_nuevo_id = SQLCA.SQLERRD[2];

RETURN v_nuevo_id;

END PROCEDURE;

-- =============================================
-- SP_PRIVILEGIOS_UPDATE: Actualizar privilegio existente
-- =============================================
DROP PROCEDURE IF EXISTS SP_PRIVILEGIOS_UPDATE;

CREATE PROCEDURE SP_PRIVILEGIOS_UPDATE(
    p_id_privilegio INTEGER,
    p_descripcion VARCHAR(200),
    p_fecha_inicio DATE,
    p_fecha_fin DATE,
    p_observaciones VARCHAR(500),
    p_usuario_modifica VARCHAR(50)
)

RETURNING SMALLINT AS resultado;

DEFINE v_existe_privilegio SMALLINT;

-- Validar parámetros
IF p_id_privilegio IS NULL OR p_id_privilegio <= 0 THEN
    RAISE EXCEPTION -746, 0, "El ID del privilegio es requerido";
END IF;

-- Verificar que el privilegio existe y está activo
SELECT COUNT(*) INTO v_existe_privilegio
FROM privilegios
WHERE id = p_id_privilegio AND fecha_revocacion IS NULL;

IF v_existe_privilegio = 0 THEN
    RAISE EXCEPTION -746, 0, "El privilegio especificado no existe o ya fue revocado";
END IF;

-- Actualizar privilegio
UPDATE privilegios SET
    descripcion = COALESCE(TRIM(p_descripcion), descripcion),
    fecha_inicio = COALESCE(p_fecha_inicio, fecha_inicio),
    fecha_fin = COALESCE(p_fecha_fin, fecha_fin),
    observaciones = COALESCE(TRIM(p_observaciones), observaciones),
    fecha_modificacion = TODAY,
    usuario_modifica = TRIM(p_usuario_modifica)
WHERE id = p_id_privilegio;

-- Registrar en auditoría
INSERT INTO auditoria_privilegios (
    id_privilegio,
    usuario_afectado,
    num_tag,
    accion,
    usuario_ejecuta,
    fecha_accion,
    observaciones_auditoria
) SELECT
    id,
    usuario,
    num_tag,
    'UPDATE',
    TRIM(p_usuario_modifica),
    CURRENT,
    'Privilegio actualizado: ' || COALESCE(TRIM(p_observaciones), 'Sin observaciones')
FROM privilegios
WHERE id = p_id_privilegio;

RETURN 1;

END PROCEDURE;

-- =============================================
-- SP_PRIVILEGIOS_DELETE: Eliminar (revocar) privilegio
-- =============================================
DROP PROCEDURE IF EXISTS SP_PRIVILEGIOS_DELETE;

CREATE PROCEDURE SP_PRIVILEGIOS_DELETE(
    p_id_privilegio INTEGER,
    p_usuario_revoca VARCHAR(50),
    p_motivo_revocacion VARCHAR(500)
)

RETURNING SMALLINT AS resultado;

DEFINE v_existe_privilegio SMALLINT;
DEFINE v_usuario_afectado VARCHAR(50);
DEFINE v_num_tag INTEGER;

-- Validar parámetros
IF p_id_privilegio IS NULL OR p_id_privilegio <= 0 THEN
    RAISE EXCEPTION -746, 0, "El ID del privilegio es requerido";
END IF;

-- Verificar que el privilegio existe y está activo
SELECT COUNT(*), FIRST 1 usuario, FIRST 1 num_tag
INTO v_existe_privilegio, v_usuario_afectado, v_num_tag
FROM privilegios
WHERE id = p_id_privilegio AND fecha_revocacion IS NULL;

IF v_existe_privilegio = 0 THEN
    RAISE EXCEPTION -746, 0, "El privilegio especificado no existe o ya fue revocado";
END IF;

-- Revocar privilegio (no eliminar físicamente)
UPDATE privilegios SET
    fecha_revocacion = TODAY,
    usuario_revoca = TRIM(p_usuario_revoca),
    motivo_revocacion = TRIM(p_motivo_revocacion)
WHERE id = p_id_privilegio;

-- Registrar en auditoría
INSERT INTO auditoria_privilegios (
    id_privilegio,
    usuario_afectado,
    num_tag,
    accion,
    usuario_ejecuta,
    fecha_accion,
    observaciones_auditoria
) VALUES (
    p_id_privilegio,
    v_usuario_afectado,
    v_num_tag,
    'REVOKE',
    TRIM(p_usuario_revoca),
    CURRENT,
    'Privilegio revocado: ' || COALESCE(TRIM(p_motivo_revocacion), 'Sin motivo especificado')
);

RETURN 1;

END PROCEDURE;

-- =============================================
-- SP_PRIVILEGIOS_ASIGNAR: Asignar privilegio a usuario (interfaz principal)
-- =============================================
DROP PROCEDURE IF EXISTS SP_PRIVILEGIOS_ASIGNAR;

CREATE PROCEDURE SP_PRIVILEGIOS_ASIGNAR(
    p_usuario_destino VARCHAR(50),
    p_numero_tag INTEGER,
    p_descripcion_permiso VARCHAR(200),
    p_fecha_vigencia_inicio DATE,
    p_fecha_vigencia_fin DATE,
    p_observaciones_permiso VARCHAR(500),
    p_usuario_asigna VARCHAR(50)
)

RETURNING INTEGER AS id_privilegio_creado;

DEFINE v_nuevo_id INTEGER;

-- Llamar al procedimiento de creación
EXECUTE PROCEDURE SP_PRIVILEGIOS_CREATE(
    p_usuario_destino,
    p_numero_tag,
    p_descripcion_permiso,
    p_fecha_vigencia_inicio,
    p_fecha_vigencia_fin,
    p_usuario_asigna,
    p_observaciones_permiso
) INTO v_nuevo_id;

-- Registrar en auditoría
INSERT INTO auditoria_privilegios (
    id_privilegio,
    usuario_afectado,
    num_tag,
    accion,
    usuario_ejecuta,
    fecha_accion,
    observaciones_auditoria
) VALUES (
    v_nuevo_id,
    TRIM(p_usuario_destino),
    p_numero_tag,
    'GRANT',
    TRIM(p_usuario_asigna),
    CURRENT,
    'Privilegio asignado: ' || TRIM(p_descripcion_permiso)
);

RETURN v_nuevo_id;

END PROCEDURE;

-- =============================================
-- SP_USUARIO_PERMISOS_GET: Obtener permisos activos de un usuario
-- =============================================
DROP PROCEDURE IF EXISTS SP_USUARIO_PERMISOS_GET;

CREATE PROCEDURE SP_USUARIO_PERMISOS_GET(
    p_usuario_buscar VARCHAR(50)
)

RETURNING
    INTEGER AS id,
    INTEGER AS num_tag,
    VARCHAR(200) AS descripcion,
    DATE AS fecha_asignacion,
    DATE AS fecha_inicio,
    DATE AS fecha_fin,
    VARCHAR(50) AS usuario_asigna;

-- Validar parámetros
IF p_usuario_buscar IS NULL OR LENGTH(TRIM(p_usuario_buscar)) = 0 THEN
    RAISE EXCEPTION -746, 0, "El usuario es requerido";
END IF;

-- Obtener permisos activos del usuario
FOREACH
    SELECT
        id,
        num_tag,
        descripcion,
        fecha_asignacion,
        fecha_inicio,
        fecha_fin,
        usuario_asigna
    INTO
        id,
        num_tag,
        descripcion,
        fecha_asignacion,
        fecha_inicio,
        fecha_fin,
        usuario_asigna
    FROM privilegios
    WHERE usuario = TRIM(p_usuario_buscar)
      AND fecha_revocacion IS NULL
      AND (fecha_inicio IS NULL OR fecha_inicio <= TODAY)
      AND (fecha_fin IS NULL OR fecha_fin >= TODAY)
    ORDER BY num_tag, fecha_asignacion DESC

    RETURN
        id,
        num_tag,
        descripcion,
        fecha_asignacion,
        fecha_inicio,
        fecha_fin,
        usuario_asigna;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_USUARIO_AUDITORIA_GET: Obtener auditoría de privilegios de un usuario
-- =============================================
DROP PROCEDURE IF EXISTS SP_USUARIO_AUDITORIA_GET;

CREATE PROCEDURE SP_USUARIO_AUDITORIA_GET(
    p_usuario_audit VARCHAR(50),
    p_limite_audit INTEGER
)

RETURNING
    INTEGER AS id,
    INTEGER AS num_tag,
    VARCHAR(200) AS descripcion,
    VARCHAR(10) AS proc,
    DATETIME YEAR TO SECOND AS fechahora,
    VARCHAR(100) AS equipo;

DEFINE v_limite INTEGER;

-- Validar parámetros
IF p_usuario_audit IS NULL OR LENGTH(TRIM(p_usuario_audit)) = 0 THEN
    RAISE EXCEPTION -746, 0, "El usuario es requerido";
END IF;

LET v_limite = COALESCE(p_limite_audit, 50);

-- Obtener auditoría del usuario
FOREACH
    SELECT FIRST v_limite
        ap.id,
        ap.num_tag,
        p.descripcion,
        ap.accion AS proc,
        ap.fecha_accion AS fechahora,
        COALESCE(ap.equipo_origen, 'N/A') AS equipo
    INTO
        id,
        num_tag,
        descripcion,
        proc,
        fechahora,
        equipo
    FROM auditoria_privilegios ap
    LEFT JOIN privilegios p ON ap.id_privilegio = p.id
    WHERE ap.usuario_afectado = TRIM(p_usuario_audit)
    ORDER BY ap.fecha_accion DESC

    RETURN
        id,
        num_tag,
        descripcion,
        proc,
        fechahora,
        equipo;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_AUDITORIA_PRIVILEGIOS_GLOBAL: Auditoría global del sistema
-- =============================================
DROP PROCEDURE IF EXISTS SP_AUDITORIA_PRIVILEGIOS_GLOBAL;

CREATE PROCEDURE SP_AUDITORIA_PRIVILEGIOS_GLOBAL(
    p_limite_registros INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)

RETURNING
    INTEGER AS id,
    VARCHAR(50) AS usuario,
    INTEGER AS num_tag,
    VARCHAR(200) AS descripcion,
    VARCHAR(10) AS proc,
    DATETIME YEAR TO SECOND AS fechahora,
    VARCHAR(100) AS equipo;

DEFINE v_limite INTEGER;
DEFINE v_where_fecha VARCHAR(200);

LET v_limite = COALESCE(p_limite_registros, 100);
LET v_where_fecha = "";

-- Construir filtro de fechas si se proporcionan
IF p_fecha_desde IS NOT NULL THEN
    LET v_where_fecha = " AND DATE(ap.fecha_accion) >= '" || p_fecha_desde || "'";
END IF;

IF p_fecha_hasta IS NOT NULL THEN
    LET v_where_fecha = v_where_fecha || " AND DATE(ap.fecha_accion) <= '" || p_fecha_hasta || "'";
END IF;

-- Obtener auditoría global
FOREACH CURSOR c_audit FOR
    SELECT FIRST v_limite
        ap.id,
        ap.usuario_afectado AS usuario,
        ap.num_tag,
        COALESCE(p.descripcion, 'Privilegio eliminado') AS descripcion,
        ap.accion AS proc,
        ap.fecha_accion AS fechahora,
        COALESCE(ap.equipo_origen, 'N/A') AS equipo
    FROM auditoria_privilegios ap
    LEFT JOIN privilegios p ON ap.id_privilegio = p.id
    WHERE 1=1 || v_where_fecha
    ORDER BY ap.fecha_accion DESC

    RETURN
        id,
        usuario,
        num_tag,
        descripcion,
        proc,
        fechahora,
        equipo;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_PRIVILEGIO_REVOCAR: Revocar privilegio específico
-- =============================================
DROP PROCEDURE IF EXISTS SP_PRIVILEGIO_REVOCAR;

CREATE PROCEDURE SP_PRIVILEGIO_REVOCAR(
    p_usuario_objetivo VARCHAR(50),
    p_numero_tag_revoke INTEGER,
    p_usuario_revoca VARCHAR(50),
    p_motivo_revocacion VARCHAR(500)
)

RETURNING SMALLINT AS resultado;

DEFINE v_id_privilegio INTEGER;
DEFINE v_existe_privilegio SMALLINT;

-- Validar parámetros
IF p_usuario_objetivo IS NULL OR LENGTH(TRIM(p_usuario_objetivo)) = 0 THEN
    RAISE EXCEPTION -746, 0, "El usuario objetivo es requerido";
END IF;

IF p_numero_tag_revoke IS NULL OR p_numero_tag_revoke <= 0 THEN
    RAISE EXCEPTION -746, 0, "El número de tag es requerido";
END IF;

-- Buscar el privilegio activo
SELECT COUNT(*), FIRST 1 id
INTO v_existe_privilegio, v_id_privilegio
FROM privilegios
WHERE usuario = TRIM(p_usuario_objetivo)
  AND num_tag = p_numero_tag_revoke
  AND fecha_revocacion IS NULL;

IF v_existe_privilegio = 0 THEN
    RAISE EXCEPTION -746, 0, "No se encontró un privilegio activo para el usuario y tag especificados";
END IF;

-- Llamar al procedimiento de eliminación
EXECUTE PROCEDURE SP_PRIVILEGIOS_DELETE(
    v_id_privilegio,
    p_usuario_revoca,
    p_motivo_revocacion
);

RETURN 1;

END PROCEDURE;

-- =============================================
-- Comentarios de uso y estructura de tablas requeridas
-- =============================================

/*
ESTRUCTURA DE TABLAS REQUERIDAS:

1. tabla: usuarios
   - usuario VARCHAR(50) PRIMARY KEY
   - nombres VARCHAR(150)
   - nombredepto VARCHAR(100)
   - baja SMALLINT DEFAULT 0

2. tabla: privilegios
   - id SERIAL PRIMARY KEY
   - usuario VARCHAR(50) REFERENCES usuarios(usuario)
   - num_tag INTEGER NOT NULL
   - descripcion VARCHAR(200) NOT NULL
   - fecha_asignacion DATE DEFAULT TODAY
   - fecha_inicio DATE
   - fecha_fin DATE
   - fecha_revocacion DATE
   - fecha_modificacion DATE
   - usuario_asigna VARCHAR(50)
   - usuario_revoca VARCHAR(50)
   - usuario_modifica VARCHAR(50)
   - motivo_revocacion VARCHAR(500)
   - observaciones VARCHAR(500)

3. tabla: auditoria_privilegios
   - id SERIAL PRIMARY KEY
   - id_privilegio INTEGER
   - usuario_afectado VARCHAR(50)
   - num_tag INTEGER
   - accion VARCHAR(10) -- GRANT, REVOKE, UPDATE
   - usuario_ejecuta VARCHAR(50)
   - fecha_accion DATETIME YEAR TO SECOND DEFAULT CURRENT
   - equipo_origen VARCHAR(100)
   - observaciones_auditoria VARCHAR(500)

ÍNDICES RECOMENDADOS:
- CREATE INDEX idx_privilegios_usuario ON privilegios(usuario, fecha_revocacion);
- CREATE INDEX idx_privilegios_tag ON privilegios(num_tag, fecha_revocacion);
- CREATE INDEX idx_auditoria_usuario ON auditoria_privilegios(usuario_afectado, fecha_accion);
- CREATE INDEX idx_auditoria_fecha ON auditoria_privilegios(fecha_accion);
*/