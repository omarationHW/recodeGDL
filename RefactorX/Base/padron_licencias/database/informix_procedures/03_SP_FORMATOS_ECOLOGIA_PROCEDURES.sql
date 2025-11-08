-- ============================================
-- STORED PROCEDURES FOR INFORMIX COMPATIBILITY
-- Component: formatosEcologiafrm.vue
-- Base: padron_licencias
-- Description: Procedures for ecological formats management
-- ============================================

-- 1. sp_formatosecologia_list - List ecological formats
DROP PROCEDURE IF EXISTS sp_formatosecologia_list;

CREATE PROCEDURE sp_formatosecologia_list(
    p_nombre VARCHAR(255),
    p_tipo VARCHAR(50),
    p_activo CHAR(1),
    p_limite INTEGER,
    p_offset INTEGER
)
RETURNING
    INTEGER AS id,
    VARCHAR(255) AS nombre,
    VARCHAR(50) AS codigo,
    VARCHAR(50) AS tipo,
    INTEGER AS vigencia_meses,
    VARCHAR(500) AS descripcion,
    VARCHAR(500) AS observaciones,
    CHAR(1) AS es_obligatorio,
    CHAR(1) AS activo,
    DATE AS fecha_creacion,
    DATE AS fecha_modificacion,
    INTEGER AS total_registros;

    DEFINE v_id INTEGER;
    DEFINE v_nombre VARCHAR(255);
    DEFINE v_codigo VARCHAR(50);
    DEFINE v_tipo VARCHAR(50);
    DEFINE v_vigencia_meses INTEGER;
    DEFINE v_descripcion VARCHAR(500);
    DEFINE v_observaciones VARCHAR(500);
    DEFINE v_es_obligatorio CHAR(1);
    DEFINE v_activo CHAR(1);
    DEFINE v_fecha_creacion DATE;
    DEFINE v_fecha_modificacion DATE;
    DEFINE v_total INTEGER;

    -- Count total records
    SELECT COUNT(*)
    INTO v_total
    FROM formatos_ecologia
    WHERE (p_nombre IS NULL OR nombre LIKE '%' || p_nombre || '%')
      AND (p_tipo IS NULL OR tipo = p_tipo)
      AND (p_activo IS NULL OR activo = p_activo);

    -- Return paginated results
    FOREACH SELECT
        id,
        nombre,
        NVL(codigo, ''),
        NVL(tipo, ''),
        NVL(vigencia_meses, 12),
        NVL(descripcion, ''),
        NVL(observaciones, ''),
        NVL(es_obligatorio, 'N'),
        NVL(activo, 'S'),
        fecha_creacion,
        fecha_modificacion
    INTO
        v_id, v_nombre, v_codigo, v_tipo, v_vigencia_meses,
        v_descripcion, v_observaciones, v_es_obligatorio, v_activo,
        v_fecha_creacion, v_fecha_modificacion
    FROM formatos_ecologia
    WHERE (p_nombre IS NULL OR nombre LIKE '%' || p_nombre || '%')
      AND (p_tipo IS NULL OR tipo = p_tipo)
      AND (p_activo IS NULL OR activo = p_activo)
    ORDER BY nombre
    SKIP p_offset
    FIRST p_limite

        RETURN v_id, v_nombre, v_codigo, v_tipo, v_vigencia_meses,
               v_descripcion, v_observaciones, v_es_obligatorio, v_activo,
               v_fecha_creacion, v_fecha_modificacion, v_total
        WITH RESUME;

    END FOREACH;

END PROCEDURE;

-- ============================================

-- 2. sp_formatosecologia_get - Get specific ecological format
DROP PROCEDURE IF EXISTS sp_formatosecologia_get;

CREATE PROCEDURE sp_formatosecologia_get(p_id INTEGER)
RETURNING
    INTEGER AS id,
    VARCHAR(255) AS nombre,
    VARCHAR(50) AS codigo,
    VARCHAR(50) AS tipo,
    INTEGER AS vigencia_meses,
    VARCHAR(500) AS descripcion,
    VARCHAR(500) AS observaciones,
    CHAR(1) AS es_obligatorio,
    CHAR(1) AS activo,
    DATE AS fecha_creacion,
    DATE AS fecha_modificacion;

    DEFINE v_id INTEGER;
    DEFINE v_nombre VARCHAR(255);
    DEFINE v_codigo VARCHAR(50);
    DEFINE v_tipo VARCHAR(50);
    DEFINE v_vigencia_meses INTEGER;
    DEFINE v_descripcion VARCHAR(500);
    DEFINE v_observaciones VARCHAR(500);
    DEFINE v_es_obligatorio CHAR(1);
    DEFINE v_activo CHAR(1);
    DEFINE v_fecha_creacion DATE;
    DEFINE v_fecha_modificacion DATE;

    SELECT
        id,
        nombre,
        NVL(codigo, ''),
        NVL(tipo, ''),
        NVL(vigencia_meses, 12),
        NVL(descripcion, ''),
        NVL(observaciones, ''),
        NVL(es_obligatorio, 'N'),
        NVL(activo, 'S'),
        fecha_creacion,
        fecha_modificacion
    INTO
        v_id, v_nombre, v_codigo, v_tipo, v_vigencia_meses,
        v_descripcion, v_observaciones, v_es_obligatorio, v_activo,
        v_fecha_creacion, v_fecha_modificacion
    FROM formatos_ecologia
    WHERE id = p_id;

    IF SQLCA.SQLCODE = 0 THEN
        RETURN v_id, v_nombre, v_codigo, v_tipo, v_vigencia_meses,
               v_descripcion, v_observaciones, v_es_obligatorio, v_activo,
               v_fecha_creacion, v_fecha_modificacion
        WITH RESUME;
    END IF;

END PROCEDURE;

-- ============================================

-- 3. sp_formatosecologia_create - Create new ecological format
DROP PROCEDURE IF EXISTS sp_formatosecologia_create;

CREATE PROCEDURE sp_formatosecologia_create(
    p_nombre VARCHAR(255),
    p_codigo VARCHAR(50),
    p_tipo VARCHAR(50),
    p_vigencia_meses INTEGER,
    p_descripcion VARCHAR(500),
    p_observaciones VARCHAR(500),
    p_es_obligatorio CHAR(1),
    p_activo CHAR(1)
)
RETURNING
    INTEGER AS id,
    VARCHAR(50) AS status,
    VARCHAR(255) AS mensaje;

    DEFINE v_new_id INTEGER;
    DEFINE v_exists INTEGER;

    -- Check if format with same name already exists
    SELECT COUNT(*)
    INTO v_exists
    FROM formatos_ecologia
    WHERE UPPER(nombre) = UPPER(p_nombre);

    IF v_exists > 0 THEN
        RETURN 0, 'ERROR', 'Ya existe un formato con ese nombre' WITH RESUME;
    END IF;

    -- Get next ID
    SELECT NVL(MAX(id), 0) + 1
    INTO v_new_id
    FROM formatos_ecologia;

    -- Insert new format
    INSERT INTO formatos_ecologia (
        id,
        nombre,
        codigo,
        tipo,
        vigencia_meses,
        descripcion,
        observaciones,
        es_obligatorio,
        activo,
        fecha_creacion,
        fecha_modificacion
    ) VALUES (
        v_new_id,
        p_nombre,
        p_codigo,
        p_tipo,
        NVL(p_vigencia_meses, 12),
        p_descripcion,
        p_observaciones,
        NVL(p_es_obligatorio, 'N'),
        NVL(p_activo, 'S'),
        TODAY,
        TODAY
    );

    IF SQLCA.SQLCODE = 0 THEN
        RETURN v_new_id, 'SUCCESS', 'Formato creado exitosamente' WITH RESUME;
    ELSE
        RETURN 0, 'ERROR', 'Error al crear el formato' WITH RESUME;
    END IF;

END PROCEDURE;

-- ============================================

-- 4. sp_formatosecologia_cambiar_estado - Change format status
DROP PROCEDURE IF EXISTS sp_formatosecologia_cambiar_estado;

CREATE PROCEDURE sp_formatosecologia_cambiar_estado(
    p_id INTEGER,
    p_nuevo_estado CHAR(1)
)
RETURNING
    VARCHAR(50) AS status,
    VARCHAR(255) AS mensaje;

    DEFINE v_exists INTEGER;

    -- Check if format exists
    SELECT COUNT(*)
    INTO v_exists
    FROM formatos_ecologia
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN 'ERROR', 'Formato no encontrado' WITH RESUME;
    END IF;

    -- Update status
    UPDATE formatos_ecologia
    SET activo = p_nuevo_estado,
        fecha_modificacion = TODAY
    WHERE id = p_id;

    IF SQLCA.SQLCODE = 0 THEN
        IF p_nuevo_estado = 'S' THEN
            RETURN 'SUCCESS', 'Formato activado exitosamente' WITH RESUME;
        ELSE
            RETURN 'SUCCESS', 'Formato desactivado exitosamente' WITH RESUME;
        END IF;
    ELSE
        RETURN 'ERROR', 'Error al cambiar el estado del formato' WITH RESUME;
    END IF;

END PROCEDURE;

-- ============================================

-- 5. sp_formatosecologia_update - Update ecological format
DROP PROCEDURE IF EXISTS sp_formatosecologia_update;

CREATE PROCEDURE sp_formatosecologia_update(
    p_id INTEGER,
    p_nombre VARCHAR(255),
    p_codigo VARCHAR(50),
    p_tipo VARCHAR(50),
    p_vigencia_meses INTEGER,
    p_descripcion VARCHAR(500),
    p_observaciones VARCHAR(500),
    p_es_obligatorio CHAR(1),
    p_activo CHAR(1)
)
RETURNING
    VARCHAR(50) AS status,
    VARCHAR(255) AS mensaje;

    DEFINE v_exists INTEGER;
    DEFINE v_name_exists INTEGER;

    -- Check if format exists
    SELECT COUNT(*)
    INTO v_exists
    FROM formatos_ecologia
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN 'ERROR', 'Formato no encontrado' WITH RESUME;
    END IF;

    -- Check if another format with same name exists
    SELECT COUNT(*)
    INTO v_name_exists
    FROM formatos_ecologia
    WHERE UPPER(nombre) = UPPER(p_nombre)
      AND id != p_id;

    IF v_name_exists > 0 THEN
        RETURN 'ERROR', 'Ya existe otro formato con ese nombre' WITH RESUME;
    END IF;

    -- Update format
    UPDATE formatos_ecologia
    SET nombre = p_nombre,
        codigo = p_codigo,
        tipo = p_tipo,
        vigencia_meses = p_vigencia_meses,
        descripcion = p_descripcion,
        observaciones = p_observaciones,
        es_obligatorio = p_es_obligatorio,
        activo = p_activo,
        fecha_modificacion = TODAY
    WHERE id = p_id;

    IF SQLCA.SQLCODE = 0 THEN
        RETURN 'SUCCESS', 'Formato actualizado exitosamente' WITH RESUME;
    ELSE
        RETURN 'ERROR', 'Error al actualizar el formato' WITH RESUME;
    END IF;

END PROCEDURE;