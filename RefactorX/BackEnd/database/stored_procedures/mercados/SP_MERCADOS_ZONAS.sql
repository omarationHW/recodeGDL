-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: ZonasMercados.vue
-- DESCRIPCIÓN: Procedimientos almacenados para gestión de zonas geográficas
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_ZONAS_LIST
-- Descripción: Lista todas las zonas
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ZONAS_LIST()

RETURNING
    SMALLINT AS id_zona,
    VARCHAR(100) AS descripcion,
    VARCHAR(100) AS area_geografica,
    INT AS total_mercados,
    VARCHAR(1) AS vigencia;

DEFINE v_id_zona SMALLINT;
DEFINE v_descripcion VARCHAR(100);
DEFINE v_area_geografica VARCHAR(100);
DEFINE v_total_mercados INT;
DEFINE v_vigencia VARCHAR(1);

FOREACH
    SELECT
        z.id_zona,
        TRIM(z.descripcion),
        TRIM(z.area_geografica),
        (SELECT COUNT(*) FROM ta_11_mercados m WHERE m.id_zona = z.id_zona),
        TRIM(z.vigencia)
    INTO
        v_id_zona,
        v_descripcion,
        v_area_geografica,
        v_total_mercados,
        v_vigencia
    FROM ta_11_zonas z
    ORDER BY z.id_zona

    RETURN
        v_id_zona,
        v_descripcion,
        v_area_geografica,
        v_total_mercados,
        v_vigencia
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_ZONAS_CREATE
-- Descripción: Crea una nueva zona
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ZONAS_CREATE(
    p_id_zona SMALLINT,
    p_descripcion VARCHAR(100),
    p_area_geografica VARCHAR(100),
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar si ya existe
DEFINE v_existe INT;

SELECT COUNT(*)
INTO v_existe
FROM ta_11_zonas
WHERE id_zona = p_id_zona;

IF v_existe > 0 THEN
    RAISE EXCEPTION 'Ya existe una zona con este identificador';
END IF;

-- Insertar
INSERT INTO ta_11_zonas (
    id_zona,
    descripcion,
    area_geografica,
    vigencia
) VALUES (
    p_id_zona,
    p_descripcion,
    p_area_geografica,
    p_vigencia
);

RETURN 'Zona creada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_ZONAS_UPDATE
-- Descripción: Actualiza una zona existente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ZONAS_UPDATE(
    p_id_zona SMALLINT,
    p_descripcion VARCHAR(100),
    p_area_geografica VARCHAR(100),
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

UPDATE ta_11_zonas
SET
    descripcion = p_descripcion,
    area_geografica = p_area_geografica,
    vigencia = p_vigencia
WHERE id_zona = p_id_zona;

RETURN 'Zona actualizada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_ZONAS_DELETE
-- Descripción: Elimina una zona
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ZONAS_DELETE(
    p_id_zona SMALLINT
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar que no tenga mercados asociados
DEFINE v_tiene_mercados INT;

SELECT COUNT(*)
INTO v_tiene_mercados
FROM ta_11_mercados
WHERE id_zona = p_id_zona;

IF v_tiene_mercados > 0 THEN
    RAISE EXCEPTION 'No se puede eliminar la zona porque tiene mercados asociados';
END IF;

-- Eliminar
DELETE FROM ta_11_zonas
WHERE id_zona = p_id_zona;

RETURN 'Zona eliminada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA ZONAS
-- =============================================
