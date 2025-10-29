-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: Secciones.vue
-- DESCRIPCIÓN: Procedimientos almacenados para gestión de secciones de mercados
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_SECCIONES_BY_MERCADO
-- Descripción: Lista secciones de un mercado específico
-- =============================================

CREATE PROCEDURE SP_MERCADOS_SECCIONES_BY_MERCADO(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT
)

RETURNING
    INT AS id_seccion,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS desc_mercado,
    SMALLINT AS num_seccion,
    VARCHAR(100) AS descripcion,
    VARCHAR(1) AS vigencia;

DEFINE v_id_seccion INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_desc_mercado VARCHAR(100);
DEFINE v_num_seccion SMALLINT;
DEFINE v_descripcion VARCHAR(100);
DEFINE v_vigencia VARCHAR(1);

FOREACH
    SELECT
        s.id_seccion,
        s.oficina,
        s.num_mercado,
        TRIM(m.descripcion),
        s.num_seccion,
        TRIM(s.descripcion),
        TRIM(s.vigencia)
    INTO
        v_id_seccion,
        v_oficina,
        v_num_mercado,
        v_desc_mercado,
        v_num_seccion,
        v_descripcion,
        v_vigencia
    FROM ta_11_secciones s
    INNER JOIN ta_11_mercados m ON s.oficina = m.oficina AND s.num_mercado = m.num_mercado_nvo
    WHERE (p_oficina IS NULL OR s.oficina = p_oficina)
      AND (p_num_mercado IS NULL OR s.num_mercado = p_num_mercado)
    ORDER BY s.oficina, s.num_mercado, s.num_seccion

    RETURN
        v_id_seccion,
        v_oficina,
        v_num_mercado,
        v_desc_mercado,
        v_num_seccion,
        v_descripcion,
        v_vigencia
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_SECCIONES_CREATE
-- Descripción: Crea una nueva sección
-- =============================================

CREATE PROCEDURE SP_MERCADOS_SECCIONES_CREATE(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_num_seccion SMALLINT,
    p_descripcion VARCHAR(100),
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar si ya existe
DEFINE v_existe INT;

SELECT COUNT(*)
INTO v_existe
FROM ta_11_secciones
WHERE oficina = p_oficina
  AND num_mercado = p_num_mercado
  AND num_seccion = p_num_seccion;

IF v_existe > 0 THEN
    RAISE EXCEPTION 'Ya existe una sección con este número en el mercado';
END IF;

-- Insertar
INSERT INTO ta_11_secciones (
    oficina,
    num_mercado,
    num_seccion,
    descripcion,
    vigencia
) VALUES (
    p_oficina,
    p_num_mercado,
    p_num_seccion,
    p_descripcion,
    p_vigencia
);

RETURN 'Sección creada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_SECCIONES_UPDATE
-- Descripción: Actualiza una sección existente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_SECCIONES_UPDATE(
    p_id_seccion INT,
    p_descripcion VARCHAR(100),
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

UPDATE ta_11_secciones
SET
    descripcion = p_descripcion,
    vigencia = p_vigencia
WHERE id_seccion = p_id_seccion;

RETURN 'Sección actualizada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_SECCIONES_DELETE
-- Descripción: Elimina una sección
-- =============================================

CREATE PROCEDURE SP_MERCADOS_SECCIONES_DELETE(
    p_id_seccion INT
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar que no tenga locales asociados
DEFINE v_tiene_locales INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_num_seccion SMALLINT;

SELECT oficina, num_mercado, num_seccion
INTO v_oficina, v_num_mercado, v_num_seccion
FROM ta_11_secciones
WHERE id_seccion = p_id_seccion;

SELECT COUNT(*)
INTO v_tiene_locales
FROM ta_11_locales
WHERE oficina = v_oficina
  AND num_mercado = v_num_mercado
  AND seccion = v_num_seccion;

IF v_tiene_locales > 0 THEN
    RAISE EXCEPTION 'No se puede eliminar la sección porque tiene locales asociados';
END IF;

-- Eliminar
DELETE FROM ta_11_secciones
WHERE id_seccion = p_id_seccion;

RETURN 'Sección eliminada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA SECCIONES
-- =============================================
