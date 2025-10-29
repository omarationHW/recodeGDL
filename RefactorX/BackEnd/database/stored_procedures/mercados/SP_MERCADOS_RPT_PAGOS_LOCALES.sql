-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: RptPagosLocales.vue
-- DESCRIPCIÓN: Procedimientos almacenados para reporte detallado de pagos de locales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP: SP_MERCADOS_RPT_PAGOS_LOCALES
-- Descripción: Reporte detallado de pagos de locales con información completa
-- =============================================

CREATE PROCEDURE SP_MERCADOS_RPT_PAGOS_LOCALES(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_oficina SMALLINT
)

RETURNING
    INT AS id_pago_local,
    INT AS id_local,
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DATE AS fecha_pago,
    SMALLINT AS oficina_pago,
    VARCHAR(4) AS caja_pago,
    INT AS operacion_pago,
    DECIMAL(14,2) AS importe_pago,
    VARCHAR(20) AS folio,
    DATETIME YEAR TO SECOND AS fecha_modificacion,
    INT AS id_usuario,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(30) AS usuario,
    VARCHAR(30) AS nombre_comerciante,
    VARCHAR(100) AS recaudadora,
    VARCHAR(255) AS datos_local,
    VARCHAR(20) AS axo_periodo;

DEFINE v_id_pago_local INT;
DEFINE v_id_local INT;
DEFINE v_axo SMALLINT;
DEFINE v_periodo SMALLINT;
DEFINE v_fecha_pago DATE;
DEFINE v_oficina_pago SMALLINT;
DEFINE v_caja_pago VARCHAR(4);
DEFINE v_operacion_pago INT;
DEFINE v_importe_pago DECIMAL(14,2);
DEFINE v_folio VARCHAR(20);
DEFINE v_fecha_modificacion DATETIME YEAR TO SECOND;
DEFINE v_id_usuario INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_usuario VARCHAR(30);
DEFINE v_nombre_comerciante VARCHAR(30);
DEFINE v_recaudadora VARCHAR(100);
DEFINE v_datos_local VARCHAR(255);
DEFINE v_axo_periodo VARCHAR(20);

FOREACH
    SELECT
        pag.id_pago_local,
        pag.id_local,
        pag.axo,
        pag.periodo,
        pag.fecha_pago,
        pag.oficina_pago,
        pag.caja_pago,
        pag.operacion_pago,
        pag.importe_pago,
        TRIM(pag.folio),
        pag.fecha_modificacion,
        pag.id_usuario,
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        TRIM(loc.seccion),
        loc.local,
        TRIM(loc.letra_local),
        TRIM(loc.bloque),
        TRIM(usr.usuario),
        TRIM(loc.nombre),
        TRIM(rec.recaudadora)
    INTO
        v_id_pago_local,
        v_id_local,
        v_axo,
        v_periodo,
        v_fecha_pago,
        v_oficina_pago,
        v_caja_pago,
        v_operacion_pago,
        v_importe_pago,
        v_folio,
        v_fecha_modificacion,
        v_id_usuario,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_usuario,
        v_nombre_comerciante,
        v_recaudadora
    FROM ta_11_pagos_local pag
    INNER JOIN ta_11_locales loc
        ON pag.id_local = loc.id_local
    INNER JOIN ta_12_passwords usr
        ON pag.id_usuario = usr.id_usuario
    INNER JOIN ta_12_recaudadoras rec
        ON pag.oficina_pago = rec.id_rec
    WHERE pag.fecha_pago >= p_fecha_desde
      AND pag.fecha_pago <= p_fecha_hasta
      AND loc.oficina = p_oficina
    ORDER BY
        pag.oficina_pago,
        pag.fecha_pago,
        pag.caja_pago,
        pag.operacion_pago,
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        loc.seccion,
        loc.local,
        loc.letra_local,
        loc.bloque,
        pag.axo,
        pag.periodo

    -- Construir datos del local concatenados
    LET v_datos_local = TRIM(v_oficina) || ' ' || TRIM(v_num_mercado) || ' ' ||
                        TRIM(v_categoria) || ' ' || TRIM(v_seccion) || ' ' ||
                        TRIM(v_local) || ' ' || NVL(TRIM(v_letra_local), '') || ' ' ||
                        NVL(TRIM(v_bloque), '');

    -- Construir año-periodo
    LET v_axo_periodo = TRIM(v_axo) || '-' || TRIM(v_periodo);

    RETURN
        v_id_pago_local,
        v_id_local,
        v_axo,
        v_periodo,
        v_fecha_pago,
        v_oficina_pago,
        v_caja_pago,
        v_operacion_pago,
        v_importe_pago,
        v_folio,
        v_fecha_modificacion,
        v_id_usuario,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_usuario,
        v_nombre_comerciante,
        v_recaudadora,
        v_datos_local,
        v_axo_periodo
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA REPORTE DE PAGOS LOCALES
-- =============================================
