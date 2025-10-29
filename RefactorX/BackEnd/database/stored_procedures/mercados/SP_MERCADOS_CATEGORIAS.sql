-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: Categoria.vue
-- DESCRIPCIÓN: Procedimientos almacenados para gestión de categorías de locales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_CATEGORIAS_LIST
-- Descripción: Lista todas las categorías de locales
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CATEGORIAS_LIST()

RETURNING
    INT AS id_categoria,
    SMALLINT AS cve_categoria,
    VARCHAR(100) AS descripcion,
    VARCHAR(1) AS vigencia;

DEFINE v_id_categoria INT;
DEFINE v_cve_categoria SMALLINT;
DEFINE v_descripcion VARCHAR(100);
DEFINE v_vigencia VARCHAR(1);

FOREACH
    SELECT
        id_categoria,
        cve_categoria,
        TRIM(descripcion),
        TRIM(vigencia)
    INTO
        v_id_categoria,
        v_cve_categoria,
        v_descripcion,
        v_vigencia
    FROM ta_11_categoria_local
    ORDER BY cve_categoria

    RETURN
        v_id_categoria,
        v_cve_categoria,
        v_descripcion,
        v_vigencia
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_CATEGORIAS_CREATE
-- Descripción: Crea una nueva categoría de local
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CATEGORIAS_CREATE(
    p_cve_categoria SMALLINT,
    p_descripcion VARCHAR(100),
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar si ya existe la clave
DEFINE v_existe INT;

SELECT COUNT(*)
INTO v_existe
FROM ta_11_categoria_local
WHERE cve_categoria = p_cve_categoria;

IF v_existe > 0 THEN
    RAISE EXCEPTION 'Ya existe una categoría con esta clave';
END IF;

-- Insertar
INSERT INTO ta_11_categoria_local (
    cve_categoria,
    descripcion,
    vigencia
) VALUES (
    p_cve_categoria,
    p_descripcion,
    p_vigencia
);

RETURN 'Categoría creada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_CATEGORIAS_UPDATE
-- Descripción: Actualiza una categoría existente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CATEGORIAS_UPDATE(
    p_id_categoria INT,
    p_descripcion VARCHAR(100),
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

UPDATE ta_11_categoria_local
SET
    descripcion = p_descripcion,
    vigencia = p_vigencia
WHERE id_categoria = p_id_categoria;

RETURN 'Categoría actualizada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_CATEGORIAS_DELETE
-- Descripción: Elimina una categoría
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CATEGORIAS_DELETE(
    p_id_categoria INT
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar que no tenga locales asociados
DEFINE v_tiene_locales INT;
DEFINE v_cve_categoria SMALLINT;

SELECT cve_categoria
INTO v_cve_categoria
FROM ta_11_categoria_local
WHERE id_categoria = p_id_categoria;

SELECT COUNT(*)
INTO v_tiene_locales
FROM ta_11_locales
WHERE categoria = v_cve_categoria;

IF v_tiene_locales > 0 THEN
    RAISE EXCEPTION 'No se puede eliminar la categoría porque tiene locales asociados';
END IF;

-- Eliminar
DELETE FROM ta_11_categoria_local
WHERE id_categoria = p_id_categoria;

RETURN 'Categoría eliminada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA CATEGORÍAS
-- =============================================
