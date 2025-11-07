-- =====================================================
-- TABLA Y STORED PROCEDURES: CATEGORÍAS DE GIROS
-- Módulo: Licencias
-- Descripción: Gestión de categorías de giros comerciales
-- Esquema: catastro_gdl
-- Fecha: 2025-01-06
-- =====================================================

-- 1. Crear tabla de categorías de giros si no existe
CREATE TABLE IF NOT EXISTS catastro_gdl.categorias_giros (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    orden INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50),
    updated_by VARCHAR(50)
);

-- 2. Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_categorias_giros_activo
    ON catastro_gdl.categorias_giros(activo);
CREATE INDEX IF NOT EXISTS idx_categorias_giros_nombre
    ON catastro_gdl.categorias_giros(nombre);

-- 3. SP para listar categorías de giros activas
CREATE OR REPLACE FUNCTION catastro_gdl.sp_categorias_giros_listar()
RETURNS TABLE (
    id INTEGER,
    nombre VARCHAR(100),
    descripcion TEXT,
    activo CHAR(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.nombre,
        c.descripcion,
        c.activo
    FROM catastro_gdl.categorias_giros c
    WHERE c.activo = 'S'
    ORDER BY c.nombre ASC;
END;
$$ LANGUAGE plpgsql;

-- 4. SP para obtener todas las categorías (incluyendo inactivas)
CREATE OR REPLACE FUNCTION catastro_gdl.sp_categorias_giros_list_all()
RETURNS TABLE (
    id INTEGER,
    nombre VARCHAR(100),
    descripcion TEXT,
    activo CHAR(1),
    orden INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.nombre,
        c.descripcion,
        c.activo,
        c.orden
    FROM catastro_gdl.categorias_giros c
    ORDER BY c.orden, c.nombre ASC;
END;
$$ LANGUAGE plpgsql;

-- 5. SP para crear una categoría
CREATE OR REPLACE FUNCTION catastro_gdl.sp_categorias_giros_crear(
    p_nombre VARCHAR(100),
    p_descripcion TEXT DEFAULT NULL,
    p_orden INTEGER DEFAULT 0,
    p_created_by VARCHAR(50) DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_created INTEGER
) AS $$
DECLARE
    new_id INTEGER;
    categoria_exists INTEGER;
BEGIN
    -- Verificar si ya existe una categoría con el mismo nombre
    SELECT COUNT(*) INTO categoria_exists
    FROM catastro_gdl.categorias_giros
    WHERE LOWER(nombre) = LOWER(p_nombre);

    IF categoria_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una categoría con ese nombre'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar nueva categoría
    INSERT INTO catastro_gdl.categorias_giros (
        nombre,
        descripcion,
        activo,
        orden,
        created_by
    ) VALUES (
        p_nombre,
        p_descripcion,
        'S',
        p_orden,
        p_created_by
    ) RETURNING id INTO new_id;

    RETURN QUERY SELECT TRUE, 'Categoría creada exitosamente'::TEXT, new_id;
END;
$$ LANGUAGE plpgsql;

-- 6. SP para actualizar una categoría
CREATE OR REPLACE FUNCTION catastro_gdl.sp_categorias_giros_actualizar(
    p_id INTEGER,
    p_nombre VARCHAR(100),
    p_descripcion TEXT DEFAULT NULL,
    p_activo CHAR(1) DEFAULT 'S',
    p_orden INTEGER DEFAULT 0,
    p_updated_by VARCHAR(50) DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    affected_rows INTEGER;
    categoria_exists INTEGER;
BEGIN
    -- Verificar si la categoría existe
    SELECT COUNT(*) INTO categoria_exists
    FROM catastro_gdl.categorias_giros
    WHERE id = p_id;

    IF categoria_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'Categoría no encontrada'::TEXT;
        RETURN;
    END IF;

    -- Actualizar categoría
    UPDATE catastro_gdl.categorias_giros SET
        nombre = p_nombre,
        descripcion = p_descripcion,
        activo = p_activo,
        orden = p_orden,
        updated_at = CURRENT_TIMESTAMP,
        updated_by = p_updated_by
    WHERE id = p_id;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;

    IF affected_rows > 0 THEN
        RETURN QUERY SELECT TRUE, 'Categoría actualizada exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Error al actualizar la categoría'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 7. SP para eliminar (desactivar) una categoría
CREATE OR REPLACE FUNCTION catastro_gdl.sp_categorias_giros_eliminar(
    p_id INTEGER,
    p_updated_by VARCHAR(50) DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    affected_rows INTEGER;
BEGIN
    UPDATE catastro_gdl.categorias_giros SET
        activo = 'N',
        updated_at = CURRENT_TIMESTAMP,
        updated_by = p_updated_by
    WHERE id = p_id;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;

    IF affected_rows > 0 THEN
        RETURN QUERY SELECT TRUE, 'Categoría eliminada exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Categoría no encontrada'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 8. Insertar categorías por defecto si la tabla está vacía
DO $$
DECLARE
    record_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO record_count FROM catastro_gdl.categorias_giros;

    IF record_count = 0 THEN
        INSERT INTO catastro_gdl.categorias_giros (nombre, descripcion, activo, orden) VALUES
        ('Comercio', 'Actividades comerciales y de venta al público', 'S', 1),
        ('Servicios', 'Prestación de servicios profesionales y técnicos', 'S', 2),
        ('Alimentos y Bebidas', 'Restaurantes, bares y establecimientos de alimentos', 'S', 3),
        ('Entretenimiento', 'Centros de entretenimiento y recreación', 'S', 4),
        ('Salud', 'Servicios médicos y de salud', 'S', 5),
        ('Educación', 'Instituciones educativas y de capacitación', 'S', 6),
        ('Industria', 'Actividades industriales y manufactureras', 'S', 7),
        ('Construcción', 'Actividades relacionadas con la construcción', 'S', 8),
        ('Transporte', 'Servicios de transporte y logística', 'S', 9),
        ('Tecnología', 'Servicios tecnológicos y de informática', 'S', 10),
        ('Otros', 'Otros giros no clasificados', 'S', 99);

        RAISE NOTICE 'Categorías de giros insertadas correctamente';
    END IF;
END $$;

-- =====================================================
-- COMENTARIOS DE IMPLEMENTACIÓN:
--
-- 1. Tabla categorias_giros en esquema catastro_gdl
-- 2. SPs para CRUD completo de categorías
-- 3. sp_categorias_giros_listar() retorna solo activas
-- 4. Categorías por defecto insertadas automáticamente
-- 5. Sistema de activación/desactivación (soft delete)
-- 6. Auditoría básica con created_by y updated_by
-- =====================================================
