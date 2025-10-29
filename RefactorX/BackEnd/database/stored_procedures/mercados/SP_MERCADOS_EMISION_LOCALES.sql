-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: EmisionLocales.vue
-- DESCRIPCIÓN: Procedimientos almacenados para emisión de recibos de locales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_EMISION_MERCADOS_LIST
-- Descripción: Lista los mercados activos de una recaudadora/oficina
-- =============================================

CREATE PROCEDURE SP_MERCADOS_EMISION_MERCADOS_LIST(
    p_oficina SMALLINT
)

RETURNING
    SMALLINT AS oficina,
    SMALLINT AS num_mercado_nvo,
    SMALLINT AS categoria,
    VARCHAR(100) AS descripcion,
    INT AS cuenta_ingreso,
    VARCHAR(1) AS tipo_emision;

DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_descripcion VARCHAR(100);
DEFINE v_cuenta_ingreso INT;
DEFINE v_tipo_emision VARCHAR(1);

FOREACH
    SELECT
        oficina,
        num_mercado_nvo,
        categoria,
        TRIM(descripcion),
        cuenta_ingreso,
        TRIM(tipo_emision)
    INTO
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_descripcion,
        v_cuenta_ingreso,
        v_tipo_emision
    FROM ta_11_mercados
    WHERE oficina = p_oficina
      AND tipo_emision <> 'B'
    ORDER BY num_mercado_nvo

    RETURN
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_descripcion,
        v_cuenta_ingreso,
        v_tipo_emision
    WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_EMISION_EMITIR_RECIBOS
-- Descripción: Lista locales para emisión (sin pago ni cancelación)
-- =============================================

CREATE PROCEDURE SP_MERCADOS_EMISION_EMITIR_RECIBOS(
    p_oficina SMALLINT,
    p_mercado SMALLINT,
    p_axo SMALLINT,
    p_periodo SMALLINT
)

RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS num_local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(30) AS nombre,
    VARCHAR(100) AS descripcion_local,
    DECIMAL(10,2) AS superficie,
    SMALLINT AS clave_cuota,
    DECIMAL(12,2) AS importe_cuota,
    DECIMAL(14,2) AS renta;

DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_num_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_nombre VARCHAR(30);
DEFINE v_descripcion VARCHAR(100);
DEFINE v_superficie DECIMAL(10,2);
DEFINE v_clave_cuota SMALLINT;
DEFINE v_importe_cuota DECIMAL(12,2);
DEFINE v_renta DECIMAL(14,2);
DEFINE v_pago_count INT;
DEFINE v_canc_count INT;

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
        TRIM(loc.descripcion_local),
        loc.superficie,
        loc.clave_cuota,
        cuo.importe_cuota,
        -- Cálculo de renta según reglas
        CASE
            WHEN TRIM(loc.seccion) = 'PS' AND loc.clave_cuota = 4 THEN
                loc.superficie * cuo.importe_cuota
            WHEN TRIM(loc.seccion) = 'PS' THEN
                (cuo.importe_cuota * loc.superficie) * 30
            ELSE
                loc.superficie * cuo.importe_cuota
        END
    INTO
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_num_local,
        v_letra_local,
        v_bloque,
        v_nombre,
        v_descripcion,
        v_superficie,
        v_clave_cuota,
        v_importe_cuota,
        v_renta
    FROM ta_11_locales loc
    INNER JOIN ta_11_cuo_locales cuo
        ON cuo.axo = p_axo
        AND loc.categoria = cuo.categoria
        AND loc.seccion = cuo.seccion
        AND loc.clave_cuota = cuo.clave_cuota
    WHERE loc.oficina = p_oficina
      AND loc.num_mercado = p_mercado
      AND loc.vigencia = 'A'
      AND NVL(loc.bloqueo, 0) < 4

    -- Verificar si ya tiene pago
    SELECT COUNT(*)
    INTO v_pago_count
    FROM ta_11_pagos_local
    WHERE id_local = v_id_local
      AND axo = p_axo
      AND periodo = p_periodo;

    -- Verificar si está cancelado
    SELECT COUNT(*)
    INTO v_canc_count
    FROM ta_11_ade_loc_canc
    WHERE id_local = v_id_local
      AND axo = p_axo
      AND periodo = p_periodo;

    -- Solo retornar si no tiene pago ni está cancelado
    IF v_pago_count = 0 AND v_canc_count = 0 THEN
        RETURN
            v_id_local,
            v_oficina,
            v_num_mercado,
            v_categoria,
            v_seccion,
            v_num_local,
            v_letra_local,
            v_bloque,
            v_nombre,
            v_descripcion,
            v_superficie,
            v_clave_cuota,
            v_importe_cuota,
            v_renta
        WITH RESUME;
    END IF;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_EMISION_GRABAR
-- Descripción: Graba la emisión de recibos en tabla de adeudos
-- =============================================

CREATE PROCEDURE SP_MERCADOS_EMISION_GRABAR(
    p_oficina SMALLINT,
    p_mercado SMALLINT,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_id_usuario INT
)

RETURNING
    INT AS total_insertados,
    INT AS total_ya_existentes,
    VARCHAR(255) AS mensaje;

DEFINE v_id_local INT;
DEFINE v_superficie DECIMAL(10,2);
DEFINE v_seccion VARCHAR(2);
DEFINE v_clave_cuota SMALLINT;
DEFINE v_importe_cuota DECIMAL(12,2);
DEFINE v_renta DECIMAL(14,2);
DEFINE v_adeudo_count INT;
DEFINE v_fecha_alta DATETIME YEAR TO SECOND;
DEFINE v_insertados INT;
DEFINE v_existentes INT;

LET v_fecha_alta = CURRENT YEAR TO SECOND;
LET v_insertados = 0;
LET v_existentes = 0;

FOREACH
    SELECT
        loc.id_local,
        loc.superficie,
        TRIM(loc.seccion),
        loc.clave_cuota,
        cuo.importe_cuota
    INTO
        v_id_local,
        v_superficie,
        v_seccion,
        v_clave_cuota,
        v_importe_cuota
    FROM ta_11_locales loc
    INNER JOIN ta_11_cuo_locales cuo
        ON cuo.axo = p_axo
        AND loc.categoria = cuo.categoria
        AND loc.seccion = cuo.seccion
        AND loc.clave_cuota = cuo.clave_cuota
    WHERE loc.oficina = p_oficina
      AND loc.num_mercado = p_mercado
      AND loc.vigencia = 'A'
      AND NVL(loc.bloqueo, 0) < 4

    -- Calcular renta
    IF v_seccion = 'PS' AND v_clave_cuota = 4 THEN
        LET v_renta = v_superficie * v_importe_cuota;
    ELIF v_seccion = 'PS' THEN
        LET v_renta = (v_importe_cuota * v_superficie) * 30;
    ELSE
        LET v_renta = v_superficie * v_importe_cuota;
    END IF;

    -- Verificar si ya existe adeudo
    SELECT COUNT(*)
    INTO v_adeudo_count
    FROM ta_11_adeudo_local
    WHERE id_local = v_id_local
      AND axo = p_axo
      AND periodo = p_periodo;

    -- Solo insertar si no existe
    IF v_adeudo_count = 0 THEN
        INSERT INTO ta_11_adeudo_local (
            id_local,
            axo,
            periodo,
            importe,
            fecha_alta,
            id_usuario
        ) VALUES (
            v_id_local,
            p_axo,
            p_periodo,
            v_renta,
            v_fecha_alta,
            p_id_usuario
        );
        LET v_insertados = v_insertados + 1;
    ELSE
        LET v_existentes = v_existentes + 1;
    END IF;
END FOREACH;

RETURN
    v_insertados,
    v_existentes,
    'Emisión completada: ' || v_insertados || ' insertados, ' || v_existentes || ' ya existían';

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_EMISION_FACTURACION
-- Descripción: Genera listado para facturación
-- =============================================

CREATE PROCEDURE SP_MERCADOS_EMISION_FACTURACION(
    p_oficina SMALLINT,
    p_mercado SMALLINT,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_solo_mercado SMALLINT
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
    VARCHAR(30) AS nombre,
    VARCHAR(100) AS descripcion_local,
    DECIMAL(10,2) AS superficie,
    SMALLINT AS clave_cuota,
    DECIMAL(14,2) AS renta,
    DECIMAL(14,2) AS subtotal;

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
DEFINE v_descripcion VARCHAR(100);
DEFINE v_superficie DECIMAL(10,2);
DEFINE v_clave_cuota SMALLINT;
DEFINE v_renta DECIMAL(14,2);
DEFINE v_subtotal DECIMAL(14,2);

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
        TRIM(loc.descripcion_local),
        loc.superficie,
        loc.clave_cuota,
        CASE
            WHEN TRIM(loc.seccion) = 'PS' AND loc.clave_cuota = 4 THEN
                loc.superficie * cuo.importe_cuota
            WHEN TRIM(loc.seccion) = 'PS' THEN
                (cuo.importe_cuota * loc.superficie) * 30
            ELSE
                loc.superficie * cuo.importe_cuota
        END,
        0
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
        v_descripcion,
        v_superficie,
        v_clave_cuota,
        v_renta,
        v_subtotal
    FROM ta_11_locales loc
    INNER JOIN ta_11_mercados merc
        ON loc.oficina = merc.oficina
        AND loc.num_mercado = merc.num_mercado_nvo
    INNER JOIN ta_11_cuo_locales cuo
        ON cuo.axo = p_axo
        AND loc.categoria = cuo.categoria
        AND loc.seccion = cuo.seccion
        AND loc.clave_cuota = cuo.clave_cuota
    WHERE loc.oficina = p_oficina
      AND (p_solo_mercado = 0 OR loc.num_mercado = p_mercado)
      AND loc.vigencia = 'A'
      AND NVL(loc.bloqueo, 0) < 4
    ORDER BY
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        loc.seccion DESC,
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
        v_descripcion,
        v_superficie,
        v_clave_cuota,
        v_renta,
        v_subtotal
    WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 5: SP_MERCADOS_EMISION_VERIFICAR
-- Descripción: Verifica si ya existe emisión para periodo
-- =============================================

CREATE PROCEDURE SP_MERCADOS_EMISION_VERIFICAR(
    p_oficina SMALLINT,
    p_mercado SMALLINT,
    p_axo SMALLINT,
    p_periodo SMALLINT
)

RETURNING
    INT AS total_adeudos,
    INT AS total_locales_activos,
    VARCHAR(255) AS mensaje;

DEFINE v_total_adeudos INT;
DEFINE v_total_locales INT;

-- Contar adeudos existentes
SELECT COUNT(*)
INTO v_total_adeudos
FROM ta_11_adeudo_local ade
INNER JOIN ta_11_locales loc
    ON ade.id_local = loc.id_local
WHERE loc.oficina = p_oficina
  AND loc.num_mercado = p_mercado
  AND ade.axo = p_axo
  AND ade.periodo = p_periodo;

-- Contar locales activos
SELECT COUNT(*)
INTO v_total_locales
FROM ta_11_locales
WHERE oficina = p_oficina
  AND num_mercado = p_mercado
  AND vigencia = 'A'
  AND NVL(bloqueo, 0) < 4;

RETURN
    v_total_adeudos,
    v_total_locales,
    'Total adeudos: ' || v_total_adeudos || ' de ' || v_total_locales || ' locales activos';

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA EMISIÓN DE LOCALES
-- =============================================
