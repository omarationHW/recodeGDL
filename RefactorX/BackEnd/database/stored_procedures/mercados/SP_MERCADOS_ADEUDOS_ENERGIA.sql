-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: AdeudosEnergia.vue
-- DESCRIPCIÓN: Procedimientos almacenados para reporte de adeudos de energía
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP: SP_MERCADOS_ADEUDOS_ENERGIA
-- Descripción: Listado de adeudos de energía por año y oficina
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ADEUDOS_ENERGIA(
    p_axo SMALLINT,
    p_oficina SMALLINT
)

RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(1) AS cve_consumo,
    INT AS id_energia,
    VARCHAR(30) AS nombre,
    VARCHAR(50) AS local_adicional,
    SMALLINT AS axo,
    DECIMAL(14,2) AS adeudo,
    DECIMAL(14,2) AS cuota,
    VARCHAR(100) AS meses;

DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_cve_consumo VARCHAR(1);
DEFINE v_id_energia INT;
DEFINE v_nombre VARCHAR(30);
DEFINE v_local_adicional VARCHAR(50);
DEFINE v_axo SMALLINT;
DEFINE v_adeudo DECIMAL(14,2);
DEFINE v_cuota DECIMAL(14,2);
DEFINE v_meses VARCHAR(100);
DEFINE v_periodo SMALLINT;
DEFINE v_importe DECIMAL(14,2);

FOREACH
    SELECT
        c.id_local,
        c.oficina,
        c.num_mercado,
        c.categoria,
        TRIM(c.seccion),
        c.local,
        TRIM(c.letra_local),
        TRIM(c.bloque),
        TRIM(f.cve_consumo),
        f.id_energia,
        TRIM(c.nombre),
        TRIM(f.local_adicional),
        a.axo,
        SUM(a.importe)
    INTO
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_cve_consumo,
        v_id_energia,
        v_nombre,
        v_local_adicional,
        v_axo,
        v_adeudo
    FROM ta_11_adeudo_energ a
    INNER JOIN ta_11_energia f
        ON a.id_energia = f.id_energia
        AND f.vigencia <> 'B'
    INNER JOIN ta_11_locales c
        ON c.id_local = f.id_local
    WHERE a.axo = p_axo
      AND c.oficina = p_oficina
    GROUP BY
        c.id_local,
        c.oficina,
        c.num_mercado,
        c.categoria,
        c.seccion,
        c.local,
        c.letra_local,
        c.bloque,
        f.cve_consumo,
        f.id_energia,
        c.nombre,
        f.local_adicional,
        a.axo
    ORDER BY
        c.oficina,
        c.num_mercado,
        c.categoria,
        c.seccion,
        c.local,
        c.letra_local,
        c.bloque

    -- Obtener meses y cuota
    LET v_meses = '';
    LET v_cuota = 0;

    FOREACH
        SELECT periodo, importe
        INTO v_periodo, v_importe
        FROM ta_11_adeudo_energ
        WHERE id_energia = v_id_energia
          AND axo = p_axo
        ORDER BY periodo

        LET v_meses = v_meses || TRIM(v_periodo) || '-';
        LET v_cuota = v_importe;

    END FOREACH;

    -- Quitar el último guión
    IF LENGTH(v_meses) > 0 THEN
        LET v_meses = SUBSTRING(v_meses FROM 1 FOR LENGTH(v_meses) - 1);
    END IF;

    RETURN
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_cve_consumo,
        v_id_energia,
        v_nombre,
        v_local_adicional,
        v_axo,
        v_adeudo,
        v_cuota,
        v_meses
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA ADEUDOS DE ENERGÍA
-- =============================================
