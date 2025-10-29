-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: EstadPagosyAdeudos.vue
-- DESCRIPCIÓN: Procedimientos almacenados para estadísticas de pagos y adeudos
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_ESTAD_ESTADISTICA_PAGOS_ADEUDOS
-- Descripción: Estadística consolidada de pagos, capturas y adeudos por mercado
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ESTAD_ESTADISTICA_PAGOS_ADEUDOS(
    p_oficina SMALLINT,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)

RETURNING
    SMALLINT AS num_mercado,
    VARCHAR(100) AS descripcion,
    INT AS locales_pagados,
    DECIMAL(14,2) AS importe_pagado,
    INT AS periodos_pagados,
    INT AS locales_capturados,
    DECIMAL(14,2) AS importe_capturado,
    INT AS periodos_capturados,
    INT AS locales_adeudo,
    DECIMAL(14,2) AS importe_adeudo,
    INT AS periodos_adeudo;

DEFINE v_num_mercado SMALLINT;
DEFINE v_descripcion VARCHAR(100);
DEFINE v_locales_pagados INT;
DEFINE v_importe_pagado DECIMAL(14,2);
DEFINE v_periodos_pagados INT;
DEFINE v_locales_capturados INT;
DEFINE v_importe_capturado DECIMAL(14,2);
DEFINE v_periodos_capturados INT;
DEFINE v_locales_adeudo INT;
DEFINE v_importe_adeudo DECIMAL(14,2);
DEFINE v_periodos_adeudo INT;

-- Cursor principal: todos los mercados activos de la oficina
FOREACH
    SELECT
        num_mercado_nvo,
        TRIM(descripcion)
    INTO
        v_num_mercado,
        v_descripcion
    FROM ta_11_mercados
    WHERE oficina = p_oficina
      AND tipo_emision <> 'B'
    ORDER BY num_mercado_nvo

    -- Estadística de PAGOS (fecha_pago en el rango)
    SELECT
        COUNT(DISTINCT loc.id_local),
        NVL(SUM(pag.importe_pago), 0),
        COUNT(pag.id_pago_local)
    INTO
        v_locales_pagados,
        v_importe_pagado,
        v_periodos_pagados
    FROM ta_11_locales loc
    LEFT OUTER JOIN ta_11_pagos_local pag
        ON pag.id_local = loc.id_local
        AND pag.fecha_pago >= p_fecha_desde
        AND pag.fecha_pago <= p_fecha_hasta
    WHERE loc.oficina = p_oficina
      AND loc.num_mercado = v_num_mercado
      AND loc.vigencia = 'A'
      AND pag.id_pago_local IS NOT NULL;

    -- Si no hay registros, asignar 0
    IF v_locales_pagados IS NULL THEN
        LET v_locales_pagados = 0;
        LET v_importe_pagado = 0;
        LET v_periodos_pagados = 0;
    END IF;

    -- Estadística de CAPTURAS (fecha_modificacion en el rango)
    SELECT
        COUNT(DISTINCT loc.id_local),
        NVL(SUM(pag.importe_pago), 0),
        COUNT(pag.id_pago_local)
    INTO
        v_locales_capturados,
        v_importe_capturado,
        v_periodos_capturados
    FROM ta_11_locales loc
    LEFT OUTER JOIN ta_11_pagos_local pag
        ON pag.id_local = loc.id_local
        AND pag.fecha_modificacion >= p_fecha_desde
        AND pag.fecha_modificacion <= p_fecha_hasta
    WHERE loc.oficina = p_oficina
      AND loc.num_mercado = v_num_mercado
      AND loc.vigencia = 'A'
      AND pag.id_pago_local IS NOT NULL;

    -- Si no hay registros, asignar 0
    IF v_locales_capturados IS NULL THEN
        LET v_locales_capturados = 0;
        LET v_importe_capturado = 0;
        LET v_periodos_capturados = 0;
    END IF;

    -- Estadística de ADEUDOS (hasta año/periodo especificado)
    SELECT
        COUNT(DISTINCT loc.id_local),
        NVL(SUM(ade.importe), 0),
        COUNT(ade.id_adeudo_local)
    INTO
        v_locales_adeudo,
        v_importe_adeudo,
        v_periodos_adeudo
    FROM ta_11_locales loc
    LEFT OUTER JOIN ta_11_adeudo_local ade
        ON ade.id_local = loc.id_local
        AND (
            (ade.axo = p_axo AND ade.periodo <= p_periodo)
            OR (ade.axo < p_axo)
        )
    WHERE loc.oficina = p_oficina
      AND loc.num_mercado = v_num_mercado
      AND loc.vigencia = 'A'
      AND ade.id_adeudo_local IS NOT NULL;

    -- Si no hay registros, asignar 0
    IF v_locales_adeudo IS NULL THEN
        LET v_locales_adeudo = 0;
        LET v_importe_adeudo = 0;
        LET v_periodos_adeudo = 0;
    END IF;

    -- Retornar la fila consolidada
    RETURN
        v_num_mercado,
        v_descripcion,
        v_locales_pagados,
        v_importe_pagado,
        v_periodos_pagados,
        v_locales_capturados,
        v_importe_capturado,
        v_periodos_capturados,
        v_locales_adeudo,
        v_importe_adeudo,
        v_periodos_adeudo
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_ESTAD_MERCADO_DETALLE
-- Descripción: Detalle de pagos y adeudos por local de un mercado
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ESTAD_MERCADO_DETALLE(
    p_oficina SMALLINT,
    p_mercado SMALLINT
)

RETURNING
    INT AS id_local,
    VARCHAR(30) AS nombre,
    DECIMAL(14,2) AS total_pagado,
    DECIMAL(14,2) AS total_adeudo,
    INT AS periodos_pagados,
    INT AS periodos_adeudo;

DEFINE v_id_local INT;
DEFINE v_nombre VARCHAR(30);
DEFINE v_total_pagado DECIMAL(14,2);
DEFINE v_total_adeudo DECIMAL(14,2);
DEFINE v_periodos_pagados INT;
DEFINE v_periodos_adeudo INT;

FOREACH
    SELECT
        id_local,
        TRIM(nombre)
    INTO
        v_id_local,
        v_nombre
    FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_mercado
    ORDER BY local, letra_local, bloque

    -- Calcular total pagado
    SELECT NVL(SUM(importe_pago), 0)
    INTO v_total_pagado
    FROM ta_11_pagos_local
    WHERE id_local = v_id_local;

    -- Calcular total adeudo
    SELECT NVL(SUM(importe), 0)
    INTO v_total_adeudo
    FROM ta_11_adeudo_local
    WHERE id_local = v_id_local;

    -- Contar periodos pagados
    SELECT COUNT(*)
    INTO v_periodos_pagados
    FROM ta_11_pagos_local
    WHERE id_local = v_id_local;

    -- Contar periodos con adeudo
    SELECT COUNT(*)
    INTO v_periodos_adeudo
    FROM ta_11_adeudo_local
    WHERE id_local = v_id_local;

    RETURN
        v_id_local,
        v_nombre,
        v_total_pagado,
        v_total_adeudo,
        v_periodos_pagados,
        v_periodos_adeudo
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA ESTADÍSTICAS PAGOS Y ADEUDOS
-- =============================================
