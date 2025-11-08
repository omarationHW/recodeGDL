-- =====================================================
-- SCRIPT MAESTRO DE DESPLIEGUE - DICTÁMENES
-- Componente: dictamenfrm.vue
-- Módulo: padron_licencias
-- Esquema: comun
-- Tabla: comun.dictamenes (17,470 registros)
-- Fecha: 2025-11-05
-- =====================================================

-- LIMPIAR SPs EXISTENTES
DROP FUNCTION IF EXISTS comun.sp_dictamenes_list(INTEGER,INTEGER,TEXT,TEXT,TEXT);
DROP FUNCTION IF EXISTS comun.sp_dictamenes_get(INTEGER);
DROP FUNCTION IF EXISTS comun.sp_dictamenes_create(INTEGER,CHAR,CHAR,CHAR,CHAR,DOUBLE PRECISION,DOUBLE PRECISION,INTEGER,CHAR,CHAR,CHAR,INTEGER,INTEGER,CHAR,CHAR,DATE);
DROP FUNCTION IF EXISTS comun.sp_dictamenes_update(INTEGER,INTEGER,CHAR,CHAR,CHAR,CHAR,DOUBLE PRECISION,DOUBLE PRECISION,INTEGER,CHAR,CHAR,CHAR,INTEGER,INTEGER,CHAR,CHAR,DATE);
DROP FUNCTION IF EXISTS comun.sp_dictamenes_estadisticas();

-- =====================================================
-- 1. SP: sp_dictamenes_list
-- Listado con paginación y filtros
-- =====================================================
CREATE OR REPLACE FUNCTION comun.sp_dictamenes_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 10,
    p_propietario TEXT DEFAULT NULL,
    p_domicilio TEXT DEFAULT NULL,
    p_actividad TEXT DEFAULT NULL
)
RETURNS TABLE (
    id_dictamen INTEGER,
    id_giro INTEGER,
    propietario CHAR(100),
    domicilio CHAR(100),
    no_exterior CHAR(5),
    no_interior CHAR(5),
    supconst DOUBLE PRECISION,
    area_util DOUBLE PRECISION,
    num_cajones INTEGER,
    actividad CHAR(100),
    uso_suelo CHAR(200),
    desc_uso CHAR(120),
    zona INTEGER,
    subzona INTEGER,
    dictamen CHAR(1),
    capturista CHAR(10),
    fecha DATE,
    total_count BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    RETURN QUERY
    WITH filtered_dictamenes AS (
        SELECT
            d.id_dictamen,
            d.id_giro,
            d.propietario,
            d.domicilio,
            d.no_exterior,
            d.no_interior,
            d.supconst,
            d.area_util,
            d.num_cajones,
            d.actividad,
            d.uso_suelo,
            d.desc_uso,
            d.zona,
            d.subzona,
            d.dictamen,
            d.capturista,
            d.fecha,
            COUNT(*) OVER() as total_count
        FROM comun.dictamenes d
        WHERE 1=1
            AND (p_propietario IS NULL OR d.propietario ILIKE '%' || p_propietario || '%')
            AND (p_domicilio IS NULL OR d.domicilio ILIKE '%' || p_domicilio || '%')
            AND (p_actividad IS NULL OR d.actividad ILIKE '%' || p_actividad || '%')
        ORDER BY d.fecha DESC NULLS LAST, d.id_dictamen DESC
        LIMIT p_page_size
        OFFSET v_offset
    )
    SELECT * FROM filtered_dictamenes;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- 2. SP: sp_dictamenes_get
-- Obtener un dictamen por ID
-- =====================================================
CREATE OR REPLACE FUNCTION comun.sp_dictamenes_get(
    p_id_dictamen INTEGER
)
RETURNS TABLE (
    id_dictamen INTEGER,
    id_giro INTEGER,
    propietario CHAR(100),
    domicilio CHAR(100),
    no_exterior CHAR(5),
    no_interior CHAR(5),
    supconst DOUBLE PRECISION,
    area_util DOUBLE PRECISION,
    num_cajones INTEGER,
    actividad CHAR(100),
    uso_suelo CHAR(200),
    desc_uso CHAR(120),
    zona INTEGER,
    subzona INTEGER,
    dictamen CHAR(1),
    capturista CHAR(10),
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_dictamen,
        d.id_giro,
        d.propietario,
        d.domicilio,
        d.no_exterior,
        d.no_interior,
        d.supconst,
        d.area_util,
        d.num_cajones,
        d.actividad,
        d.uso_suelo,
        d.desc_uso,
        d.zona,
        d.subzona,
        d.dictamen,
        d.capturista,
        d.fecha
    FROM comun.dictamenes d
    WHERE d.id_dictamen = p_id_dictamen;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- 3. SP: sp_dictamenes_create
-- Crear nuevo dictamen
-- =====================================================
CREATE OR REPLACE FUNCTION comun.sp_dictamenes_create(
    p_id_giro INTEGER,
    p_propietario VARCHAR(100),
    p_domicilio VARCHAR(100),
    p_actividad VARCHAR(100),
    p_no_exterior VARCHAR(5) DEFAULT NULL,
    p_no_interior VARCHAR(5) DEFAULT NULL,
    p_supconst DOUBLE PRECISION DEFAULT NULL,
    p_area_util DOUBLE PRECISION DEFAULT NULL,
    p_num_cajones INTEGER DEFAULT 0,
    p_uso_suelo VARCHAR(200) DEFAULT NULL,
    p_desc_uso VARCHAR(120) DEFAULT NULL,
    p_zona INTEGER DEFAULT NULL,
    p_subzona INTEGER DEFAULT NULL,
    p_dictamen VARCHAR(1) DEFAULT '0',
    p_capturista VARCHAR(10) DEFAULT NULL,
    p_fecha DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_dictamen INTEGER
) AS $$
DECLARE
    v_id_dictamen INTEGER;
BEGIN
    -- Validaciones básicas
    IF p_propietario IS NULL OR TRIM(p_propietario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El nombre del propietario es requerido', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_domicilio IS NULL OR TRIM(p_domicilio) = '' THEN
        RETURN QUERY SELECT FALSE, 'El domicilio es requerido', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_actividad IS NULL OR TRIM(p_actividad) = '' THEN
        RETURN QUERY SELECT FALSE, 'La actividad es requerida', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar nuevo registro
    INSERT INTO comun.dictamenes (
        id_giro, propietario, domicilio, no_exterior, no_interior,
        supconst, area_util, num_cajones, actividad, uso_suelo,
        desc_uso, zona, subzona, dictamen, capturista, fecha
    ) VALUES (
        p_id_giro, p_propietario, p_domicilio, p_no_exterior, p_no_interior,
        p_supconst, p_area_util, p_num_cajones, p_actividad, p_uso_suelo,
        p_desc_uso, p_zona, p_subzona, p_dictamen, p_capturista, p_fecha
    ) RETURNING dictamenes.id_dictamen INTO v_id_dictamen;

    RETURN QUERY SELECT TRUE, 'Dictamen creado exitosamente con ID: ' || v_id_dictamen::TEXT, v_id_dictamen;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al crear el dictamen: ' || SQLERRM, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. SP: sp_dictamenes_update
-- Actualizar dictamen existente
-- =====================================================
CREATE OR REPLACE FUNCTION comun.sp_dictamenes_update(
    p_id_dictamen INTEGER,
    p_id_giro INTEGER,
    p_propietario VARCHAR(100),
    p_domicilio VARCHAR(100),
    p_actividad VARCHAR(100),
    p_no_exterior VARCHAR(5) DEFAULT NULL,
    p_no_interior VARCHAR(5) DEFAULT NULL,
    p_supconst DOUBLE PRECISION DEFAULT NULL,
    p_area_util DOUBLE PRECISION DEFAULT NULL,
    p_num_cajones INTEGER DEFAULT 0,
    p_uso_suelo VARCHAR(200) DEFAULT NULL,
    p_desc_uso VARCHAR(120) DEFAULT NULL,
    p_zona INTEGER DEFAULT NULL,
    p_subzona INTEGER DEFAULT NULL,
    p_dictamen VARCHAR(1) DEFAULT '0',
    p_capturista VARCHAR(10) DEFAULT NULL,
    p_fecha DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_dictamen_existe BOOLEAN;
BEGIN
    -- Verificar que el dictamen existe
    SELECT EXISTS(SELECT 1 FROM comun.dictamenes WHERE id_dictamen = p_id_dictamen) INTO v_dictamen_existe;
    IF NOT v_dictamen_existe THEN
        RETURN QUERY SELECT FALSE, 'El dictamen no existe';
        RETURN;
    END IF;

    -- Validaciones básicas
    IF p_propietario IS NULL OR TRIM(p_propietario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El nombre del propietario es requerido';
        RETURN;
    END IF;

    IF p_domicilio IS NULL OR TRIM(p_domicilio) = '' THEN
        RETURN QUERY SELECT FALSE, 'El domicilio es requerido';
        RETURN;
    END IF;

    IF p_actividad IS NULL OR TRIM(p_actividad) = '' THEN
        RETURN QUERY SELECT FALSE, 'La actividad es requerida';
        RETURN;
    END IF;

    -- Actualizar registro
    UPDATE comun.dictamenes SET
        id_giro = p_id_giro,
        propietario = p_propietario,
        domicilio = p_domicilio,
        no_exterior = p_no_exterior,
        no_interior = p_no_interior,
        supconst = p_supconst,
        area_util = p_area_util,
        num_cajones = p_num_cajones,
        actividad = p_actividad,
        uso_suelo = p_uso_suelo,
        desc_uso = p_desc_uso,
        zona = p_zona,
        subzona = p_subzona,
        dictamen = p_dictamen,
        capturista = p_capturista,
        fecha = p_fecha
    WHERE id_dictamen = p_id_dictamen;

    RETURN QUERY SELECT TRUE, 'Dictamen actualizado exitosamente';

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al actualizar el dictamen: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. SP: sp_dictamenes_estadisticas
-- Estadísticas para stats cards
-- =====================================================
CREATE OR REPLACE FUNCTION comun.sp_dictamenes_estadisticas()
RETURNS TABLE (
    total_dictamenes BIGINT,
    dictamenes_aprobados BIGINT,
    dictamenes_rechazados BIGINT,
    dictamenes_pendientes BIGINT,
    promedio_superficie DOUBLE PRECISION,
    promedio_area_util DOUBLE PRECISION,
    total_cajones BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::BIGINT as total_dictamenes,
        COUNT(*) FILTER (WHERE dictamen = '1')::BIGINT as dictamenes_aprobados,
        COUNT(*) FILTER (WHERE dictamen = '0')::BIGINT as dictamenes_rechazados,
        COUNT(*) FILTER (WHERE dictamen NOT IN ('0', '1') OR dictamen IS NULL)::BIGINT as dictamenes_pendientes,
        AVG(supconst)::DOUBLE PRECISION as promedio_superficie,
        AVG(area_util)::DOUBLE PRECISION as promedio_area_util,
        SUM(num_cajones)::BIGINT as total_cajones
    FROM comun.dictamenes;
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- VERIFICACIÓN FINAL
-- =====================================================
SELECT
    proname as sp_name,
    pg_get_function_arguments(oid) as arguments
FROM pg_proc
WHERE pronamespace = 'comun'::regnamespace
    AND proname LIKE 'sp_dictamenes%'
ORDER BY proname;
