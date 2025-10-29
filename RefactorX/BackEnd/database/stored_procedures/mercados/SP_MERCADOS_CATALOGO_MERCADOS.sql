-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: CatalogoMercados.vue
-- DESCRIPCIÓN: Procedimientos almacenados para catálogo de mercados (CRUD)
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_CATALOGO_LIST
-- Descripción: Lista todos los mercados
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CATALOGO_LIST()

RETURNING
    SMALLINT AS oficina,
    SMALLINT AS num_mercado_nvo,
    SMALLINT AS categoria,
    VARCHAR(100) AS descripcion,
    INT AS cuenta_ingreso,
    INT AS cuenta_energia,
    SMALLINT AS id_zona,
    VARCHAR(1) AS tipo_emision;

DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado_nvo SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_descripcion VARCHAR(100);
DEFINE v_cuenta_ingreso INT;
DEFINE v_cuenta_energia INT;
DEFINE v_id_zona SMALLINT;
DEFINE v_tipo_emision VARCHAR(1);

FOREACH
    SELECT
        oficina,
        num_mercado_nvo,
        categoria,
        TRIM(descripcion),
        cuenta_ingreso,
        cuenta_energia,
        id_zona,
        TRIM(tipo_emision)
    INTO
        v_oficina,
        v_num_mercado_nvo,
        v_categoria,
        v_descripcion,
        v_cuenta_ingreso,
        v_cuenta_energia,
        v_id_zona,
        v_tipo_emision
    FROM ta_11_mercados
    ORDER BY oficina, num_mercado_nvo

    RETURN
        v_oficina,
        v_num_mercado_nvo,
        v_categoria,
        v_descripcion,
        v_cuenta_ingreso,
        v_cuenta_energia,
        v_id_zona,
        v_tipo_emision
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_CATALOGO_CREATE
-- Descripción: Crea un nuevo mercado
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CATALOGO_CREATE(
    p_oficina SMALLINT,
    p_num_mercado_nvo SMALLINT,
    p_categoria SMALLINT,
    p_descripcion VARCHAR(100),
    p_cuenta_ingreso INT,
    p_cuenta_energia INT,
    p_id_zona SMALLINT,
    p_tipo_emision VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar si ya existe
DEFINE v_existe INT;

SELECT COUNT(*)
INTO v_existe
FROM ta_11_mercados
WHERE oficina = p_oficina
  AND num_mercado_nvo = p_num_mercado_nvo;

IF v_existe > 0 THEN
    RAISE EXCEPTION 'El mercado ya existe';
END IF;

-- Insertar
INSERT INTO ta_11_mercados (
    oficina,
    num_mercado_nvo,
    categoria,
    descripcion,
    cuenta_ingreso,
    cuenta_energia,
    id_zona,
    tipo_emision
) VALUES (
    p_oficina,
    p_num_mercado_nvo,
    p_categoria,
    p_descripcion,
    p_cuenta_ingreso,
    p_cuenta_energia,
    p_id_zona,
    p_tipo_emision
);

RETURN 'Mercado creado correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_CATALOGO_UPDATE
-- Descripción: Actualiza un mercado existente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CATALOGO_UPDATE(
    p_oficina SMALLINT,
    p_num_mercado_nvo SMALLINT,
    p_categoria SMALLINT,
    p_descripcion VARCHAR(100),
    p_cuenta_ingreso INT,
    p_cuenta_energia INT,
    p_id_zona SMALLINT,
    p_tipo_emision VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

UPDATE ta_11_mercados
SET
    categoria = p_categoria,
    descripcion = p_descripcion,
    cuenta_ingreso = p_cuenta_ingreso,
    cuenta_energia = p_cuenta_energia,
    id_zona = p_id_zona,
    tipo_emision = p_tipo_emision
WHERE oficina = p_oficina
  AND num_mercado_nvo = p_num_mercado_nvo;

RETURN 'Mercado actualizado correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_CATALOGO_DELETE
-- Descripción: Elimina un mercado
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CATALOGO_DELETE(
    p_oficina SMALLINT,
    p_num_mercado_nvo SMALLINT
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar que no tenga locales asociados
DEFINE v_tiene_locales INT;

SELECT COUNT(*)
INTO v_tiene_locales
FROM ta_11_locales
WHERE oficina = p_oficina
  AND num_mercado = p_num_mercado_nvo;

IF v_tiene_locales > 0 THEN
    RAISE EXCEPTION 'No se puede eliminar el mercado porque tiene locales asociados';
END IF;

-- Eliminar
DELETE FROM ta_11_mercados
WHERE oficina = p_oficina
  AND num_mercado_nvo = p_num_mercado_nvo;

RETURN 'Mercado eliminado correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA CATÁLOGO DE MERCADOS
-- =============================================
