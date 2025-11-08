-- =====================================================
-- SP: catalogo_actividades_list
-- Descripción: Lista de actividades con filtros
-- Esquema: comun
-- =====================================================

CREATE OR REPLACE FUNCTION comun.catalogo_actividades_list()
RETURNS TABLE (
    id_actividad INTEGER,
    id_giro INTEGER,
    descripcion VARCHAR,
    observaciones TEXT,
    vigente BOOLEAN,
    fecha_alta TIMESTAMP,
    usuario_alta VARCHAR,
    giro_descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_actividad,
        a.id_giro,
        a.descripcion,
        a.observaciones,
        a.vigente,
        a.fecha_alta,
        a.usuario_alta,
        COALESCE(g.descripcion, '') as giro_descripcion
    FROM comun.c_actividades a
    LEFT JOIN comun.c_giros g ON a.id_giro = g.id_giro
    ORDER BY a.descripcion;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: catalogo_actividades_create
-- Descripción: Crear nueva actividad
-- =====================================================

CREATE OR REPLACE FUNCTION comun.catalogo_actividades_create(
    p_id_giro INTEGER,
    p_descripcion VARCHAR,
    p_observaciones TEXT,
    p_vigente BOOLEAN,
    p_usuario_alta VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR,
    id_actividad INTEGER
) AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    -- Insertar nueva actividad
    INSERT INTO comun.c_actividades (
        id_giro,
        descripcion,
        observaciones,
        vigente,
        fecha_alta,
        usuario_alta
    ) VALUES (
        p_id_giro,
        p_descripcion,
        p_observaciones,
        p_vigente,
        CURRENT_TIMESTAMP,
        p_usuario_alta
    ) RETURNING c_actividades.id_actividad INTO v_new_id;

    RETURN QUERY SELECT
        true as success,
        'Actividad creada exitosamente'::VARCHAR as message,
        v_new_id as id_actividad;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT
        false as success,
        ('Error al crear actividad: ' || SQLERRM)::VARCHAR as message,
        NULL::INTEGER as id_actividad;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: catalogo_actividades_update
-- Descripción: Actualizar actividad existente
-- =====================================================

CREATE OR REPLACE FUNCTION comun.catalogo_actividades_update(
    p_id_actividad INTEGER,
    p_id_giro INTEGER,
    p_descripcion VARCHAR,
    p_observaciones TEXT,
    p_vigente BOOLEAN
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
BEGIN
    UPDATE comun.c_actividades
    SET
        id_giro = p_id_giro,
        descripcion = p_descripcion,
        observaciones = p_observaciones,
        vigente = p_vigente,
        fecha_modificacion = CURRENT_TIMESTAMP
    WHERE id_actividad = p_id_actividad;

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
-- Descripción: Eliminar (marcar como no vigente) actividad
-- =====================================================

CREATE OR REPLACE FUNCTION comun.catalogo_actividades_delete(
    p_id_actividad INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
BEGIN
    UPDATE comun.c_actividades
    SET
        vigente = false,
        fecha_modificacion = CURRENT_TIMESTAMP
    WHERE id_actividad = p_id_actividad;

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
    vigentes INTEGER,
    no_vigentes INTEGER,
    con_giro INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::INTEGER as total,
        COUNT(*) FILTER (WHERE vigente = true)::INTEGER as vigentes,
        COUNT(*) FILTER (WHERE vigente = false)::INTEGER as no_vigentes,
        COUNT(*) FILTER (WHERE id_giro IS NOT NULL)::INTEGER as con_giro
    FROM comun.c_actividades;
END;
$$ LANGUAGE plpgsql;
