-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: PadronGlobal.vue
-- DESCRIPCIÓN: Procedimientos almacenados para el padrón global de locales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP: SP_MERCADOS_PADRON_GLOBAL
-- Descripción: Obtiene el padrón global de locales según filtros
-- =============================================

CREATE PROCEDURE SP_MERCADOS_PADRON_GLOBAL(
    p_axo SMALLINT,
    p_mes SMALLINT,
    p_vig VARCHAR(1)
)

RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    VARCHAR(100) AS descripcion,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(30) AS nombre,
    VARCHAR(50) AS descripcion_local,
    DECIMAL(10,2) AS superficie,
    DECIMAL(14,2) AS renta,
    VARCHAR(1) AS vigencia,
    VARCHAR(100) AS leyenda;

DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_descripcion VARCHAR(100);
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_nombre VARCHAR(30);
DEFINE v_descripcion_local VARCHAR(50);
DEFINE v_superficie DECIMAL(10,2);
DEFINE v_renta DECIMAL(14,2);
DEFINE v_vigencia VARCHAR(1);
DEFINE v_leyenda VARCHAR(100);

FOREACH
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        TRIM(m.descripcion),
        l.categoria,
        TRIM(l.seccion),
        l.local,
        TRIM(l.letra_local),
        TRIM(l.bloque),
        TRIM(l.nombre),
        TRIM(l.descripcion_local),
        l.area,
        l.renta,
        TRIM(l.vigencia),
        TRIM(l.leyenda)
    INTO
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_descripcion,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_nombre,
        v_descripcion_local,
        v_superficie,
        v_renta,
        v_vigencia,
        v_leyenda
    FROM ta_11_locales l
    INNER JOIN ta_11_mercados m
        ON l.oficina = m.oficina
        AND l.num_mercado = m.num_mercado_nvo
    WHERE (p_vig = 'A' AND TRIM(l.vigencia) = 'V')
       OR (p_vig = 'B' AND TRIM(l.vigencia) = 'B')
       OR (p_vig = 'C' AND TRIM(l.vigencia) = 'C')
       OR (p_vig = 'D' AND TRIM(l.vigencia) = 'D')
    ORDER BY
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque

    RETURN
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_descripcion,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_nombre,
        v_descripcion_local,
        v_superficie,
        v_renta,
        v_vigencia,
        v_leyenda
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA PADRÓN GLOBAL
-- =============================================
