-- =============================================
-- SP_MERCADOS_GET_PAGOS_ENERGIA_CAPTURADOS
-- Obtener pagos de energía capturados
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_PAGOS_ENERGIA_CAPTURADOS(
    p_id_energia INTEGER,
    p_mercado VARCHAR(10),
    p_categoria INTEGER,
    p_seccion VARCHAR(10),
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNING
    INTEGER AS id_pago_energia,
    INTEGER AS id_adeudo_energia,
    INTEGER AS id_local_energia,
    VARCHAR(10) AS oficina,
    VARCHAR(10) AS mercado,
    INTEGER AS categoria,
    VARCHAR(10) AS seccion,
    VARCHAR(20) AS local,
    INTEGER AS anio,
    INTEGER AS periodo,
    DECIMAL(12,2) AS importe,
    VARCHAR(20) AS partida,
    DATE AS fecha_pago,
    DATE AS fecha_captura,
    VARCHAR(50) AS usuario_captura,
    VARCHAR(100) AS nombre_mercado,
    VARCHAR(30) AS descripcion_categoria;

    DEFINE v_id_pago_energia INTEGER;
    DEFINE v_id_adeudo_energia INTEGER;
    DEFINE v_id_local_energia INTEGER;
    DEFINE v_oficina VARCHAR(10);
    DEFINE v_mercado VARCHAR(10);
    DEFINE v_categoria INTEGER;
    DEFINE v_seccion VARCHAR(10);
    DEFINE v_local VARCHAR(20);
    DEFINE v_anio INTEGER;
    DEFINE v_periodo INTEGER;
    DEFINE v_importe DECIMAL(12,2);
    DEFINE v_partida VARCHAR(20);
    DEFINE v_fecha_pago DATE;
    DEFINE v_fecha_captura DATE;
    DEFINE v_usuario_captura VARCHAR(50);
    DEFINE v_nombre_mercado VARCHAR(100);
    DEFINE v_descripcion_categoria VARCHAR(30);

    FOREACH
        SELECT
            pe.id_pago_energia,
            pe.id_adeudo_energia,
            ae.id_local_energia,
            le.oficina,
            le.mercado,
            le.categoria,
            le.seccion,
            le.local,
            ae.anio,
            ae.periodo,
            pe.importe,
            pe.partida,
            pe.fecha_pago,
            pe.fecha_captura,
            pe.usuario_captura,
            m.nombre AS nombre_mercado,
            cm.descripcion AS descripcion_categoria
        INTO
            v_id_pago_energia,
            v_id_adeudo_energia,
            v_id_local_energia,
            v_oficina,
            v_mercado,
            v_categoria,
            v_seccion,
            v_local,
            v_anio,
            v_periodo,
            v_importe,
            v_partida,
            v_fecha_pago,
            v_fecha_captura,
            v_usuario_captura,
            v_nombre_mercado,
            v_descripcion_categoria
        FROM pagos_energia pe
        INNER JOIN adeudos_energia ae ON pe.id_adeudo_energia = ae.id_adeudo_energia
        INNER JOIN locales_energia le ON ae.id_local_energia = le.id_local_energia
        LEFT JOIN mercados m ON le.mercado = m.mercado
        LEFT JOIN categorias_mercados cm ON le.categoria = cm.categoria
        WHERE (p_id_energia IS NULL OR le.id_local_energia = p_id_energia)
          AND (p_mercado IS NULL OR p_mercado = '' OR le.mercado = p_mercado)
          AND (p_categoria IS NULL OR p_categoria = 0 OR le.categoria = p_categoria)
          AND (p_seccion IS NULL OR p_seccion = '' OR le.seccion = p_seccion)
          AND (p_fecha_desde IS NULL OR pe.fecha_captura >= p_fecha_desde)
          AND (p_fecha_hasta IS NULL OR pe.fecha_captura <= p_fecha_hasta)
        ORDER BY pe.fecha_captura DESC, le.mercado, le.local

        RETURN
            v_id_pago_energia,
            v_id_adeudo_energia,
            v_id_local_energia,
            v_oficina,
            v_mercado,
            v_categoria,
            v_seccion,
            v_local,
            v_anio,
            v_periodo,
            v_importe,
            v_partida,
            v_fecha_pago,
            v_fecha_captura,
            v_usuario_captura,
            v_nombre_mercado,
            v_descripcion_categoria
        WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_ENERGIA_BY_ID
-- Obtener datos de un local de energía por ID
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_ENERGIA_BY_ID(
    p_id_local_energia INTEGER
)
RETURNING
    INTEGER AS id_local_energia,
    VARCHAR(10) AS oficina,
    VARCHAR(10) AS mercado,
    INTEGER AS categoria,
    VARCHAR(10) AS seccion,
    VARCHAR(20) AS local,
    VARCHAR(100) AS nombre_mercado,
    VARCHAR(30) AS descripcion_categoria;

    DEFINE v_id_local_energia INTEGER;
    DEFINE v_oficina VARCHAR(10);
    DEFINE v_mercado VARCHAR(10);
    DEFINE v_categoria INTEGER;
    DEFINE v_seccion VARCHAR(10);
    DEFINE v_local VARCHAR(20);
    DEFINE v_nombre_mercado VARCHAR(100);
    DEFINE v_descripcion_categoria VARCHAR(30);

    SELECT
        le.id_local_energia,
        le.oficina,
        le.mercado,
        le.categoria,
        le.seccion,
        le.local,
        m.nombre AS nombre_mercado,
        cm.descripcion AS descripcion_categoria
    INTO
        v_id_local_energia,
        v_oficina,
        v_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_nombre_mercado,
        v_descripcion_categoria
    FROM locales_energia le
    LEFT JOIN mercados m ON le.mercado = m.mercado
    LEFT JOIN categorias_mercados cm ON le.categoria = cm.categoria
    WHERE le.id_local_energia = p_id_local_energia;

    RETURN
        v_id_local_energia,
        v_oficina,
        v_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_nombre_mercado,
        v_descripcion_categoria;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_DELETE_PAGO_ENERGIA
-- Eliminar un pago de energía capturado
-- =============================================
CREATE PROCEDURE SP_MERCADOS_DELETE_PAGO_ENERGIA(
    p_id_pago_energia INTEGER
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje,
    INTEGER AS id_adeudo_energia;

    DEFINE v_id_adeudo_energia INTEGER;
    DEFINE v_count INTEGER;

    -- Verificar que el pago existe
    SELECT COUNT(*)
    INTO v_count
    FROM pagos_energia
    WHERE id_pago_energia = p_id_pago_energia;

    IF v_count = 0 THEN
        RETURN 0, 'El pago de energía no existe', NULL;
    END IF;

    -- Obtener el id_adeudo_energia antes de eliminar
    SELECT id_adeudo_energia
    INTO v_id_adeudo_energia
    FROM pagos_energia
    WHERE id_pago_energia = p_id_pago_energia;

    -- Eliminar el pago
    DELETE FROM pagos_energia
    WHERE id_pago_energia = p_id_pago_energia;

    RETURN 1, 'Pago de energía eliminado correctamente', v_id_adeudo_energia;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_RESTORE_ADEUDO_ENERGIA
-- Restaurar un adeudo de energía al eliminar pago
-- =============================================
CREATE PROCEDURE SP_MERCADOS_RESTORE_ADEUDO_ENERGIA(
    p_id_adeudo_energia INTEGER
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje;

    DEFINE v_count INTEGER;

    -- Verificar que el adeudo existe
    SELECT COUNT(*)
    INTO v_count
    FROM adeudos_energia
    WHERE id_adeudo_energia = p_id_adeudo_energia;

    IF v_count = 0 THEN
        RETURN 0, 'El adeudo de energía no existe';
    END IF;

    -- Actualizar el adeudo para restaurarlo
    UPDATE adeudos_energia
    SET fecha_pago = NULL,
        pagado = 'N'
    WHERE id_adeudo_energia = p_id_adeudo_energia;

    RETURN 1, 'Adeudo de energía restaurado correctamente';

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_DETALLE_PAGO_ENERGIA
-- Obtener detalle completo de un pago de energía
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_DETALLE_PAGO_ENERGIA(
    p_id_pago_energia INTEGER
)
RETURNING
    INTEGER AS id_pago_energia,
    INTEGER AS id_adeudo_energia,
    INTEGER AS id_local_energia,
    VARCHAR(10) AS oficina,
    VARCHAR(10) AS mercado,
    INTEGER AS categoria,
    VARCHAR(10) AS seccion,
    VARCHAR(20) AS local,
    INTEGER AS anio,
    INTEGER AS periodo,
    DECIMAL(12,2) AS importe,
    VARCHAR(20) AS partida,
    DATE AS fecha_pago,
    DATE AS fecha_captura,
    VARCHAR(50) AS usuario_captura,
    VARCHAR(100) AS nombre_mercado,
    VARCHAR(30) AS descripcion_categoria,
    VARCHAR(100) AS nombre_titular;

    DEFINE v_id_pago_energia INTEGER;
    DEFINE v_id_adeudo_energia INTEGER;
    DEFINE v_id_local_energia INTEGER;
    DEFINE v_oficina VARCHAR(10);
    DEFINE v_mercado VARCHAR(10);
    DEFINE v_categoria INTEGER;
    DEFINE v_seccion VARCHAR(10);
    DEFINE v_local VARCHAR(20);
    DEFINE v_anio INTEGER;
    DEFINE v_periodo INTEGER;
    DEFINE v_importe DECIMAL(12,2);
    DEFINE v_partida VARCHAR(20);
    DEFINE v_fecha_pago DATE;
    DEFINE v_fecha_captura DATE;
    DEFINE v_usuario_captura VARCHAR(50);
    DEFINE v_nombre_mercado VARCHAR(100);
    DEFINE v_descripcion_categoria VARCHAR(30);
    DEFINE v_nombre_titular VARCHAR(100);

    SELECT
        pe.id_pago_energia,
        pe.id_adeudo_energia,
        ae.id_local_energia,
        le.oficina,
        le.mercado,
        le.categoria,
        le.seccion,
        le.local,
        ae.anio,
        ae.periodo,
        pe.importe,
        pe.partida,
        pe.fecha_pago,
        pe.fecha_captura,
        pe.usuario_captura,
        m.nombre AS nombre_mercado,
        cm.descripcion AS descripcion_categoria,
        le.nombre_titular
    INTO
        v_id_pago_energia,
        v_id_adeudo_energia,
        v_id_local_energia,
        v_oficina,
        v_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_anio,
        v_periodo,
        v_importe,
        v_partida,
        v_fecha_pago,
        v_fecha_captura,
        v_usuario_captura,
        v_nombre_mercado,
        v_descripcion_categoria,
        v_nombre_titular
    FROM pagos_energia pe
    INNER JOIN adeudos_energia ae ON pe.id_adeudo_energia = ae.id_adeudo_energia
    INNER JOIN locales_energia le ON ae.id_local_energia = le.id_local_energia
    LEFT JOIN mercados m ON le.mercado = m.mercado
    LEFT JOIN categorias_mercados cm ON le.categoria = cm.categoria
    WHERE pe.id_pago_energia = p_id_pago_energia;

    RETURN
        v_id_pago_energia,
        v_id_adeudo_energia,
        v_id_local_energia,
        v_oficina,
        v_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_anio,
        v_periodo,
        v_importe,
        v_partida,
        v_fecha_pago,
        v_fecha_captura,
        v_usuario_captura,
        v_nombre_mercado,
        v_descripcion_categoria,
        v_nombre_titular;

END PROCEDURE;
