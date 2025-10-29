-- =============================================
-- SP_MERCADOS_GET_ADEUDOS_ENERGIA_RANGO
-- Buscar adeudos de energía por rango de locales
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_ADEUDOS_ENERGIA_RANGO(
    p_oficina VARCHAR(10),
    p_mercado VARCHAR(10),
    p_categoria VARCHAR(10),
    p_seccion VARCHAR(10),
    p_local_desde VARCHAR(20),
    p_local_hasta VARCHAR(20)
)
RETURNING
    INTEGER AS id_adeudo_energia,
    INTEGER AS id_local_energia,
    VARCHAR(10) AS oficina,
    VARCHAR(10) AS mercado,
    VARCHAR(10) AS categoria,
    VARCHAR(10) AS seccion,
    VARCHAR(20) AS local_num,
    VARCHAR(5) AS letra,
    INTEGER AS anio,
    INTEGER AS mes,
    DECIMAL(12,2) AS importe,
    DATE AS fecha_vencimiento,
    VARCHAR(100) AS nombre_titular;

    DEFINE v_id_adeudo_energia INTEGER;
    DEFINE v_id_local_energia INTEGER;
    DEFINE v_oficina VARCHAR(10);
    DEFINE v_mercado VARCHAR(10);
    DEFINE v_categoria VARCHAR(10);
    DEFINE v_seccion VARCHAR(10);
    DEFINE v_local_num VARCHAR(20);
    DEFINE v_letra VARCHAR(5);
    DEFINE v_anio INTEGER;
    DEFINE v_mes INTEGER;
    DEFINE v_importe DECIMAL(12,2);
    DEFINE v_fecha_vencimiento DATE;
    DEFINE v_nombre_titular VARCHAR(100);

    FOREACH
        SELECT
            ae.id_adeudo_energia,
            ae.id_local_energia,
            le.oficina,
            le.mercado,
            le.categoria,
            le.seccion,
            le.local_num,
            le.letra,
            ae.anio,
            ae.mes,
            ae.importe,
            ae.fecha_vencimiento,
            le.nombre_titular
        INTO
            v_id_adeudo_energia,
            v_id_local_energia,
            v_oficina,
            v_mercado,
            v_categoria,
            v_seccion,
            v_local_num,
            v_letra,
            v_anio,
            v_mes,
            v_importe,
            v_fecha_vencimiento,
            v_nombre_titular
        FROM adeudos_energia ae
        INNER JOIN locales_energia le ON ae.id_local_energia = le.id_local_energia
        WHERE ae.pagado = 0
        AND (p_oficina IS NULL OR p_oficina = '' OR le.oficina = p_oficina)
        AND (p_mercado IS NULL OR p_mercado = '' OR le.mercado = p_mercado)
        AND (p_categoria IS NULL OR p_categoria = '' OR le.categoria = p_categoria)
        AND (p_seccion IS NULL OR p_seccion = '' OR le.seccion = p_seccion)
        AND (p_local_desde IS NULL OR p_local_desde = '' OR le.local_num >= p_local_desde)
        AND (p_local_hasta IS NULL OR p_local_hasta = '' OR le.local_num <= p_local_hasta)
        ORDER BY le.oficina, le.mercado, le.categoria, le.seccion, le.local_num, ae.anio, ae.mes

        RETURN
            v_id_adeudo_energia,
            v_id_local_energia,
            v_oficina,
            v_mercado,
            v_categoria,
            v_seccion,
            v_local_num,
            v_letra,
            v_anio,
            v_mes,
            v_importe,
            v_fecha_vencimiento,
            v_nombre_titular
        WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_CARGAR_PAGO_ENERGIA_CON_PARTIDA
-- Cargar pago de energía individual con número de partida
-- =============================================
CREATE PROCEDURE SP_MERCADOS_CARGAR_PAGO_ENERGIA_CON_PARTIDA(
    p_id_adeudo_energia INTEGER,
    p_partida VARCHAR(20),
    p_fecha_pago DATE,
    p_oficina_pago VARCHAR(10),
    p_caja_pago VARCHAR(10),
    p_operacion_pago VARCHAR(20),
    p_id_usuario INTEGER
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje,
    INTEGER AS id_pago;

    DEFINE v_id_pago_energia INTEGER;
    DEFINE v_importe DECIMAL(12,2);
    DEFINE v_id_local_energia INTEGER;
    DEFINE v_anio INTEGER;
    DEFINE v_mes INTEGER;
    DEFINE v_ya_pagado INTEGER;

    -- Validar partida
    IF p_partida IS NULL OR p_partida = '' OR p_partida = '0' THEN
        RETURN 0, 'Número de partida inválido', 0;
    END IF;

    -- Verificar si el adeudo existe y no está pagado
    SELECT COUNT(*), importe, id_local_energia, anio, mes
    INTO v_ya_pagado, v_importe, v_id_local_energia, v_anio, v_mes
    FROM adeudos_energia
    WHERE id_adeudo_energia = p_id_adeudo_energia
    AND pagado = 0;

    IF v_ya_pagado = 0 THEN
        RETURN 0, 'El adeudo no existe o ya está pagado', 0;
    END IF;

    -- Insertar pago
    INSERT INTO pagos_energia (
        id_local_energia,
        anio,
        mes,
        fecha_pago,
        oficina_pago,
        caja_pago,
        operacion_pago,
        partida,
        importe,
        id_usuario,
        fecha_registro
    ) VALUES (
        v_id_local_energia,
        v_anio,
        v_mes,
        p_fecha_pago,
        p_oficina_pago,
        p_caja_pago,
        p_operacion_pago,
        p_partida,
        v_importe,
        p_id_usuario,
        CURRENT
    );

    SELECT MAX(id_pago_energia) INTO v_id_pago_energia FROM pagos_energia;

    -- Actualizar adeudo como pagado
    UPDATE adeudos_energia
    SET pagado = 1,
        id_pago = v_id_pago_energia,
        fecha_pago = p_fecha_pago
    WHERE id_adeudo_energia = p_id_adeudo_energia;

    RETURN 1, 'Pago cargado correctamente con partida ' || p_partida, v_id_pago_energia;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_VALIDAR_RANGO_LOCALES
-- Validar que el rango de locales sea válido
-- =============================================
CREATE PROCEDURE SP_MERCADOS_VALIDAR_RANGO_LOCALES(
    p_oficina VARCHAR(10),
    p_mercado VARCHAR(10),
    p_categoria VARCHAR(10),
    p_seccion VARCHAR(10),
    p_local_desde VARCHAR(20),
    p_local_hasta VARCHAR(20)
)
RETURNING
    INTEGER AS valido,
    VARCHAR(255) AS mensaje,
    INTEGER AS total_locales;

    DEFINE v_count_desde INTEGER;
    DEFINE v_count_hasta INTEGER;
    DEFINE v_total_locales INTEGER;

    -- Verificar que el local "desde" existe
    SELECT COUNT(*)
    INTO v_count_desde
    FROM locales_energia
    WHERE oficina = p_oficina
    AND mercado = p_mercado
    AND categoria = p_categoria
    AND seccion = p_seccion
    AND local_num = p_local_desde;

    IF v_count_desde = 0 THEN
        RETURN 0, 'El local inicial "' || p_local_desde || '" no existe', 0;
    END IF;

    -- Verificar que el local "hasta" existe
    SELECT COUNT(*)
    INTO v_count_hasta
    FROM locales_energia
    WHERE oficina = p_oficina
    AND mercado = p_mercado
    AND categoria = p_categoria
    AND seccion = p_seccion
    AND local_num = p_local_hasta;

    IF v_count_hasta = 0 THEN
        RETURN 0, 'El local final "' || p_local_hasta || '" no existe', 0;
    END IF;

    -- Contar cuántos locales hay en el rango
    SELECT COUNT(*)
    INTO v_total_locales
    FROM locales_energia
    WHERE oficina = p_oficina
    AND mercado = p_mercado
    AND categoria = p_categoria
    AND seccion = p_seccion
    AND local_num >= p_local_desde
    AND local_num <= p_local_hasta;

    RETURN 1, 'Rango válido con ' || v_total_locales || ' locales', v_total_locales;

END PROCEDURE;
