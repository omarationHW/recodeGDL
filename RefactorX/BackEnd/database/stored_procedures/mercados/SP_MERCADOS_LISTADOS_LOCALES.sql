-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: ListadosLocales.vue
-- DESCRIPCIÓN: Procedimientos almacenados para listados y reportes de locales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_LISTADO_PADRON_LOCALES
-- Descripción: Padrón completo de locales con cálculo de renta
-- =============================================

CREATE PROCEDURE SP_MERCADOS_LISTADO_PADRON_LOCALES(
    p_oficina SMALLINT,
    p_mercado SMALLINT
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
    VARCHAR(30) AS nombre,
    DECIMAL(10,2) AS superficie,
    DECIMAL(14,2) AS renta,
    VARCHAR(1) AS vigencia;

DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_nombre VARCHAR(30);
DEFINE v_superficie DECIMAL(10,2);
DEFINE v_renta DECIMAL(14,2);
DEFINE v_vigencia VARCHAR(1);
DEFINE v_clave_cuota SMALLINT;
DEFINE v_importe_cuota DECIMAL(12,2);
DEFINE v_axo_actual SMALLINT;
DEFINE v_mes_actual SMALLINT;
DEFINE v_sabados_acum INT;

-- Obtener año y mes actual
LET v_axo_actual = YEAR(TODAY);
LET v_mes_actual = MONTH(TODAY);

-- Obtener sábados acumulados del mes actual
SELECT NVL(sabadosacum, 1)
INTO v_sabados_acum
FROM ta_11_fecha_desc
WHERE mes = v_mes_actual;

IF v_sabados_acum IS NULL THEN
    LET v_sabados_acum = 1;
END IF;

FOREACH
    SELECT
        loc.id_local,
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        TRIM(loc.seccion),
        loc.local,
        TRIM(loc.letra_local),
        TRIM(loc.bloque),
        TRIM(loc.nombre),
        loc.superficie,
        loc.vigencia,
        loc.clave_cuota,
        cuo.importe_cuota
    INTO
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_nombre,
        v_superficie,
        v_vigencia,
        v_clave_cuota,
        v_importe_cuota
    FROM ta_11_locales loc
    INNER JOIN ta_11_cuo_locales cuo
        ON cuo.axo = v_axo_actual
        AND cuo.categoria = loc.categoria
        AND cuo.seccion = loc.seccion
        AND cuo.clave_cuota = loc.clave_cuota
    WHERE loc.oficina = p_oficina
      AND loc.num_mercado = p_mercado
    ORDER BY
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        loc.seccion DESC,
        loc.local,
        loc.letra_local,
        loc.bloque

    -- Calcular renta según reglas especiales
    IF v_seccion = 'PS' AND v_clave_cuota = 4 THEN
        LET v_renta = v_superficie * v_importe_cuota;
    ELIF v_seccion = 'PS' THEN
        LET v_renta = (v_importe_cuota * v_superficie) * 30;
    ELIF v_num_mercado = 214 THEN
        LET v_renta = (v_superficie * v_importe_cuota) * v_sabados_acum;
    ELSE
        LET v_renta = v_superficie * v_importe_cuota;
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
        v_nombre,
        v_superficie,
        v_renta,
        v_vigencia
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_LISTADO_MOVIMIENTOS
-- Descripción: Movimientos de locales en un rango de fechas
-- =============================================

CREATE PROCEDURE SP_MERCADOS_LISTADO_MOVIMIENTOS(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_oficina SMALLINT
)

RETURNING
    INT AS id_movimiento,
    DATETIME YEAR TO SECOND AS fecha,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(50) AS tipo_descripcion,
    VARCHAR(30) AS nombre;

DEFINE v_id_movimiento INT;
DEFINE v_fecha DATETIME YEAR TO SECOND;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_tipo_movimiento SMALLINT;
DEFINE v_tipo_descripcion VARCHAR(50);
DEFINE v_nombre VARCHAR(30);

FOREACH
    SELECT
        mov.id_movimiento,
        mov.fecha,
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        TRIM(loc.seccion),
        loc.local,
        TRIM(loc.letra_local),
        TRIM(loc.bloque),
        mov.tipo_movimiento,
        TRIM(loc.nombre)
    INTO
        v_id_movimiento,
        v_fecha,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_tipo_movimiento,
        v_nombre
    FROM ta_11_movimientos mov
    INNER JOIN ta_11_locales loc
        ON mov.id_local = loc.id_local
    WHERE mov.fecha >= p_fecha_desde
      AND mov.fecha <= p_fecha_hasta
      AND loc.oficina = p_oficina
    ORDER BY
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        loc.seccion,
        loc.local,
        loc.letra_local,
        loc.bloque,
        mov.axo_memo,
        mov.numero_memo

    -- Determinar descripción del tipo de movimiento
    IF v_tipo_movimiento = 1 THEN
        LET v_tipo_descripcion = 'ALTA';
    ELIF v_tipo_movimiento = 2 THEN
        LET v_tipo_descripcion = 'CAMBIO DE GIRO';
    ELIF v_tipo_movimiento = 3 THEN
        LET v_tipo_descripcion = 'CAMBIO FECHA ALTA';
    ELIF v_tipo_movimiento = 4 THEN
        LET v_tipo_descripcion = 'CAMBIO NOMBRE LOC.';
    ELIF v_tipo_movimiento = 5 THEN
        LET v_tipo_descripcion = 'CAMBIO DOMICILIO';
    ELIF v_tipo_movimiento = 6 THEN
        LET v_tipo_descripcion = 'CAMBIO DE ZONA';
    ELIF v_tipo_movimiento = 7 THEN
        LET v_tipo_descripcion = 'CAMBIO LOCAL,SUPERF.';
    ELIF v_tipo_movimiento = 8 THEN
        LET v_tipo_descripcion = 'BAJA TOTAL';
    ELIF v_tipo_movimiento = 9 THEN
        LET v_tipo_descripcion = 'BAJA ADMINISTRATIVA';
    ELIF v_tipo_movimiento = 10 THEN
        LET v_tipo_descripcion = 'BAJA POR ACUERDO';
    ELIF v_tipo_movimiento = 11 THEN
        LET v_tipo_descripcion = 'REACTIVACION';
    ELIF v_tipo_movimiento = 12 THEN
        LET v_tipo_descripcion = 'BLOQUEADO';
    ELIF v_tipo_movimiento = 13 THEN
        LET v_tipo_descripcion = 'REACTIVAR BLOQUEO';
    ELSE
        LET v_tipo_descripcion = 'OTRO';
    END IF;

    RETURN
        v_id_movimiento,
        v_fecha,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_tipo_descripcion,
        v_nombre
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_LISTADO_PAGOS
-- Descripción: Pagos de locales en un rango de fechas
-- =============================================

CREATE PROCEDURE SP_MERCADOS_LISTADO_PAGOS(
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
    VARCHAR(30) AS nombre,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque;

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
DEFINE v_nombre VARCHAR(30);
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);

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
        TRIM(loc.nombre),
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        TRIM(loc.seccion),
        loc.local,
        TRIM(loc.letra_local),
        TRIM(loc.bloque)
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
        v_nombre,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque
    FROM ta_11_pagos_local pag
    INNER JOIN ta_11_locales loc
        ON pag.id_local = loc.id_local
    WHERE pag.fecha_pago >= p_fecha_desde
      AND pag.fecha_pago <= p_fecha_hasta
      AND pag.oficina_pago = p_oficina
    ORDER BY
        pag.fecha_pago,
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        loc.seccion,
        loc.local,
        loc.letra_local,
        loc.bloque

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
        v_nombre,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_LISTADO_INGRESO_ZONIFICADO
-- Descripción: Ingreso global agrupado por zonas
-- =============================================

CREATE PROCEDURE SP_MERCADOS_LISTADO_INGRESO_ZONIFICADO(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)

RETURNING
    SMALLINT AS id_zona,
    VARCHAR(50) AS zona,
    DECIMAL(14,2) AS pagado;

DEFINE v_id_zona SMALLINT;
DEFINE v_zona VARCHAR(50);
DEFINE v_pagado DECIMAL(14,2);

FOREACH
    SELECT
        merc.id_zona,
        TRIM(zon.zona),
        NVL(SUM(imp.importe_cta), 0)
    INTO
        v_id_zona,
        v_zona,
        v_pagado
    FROM ta_12_ingreso ing
    INNER JOIN ta_12_importes imp
        ON ing.fecing = imp.fecing
        AND ing.recing = imp.recing
        AND ing.cajing = imp.cajing
        AND ing.opcaja = imp.opcaja
    INNER JOIN ta_11_mercados merc
        ON imp.cta_aplicacion = merc.cuenta_ingreso
    INNER JOIN ta_12_zonas zon
        ON merc.id_zona = zon.id_zona
    WHERE ing.fecing >= p_fecha_desde
      AND ing.fecing <= p_fecha_hasta
      AND (
          (imp.cta_aplicacion BETWEEN 44501 AND 44588)
          OR imp.cta_aplicacion = 44119
      )
    GROUP BY
        merc.id_zona,
        zon.zona
    ORDER BY merc.id_zona

    RETURN
        v_id_zona,
        v_zona,
        v_pagado
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA LISTADOS DE LOCALES
-- =============================================
