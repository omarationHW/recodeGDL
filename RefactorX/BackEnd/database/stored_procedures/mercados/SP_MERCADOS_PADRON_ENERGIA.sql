-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: PadronEnergia.vue
-- DESCRIPCIÓN: Procedimientos almacenados para el padrón de energía eléctrica
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_RECAUDADORAS_LIST
-- Descripción: Lista de recaudadoras (reutilizado de otros módulos)
-- =============================================
-- Este SP ya existe, no es necesario recrearlo

-- =============================================
-- SP 2: SP_MERCADOS_MERCADOS_BY_RECAUDADORA
-- Descripción: Mercados de una recaudadora que tienen energía eléctrica
-- =============================================

CREATE PROCEDURE SP_MERCADOS_MERCADOS_BY_RECAUDADORA(
    p_id_rec SMALLINT
)

RETURNING
    SMALLINT AS num_mercado_nvo,
    VARCHAR(100) AS descripcion;

DEFINE v_num_mercado_nvo SMALLINT;
DEFINE v_descripcion VARCHAR(100);

FOREACH
    SELECT
        num_mercado_nvo,
        TRIM(descripcion)
    INTO
        v_num_mercado_nvo,
        v_descripcion
    FROM ta_11_mercados
    WHERE oficina = p_id_rec
      AND cuenta_energia > 0
    ORDER BY num_mercado_nvo

    RETURN
        v_num_mercado_nvo,
        v_descripcion
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_PADRON_ENERGIA
-- Descripción: Padrón de energía eléctrica por recaudadora y mercado
-- =============================================

CREATE PROCEDURE SP_MERCADOS_PADRON_ENERGIA(
    p_id_rec SMALLINT,
    p_num_mercado_nvo SMALLINT
)

RETURNING
    VARCHAR(100) AS descripcion,
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(255) AS descripcion_local,
    VARCHAR(1) AS cve_consumo,
    VARCHAR(50) AS local_adicional,
    VARCHAR(30) AS nombre,
    DECIMAL(10,2) AS cantidad,
    VARCHAR(1) AS vigencia;

DEFINE v_descripcion VARCHAR(100);
DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_descripcion_local VARCHAR(255);
DEFINE v_cve_consumo VARCHAR(1);
DEFINE v_local_adicional VARCHAR(50);
DEFINE v_nombre VARCHAR(30);
DEFINE v_cantidad DECIMAL(10,2);
DEFINE v_vigencia VARCHAR(1);

FOREACH
    SELECT
        TRIM(a.descripcion),
        b.id_local,
        b.oficina,
        b.num_mercado,
        b.categoria,
        TRIM(b.seccion),
        b.local,
        TRIM(b.letra_local),
        TRIM(b.bloque),
        TRIM(b.descripcion_local),
        TRIM(c.cve_consumo),
        TRIM(c.local_adicional),
        TRIM(b.nombre),
        c.cantidad,
        TRIM(c.vigencia)
    INTO
        v_descripcion,
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_descripcion_local,
        v_cve_consumo,
        v_local_adicional,
        v_nombre,
        v_cantidad,
        v_vigencia
    FROM ta_11_mercados a
    INNER JOIN ta_11_locales b
        ON a.oficina = b.oficina
        AND a.num_mercado_nvo = b.num_mercado
    INNER JOIN ta_11_energia c
        ON b.id_local = c.id_local
    WHERE a.oficina = p_id_rec
      AND a.num_mercado_nvo = p_num_mercado_nvo
    ORDER BY
        b.oficina,
        b.num_mercado,
        b.categoria,
        b.seccion,
        b.local,
        b.letra_local,
        b.bloque

    RETURN
        v_descripcion,
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_descripcion_local,
        v_cve_consumo,
        v_local_adicional,
        v_nombre,
        v_cantidad,
        v_vigencia
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA PADRÓN DE ENERGÍA
-- =============================================
