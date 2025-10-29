-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: Giros.vue
-- DESCRIPCIÓN: Procedimientos almacenados para gestión de giros comerciales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_GIROS_LIST
-- Descripción: Lista todos los giros comerciales
-- =============================================

CREATE PROCEDURE SP_MERCADOS_GIROS_LIST()

RETURNING
    INT AS id_giro,
    VARCHAR(10) AS cve_giro,
    VARCHAR(100) AS descripcion,
    VARCHAR(1) AS vigencia;

DEFINE v_id_giro INT;
DEFINE v_cve_giro VARCHAR(10);
DEFINE v_descripcion VARCHAR(100);
DEFINE v_vigencia VARCHAR(1);

FOREACH
    SELECT
        id_giro,
        TRIM(cve_giro),
        TRIM(descripcion),
        TRIM(vigencia)
    INTO
        v_id_giro,
        v_cve_giro,
        v_descripcion,
        v_vigencia
    FROM ta_11_giros
    ORDER BY cve_giro

    RETURN
        v_id_giro,
        v_cve_giro,
        v_descripcion,
        v_vigencia
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_GIROS_CREATE
-- Descripción: Crea un nuevo giro comercial
-- =============================================

CREATE PROCEDURE SP_MERCADOS_GIROS_CREATE(
    p_cve_giro VARCHAR(10),
    p_descripcion VARCHAR(100),
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar si ya existe la clave
DEFINE v_existe INT;

SELECT COUNT(*)
INTO v_existe
FROM ta_11_giros
WHERE TRIM(cve_giro) = TRIM(p_cve_giro);

IF v_existe > 0 THEN
    RAISE EXCEPTION 'Ya existe un giro con esta clave';
END IF;

-- Insertar
INSERT INTO ta_11_giros (
    cve_giro,
    descripcion,
    vigencia
) VALUES (
    p_cve_giro,
    p_descripcion,
    p_vigencia
);

RETURN 'Giro creado correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_GIROS_UPDATE
-- Descripción: Actualiza un giro existente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_GIROS_UPDATE(
    p_id_giro INT,
    p_descripcion VARCHAR(100),
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

UPDATE ta_11_giros
SET
    descripcion = p_descripcion,
    vigencia = p_vigencia
WHERE id_giro = p_id_giro;

RETURN 'Giro actualizado correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_GIROS_DELETE
-- Descripción: Elimina un giro
-- =============================================

CREATE PROCEDURE SP_MERCADOS_GIROS_DELETE(
    p_id_giro INT
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar que no tenga locales asociados
DEFINE v_tiene_locales INT;
DEFINE v_cve_giro VARCHAR(10);

SELECT TRIM(cve_giro)
INTO v_cve_giro
FROM ta_11_giros
WHERE id_giro = p_id_giro;

SELECT COUNT(*)
INTO v_tiene_locales
FROM ta_11_locales
WHERE TRIM(giro) = v_cve_giro;

IF v_tiene_locales > 0 THEN
    RAISE EXCEPTION 'No se puede eliminar el giro porque tiene locales asociados';
END IF;

-- Eliminar
DELETE FROM ta_11_giros
WHERE id_giro = p_id_giro;

RETURN 'Giro eliminado correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA GIROS
-- =============================================
