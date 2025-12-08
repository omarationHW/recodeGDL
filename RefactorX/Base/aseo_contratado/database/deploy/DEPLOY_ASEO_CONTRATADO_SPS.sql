-- ================================================================
-- DEPLOYMENT SCRIPT: Aseo Contratado - Stored Procedures
-- Módulo: Aseo Contratado
-- Fecha: 2025-11-26
-- ================================================================
--
-- DESCRIPCIÓN:
-- Este script crea todos los stored procedures necesarios para el módulo
-- de Aseo Contratado, renombrándolos para compatibilidad con el frontend Vue.
--
-- CONVENCIÓN DE NOMBRES:
-- - Los SPs originales: sp_nombre_accion
-- - Los SPs para Vue: SP_ASEO_ENTIDAD_ACCION
--
-- INSTRUCCIONES:
-- 1. Ejecutar este script en la base de datos: guadalajara
-- 2. Verificar que todos los SPs se crearon correctamente
-- 3. Probar desde el frontend Vue
--
-- TABLAS UTILIZADAS:
-- - ta_16_empresas: Empresas prestadoras de servicio
-- - ta_16_tipos_emp: Tipos de empresa
-- - ta_16_zonas: Zonas de cobertura
-- - ta_16_tipo_aseo: Tipos de aseo
-- - ta_16_contratos: Contratos de servicio
-- - ta_16_unidades: Unidades de recolección
-- - ta_16_recargos: Recargos por periodo
-- - ta_16_recaudadoras: Oficinas recaudadoras
-- - ta_16_operacion: Claves de operación
-- - ta_16_gastos: Gastos de cobranza
-- - ta_16_adeudos: Adeudos de contratos
-- - ta_16_pagos: Pagos realizados
--
-- ================================================================

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT: Aseo Contratado - Stored Procedures'
\echo 'Fecha: 2025-11-26'
\echo '=================================================='
\echo ''

-- Establecer schema
SET search_path TO public;

-- ================================================================
-- SECCIÓN 1: CATÁLOGO DE EMPRESAS
-- ================================================================

\echo ''
\echo '=== EMPRESAS ==='
\echo ''

-- SP_ASEO_EMPRESAS_LIST
\echo 'Creando: SP_ASEO_EMPRESAS_LIST...'
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESAS_LIST(
    p_search VARCHAR DEFAULT NULL,
    p_ctrol_emp INTEGER DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR,
    representante VARCHAR,
    telefono VARCHAR,
    email VARCHAR,
    direccion VARCHAR,
    fecha_alta TIMESTAMP,
    fecha_baja TIMESTAMP,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_limit;

    RETURN QUERY
    WITH filtered_data AS (
        SELECT
            a.num_empresa,
            a.ctrol_emp,
            b.tipo_empresa,
            a.descripcion,
            a.representante,
            a.telefono,
            a.email,
            a.direccion,
            a.fecha_alta,
            a.fecha_baja
        FROM ta_16_empresas a
        JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
        WHERE
            (p_search IS NULL OR
             a.descripcion ILIKE '%'||p_search||'%' OR
             a.representante ILIKE '%'||p_search||'%' OR
             CAST(a.num_empresa AS TEXT) LIKE '%'||p_search||'%')
            AND (p_ctrol_emp IS NULL OR a.ctrol_emp = p_ctrol_emp)
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM filtered_data
    )
    SELECT
        f.num_empresa,
        f.ctrol_emp,
        f.tipo_empresa,
        f.descripcion,
        f.representante,
        f.telefono,
        f.email,
        f.direccion,
        f.fecha_alta,
        f.fecha_baja,
        t.total
    FROM filtered_data f
    CROSS JOIN total_count t
    ORDER BY f.descripcion, f.num_empresa
    LIMIT p_limit OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_EMPRESAS_GET
\echo 'Creando: SP_ASEO_EMPRESAS_GET...'
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESAS_GET(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER
)
RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR,
    representante VARCHAR,
    telefono VARCHAR,
    email VARCHAR,
    direccion VARCHAR,
    fecha_alta TIMESTAMP,
    fecha_baja TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.num_empresa,
        a.ctrol_emp,
        b.tipo_empresa,
        a.descripcion,
        a.representante,
        a.telefono,
        a.email,
        a.direccion,
        a.fecha_alta,
        a.fecha_baja
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    WHERE a.num_empresa = p_num_empresa AND a.ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_EMPRESAS_CREATE
\echo 'Creando: SP_ASEO_EMPRESAS_CREATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESAS_CREATE(
    p_ctrol_emp INTEGER,
    p_descripcion VARCHAR,
    p_representante VARCHAR,
    p_telefono VARCHAR DEFAULT NULL,
    p_email VARCHAR DEFAULT NULL,
    p_direccion VARCHAR DEFAULT NULL,
    p_usuario VARCHAR DEFAULT 'sistema'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    num_empresa INTEGER,
    ctrol_emp INTEGER
) AS $$
DECLARE
    v_num_empresa INTEGER;
BEGIN
    -- Generar nuevo número de empresa
    SELECT COALESCE(MAX(num_empresa),0)+1 INTO v_num_empresa
    FROM ta_16_empresas
    WHERE ctrol_emp = p_ctrol_emp;

    -- Insertar empresa
    INSERT INTO ta_16_empresas (
        num_empresa, ctrol_emp, descripcion, representante,
        telefono, email, direccion, fecha_alta
    )
    VALUES (
        v_num_empresa, p_ctrol_emp, p_descripcion, p_representante,
        p_telefono, p_email, p_direccion, NOW()
    );

    RETURN QUERY SELECT
        true,
        'Empresa creada correctamente'::TEXT,
        v_num_empresa,
        p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_EMPRESAS_UPDATE
\echo 'Creando: SP_ASEO_EMPRESAS_UPDATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESAS_UPDATE(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER,
    p_tipo_empresa VARCHAR,
    p_descripcion VARCHAR,
    p_representante VARCHAR,
    p_telefono VARCHAR DEFAULT NULL,
    p_email VARCHAR DEFAULT NULL,
    p_direccion VARCHAR DEFAULT NULL,
    p_fecha_baja TIMESTAMP DEFAULT NULL,
    p_usuario VARCHAR DEFAULT 'sistema'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar existencia
    SELECT COUNT(*) INTO v_exists
    FROM ta_16_empresas
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe la empresa'::TEXT;
        RETURN;
    END IF;

    -- Actualizar empresa
    UPDATE ta_16_empresas SET
        descripcion = p_descripcion,
        representante = p_representante,
        telefono = p_telefono,
        email = p_email,
        direccion = p_direccion,
        fecha_baja = p_fecha_baja,
        fecha_mod = NOW()
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;

    RETURN QUERY SELECT true, 'Empresa actualizada correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_EMPRESAS_DELETE
\echo 'Creando: SP_ASEO_EMPRESAS_DELETE...'
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESAS_DELETE(
    p_num_empresa INTEGER,
    p_usuario VARCHAR DEFAULT 'sistema'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_contratos INTEGER;
BEGIN
    -- Verificar contratos asociados
    SELECT COUNT(*) INTO v_contratos
    FROM ta_16_contratos
    WHERE num_empresa = p_num_empresa;

    IF v_contratos > 0 THEN
        -- Dar de baja (soft delete)
        UPDATE ta_16_empresas
        SET fecha_baja = NOW()
        WHERE num_empresa = p_num_empresa;

        RETURN QUERY SELECT true, 'Empresa dada de baja correctamente'::TEXT;
    ELSE
        -- Eliminar físicamente
        DELETE FROM ta_16_empresas WHERE num_empresa = p_num_empresa;
        RETURN QUERY SELECT true, 'Empresa eliminada correctamente'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- ================================================================
-- SECCIÓN 2: CATÁLOGO DE TIPOS DE EMPRESA
-- ================================================================

\echo ''
\echo '=== TIPOS DE EMPRESA ==='
\echo ''

-- SP_ASEO_TIPOS_EMP_LIST
\echo 'Creando: SP_ASEO_TIPOS_EMP_LIST...'
CREATE OR REPLACE FUNCTION SP_ASEO_TIPOS_EMP_LIST()
RETURNS TABLE(
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_emp, tipo_empresa, descripcion
    FROM ta_16_tipos_emp
    ORDER BY ctrol_emp;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_TIPOS_EMP_GET
\echo 'Creando: SP_ASEO_TIPOS_EMP_GET...'
CREATE OR REPLACE FUNCTION SP_ASEO_TIPOS_EMP_GET(
    p_ctrol_emp INTEGER
)
RETURNS TABLE(
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_emp, tipo_empresa, descripcion
    FROM ta_16_tipos_emp
    WHERE ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_TIPOS_EMP_CREATE
\echo 'Creando: SP_ASEO_TIPOS_EMP_CREATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_TIPOS_EMP_CREATE(
    p_ctrol_emp INTEGER,
    p_tipo_empresa VARCHAR,
    p_descripcion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM ta_16_tipos_emp
    WHERE ctrol_emp = p_ctrol_emp;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un tipo de empresa con ese control'::TEXT;
        RETURN;
    END IF;

    INSERT INTO ta_16_tipos_emp (ctrol_emp, tipo_empresa, descripcion)
    VALUES (p_ctrol_emp, p_tipo_empresa, p_descripcion);

    RETURN QUERY SELECT true, 'Tipo de empresa creado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_TIPOS_EMP_UPDATE
\echo 'Creando: SP_ASEO_TIPOS_EMP_UPDATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_TIPOS_EMP_UPDATE(
    p_ctrol_emp INTEGER,
    p_tipo_empresa VARCHAR,
    p_descripcion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE ta_16_tipos_emp
    SET tipo_empresa = p_tipo_empresa,
        descripcion = p_descripcion
    WHERE ctrol_emp = p_ctrol_emp;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Tipo de empresa actualizado correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe el tipo de empresa'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_TIPOS_EMP_DELETE
\echo 'Creando: SP_ASEO_TIPOS_EMP_DELETE...'
CREATE OR REPLACE FUNCTION SP_ASEO_TIPOS_EMP_DELETE(
    p_ctrol_emp INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_empresas INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_empresas
    FROM ta_16_empresas
    WHERE ctrol_emp = p_ctrol_emp;

    IF v_empresas > 0 THEN
        RETURN QUERY SELECT false, 'No se puede eliminar: existen empresas asociadas'::TEXT;
        RETURN;
    END IF;

    DELETE FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
    RETURN QUERY SELECT true, 'Tipo de empresa eliminado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- ================================================================
-- SECCIÓN 3: CATÁLOGO DE ZONAS
-- ================================================================

\echo ''
\echo '=== ZONAS ==='
\echo ''

-- SP_ASEO_ZONAS_LIST
\echo 'Creando: SP_ASEO_ZONAS_LIST...'
CREATE OR REPLACE FUNCTION SP_ASEO_ZONAS_LIST(
    p_search VARCHAR DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    ctrol_zona INTEGER,
    zona INTEGER,
    sub_zona INTEGER,
    descripcion VARCHAR,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_limit;

    RETURN QUERY
    WITH filtered_data AS (
        SELECT
            ctrol_zona,
            zona,
            sub_zona,
            descripcion
        FROM ta_16_zonas
        WHERE p_search IS NULL OR descripcion ILIKE '%'||p_search||'%'
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM filtered_data
    )
    SELECT
        f.ctrol_zona,
        f.zona,
        f.sub_zona,
        f.descripcion,
        t.total
    FROM filtered_data f
    CROSS JOIN total_count t
    ORDER BY f.zona, f.sub_zona
    LIMIT p_limit OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_ZONAS_CREATE
\echo 'Creando: SP_ASEO_ZONAS_CREATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_ZONAS_CREATE(
    p_zona INTEGER,
    p_sub_zona INTEGER,
    p_descripcion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    ctrol_zona INTEGER
) AS $$
DECLARE
    v_ctrol INTEGER;
BEGIN
    -- Validar existencia
    IF EXISTS (SELECT 1 FROM ta_16_zonas WHERE zona = p_zona AND sub_zona = p_sub_zona) THEN
        RETURN QUERY SELECT false, 'Ya existe una zona con esos datos'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar
    INSERT INTO ta_16_zonas(zona, sub_zona, descripcion)
    VALUES (p_zona, p_sub_zona, p_descripcion)
    RETURNING ctrol_zona INTO v_ctrol;

    RETURN QUERY SELECT true, 'Zona creada correctamente'::TEXT, v_ctrol;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_ZONAS_UPDATE
\echo 'Creando: SP_ASEO_ZONAS_UPDATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_ZONAS_UPDATE(
    p_ctrol_zona INTEGER,
    p_zona INTEGER,
    p_sub_zona INTEGER,
    p_descripcion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE ta_16_zonas
    SET zona = p_zona,
        sub_zona = p_sub_zona,
        descripcion = p_descripcion
    WHERE ctrol_zona = p_ctrol_zona;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Zona actualizada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe la zona'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_ZONAS_DELETE
\echo 'Creando: SP_ASEO_ZONAS_DELETE...'
CREATE OR REPLACE FUNCTION SP_ASEO_ZONAS_DELETE(
    p_ctrol_zona INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_empresas INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_empresas
    FROM ta_16_empresas
    WHERE ctrol_zona = p_ctrol_zona;

    IF v_empresas > 0 THEN
        RETURN QUERY SELECT false, 'No se puede eliminar: existen empresas con esta zona'::TEXT;
        RETURN;
    END IF;

    DELETE FROM ta_16_zonas WHERE ctrol_zona = p_ctrol_zona;
    RETURN QUERY SELECT true, 'Zona eliminada correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- ================================================================
-- SECCIÓN 4: CATÁLOGO DE TIPOS DE ASEO
-- ================================================================

\echo ''
\echo '=== TIPOS DE ASEO ==='
\echo ''

-- SP_ASEO_TIPOS_LIST
\echo 'Creando: SP_ASEO_TIPOS_LIST...'
CREATE OR REPLACE FUNCTION SP_ASEO_TIPOS_LIST(
    p_search VARCHAR DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    cta_aplicacion INTEGER,
    usuario_alta INTEGER,
    fecha_alta TIMESTAMP,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_limit;

    RETURN QUERY
    WITH filtered_data AS (
        SELECT
            ctrol_aseo,
            tipo_aseo,
            descripcion,
            cta_aplicacion,
            usuario_alta,
            fecha_alta
        FROM ta_16_tipo_aseo
        WHERE p_search IS NULL OR descripcion ILIKE '%'||p_search||'%'
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM filtered_data
    )
    SELECT
        f.ctrol_aseo,
        f.tipo_aseo,
        f.descripcion,
        f.cta_aplicacion,
        f.usuario_alta,
        f.fecha_alta,
        t.total
    FROM filtered_data f
    CROSS JOIN total_count t
    ORDER BY f.tipo_aseo
    LIMIT p_limit OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_TIPOS_CREATE
\echo 'Creando: SP_ASEO_TIPOS_CREATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_TIPOS_CREATE(
    p_tipo_aseo VARCHAR,
    p_descripcion VARCHAR,
    p_cta_aplicacion INTEGER,
    p_usuario INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists INTEGER;
    v_cta_exists INTEGER;
BEGIN
    -- Validar duplicado
    SELECT COUNT(*) INTO v_exists
    FROM ta_16_tipo_aseo
    WHERE tipo_aseo = p_tipo_aseo;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe el tipo de aseo'::TEXT;
        RETURN;
    END IF;

    -- Validar cuenta de aplicación
    SELECT COUNT(*) INTO v_cta_exists
    FROM ta_16_ctas_aplicacion
    WHERE cta_aplicacion = p_cta_aplicacion;

    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe'::TEXT;
        RETURN;
    END IF;

    -- Insertar
    INSERT INTO ta_16_tipo_aseo (tipo_aseo, descripcion, cta_aplicacion, usuario_alta, fecha_alta)
    VALUES (p_tipo_aseo, p_descripcion, p_cta_aplicacion, p_usuario, NOW());

    RETURN QUERY SELECT true, 'Tipo de aseo creado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_TIPOS_UPDATE
\echo 'Creando: SP_ASEO_TIPOS_UPDATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_TIPOS_UPDATE(
    p_ctrol_aseo INTEGER,
    p_tipo_aseo VARCHAR,
    p_descripcion VARCHAR,
    p_cta_aplicacion INTEGER,
    p_usuario INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE ta_16_tipo_aseo
    SET tipo_aseo = p_tipo_aseo,
        descripcion = p_descripcion,
        cta_aplicacion = p_cta_aplicacion,
        usuario_mod = p_usuario,
        fecha_mod = NOW()
    WHERE ctrol_aseo = p_ctrol_aseo;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Tipo de aseo actualizado correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe el tipo de aseo'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_TIPOS_DELETE
\echo 'Creando: SP_ASEO_TIPOS_DELETE...'
CREATE OR REPLACE FUNCTION SP_ASEO_TIPOS_DELETE(
    p_ctrol_aseo INTEGER,
    p_usuario INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_contratos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_contratos
    FROM ta_16_contratos
    WHERE ctrol_aseo = p_ctrol_aseo;

    IF v_contratos > 0 THEN
        RETURN QUERY SELECT false, 'Existen contratos con este tipo de aseo'::TEXT;
        RETURN;
    END IF;

    DELETE FROM ta_16_tipo_aseo WHERE ctrol_aseo = p_ctrol_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo eliminado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- ================================================================
-- SECCIÓN 5: CATÁLOGO DE UNIDADES DE RECOLECCIÓN
-- ================================================================

\echo ''
\echo '=== UNIDADES DE RECOLECCIÓN ==='
\echo ''

-- SP_ASEO_UNIDADES_LIST
\echo 'Creando: SP_ASEO_UNIDADES_LIST...'
CREATE OR REPLACE FUNCTION SP_ASEO_UNIDADES_LIST(
    p_ejercicio INTEGER DEFAULT NULL,
    p_search VARCHAR DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC,
    costo_exed NUMERIC,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_limit;

    RETURN QUERY
    WITH filtered_data AS (
        SELECT
            ctrol_recolec,
            ejercicio_recolec,
            cve_recolec,
            descripcion,
            costo_unidad,
            costo_exed
        FROM ta_16_unidades
        WHERE
            (p_ejercicio IS NULL OR ejercicio_recolec = p_ejercicio)
            AND (p_search IS NULL OR descripcion ILIKE '%'||p_search||'%')
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM filtered_data
    )
    SELECT
        f.ctrol_recolec,
        f.ejercicio_recolec,
        f.cve_recolec,
        f.descripcion,
        f.costo_unidad,
        f.costo_exed,
        t.total
    FROM filtered_data f
    CROSS JOIN total_count t
    ORDER BY f.ejercicio_recolec, f.cve_recolec
    LIMIT p_limit OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_UNIDADES_CREATE
\echo 'Creando: SP_ASEO_UNIDADES_CREATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_UNIDADES_CREATE(
    p_ejercicio SMALLINT,
    p_cve VARCHAR,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC,
    p_usuario_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    ctrol_recolec INTEGER
) AS $$
DECLARE
    v_ctrol INTEGER;
BEGIN
    -- Validar existencia
    IF EXISTS (SELECT 1 FROM ta_16_unidades
               WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = p_cve) THEN
        RETURN QUERY SELECT false, 'Ya existe la clave para este ejercicio'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Generar control
    SELECT COALESCE(MAX(ctrol_recolec),0)+1 INTO v_ctrol
    FROM ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio;

    INSERT INTO ta_16_unidades (
        ctrol_recolec, ejercicio_recolec, cve_recolec,
        descripcion, costo_unidad, costo_exed
    )
    VALUES (
        v_ctrol, p_ejercicio, p_cve,
        p_descripcion, p_costo_unidad, p_costo_exed
    );

    RETURN QUERY SELECT true, 'Unidad creada correctamente'::TEXT, v_ctrol;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_UNIDADES_UPDATE
\echo 'Creando: SP_ASEO_UNIDADES_UPDATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_UNIDADES_UPDATE(
    p_ctrol INTEGER,
    p_ejercicio SMALLINT,
    p_cve VARCHAR,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC,
    p_usuario_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE ta_16_unidades
    SET ejercicio_recolec = p_ejercicio,
        cve_recolec = p_cve,
        descripcion = p_descripcion,
        costo_unidad = p_costo_unidad,
        costo_exed = p_costo_exed
    WHERE ctrol_recolec = p_ctrol;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Unidad actualizada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe la unidad'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_UNIDADES_DELETE
\echo 'Creando: SP_ASEO_UNIDADES_DELETE...'
CREATE OR REPLACE FUNCTION SP_ASEO_UNIDADES_DELETE(
    p_ctrol INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_contratos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_contratos
    FROM ta_16_contratos
    WHERE ctrol_recolec = p_ctrol;

    IF v_contratos > 0 THEN
        RETURN QUERY SELECT false, 'Existen contratos con esta unidad'::TEXT;
        RETURN;
    END IF;

    DELETE FROM ta_16_unidades WHERE ctrol_recolec = p_ctrol;
    RETURN QUERY SELECT true, 'Unidad eliminada correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- ================================================================
-- SECCIÓN 6: CATÁLOGO DE RECARGOS
-- ================================================================

\echo ''
\echo '=== RECARGOS ==='
\echo ''

-- SP_ASEO_RECARGOS_LIST
\echo 'Creando: SP_ASEO_RECARGOS_LIST...'
CREATE OR REPLACE FUNCTION SP_ASEO_RECARGOS_LIST(
    p_year INTEGER DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    aso_mes_recargo DATE,
    porc_recargo FLOAT,
    porc_multa FLOAT,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_limit;

    RETURN QUERY
    WITH filtered_data AS (
        SELECT
            aso_mes_recargo,
            porc_recargo,
            porc_multa
        FROM ta_16_recargos
        WHERE p_year IS NULL OR EXTRACT(YEAR FROM aso_mes_recargo) = p_year
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM filtered_data
    )
    SELECT
        f.aso_mes_recargo,
        f.porc_recargo,
        f.porc_multa,
        t.total
    FROM filtered_data f
    CROSS JOIN total_count t
    ORDER BY f.aso_mes_recargo
    LIMIT p_limit OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_RECARGOS_CREATE
\echo 'Creando: SP_ASEO_RECARGOS_CREATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_RECARGOS_CREATE(
    p_aso_mes_recargo DATE,
    p_porc_recargo FLOAT,
    p_porc_multa FLOAT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_recargos WHERE aso_mes_recargo = p_aso_mes_recargo) THEN
        RETURN QUERY SELECT false, 'Ya existe un recargo para ese periodo'::TEXT;
        RETURN;
    END IF;

    INSERT INTO ta_16_recargos (aso_mes_recargo, porc_recargo, porc_multa)
    VALUES (p_aso_mes_recargo, p_porc_recargo, p_porc_multa);

    RETURN QUERY SELECT true, 'Recargo creado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_RECARGOS_UPDATE
\echo 'Creando: SP_ASEO_RECARGOS_UPDATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_RECARGOS_UPDATE(
    p_aso_mes_recargo DATE,
    p_porc_recargo FLOAT,
    p_porc_multa FLOAT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE ta_16_recargos
    SET porc_recargo = p_porc_recargo,
        porc_multa = p_porc_multa
    WHERE aso_mes_recargo = p_aso_mes_recargo;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Recargo actualizado correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe el recargo'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_RECARGOS_DELETE
\echo 'Creando: SP_ASEO_RECARGOS_DELETE...'
CREATE OR REPLACE FUNCTION SP_ASEO_RECARGOS_DELETE(
    p_aso_mes_recargo DATE
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    DELETE FROM ta_16_recargos WHERE aso_mes_recargo = p_aso_mes_recargo;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Recargo eliminado correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe el recargo'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- ================================================================
-- SECCIÓN 7: CATÁLOGO DE RECAUDADORAS
-- ================================================================

\echo ''
\echo '=== RECAUDADORAS ==='
\echo ''

-- SP_ASEO_RECAUDADORAS_LIST
\echo 'Creando: SP_ASEO_RECAUDADORAS_LIST...'
CREATE OR REPLACE FUNCTION SP_ASEO_RECAUDADORAS_LIST(
    p_search VARCHAR DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    num_rec SMALLINT,
    descripcion VARCHAR,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_limit;

    RETURN QUERY
    WITH filtered_data AS (
        SELECT
            num_rec,
            descripcion
        FROM ta_16_recaudadoras
        WHERE p_search IS NULL OR descripcion ILIKE '%'||p_search||'%'
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM filtered_data
    )
    SELECT
        f.num_rec,
        f.descripcion,
        t.total
    FROM filtered_data f
    CROSS JOIN total_count t
    ORDER BY f.num_rec
    LIMIT p_limit OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_RECAUDADORAS_CREATE
\echo 'Creando: SP_ASEO_RECAUDADORAS_CREATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_RECAUDADORAS_CREATE(
    p_num_rec SMALLINT,
    p_descripcion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RETURN QUERY SELECT false, 'Ya existe una recaudadora con ese número'::TEXT;
        RETURN;
    END IF;

    INSERT INTO ta_16_recaudadoras(num_rec, descripcion)
    VALUES (p_num_rec, p_descripcion);

    RETURN QUERY SELECT true, 'Recaudadora creada correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_RECAUDADORAS_UPDATE
\echo 'Creando: SP_ASEO_RECAUDADORAS_UPDATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_RECAUDADORAS_UPDATE(
    p_num_rec SMALLINT,
    p_descripcion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE ta_16_recaudadoras
    SET descripcion = p_descripcion
    WHERE num_rec = p_num_rec;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Recaudadora actualizada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe la recaudadora'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_RECAUDADORAS_DELETE
\echo 'Creando: SP_ASEO_RECAUDADORAS_DELETE...'
CREATE OR REPLACE FUNCTION SP_ASEO_RECAUDADORAS_DELETE(
    p_num_rec SMALLINT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM ta_16_contratos
    WHERE id_rec = p_num_rec;

    IF v_count > 0 THEN
        RETURN QUERY SELECT false, 'Existen contratos asociados'::TEXT;
        RETURN;
    END IF;

    DELETE FROM ta_16_recaudadoras WHERE num_rec = p_num_rec;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Recaudadora eliminada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe la recaudadora'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- ================================================================
-- SECCIÓN 8: CATÁLOGO DE CLAVES DE OPERACIÓN
-- ================================================================

\echo ''
\echo '=== CLAVES DE OPERACIÓN ==='
\echo ''

-- SP_ASEO_CVES_OPERACION_LIST
\echo 'Creando: SP_ASEO_CVES_OPERACION_LIST...'
CREATE OR REPLACE FUNCTION SP_ASEO_CVES_OPERACION_LIST(
    p_search VARCHAR DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    ctrol_operacion INTEGER,
    cve_operacion VARCHAR,
    descripcion VARCHAR,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_limit;

    RETURN QUERY
    WITH filtered_data AS (
        SELECT
            ctrol_operacion,
            cve_operacion,
            descripcion
        FROM ta_16_operacion
        WHERE p_search IS NULL OR descripcion ILIKE '%'||p_search||'%'
    ),
    total_count AS (
        SELECT COUNT(*) as total FROM filtered_data
    )
    SELECT
        f.ctrol_operacion,
        f.cve_operacion,
        f.descripcion,
        t.total
    FROM filtered_data f
    CROSS JOIN total_count t
    ORDER BY f.ctrol_operacion
    LIMIT p_limit OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_CVES_OPERACION_CREATE
\echo 'Creando: SP_ASEO_CVES_OPERACION_CREATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_CVES_OPERACION_CREATE(
    p_cve_operacion VARCHAR,
    p_descripcion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    ctrol_operacion INTEGER
) AS $$
DECLARE
    v_ctrol INTEGER;
BEGIN
    -- Validar unicidad
    IF EXISTS (SELECT 1 FROM ta_16_operacion WHERE cve_operacion = p_cve_operacion) THEN
        RETURN QUERY SELECT false, 'Ya existe una clave con ese valor'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    INSERT INTO ta_16_operacion (cve_operacion, descripcion)
    VALUES (p_cve_operacion, p_descripcion)
    RETURNING ctrol_operacion INTO v_ctrol;

    RETURN QUERY SELECT true, 'Clave de operación creada correctamente'::TEXT, v_ctrol;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_CVES_OPERACION_UPDATE
\echo 'Creando: SP_ASEO_CVES_OPERACION_UPDATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_CVES_OPERACION_UPDATE(
    p_ctrol_operacion INTEGER,
    p_cve_operacion VARCHAR,
    p_descripcion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE ta_16_operacion
    SET cve_operacion = p_cve_operacion,
        descripcion = p_descripcion
    WHERE ctrol_operacion = p_ctrol_operacion;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Clave actualizada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe la clave'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_CVES_OPERACION_DELETE
\echo 'Creando: SP_ASEO_CVES_OPERACION_DELETE...'
CREATE OR REPLACE FUNCTION SP_ASEO_CVES_OPERACION_DELETE(
    p_ctrol_operacion INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_pagos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_pagos
    FROM ta_16_pagos
    WHERE ctrol_operacion = p_ctrol_operacion;

    IF v_pagos > 0 THEN
        RETURN QUERY SELECT false, 'Existen pagos asociados a esta clave'::TEXT;
        RETURN;
    END IF;

    DELETE FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Clave eliminada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No existe la clave'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- ================================================================
-- SECCIÓN 9: CATÁLOGO DE GASTOS
-- ================================================================

\echo ''
\echo '=== GASTOS ==='
\echo ''

-- SP_ASEO_GASTOS_LIST
\echo 'Creando: SP_ASEO_GASTOS_LIST...'
CREATE OR REPLACE FUNCTION SP_ASEO_GASTOS_LIST()
RETURNS TABLE(
    sdzmg NUMERIC,
    porc1_req NUMERIC,
    porc2_embargo NUMERIC,
    porc3_secuestro NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT sdzmg, porc1_req, porc2_embargo, porc3_secuestro
    FROM ta_16_gastos
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- SP_ASEO_GASTOS_UPDATE
\echo 'Creando: SP_ASEO_GASTOS_UPDATE...'
CREATE OR REPLACE FUNCTION SP_ASEO_GASTOS_UPDATE(
    p_sdzmg NUMERIC,
    p_porc1_req NUMERIC,
    p_porc2_embargo NUMERIC,
    p_porc3_secuestro NUMERIC
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- Eliminar registro anterior
    DELETE FROM ta_16_gastos;

    -- Insertar nuevo
    INSERT INTO ta_16_gastos (sdzmg, porc1_req, porc2_embargo, porc3_secuestro)
    VALUES (p_sdzmg, p_porc1_req, p_porc2_embargo, p_porc3_secuestro);

    RETURN QUERY SELECT true, 'Gastos actualizados correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;
\echo '   OK'

-- ================================================================
-- FINAL DEL DEPLOYMENT
-- ================================================================

\echo ''
\echo '=================================================='
\echo 'DEPLOYMENT COMPLETADO'
\echo '=================================================='
\echo ''
\echo 'RESUMEN:'
\echo '- Empresas: 5 SPs'
\echo '- Tipos de Empresa: 5 SPs'
\echo '- Zonas: 4 SPs'
\echo '- Tipos de Aseo: 4 SPs'
\echo '- Unidades de Recolección: 4 SPs'
\echo '- Recargos: 4 SPs'
\echo '- Recaudadoras: 4 SPs'
\echo '- Claves de Operación: 4 SPs'
\echo '- Gastos: 2 SPs'
\echo ''
\echo 'TOTAL: 36 Stored Procedures creados'
\echo ''
\echo 'PRÓXIMOS PASOS:'
\echo '1. Verificar que todos los SPs se crearon correctamente'
\echo '2. Revisar permisos de ejecución'
\echo '3. Probar desde el frontend Vue'
\echo '4. Continuar con los SPs de Contratos, Adeudos y Pagos'
\echo ''
\echo '=================================================='
