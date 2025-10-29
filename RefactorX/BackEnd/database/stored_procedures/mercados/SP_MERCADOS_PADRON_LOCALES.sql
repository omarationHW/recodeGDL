-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: PadronLocales.vue
-- DESCRIPCIÓN: Procedimientos almacenados para padrón de locales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_RECAUDADORAS_LIST
-- Descripción: Obtiene la lista de recaudadoras/oficinas
-- =============================================

CREATE PROCEDURE SP_MERCADOS_RECAUDADORAS_LIST()

RETURNING
    SMALLINT AS oficina,
    VARCHAR(100) AS nombre_oficina;

DEFINE v_oficina SMALLINT;
DEFINE v_nombre VARCHAR(100);

FOREACH
    SELECT DISTINCT
        oficina,
        TRIM(nom_ofic) AS nombre_oficina
    INTO
        v_oficina,
        v_nombre
    FROM ta_01_oficinas
    WHERE vigencia = 'A'
    ORDER BY oficina

    RETURN v_oficina, v_nombre WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_PADRON_LOCALES_LIST
-- Descripción: Obtiene el padrón completo de locales con cálculo de renta
-- Parámetros:
--   p_oficina: Código de la oficina/recaudadora
-- =============================================

CREATE PROCEDURE SP_MERCADOS_PADRON_LOCALES_LIST(
    p_oficina SMALLINT
)

RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS nombre_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS num_local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(30) AS nombre_comerciante,
    DECIMAL(10,2) AS superficie,
    SMALLINT AS clave_cuota,
    VARCHAR(30) AS descripcion_cuota,
    DECIMAL(12,2) AS importe_cuota,
    DECIMAL(14,2) AS renta,
    VARCHAR(1) AS vigencia;

DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_nombre_mercado VARCHAR(100);
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_num_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_nombre VARCHAR(30);
DEFINE v_superficie DECIMAL(10,2);
DEFINE v_clave_cuota SMALLINT;
DEFINE v_descripcion VARCHAR(30);
DEFINE v_importe DECIMAL(12,2);
DEFINE v_renta DECIMAL(14,2);
DEFINE v_vigencia VARCHAR(1);
DEFINE v_anio_actual SMALLINT;

-- Obtener año actual
LET v_anio_actual = YEAR(TODAY);

FOREACH
    SELECT
        loc.id_local,
        loc.oficina,
        loc.num_mercado,
        TRIM(merc.descripcion),
        loc.categoria,
        TRIM(loc.seccion),
        loc.local,
        TRIM(loc.letra_local),
        TRIM(loc.bloque),
        TRIM(loc.nombre),
        loc.superficie,
        loc.clave_cuota,
        TRIM(cuo.descripcion),
        NVL(cuo.importe_cuota, 0),
        -- Cálculo de renta según sección
        CASE
            WHEN TRIM(loc.seccion) = 'PS' THEN
                (NVL(loc.superficie, 0) * NVL(cuo.importe_cuota, 0)) * 30
            ELSE
                NVL(loc.superficie, 0) * NVL(cuo.importe_cuota, 0)
        END,
        loc.vigencia
    INTO
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_nombre_mercado,
        v_categoria,
        v_seccion,
        v_num_local,
        v_letra_local,
        v_bloque,
        v_nombre,
        v_superficie,
        v_clave_cuota,
        v_descripcion,
        v_importe,
        v_renta,
        v_vigencia
    FROM ta_11_locales loc
    INNER JOIN ta_11_mercados merc
        ON loc.oficina = merc.oficina
        AND loc.num_mercado = merc.num_mercado_nvo
    LEFT OUTER JOIN ta_11_cuo_locales cuo
        ON cuo.axo = v_anio_actual
        AND cuo.categoria = loc.categoria
        AND cuo.seccion = loc.seccion
        AND cuo.clave_cuota = loc.clave_cuota
    WHERE loc.oficina = p_oficina
      AND loc.vigencia = 'A'
    ORDER BY
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        loc.seccion,
        loc.local,
        loc.letra_local,
        loc.bloque

    RETURN
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_nombre_mercado,
        v_categoria,
        v_seccion,
        v_num_local,
        v_letra_local,
        v_bloque,
        v_nombre,
        v_superficie,
        v_clave_cuota,
        v_descripcion,
        v_importe,
        v_renta,
        v_vigencia
    WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_MERCADOS_LIST
-- Descripción: Obtiene la lista de mercados por oficina
-- =============================================

CREATE PROCEDURE SP_MERCADOS_MERCADOS_LIST(
    p_oficina SMALLINT
)

RETURNING
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS descripcion,
    VARCHAR(1) AS vigencia;

DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_descripcion VARCHAR(100);
DEFINE v_vigencia VARCHAR(1);

FOREACH
    SELECT
        oficina,
        num_mercado_nvo,
        TRIM(descripcion),
        vigencia
    INTO
        v_oficina,
        v_num_mercado,
        v_descripcion,
        v_vigencia
    FROM ta_11_mercados
    WHERE oficina = p_oficina
      AND vigencia = 'A'
    ORDER BY num_mercado_nvo

    RETURN v_oficina, v_num_mercado, v_descripcion, v_vigencia WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_LOCAL_CONSULTAR
-- Descripción: Consulta detallada de un local específico
-- =============================================

CREATE PROCEDURE SP_MERCADOS_LOCAL_CONSULTAR(
    p_id_local INT
)

RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS nombre_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS num_local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(30) AS nombre_comerciante,
    DECIMAL(10,2) AS superficie,
    SMALLINT AS clave_cuota,
    VARCHAR(30) AS descripcion_cuota,
    DECIMAL(12,2) AS importe_cuota,
    DECIMAL(14,2) AS renta,
    VARCHAR(1) AS vigencia,
    DATE AS fecha_alta,
    INT AS id_usuario;

DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_nombre_mercado VARCHAR(100);
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_num_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_nombre VARCHAR(30);
DEFINE v_superficie DECIMAL(10,2);
DEFINE v_clave_cuota SMALLINT;
DEFINE v_descripcion VARCHAR(30);
DEFINE v_importe DECIMAL(12,2);
DEFINE v_renta DECIMAL(14,2);
DEFINE v_vigencia VARCHAR(1);
DEFINE v_fecha_alta DATE;
DEFINE v_id_usuario INT;
DEFINE v_anio_actual SMALLINT;

LET v_anio_actual = YEAR(TODAY);

SELECT
    loc.id_local,
    loc.oficina,
    loc.num_mercado,
    TRIM(merc.descripcion),
    loc.categoria,
    TRIM(loc.seccion),
    loc.local,
    TRIM(loc.letra_local),
    TRIM(loc.bloque),
    TRIM(loc.nombre),
    loc.superficie,
    loc.clave_cuota,
    TRIM(cuo.descripcion),
    NVL(cuo.importe_cuota, 0),
    CASE
        WHEN TRIM(loc.seccion) = 'PS' THEN
            (NVL(loc.superficie, 0) * NVL(cuo.importe_cuota, 0)) * 30
        ELSE
            NVL(loc.superficie, 0) * NVL(cuo.importe_cuota, 0)
    END,
    loc.vigencia,
    loc.fecha_alta,
    loc.id_usuario
INTO
    v_id_local,
    v_oficina,
    v_num_mercado,
    v_nombre_mercado,
    v_categoria,
    v_seccion,
    v_num_local,
    v_letra_local,
    v_bloque,
    v_nombre,
    v_superficie,
    v_clave_cuota,
    v_descripcion,
    v_importe,
    v_renta,
    v_vigencia,
    v_fecha_alta,
    v_id_usuario
FROM ta_11_locales loc
INNER JOIN ta_11_mercados merc
    ON loc.oficina = merc.oficina
    AND loc.num_mercado = merc.num_mercado_nvo
LEFT OUTER JOIN ta_11_cuo_locales cuo
    ON cuo.axo = v_anio_actual
    AND cuo.categoria = loc.categoria
    AND cuo.seccion = loc.seccion
    AND cuo.clave_cuota = loc.clave_cuota
WHERE loc.id_local = p_id_local;

RETURN
    v_id_local,
    v_oficina,
    v_num_mercado,
    v_nombre_mercado,
    v_categoria,
    v_seccion,
    v_num_local,
    v_letra_local,
    v_bloque,
    v_nombre,
    v_superficie,
    v_clave_cuota,
    v_descripcion,
    v_importe,
    v_renta,
    v_vigencia,
    v_fecha_alta,
    v_id_usuario;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA PADRÓN DE LOCALES
-- =============================================
