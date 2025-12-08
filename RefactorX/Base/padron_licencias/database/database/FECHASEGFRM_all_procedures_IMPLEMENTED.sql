-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: FECHASEGFRM
-- Modulo: padron_licencias
-- Descripcion: Gestion de fechas de seguimiento y oficios para tramites
-- Schema: comun
-- Generado: 2025-11-21
-- Total SPs: 5 + 2 Alias
-- ============================================

-- ============================================
-- CREACION DE TABLA (si no existe)
-- ============================================

CREATE TABLE IF NOT EXISTS comun.fechasegfrm (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    oficio VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fechasegfrm_fecha ON comun.fechasegfrm(fecha);

COMMENT ON TABLE comun.fechasegfrm IS 'Tabla de fechas de seguimiento y oficios para tramites';
COMMENT ON COLUMN comun.fechasegfrm.id IS 'Identificador unico del registro';
COMMENT ON COLUMN comun.fechasegfrm.fecha IS 'Fecha de seguimiento';
COMMENT ON COLUMN comun.fechasegfrm.oficio IS 'Numero de oficio asociado';
COMMENT ON COLUMN comun.fechasegfrm.created_at IS 'Fecha de creacion del registro';
COMMENT ON COLUMN comun.fechasegfrm.updated_at IS 'Fecha de ultima actualizacion';

-- ============================================
-- SP 1/5: sp_fechasegfrm_list
-- Tipo: Catalog
-- Descripcion: Lista registros de fecha/oficio con filtros opcionales
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_fechasegfrm_list(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id INTEGER,
    fecha DATE,
    oficio VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.id,
        f.fecha,
        f.oficio,
        f.created_at,
        f.updated_at
    FROM comun.fechasegfrm f
    WHERE (p_fecha_desde IS NULL OR f.fecha >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR f.fecha <= p_fecha_hasta)
    ORDER BY f.fecha DESC
    LIMIT p_limit;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_fechasegfrm_list: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_fechasegfrm_list(DATE, DATE, INTEGER) IS 'Lista registros de fecha/oficio con filtros opcionales de rango de fechas';

-- ============================================
-- SP 2/5: sp_fechasegfrm_get
-- Tipo: Query
-- Descripcion: Obtiene un registro por su ID
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_fechasegfrm_get(
    p_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    fecha DATE,
    oficio VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        f.id,
        f.fecha,
        f.oficio,
        f.created_at,
        f.updated_at
    FROM comun.fechasegfrm f
    WHERE f.id = p_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'Registro con ID % no encontrado', p_id;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_fechasegfrm_get: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_fechasegfrm_get(INTEGER) IS 'Obtiene un registro de fecha/oficio por su ID';

-- ============================================
-- SP 3/5: sp_fechasegfrm_save
-- Tipo: CRUD
-- Descripcion: Crea un nuevo registro de fecha/oficio
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_fechasegfrm_save(
    p_fecha DATE,
    p_oficio VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id INTEGER
) AS $$
DECLARE
    v_id INTEGER;
    v_oficio_normalizado VARCHAR(100);
BEGIN
    -- Validar que la fecha no sea nula
    IF p_fecha IS NULL THEN
        RETURN QUERY SELECT FALSE, 'La fecha es requerida'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Normalizar oficio con UPPER(TRIM())
    v_oficio_normalizado := UPPER(TRIM(p_oficio));

    -- Insertar el nuevo registro
    INSERT INTO comun.fechasegfrm (fecha, oficio, created_at, updated_at)
    VALUES (p_fecha, v_oficio_normalizado, NOW(), NOW())
    RETURNING fechasegfrm.id INTO v_id;

    RETURN QUERY SELECT TRUE, 'Registro creado exitosamente'::TEXT, v_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al crear registro: ' || SQLERRM)::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_fechasegfrm_save(DATE, VARCHAR) IS 'Crea un nuevo registro de fecha/oficio. Normaliza el oficio con UPPER(TRIM())';

-- ============================================
-- SP 4/5: sp_fechasegfrm_update
-- Tipo: CRUD
-- Descripcion: Actualiza un registro existente
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_fechasegfrm_update(
    p_id INTEGER,
    p_fecha DATE,
    p_oficio VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists BOOLEAN;
    v_oficio_normalizado VARCHAR(100);
BEGIN
    -- Validar que el registro exista
    SELECT EXISTS(SELECT 1 FROM comun.fechasegfrm WHERE id = p_id) INTO v_exists;

    IF NOT v_exists THEN
        RETURN QUERY SELECT FALSE, ('Registro con ID ' || p_id || ' no encontrado')::TEXT;
        RETURN;
    END IF;

    -- Validar que la fecha no sea nula
    IF p_fecha IS NULL THEN
        RETURN QUERY SELECT FALSE, 'La fecha es requerida'::TEXT;
        RETURN;
    END IF;

    -- Normalizar oficio con UPPER(TRIM())
    v_oficio_normalizado := UPPER(TRIM(p_oficio));

    -- Actualizar el registro
    UPDATE comun.fechasegfrm
    SET fecha = p_fecha,
        oficio = v_oficio_normalizado,
        updated_at = NOW()
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Registro actualizado exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al actualizar registro: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_fechasegfrm_update(INTEGER, DATE, VARCHAR) IS 'Actualiza un registro de fecha/oficio existente';

-- ============================================
-- SP 5/5: sp_fechasegfrm_delete
-- Tipo: CRUD
-- Descripcion: Elimina un registro por su ID
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_fechasegfrm_delete(
    p_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Validar que el registro exista
    SELECT EXISTS(SELECT 1 FROM comun.fechasegfrm WHERE id = p_id) INTO v_exists;

    IF NOT v_exists THEN
        RETURN QUERY SELECT FALSE, ('Registro con ID ' || p_id || ' no encontrado')::TEXT;
        RETURN;
    END IF;

    -- Eliminar el registro
    DELETE FROM comun.fechasegfrm WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Registro eliminado exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al eliminar registro: ' || SQLERRM)::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_fechasegfrm_delete(INTEGER) IS 'Elimina un registro de fecha/oficio por su ID';

-- ============================================
-- ALIAS PARA COMPATIBILIDAD
-- ============================================

-- Alias 1: fechasegfrm_save (sin prefijo sp_)
CREATE OR REPLACE FUNCTION comun.fechasegfrm_save(
    p_fecha DATE,
    p_oficio VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM comun.sp_fechasegfrm_save(p_fecha, p_oficio);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.fechasegfrm_save(DATE, VARCHAR) IS 'Alias de sp_fechasegfrm_save para compatibilidad';

-- Alias 2: fechasegfrm_list (sin prefijo sp_)
CREATE OR REPLACE FUNCTION comun.fechasegfrm_list(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id INTEGER,
    fecha DATE,
    oficio VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM comun.sp_fechasegfrm_list(p_fecha_desde, p_fecha_hasta, p_limit);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.fechasegfrm_list(DATE, DATE, INTEGER) IS 'Alias de sp_fechasegfrm_list para compatibilidad';

-- ============================================
-- GRANTS DE PERMISOS
-- ============================================

-- Permisos para el schema comun
GRANT USAGE ON SCHEMA comun TO PUBLIC;

-- Permisos para la tabla
GRANT SELECT, INSERT, UPDATE, DELETE ON comun.fechasegfrm TO PUBLIC;
GRANT USAGE, SELECT ON SEQUENCE comun.fechasegfrm_id_seq TO PUBLIC;

-- Permisos para las funciones
GRANT EXECUTE ON FUNCTION comun.sp_fechasegfrm_list(DATE, DATE, INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.sp_fechasegfrm_get(INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.sp_fechasegfrm_save(DATE, VARCHAR) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.sp_fechasegfrm_update(INTEGER, DATE, VARCHAR) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.sp_fechasegfrm_delete(INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.fechasegfrm_save(DATE, VARCHAR) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.fechasegfrm_list(DATE, DATE, INTEGER) TO PUBLIC;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
