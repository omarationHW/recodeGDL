-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: RecaudadorasMercados.vue
-- DESCRIPCIÓN: Procedimientos almacenados para administración de recaudadoras
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_RECAUDADORAS_ADMIN_LIST
-- Descripción: Lista todas las recaudadoras con estadísticas
-- =============================================

CREATE PROCEDURE SP_MERCADOS_RECAUDADORAS_ADMIN_LIST()

RETURNING
    SMALLINT AS oficina,
    VARCHAR(100) AS recaudadora,
    VARCHAR(100) AS domicilio,
    VARCHAR(20) AS telefono,
    VARCHAR(100) AS responsable,
    INT AS total_mercados,
    INT AS total_locales,
    VARCHAR(1) AS vigencia;

DEFINE v_oficina SMALLINT;
DEFINE v_recaudadora VARCHAR(100);
DEFINE v_domicilio VARCHAR(100);
DEFINE v_telefono VARCHAR(20);
DEFINE v_responsable VARCHAR(100);
DEFINE v_total_mercados INT;
DEFINE v_total_locales INT;
DEFINE v_vigencia VARCHAR(1);

FOREACH
    SELECT
        r.oficina,
        TRIM(r.recaudadora),
        TRIM(r.domicilio),
        TRIM(r.telefono),
        TRIM(r.responsable),
        (SELECT COUNT(*) FROM ta_11_mercados m WHERE m.oficina = r.oficina),
        (SELECT COUNT(*) FROM ta_11_locales l WHERE l.oficina = r.oficina),
        TRIM(r.vigencia)
    INTO
        v_oficina,
        v_recaudadora,
        v_domicilio,
        v_telefono,
        v_responsable,
        v_total_mercados,
        v_total_locales,
        v_vigencia
    FROM ta_11_recaudadora r
    ORDER BY r.oficina

    RETURN
        v_oficina,
        v_recaudadora,
        v_domicilio,
        v_telefono,
        v_responsable,
        v_total_mercados,
        v_total_locales,
        v_vigencia
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_RECAUDADORAS_ADMIN_CREATE
-- Descripción: Crea una nueva recaudadora
-- =============================================

CREATE PROCEDURE SP_MERCADOS_RECAUDADORAS_ADMIN_CREATE(
    p_oficina SMALLINT,
    p_recaudadora VARCHAR(100),
    p_domicilio VARCHAR(100),
    p_telefono VARCHAR(20),
    p_responsable VARCHAR(100),
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar si ya existe
DEFINE v_existe INT;

SELECT COUNT(*)
INTO v_existe
FROM ta_11_recaudadora
WHERE oficina = p_oficina;

IF v_existe > 0 THEN
    RAISE EXCEPTION 'Ya existe una recaudadora con este número de oficina';
END IF;

-- Insertar
INSERT INTO ta_11_recaudadora (
    oficina,
    recaudadora,
    domicilio,
    telefono,
    responsable,
    vigencia
) VALUES (
    p_oficina,
    p_recaudadora,
    p_domicilio,
    p_telefono,
    p_responsable,
    p_vigencia
);

RETURN 'Recaudadora creada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_RECAUDADORAS_ADMIN_UPDATE
-- Descripción: Actualiza una recaudadora existente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_RECAUDADORAS_ADMIN_UPDATE(
    p_oficina SMALLINT,
    p_recaudadora VARCHAR(100),
    p_domicilio VARCHAR(100),
    p_telefono VARCHAR(20),
    p_responsable VARCHAR(100),
    p_vigencia VARCHAR(1)
)

RETURNING
    VARCHAR(100) AS resultado;

UPDATE ta_11_recaudadora
SET
    recaudadora = p_recaudadora,
    domicilio = p_domicilio,
    telefono = p_telefono,
    responsable = p_responsable,
    vigencia = p_vigencia
WHERE oficina = p_oficina;

RETURN 'Recaudadora actualizada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_RECAUDADORAS_ADMIN_DELETE
-- Descripción: Elimina una recaudadora
-- =============================================

CREATE PROCEDURE SP_MERCADOS_RECAUDADORAS_ADMIN_DELETE(
    p_oficina SMALLINT
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar que no tenga mercados asociados
DEFINE v_tiene_mercados INT;

SELECT COUNT(*)
INTO v_tiene_mercados
FROM ta_11_mercados
WHERE oficina = p_oficina;

IF v_tiene_mercados > 0 THEN
    RAISE EXCEPTION 'No se puede eliminar la recaudadora porque tiene mercados asociados';
END IF;

-- Eliminar
DELETE FROM ta_11_recaudadora
WHERE oficina = p_oficina;

RETURN 'Recaudadora eliminada correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA RECAUDADORAS ADMIN
-- =============================================
