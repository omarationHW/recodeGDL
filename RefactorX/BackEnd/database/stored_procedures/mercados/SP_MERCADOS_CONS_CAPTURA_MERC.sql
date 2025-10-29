-- =============================================
-- SP_MERCADOS_GET_PAGOS_BY_MERCADO
-- Obtener pagos de locales capturados por mercado
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_PAGOS_BY_MERCADO(
    p_oficina VARCHAR(10),
    p_mercado VARCHAR(10),
    p_categoria INTEGER,
    p_seccion VARCHAR(10),
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
    DEFINE v_nombre_mercado VARCHAR(100);
    DEFINE v_descripcion_categoria VARCHAR(30);
    DEFINE v_nombre_titular VARCHAR(100);

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
            v_nombre_mercado,
            v_descripcion_categoria,
            v_nombre_titular
        FROM pagos_locales pl
        INNER JOIN adeudos_locales al ON pl.id_adeudo_local = al.id_adeudo_local
        INNER JOIN locales l ON al.id_local = l.id_local
        LEFT JOIN mercados m ON l.mercado = m.mercado
        LEFT JOIN categorias_mercados cm ON l.categoria = cm.categoria
        WHERE (p_oficina IS NULL OR p_oficina = '' OR l.oficina = p_oficina)
          AND (p_mercado IS NULL OR p_mercado = '' OR l.mercado = p_mercado)
          AND (p_categoria IS NULL OR p_categoria = 0 OR l.categoria = p_categoria)
          AND (p_seccion IS NULL OR p_seccion = '' OR l.seccion = p_seccion)
          AND (p_fecha_desde IS NULL OR pl.fecha_captura >= p_fecha_desde)
          AND (p_fecha_hasta IS NULL OR pl.fecha_captura <= p_fecha_hasta)
        ORDER BY l.mercado, l.seccion, l.local, pl.fecha_captura DESC

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
            v_nombre_mercado,
            v_descripcion_categoria,
            v_nombre_titular
        WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_PAGOS_ENERGIA_BY_MERCADO
-- Obtener pagos de energía capturados por mercado
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_PAGOS_ENERGIA_BY_MERCADO(
    p_oficina VARCHAR(10),
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
        WHERE (p_oficina IS NULL OR p_oficina = '' OR le.oficina = p_oficina)
          AND (p_mercado IS NULL OR p_mercado = '' OR le.mercado = p_mercado)
          AND (p_categoria IS NULL OR p_categoria = 0 OR le.categoria = p_categoria)
          AND (p_seccion IS NULL OR p_seccion = '' OR le.seccion = p_seccion)
          AND (p_fecha_desde IS NULL OR pe.fecha_captura >= p_fecha_desde)
          AND (p_fecha_hasta IS NULL OR pe.fecha_captura <= p_fecha_hasta)
        ORDER BY le.mercado, le.seccion, le.local, pe.fecha_captura DESC

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
            v_nombre_titular
        WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_ESTADISTICAS_MERCADO
-- Obtener estadísticas de pagos por mercado
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_ESTADISTICAS_MERCADO(
    p_mercado VARCHAR(10),
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNING
    INTEGER AS total_pagos_locales,
    DECIMAL(12,2) AS importe_locales,
    INTEGER AS total_pagos_energia,
    DECIMAL(12,2) AS importe_energia,
    INTEGER AS total_locales_distintos,
    INTEGER AS total_energia_distintos;

    DEFINE v_total_pagos_locales INTEGER;
    DEFINE v_importe_locales DECIMAL(12,2);
    DEFINE v_total_pagos_energia INTEGER;
    DEFINE v_importe_energia DECIMAL(12,2);
    DEFINE v_total_locales_distintos INTEGER;
    DEFINE v_total_energia_distintos INTEGER;

    -- Estadísticas de pagos de locales
    SELECT
        COUNT(*),
        COALESCE(SUM(pl.importe), 0),
        COUNT(DISTINCT al.id_local)
    INTO
        v_total_pagos_locales,
        v_importe_locales,
        v_total_locales_distintos
    FROM pagos_locales pl
    INNER JOIN adeudos_locales al ON pl.id_adeudo_local = al.id_adeudo_local
    INNER JOIN locales l ON al.id_local = l.id_local
    WHERE (p_mercado IS NULL OR p_mercado = '' OR l.mercado = p_mercado)
      AND (p_fecha_desde IS NULL OR pl.fecha_captura >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR pl.fecha_captura <= p_fecha_hasta);

    -- Estadísticas de pagos de energía
    SELECT
        COUNT(*),
        COALESCE(SUM(pe.importe), 0),
        COUNT(DISTINCT ae.id_local_energia)
    INTO
        v_total_pagos_energia,
        v_importe_energia,
        v_total_energia_distintos
    FROM pagos_energia pe
    INNER JOIN adeudos_energia ae ON pe.id_adeudo_energia = ae.id_adeudo_energia
    INNER JOIN locales_energia le ON ae.id_local_energia = le.id_local_energia
    WHERE (p_mercado IS NULL OR p_mercado = '' OR le.mercado = p_mercado)
      AND (p_fecha_desde IS NULL OR pe.fecha_captura >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR pe.fecha_captura <= p_fecha_hasta);

    RETURN
        v_total_pagos_locales,
        v_importe_locales,
        v_total_pagos_energia,
        v_importe_energia,
        v_total_locales_distintos,
        v_total_energia_distintos;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_RESUMEN_CAPTURAS_MERCADO
-- Obtener resumen de capturas agrupadas por fecha
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_RESUMEN_CAPTURAS_MERCADO(
    p_mercado VARCHAR(10),
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNING
    DATE AS fecha_captura,
    INTEGER AS total_pagos,
    DECIMAL(12,2) AS importe_total,
    VARCHAR(50) AS usuario_captura;

    DEFINE v_fecha_captura DATE;
    DEFINE v_total_pagos INTEGER;
    DEFINE v_importe_total DECIMAL(12,2);
    DEFINE v_usuario_captura VARCHAR(50);

    FOREACH
        SELECT
            pl.fecha_captura,
            COUNT(*),
            SUM(pl.importe),
            pl.usuario_captura
        INTO
            v_fecha_captura,
            v_total_pagos,
            v_importe_total,
            v_usuario_captura
        FROM pagos_locales pl
        INNER JOIN adeudos_locales al ON pl.id_adeudo_local = al.id_adeudo_local
        INNER JOIN locales l ON al.id_local = l.id_local
        WHERE (p_mercado IS NULL OR p_mercado = '' OR l.mercado = p_mercado)
          AND (p_fecha_desde IS NULL OR pl.fecha_captura >= p_fecha_desde)
          AND (p_fecha_hasta IS NULL OR pl.fecha_captura <= p_fecha_hasta)
        GROUP BY pl.fecha_captura, pl.usuario_captura
        ORDER BY pl.fecha_captura DESC

        RETURN
            v_fecha_captura,
            v_total_pagos,
            v_importe_total,
            v_usuario_captura
        WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_SECCIONES_BY_MERCADO_PAGOS
-- Obtener secciones que tienen pagos en un mercado
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_SECCIONES_BY_MERCADO_PAGOS(
    p_mercado VARCHAR(10)
)
RETURNING
    VARCHAR(10) AS seccion;

    DEFINE v_seccion VARCHAR(10);

    FOREACH
        SELECT DISTINCT l.seccion
        INTO v_seccion
        FROM pagos_locales pl
        INNER JOIN adeudos_locales al ON pl.id_adeudo_local = al.id_adeudo_local
        INNER JOIN locales l ON al.id_local = l.id_local
        WHERE l.mercado = p_mercado
        ORDER BY l.seccion

        RETURN v_seccion WITH RESUME;
    END FOREACH;

END PROCEDURE;
