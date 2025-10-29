-- =============================================
-- SP_MERCADOS_GET_ADEUDOS_ENERGIA_CARGA
-- Buscar adeudos de energía para carga de pagos
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_ADEUDOS_ENERGIA_CARGA(
    p_oficina VARCHAR(10),
    p_mercado VARCHAR(10),
    p_categoria VARCHAR(10),
    p_seccion VARCHAR(10),
    p_local VARCHAR(20)
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
        AND (p_local IS NULL OR p_local = '' OR le.local_num = p_local)
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
-- SP_MERCADOS_GET_CAJAS_BY_OFICINA
-- Obtener cajas disponibles por oficina
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_CAJAS_BY_OFICINA(
    p_oficina VARCHAR(10)
)
RETURNING
    VARCHAR(10) AS caja,
    VARCHAR(100) AS descripcion;

    DEFINE v_caja VARCHAR(10);
    DEFINE v_descripcion VARCHAR(100);

    FOREACH
        SELECT
            caja,
            descripcion
        INTO
            v_caja,
            v_descripcion
        FROM cajas
        WHERE oficina = p_oficina
        AND activa = 1
        ORDER BY caja

        RETURN v_caja, v_descripcion WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_INSERT_PAGO_ENERGIA
-- Insertar pago de energía
-- =============================================
CREATE PROCEDURE SP_MERCADOS_INSERT_PAGO_ENERGIA(
    p_id_adeudo_energia INTEGER,
    p_fecha_pago DATE,
    p_oficina_pago VARCHAR(10),
    p_caja_pago VARCHAR(10),
    p_operacion_pago VARCHAR(20),
    p_folio_pago VARCHAR(20),
    p_partida VARCHAR(20),
    p_id_usuario INTEGER
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje;

    DEFINE v_id_pago_energia INTEGER;
    DEFINE v_importe DECIMAL(12,2);
    DEFINE v_id_local_energia INTEGER;
    DEFINE v_anio INTEGER;
    DEFINE v_mes INTEGER;
    DEFINE v_ya_pagado INTEGER;

    -- Verificar si el adeudo existe y no está pagado
    SELECT COUNT(*), importe, id_local_energia, anio, mes
    INTO v_ya_pagado, v_importe, v_id_local_energia, v_anio, v_mes
    FROM adeudos_energia
    WHERE id_adeudo_energia = p_id_adeudo_energia
    AND pagado = 0;

    IF v_ya_pagado = 0 THEN
        RETURN 0, 'El adeudo no existe o ya está pagado';
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
        folio_pago,
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
        p_folio_pago,
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

    RETURN 1, 'Pago registrado correctamente';

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_CARGAR_PAGOS_ENERGIA_BATCH
-- Cargar múltiples pagos de energía en lote
-- =============================================
CREATE PROCEDURE SP_MERCADOS_CARGAR_PAGOS_ENERGIA_BATCH(
    p_adeudos_ids VARCHAR(2000), -- IDs separados por comas
    p_partidas VARCHAR(2000), -- Partidas separadas por comas
    p_fecha_pago DATE,
    p_oficina_pago VARCHAR(10),
    p_caja_pago VARCHAR(10),
    p_operacion_pago VARCHAR(20),
    p_folio_pago VARCHAR(20),
    p_id_usuario INTEGER
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje,
    INTEGER AS pagos_cargados;

    DEFINE v_contador INTEGER;
    DEFINE v_errores INTEGER;

    LET v_contador = 0;
    LET v_errores = 0;

    -- Esta es una versión simplificada
    -- En producción, se procesaría cada ID y partida individualmente
    RETURN 1, 'Batch processing no implementado en esta versión', 0;

END PROCEDURE;
