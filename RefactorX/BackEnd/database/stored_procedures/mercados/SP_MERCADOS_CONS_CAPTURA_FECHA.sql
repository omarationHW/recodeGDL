-- =============================================
-- SP_MERCADOS_GET_PAGOS_LOCALES_CAPTURADOS
-- Obtener pagos de locales capturados por fecha
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_PAGOS_LOCALES_CAPTURADOS(
    p_oficina VARCHAR(10),
    p_caja VARCHAR(10),
    p_operacion VARCHAR(20),
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNING
    INTEGER AS id_pago_local,
    INTEGER AS id_adeudo_local,
    INTEGER AS id_local,
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
    VARCHAR(10) AS caja,
    VARCHAR(20) AS operacion,
    VARCHAR(100) AS nombre_mercado,
    VARCHAR(30) AS descripcion_categoria;

    DEFINE v_id_pago_local INTEGER;
    DEFINE v_id_adeudo_local INTEGER;
    DEFINE v_id_local INTEGER;
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
    DEFINE v_caja VARCHAR(10);
    DEFINE v_operacion VARCHAR(20);
    DEFINE v_nombre_mercado VARCHAR(100);
    DEFINE v_descripcion_categoria VARCHAR(30);

    FOREACH
        SELECT
            pl.id_pago_local,
            pl.id_adeudo_local,
            al.id_local,
            l.oficina,
            l.mercado,
            l.categoria,
            l.seccion,
            l.local,
            al.anio,
            al.periodo,
            pl.importe,
            pl.partida,
            pl.fecha_pago,
            pl.fecha_captura,
            pl.usuario_captura,
            pl.caja,
            pl.operacion,
            m.nombre AS nombre_mercado,
            cm.descripcion AS descripcion_categoria
        INTO
            v_id_pago_local,
            v_id_adeudo_local,
            v_id_local,
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
            v_caja,
            v_operacion,
            v_nombre_mercado,
            v_descripcion_categoria
        FROM pagos_locales pl
        INNER JOIN adeudos_locales al ON pl.id_adeudo_local = al.id_adeudo_local
        INNER JOIN locales l ON al.id_local = l.id_local
        LEFT JOIN mercados m ON l.mercado = m.mercado
        LEFT JOIN categorias_mercados cm ON l.categoria = cm.categoria
        WHERE (p_oficina IS NULL OR p_oficina = '' OR l.oficina = p_oficina)
          AND (p_caja IS NULL OR p_caja = '' OR pl.caja = p_caja)
          AND (p_operacion IS NULL OR p_operacion = '' OR pl.operacion = p_operacion)
          AND (p_fecha_desde IS NULL OR pl.fecha_captura >= p_fecha_desde)
          AND (p_fecha_hasta IS NULL OR pl.fecha_captura <= p_fecha_hasta)
        ORDER BY pl.fecha_captura DESC, l.mercado, l.local

        RETURN
            v_id_pago_local,
            v_id_adeudo_local,
            v_id_local,
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
            v_caja,
            v_operacion,
            v_nombre_mercado,
            v_descripcion_categoria
        WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_DELETE_PAGO_LOCAL
-- Eliminar un pago de local capturado
-- =============================================
CREATE PROCEDURE SP_MERCADOS_DELETE_PAGO_LOCAL(
    p_id_pago_local INTEGER
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje,
    INTEGER AS id_adeudo_local;

    DEFINE v_id_adeudo_local INTEGER;
    DEFINE v_count INTEGER;

    -- Verificar que el pago existe
    SELECT COUNT(*)
    INTO v_count
    FROM pagos_locales
    WHERE id_pago_local = p_id_pago_local;

    IF v_count = 0 THEN
        RETURN 0, 'El pago de local no existe', NULL;
    END IF;

    -- Obtener el id_adeudo_local antes de eliminar
    SELECT id_adeudo_local
    INTO v_id_adeudo_local
    FROM pagos_locales
    WHERE id_pago_local = p_id_pago_local;

    -- Eliminar el pago
    DELETE FROM pagos_locales
    WHERE id_pago_local = p_id_pago_local;

    RETURN 1, 'Pago de local eliminado correctamente', v_id_adeudo_local;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_RESTORE_ADEUDO_LOCAL
-- Restaurar un adeudo de local al eliminar pago
-- =============================================
CREATE PROCEDURE SP_MERCADOS_RESTORE_ADEUDO_LOCAL(
    p_id_adeudo_local INTEGER
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje;

    DEFINE v_count INTEGER;

    -- Verificar que el adeudo existe
    SELECT COUNT(*)
    INTO v_count
    FROM adeudos_locales
    WHERE id_adeudo_local = p_id_adeudo_local;

    IF v_count = 0 THEN
        RETURN 0, 'El adeudo de local no existe';
    END IF;

    -- Actualizar el adeudo para restaurarlo
    UPDATE adeudos_locales
    SET fecha_pago = NULL,
        pagado = 'N',
        fecha_ingreso = NULL
    WHERE id_adeudo_local = p_id_adeudo_local;

    RETURN 1, 'Adeudo de local restaurado correctamente';

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_DELETE_PAGOS_LOCALES_BATCH
-- Eliminar múltiples pagos de locales en lote
-- =============================================
CREATE PROCEDURE SP_MERCADOS_DELETE_PAGOS_LOCALES_BATCH(
    p_id_pago_local INTEGER
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje;

    DEFINE v_id_adeudo_local INTEGER;
    DEFINE v_count INTEGER;
    DEFINE v_resultado INTEGER;
    DEFINE v_mensaje VARCHAR(255);

    -- Verificar que el pago existe
    SELECT COUNT(*)
    INTO v_count
    FROM pagos_locales
    WHERE id_pago_local = p_id_pago_local;

    IF v_count = 0 THEN
        RETURN 0, 'El pago ' || p_id_pago_local || ' no existe';
    END IF;

    -- Obtener el id_adeudo_local
    SELECT id_adeudo_local
    INTO v_id_adeudo_local
    FROM pagos_locales
    WHERE id_pago_local = p_id_pago_local;

    -- Eliminar el pago
    DELETE FROM pagos_locales
    WHERE id_pago_local = p_id_pago_local;

    -- Restaurar el adeudo
    UPDATE adeudos_locales
    SET fecha_pago = NULL,
        pagado = 'N',
        fecha_ingreso = NULL
    WHERE id_adeudo_local = v_id_adeudo_local;

    RETURN 1, 'Pago ' || p_id_pago_local || ' eliminado y adeudo restaurado';

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_DETALLE_PAGO_LOCAL
-- Obtener detalle completo de un pago de local
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_DETALLE_PAGO_LOCAL(
    p_id_pago_local INTEGER
)
RETURNING
    INTEGER AS id_pago_local,
    INTEGER AS id_adeudo_local,
    INTEGER AS id_local,
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
    VARCHAR(10) AS caja,
    VARCHAR(20) AS operacion,
    VARCHAR(100) AS nombre_mercado,
    VARCHAR(30) AS descripcion_categoria,
    VARCHAR(100) AS nombre_titular;

    DEFINE v_id_pago_local INTEGER;
    DEFINE v_id_adeudo_local INTEGER;
    DEFINE v_id_local INTEGER;
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
    DEFINE v_caja VARCHAR(10);
    DEFINE v_operacion VARCHAR(20);
    DEFINE v_nombre_mercado VARCHAR(100);
    DEFINE v_descripcion_categoria VARCHAR(30);
    DEFINE v_nombre_titular VARCHAR(100);

    SELECT
        pl.id_pago_local,
        pl.id_adeudo_local,
        al.id_local,
        l.oficina,
        l.mercado,
        l.categoria,
        l.seccion,
        l.local,
        al.anio,
        al.periodo,
        pl.importe,
        pl.partida,
        pl.fecha_pago,
        pl.fecha_captura,
        pl.usuario_captura,
        pl.caja,
        pl.operacion,
        m.nombre AS nombre_mercado,
        cm.descripcion AS descripcion_categoria,
        l.nombre_titular
    INTO
        v_id_pago_local,
        v_id_adeudo_local,
        v_id_local,
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
        v_caja,
        v_operacion,
        v_nombre_mercado,
        v_descripcion_categoria,
        v_nombre_titular
    FROM pagos_locales pl
    INNER JOIN adeudos_locales al ON pl.id_adeudo_local = al.id_adeudo_local
    INNER JOIN locales l ON al.id_local = l.id_local
    LEFT JOIN mercados m ON l.mercado = m.mercado
    LEFT JOIN categorias_mercados cm ON l.categoria = cm.categoria
    WHERE pl.id_pago_local = p_id_pago_local;

    RETURN
        v_id_pago_local,
        v_id_adeudo_local,
        v_id_local,
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
        v_caja,
        v_operacion,
        v_nombre_mercado,
        v_descripcion_categoria,
        v_nombre_titular;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_ESTADISTICAS_PAGOS_FECHA
-- Obtener estadísticas de pagos capturados por fecha
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_ESTADISTICAS_PAGOS_FECHA(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNING
    INTEGER AS total_pagos,
    DECIMAL(12,2) AS importe_total,
    INTEGER AS total_locales_distintos;

    DEFINE v_total_pagos INTEGER;
    DEFINE v_importe_total DECIMAL(12,2);
    DEFINE v_total_locales_distintos INTEGER;

    -- Contar pagos y sumar importes
    SELECT
        COUNT(*),
        COALESCE(SUM(importe), 0),
        COUNT(DISTINCT id_adeudo_local)
    INTO
        v_total_pagos,
        v_importe_total,
        v_total_locales_distintos
    FROM pagos_locales
    WHERE (p_fecha_desde IS NULL OR fecha_captura >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR fecha_captura <= p_fecha_hasta);

    RETURN v_total_pagos, v_importe_total, v_total_locales_distintos;

END PROCEDURE;
