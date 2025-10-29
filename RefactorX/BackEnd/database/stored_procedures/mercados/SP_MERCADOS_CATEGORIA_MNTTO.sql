-- =============================================
-- SP_MERCADOS_CATEGORIA_LIST
-- Listar todas las categorías de mercados
-- =============================================
CREATE PROCEDURE SP_MERCADOS_CATEGORIA_LIST()
RETURNING
    INTEGER AS categoria,
    VARCHAR(30) AS descripcion;

    DEFINE v_categoria INTEGER;
    DEFINE v_descripcion VARCHAR(30);

    FOREACH
        SELECT
            categoria,
            descripcion
        INTO
            v_categoria,
            v_descripcion
        FROM categorias_mercados
        ORDER BY categoria

        RETURN v_categoria, v_descripcion WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_CATEGORIA_GET
-- Obtener una categoría específica
-- =============================================
CREATE PROCEDURE SP_MERCADOS_CATEGORIA_GET(
    p_categoria INTEGER
)
RETURNING
    INTEGER AS categoria,
    VARCHAR(30) AS descripcion;

    DEFINE v_categoria INTEGER;
    DEFINE v_descripcion VARCHAR(30);

    SELECT categoria, descripcion
    INTO v_categoria, v_descripcion
    FROM categorias_mercados
    WHERE categoria = p_categoria;

    RETURN v_categoria, v_descripcion;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_CATEGORIA_INSERT
-- Insertar una nueva categoría
-- =============================================
CREATE PROCEDURE SP_MERCADOS_CATEGORIA_INSERT(
    p_categoria INTEGER,
    p_descripcion VARCHAR(30)
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje;

    DEFINE v_count INTEGER;

    -- Validar rango de categoría
    IF p_categoria < 1 OR p_categoria > 12 THEN
        RETURN 0, 'La categoría debe estar entre 1 y 12';
    END IF;

    -- Validar que no exista
    SELECT COUNT(*)
    INTO v_count
    FROM categorias_mercados
    WHERE categoria = p_categoria;

    IF v_count > 0 THEN
        RETURN 0, 'La categoría ' || p_categoria || ' ya existe';
    END IF;

    -- Insertar
    INSERT INTO categorias_mercados (
        categoria,
        descripcion
    ) VALUES (
        p_categoria,
        UPPER(p_descripcion)
    );

    RETURN 1, 'Categoría agregada correctamente';

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_CATEGORIA_UPDATE
-- Actualizar una categoría existente
-- =============================================
CREATE PROCEDURE SP_MERCADOS_CATEGORIA_UPDATE(
    p_categoria INTEGER,
    p_descripcion VARCHAR(30)
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje;

    DEFINE v_count INTEGER;

    -- Verificar que existe
    SELECT COUNT(*)
    INTO v_count
    FROM categorias_mercados
    WHERE categoria = p_categoria;

    IF v_count = 0 THEN
        RETURN 0, 'La categoría ' || p_categoria || ' no existe';
    END IF;

    -- Actualizar
    UPDATE categorias_mercados
    SET descripcion = UPPER(p_descripcion)
    WHERE categoria = p_categoria;

    RETURN 1, 'Categoría actualizada correctamente';

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_CATEGORIA_DELETE
-- Eliminar una categoría
-- =============================================
CREATE PROCEDURE SP_MERCADOS_CATEGORIA_DELETE(
    p_categoria INTEGER
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje;

    DEFINE v_count INTEGER;
    DEFINE v_locales_count INTEGER;

    -- Verificar que existe
    SELECT COUNT(*)
    INTO v_count
    FROM categorias_mercados
    WHERE categoria = p_categoria;

    IF v_count = 0 THEN
        RETURN 0, 'La categoría ' || p_categoria || ' no existe';
    END IF;

    -- Verificar que no tenga locales asociados
    SELECT COUNT(*)
    INTO v_locales_count
    FROM locales
    WHERE categoria = p_categoria;

    IF v_locales_count > 0 THEN
        RETURN 0, 'No se puede eliminar. La categoría tiene ' || v_locales_count || ' locales asociados';
    END IF;

    -- Eliminar
    DELETE FROM categorias_mercados
    WHERE categoria = p_categoria;

    RETURN 1, 'Categoría eliminada correctamente';

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_CATEGORIA_VALIDATE
-- Validar si una categoría puede ser eliminada
-- =============================================
CREATE PROCEDURE SP_MERCADOS_CATEGORIA_VALIDATE(
    p_categoria INTEGER
)
RETURNING
    INTEGER AS puede_eliminar,
    INTEGER AS locales_count,
    VARCHAR(255) AS mensaje;

    DEFINE v_locales_count INTEGER;

    SELECT COUNT(*)
    INTO v_locales_count
    FROM locales
    WHERE categoria = p_categoria;

    IF v_locales_count > 0 THEN
        RETURN 0, v_locales_count, 'La categoría tiene locales asociados';
    ELSE
        RETURN 1, 0, 'La categoría puede ser eliminada';
    END IF;

END PROCEDURE;
