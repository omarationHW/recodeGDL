-- ============================================
-- STORED PROCEDURES PARA DEPENDENCIAS
-- Base de datos: padron_licencias
-- Esquema: public
-- Archivo: SP_DEPENDENCIAS_PROCEDURES.sql
-- Generado: 2025-09-21
-- Total SPs: 3
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- ============================================
-- SP 1/3: SP_DEPENDENCIAS_LIST
-- Tipo: List/Search
-- Descripción: Lista todas las dependencias con filtros opcionales
-- ============================================

CREATE OR REPLACE FUNCTION SP_DEPENDENCIAS_LIST(
    p_codigo VARCHAR DEFAULT NULL,
    p_nombre VARCHAR DEFAULT NULL,
    p_descripcion VARCHAR DEFAULT NULL,
    p_activo VARCHAR DEFAULT NULL,
    p_limite INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id_dependencia INTEGER,
    codigo VARCHAR,
    nombre VARCHAR,
    descripcion TEXT,
    responsable VARCHAR,
    telefono VARCHAR,
    email VARCHAR,
    extension VARCHAR,
    direccion TEXT,
    observaciones TEXT,
    activo VARCHAR,
    clave VARCHAR,
    abrevia VARCHAR,
    licencias INTEGER,
    vigente VARCHAR,
    fecha_registro TIMESTAMP,
    total_registros BIGINT
) AS $$
DECLARE
    v_sql TEXT;
    v_where_conditions TEXT := '';
    v_total BIGINT;
BEGIN
    -- Construir WHERE clause dinámicamente
    IF p_codigo IS NOT NULL AND p_codigo != '' THEN
        v_where_conditions := v_where_conditions || ' AND UPPER(clave) LIKE UPPER(''%' || p_codigo || '%'')';
    END IF;

    IF p_nombre IS NOT NULL AND p_nombre != '' THEN
        v_where_conditions := v_where_conditions || ' AND UPPER(descripcion) LIKE UPPER(''%' || p_nombre || '%'')';
    END IF;

    IF p_descripcion IS NOT NULL AND p_descripcion != '' THEN
        v_where_conditions := v_where_conditions || ' AND UPPER(descripcion) LIKE UPPER(''%' || p_descripcion || '%'')';
    END IF;

    IF p_activo IS NOT NULL AND p_activo != '' THEN
        v_where_conditions := v_where_conditions || ' AND vigente = ''' || p_activo || '''';
    END IF;

    -- Obtener total de registros
    v_sql := 'SELECT COUNT(*) FROM c_dependencias WHERE 1=1' || v_where_conditions;
    EXECUTE v_sql INTO v_total;

    -- Query principal con datos completos
    RETURN QUERY EXECUTE '
        SELECT
            d.id_dependencia,
            d.clave as codigo,
            d.descripcion as nombre,
            d.descripcion,
            CAST('''' as VARCHAR) as responsable,
            CAST('''' as VARCHAR) as telefono,
            CAST('''' as VARCHAR) as email,
            CAST('''' as VARCHAR) as extension,
            CAST('''' as TEXT) as direccion,
            CAST('''' as TEXT) as observaciones,
            CASE WHEN d.vigente = ''V'' THEN ''S'' ELSE ''N'' END as activo,
            d.clave,
            d.abrevia,
            d.licencias,
            d.vigente,
            NOW() as fecha_registro,
            ' || v_total || ' as total_registros
        FROM c_dependencias d
        WHERE 1=1 ' || v_where_conditions || '
        ORDER BY d.descripcion
        LIMIT ' || p_limite || ' OFFSET ' || p_offset;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/3: SP_DEPENDENCIAS_CREATE
-- Tipo: Create
-- Descripción: Crea una nueva dependencia
-- ============================================

CREATE OR REPLACE FUNCTION SP_DEPENDENCIAS_CREATE(
    p_codigo VARCHAR,
    p_nombre VARCHAR,
    p_descripcion VARCHAR DEFAULT NULL,
    p_responsable VARCHAR DEFAULT NULL,
    p_telefono VARCHAR DEFAULT NULL,
    p_email VARCHAR DEFAULT NULL,
    p_extension VARCHAR DEFAULT NULL,
    p_direccion TEXT DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_activo VARCHAR DEFAULT 'S'
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_dependencia INTEGER
) AS $$
DECLARE
    v_exists INTEGER;
    v_new_id INTEGER;
    v_vigente VARCHAR;
BEGIN
    -- Validar que no exista el código
    SELECT COUNT(*) INTO v_exists
    FROM c_dependencias
    WHERE UPPER(clave) = UPPER(p_codigo);

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una dependencia con este código', NULL::INTEGER;
        RETURN;
    END IF;

    -- Convertir activo a vigente
    v_vigente := CASE WHEN p_activo = 'S' THEN 'V' ELSE 'N' END;

    -- Obtener el siguiente ID
    SELECT COALESCE(MAX(id_dependencia), 0) + 1 INTO v_new_id FROM c_dependencias;

    -- Insertar nueva dependencia
    INSERT INTO c_dependencias (
        id_dependencia,
        clave,
        descripcion,
        abrevia,
        licencias,
        vigente
    ) VALUES (
        v_new_id,
        p_codigo,
        p_nombre,
        LEFT(p_codigo, 5), -- Abreviación basada en código
        1, -- Por defecto para licencias
        v_vigente
    );

    RETURN QUERY SELECT TRUE, 'Dependencia creada exitosamente', v_new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/3: SP_DEPENDENCIAS_UPDATE
-- Tipo: Update
-- Descripción: Actualiza una dependencia existente
-- ============================================

CREATE OR REPLACE FUNCTION SP_DEPENDENCIAS_UPDATE(
    p_id INTEGER,
    p_codigo VARCHAR,
    p_nombre VARCHAR,
    p_descripcion VARCHAR DEFAULT NULL,
    p_responsable VARCHAR DEFAULT NULL,
    p_telefono VARCHAR DEFAULT NULL,
    p_email VARCHAR DEFAULT NULL,
    p_extension VARCHAR DEFAULT NULL,
    p_direccion TEXT DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_activo VARCHAR DEFAULT 'S'
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists INTEGER;
    v_code_exists INTEGER;
    v_vigente VARCHAR;
BEGIN
    -- Validar que existe la dependencia
    SELECT COUNT(*) INTO v_exists
    FROM c_dependencias
    WHERE id_dependencia = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe la dependencia especificada';
        RETURN;
    END IF;

    -- Validar que no exista otro registro con el mismo código
    SELECT COUNT(*) INTO v_code_exists
    FROM c_dependencias
    WHERE UPPER(clave) = UPPER(p_codigo) AND id_dependencia != p_id;

    IF v_code_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe otra dependencia con este código';
        RETURN;
    END IF;

    -- Convertir activo a vigente
    v_vigente := CASE WHEN p_activo = 'S' THEN 'V' ELSE 'N' END;

    -- Actualizar dependencia
    UPDATE c_dependencias SET
        clave = p_codigo,
        descripcion = p_nombre,
        abrevia = LEFT(p_codigo, 5),
        vigente = v_vigente
    WHERE id_dependencia = p_id;

    RETURN QUERY SELECT TRUE, 'Dependencia actualizada exitosamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/3: SP_DEPENDENCIAS_DELETE
-- Tipo: Delete
-- Descripción: Elimina una dependencia (soft delete)
-- ============================================

CREATE OR REPLACE FUNCTION SP_DEPENDENCIAS_DELETE(
    p_id INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists INTEGER;
    v_in_use INTEGER;
BEGIN
    -- Validar que existe la dependencia
    SELECT COUNT(*) INTO v_exists
    FROM c_dependencias
    WHERE id_dependencia = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe la dependencia especificada';
        RETURN;
    END IF;

    -- Verificar si está en uso (en revisiones o tramites)
    SELECT COUNT(*) INTO v_in_use
    FROM revisiones
    WHERE id_dependencia = p_id;

    IF v_in_use > 0 THEN
        RETURN QUERY SELECT FALSE, 'No se puede eliminar la dependencia porque está en uso';
        RETURN;
    END IF;

    -- Soft delete - marcar como no vigente
    UPDATE c_dependencias SET
        vigente = 'N'
    WHERE id_dependencia = p_id;

    RETURN QUERY SELECT TRUE, 'Dependencia eliminada exitosamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- OTORGAR PERMISOS
-- ============================================

-- Otorgar permisos de ejecución al usuario correspondiente si es necesario
-- GRANT EXECUTE ON FUNCTION SP_DEPENDENCIAS_LIST TO licencias_user;
-- GRANT EXECUTE ON FUNCTION SP_DEPENDENCIAS_CREATE TO licencias_user;
-- GRANT EXECUTE ON FUNCTION SP_DEPENDENCIAS_UPDATE TO licencias_user;
-- GRANT EXECUTE ON FUNCTION SP_DEPENDENCIAS_DELETE TO licencias_user;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================