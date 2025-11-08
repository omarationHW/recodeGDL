-- =====================================================
-- DROP existing functions first
-- =====================================================
DROP FUNCTION IF EXISTS comun.catalogo_actividades_list();
DROP FUNCTION IF EXISTS comun.catalogo_actividades_create(INTEGER, VARCHAR, TEXT, BOOLEAN, VARCHAR);
DROP FUNCTION IF EXISTS comun.catalogo_actividades_update(INTEGER, INTEGER, VARCHAR, TEXT, BOOLEAN);
DROP FUNCTION IF EXISTS comun.catalogo_actividades_delete(INTEGER);
DROP FUNCTION IF EXISTS comun.catalogo_actividades_estadisticas();

-- =====================================================
-- SP: catalogo_actividades_list
-- Descripción: Lista de actividades basada en estructura real
-- Esquema: comun
-- Estructura real: generico, uso, actividad, concepto
-- =====================================================

CREATE OR REPLACE FUNCTION comun.catalogo_actividades_list()
RETURNS TABLE (
    generico SMALLINT,
    uso SMALLINT,
    actividad SMALLINT,
    concepto VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.generico,
        a.uso,
        a.actividad,
        TRIM(a.concepto)::VARCHAR as concepto
    FROM comun.c_actividades a
    ORDER BY a.generico, a.uso, a.actividad;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: catalogo_actividades_create
-- Descripción: Crear nueva actividad
-- =====================================================

CREATE OR REPLACE FUNCTION comun.catalogo_actividades_create(
    p_generico SMALLINT,
    p_uso SMALLINT,
    p_actividad SMALLINT,
    p_concepto VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
BEGIN
    -- Verificar si ya existe
    IF EXISTS (
        SELECT 1 FROM comun.c_actividades
        WHERE generico = p_generico AND uso = p_uso AND actividad = p_actividad
    ) THEN
        RETURN QUERY SELECT
            false as success,
            'Ya existe una actividad con esos códigos'::VARCHAR as message;
        RETURN;
    END IF;

    -- Insertar nueva actividad
    INSERT INTO comun.c_actividades (
        generico,
        uso,
        actividad,
        concepto
    ) VALUES (
        p_generico,
        p_uso,
        p_actividad,
        p_concepto
    );

    RETURN QUERY SELECT
        true as success,
        'Actividad creada exitosamente'::VARCHAR as message;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        false as success,
        ('Error al crear actividad: ' || SQLERRM)::VARCHAR as message;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: catalogo_actividades_update
-- Descripción: Actualizar actividad existente
-- =====================================================

CREATE OR REPLACE FUNCTION comun.catalogo_actividades_update(
    p_generico SMALLINT,
    p_uso SMALLINT,
    p_actividad SMALLINT,
    p_concepto VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
BEGIN
    UPDATE comun.c_actividades
    SET concepto = p_concepto
    WHERE generico = p_generico AND uso = p_uso AND actividad = p_actividad;

    IF FOUND THEN
        RETURN QUERY SELECT
            true as success,
            'Actividad actualizada exitosamente'::VARCHAR as message;
    ELSE
        RETURN QUERY SELECT
            false as success,
            'Actividad no encontrada'::VARCHAR as message;
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        false as success,
        ('Error al actualizar actividad: ' || SQLERRM)::VARCHAR as message;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: catalogo_actividades_delete
-- Descripción: Eliminar actividad
-- =====================================================

CREATE OR REPLACE FUNCTION comun.catalogo_actividades_delete(
    p_generico SMALLINT,
    p_uso SMALLINT,
    p_actividad SMALLINT
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
BEGIN
    DELETE FROM comun.c_actividades
    WHERE generico = p_generico AND uso = p_uso AND actividad = p_actividad;

    IF FOUND THEN
        RETURN QUERY SELECT
            true as success,
            'Actividad eliminada exitosamente'::VARCHAR as message;
    ELSE
        RETURN QUERY SELECT
            false as success,
            'Actividad no encontrada'::VARCHAR as message;
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        false as success,
        ('Error al eliminar actividad: ' || SQLERRM)::VARCHAR as message;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: catalogo_actividades_estadisticas
-- Descripción: Estadísticas del catálogo de actividades
-- =====================================================

CREATE OR REPLACE FUNCTION comun.catalogo_actividades_estadisticas()
RETURNS TABLE (
    total INTEGER,
    genericos_distintos INTEGER,
    usos_distintos INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::INTEGER as total,
        COUNT(DISTINCT generico)::INTEGER as genericos_distintos,
        COUNT(DISTINCT uso)::INTEGER as usos_distintos
    FROM comun.c_actividades;
END;
$$ LANGUAGE plpgsql;
