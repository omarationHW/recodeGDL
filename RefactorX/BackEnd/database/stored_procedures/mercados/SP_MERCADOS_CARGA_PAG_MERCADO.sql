-- =============================================
-- SP_MERCADOS_GET_ADEUDOS_LOCALES_CARGA
-- Buscar adeudos de locales para carga de pagos por mercado
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_ADEUDOS_LOCALES_CARGA(
    p_oficina VARCHAR(10),
    p_mercado VARCHAR(10),
    p_categoria VARCHAR(10),
    p_seccion VARCHAR(10),
    p_local VARCHAR(20)
)
RETURNING
    INTEGER AS id_adeudo_local,
    INTEGER AS id_local,
    VARCHAR(10) AS oficina,
    VARCHAR(10) AS mercado,
    VARCHAR(10) AS categoria,
    VARCHAR(10) AS seccion,
    VARCHAR(20) AS local_num,
    VARCHAR(100) AS nombre_titular,
    VARCHAR(50) AS giro,
    INTEGER AS anio,
    INTEGER AS periodo,
    DECIMAL(12,2) AS importe,
    DECIMAL(12,2) AS recargos,
    DECIMAL(12,2) AS total,
    DATE AS fecha_vencimiento,
    VARCHAR(50) AS concepto;

    DEFINE v_id_adeudo_local INTEGER;
    DEFINE v_id_local INTEGER;
    DEFINE v_oficina VARCHAR(10);
    DEFINE v_mercado VARCHAR(10);
    DEFINE v_categoria VARCHAR(10);
    DEFINE v_seccion VARCHAR(10);
    DEFINE v_local_num VARCHAR(20);
    DEFINE v_nombre_titular VARCHAR(100);
    DEFINE v_giro VARCHAR(50);
    DEFINE v_anio INTEGER;
    DEFINE v_periodo INTEGER;
    DEFINE v_importe DECIMAL(12,2);
    DEFINE v_recargos DECIMAL(12,2);
    DEFINE v_total DECIMAL(12,2);
    DEFINE v_fecha_vencimiento DATE;
    DEFINE v_concepto VARCHAR(50);

    FOREACH
        SELECT
            al.id_adeudo_local,
            al.id_local,
            l.oficina,
            l.mercado,
            l.categoria,
            l.seccion,
            l.local_num,
            l.nombre_titular,
            l.giro,
            al.anio,
            al.periodo,
            al.importe,
            al.recargos,
            (al.importe + al.recargos) AS total,
            al.fecha_vencimiento,
            al.concepto
        INTO
            v_id_adeudo_local,
            v_id_local,
            v_oficina,
            v_mercado,
            v_categoria,
            v_seccion,
            v_local_num,
            v_nombre_titular,
            v_giro,
            v_anio,
            v_periodo,
            v_importe,
            v_recargos,
            v_total,
            v_fecha_vencimiento,
            v_concepto
        FROM adeudos_locales al
        INNER JOIN locales l ON al.id_local = l.id_local
        WHERE al.pagado = 0
        AND (p_oficina IS NULL OR p_oficina = '' OR l.oficina = p_oficina)
        AND (p_mercado IS NULL OR p_mercado = '' OR l.mercado = p_mercado)
        AND (p_categoria IS NULL OR p_categoria = '' OR l.categoria = p_categoria)
        AND (p_seccion IS NULL OR p_seccion = '' OR l.seccion = p_seccion)
        AND (p_local IS NULL OR p_local = '' OR l.local_num = p_local)
        ORDER BY l.oficina, l.mercado, l.categoria, l.seccion, l.local_num, al.anio, al.periodo

        RETURN
            v_id_adeudo_local,
            v_id_local,
            v_oficina,
            v_mercado,
            v_categoria,
            v_seccion,
            v_local_num,
            v_nombre_titular,
            v_giro,
            v_anio,
            v_periodo,
            v_importe,
            v_recargos,
            v_total,
            v_fecha_vencimiento,
            v_concepto
        WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_CARGAR_PAGO_LOCAL
-- Cargar pago de local individual con partida
-- =============================================
CREATE PROCEDURE SP_MERCADOS_CARGAR_PAGO_LOCAL(
    p_id_adeudo_local INTEGER,
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
    INTEGER AS id_pago,
    DECIMAL(12,2) AS importe_pagado;

    DEFINE v_id_pago_local INTEGER;
    DEFINE v_importe DECIMAL(12,2);
    DEFINE v_recargos DECIMAL(12,2);
    DEFINE v_total DECIMAL(12,2);
    DEFINE v_id_local INTEGER;
    DEFINE v_anio INTEGER;
    DEFINE v_periodo INTEGER;
    DEFINE v_ya_pagado INTEGER;

    -- Validar partida
    IF p_partida IS NULL OR p_partida = '' OR p_partida = '0' THEN
        RETURN 0, 'Número de partida inválido', 0, 0;
    END IF;

    -- Verificar si el adeudo existe y no está pagado
    SELECT COUNT(*), importe, recargos, id_local, anio, periodo
    INTO v_ya_pagado, v_importe, v_recargos, v_id_local, v_anio, v_periodo
    FROM adeudos_locales
    WHERE id_adeudo_local = p_id_adeudo_local
    AND pagado = 0;

    IF v_ya_pagado = 0 THEN
        RETURN 0, 'El adeudo no existe o ya está pagado', 0, 0;
    END IF;

    LET v_total = v_importe + v_recargos;

    -- Insertar pago
    INSERT INTO pagos_locales (
        id_local,
        anio,
        periodo,
        fecha_pago,
        oficina_pago,
        caja_pago,
        operacion_pago,
        partida,
        importe,
        recargos,
        total,
        id_usuario,
        fecha_registro
    ) VALUES (
        v_id_local,
        v_anio,
        v_periodo,
        p_fecha_pago,
        p_oficina_pago,
        p_caja_pago,
        p_operacion_pago,
        p_partida,
        v_importe,
        v_recargos,
        v_total,
        p_id_usuario,
        CURRENT
    );

    SELECT MAX(id_pago_local) INTO v_id_pago_local FROM pagos_locales;

    -- Actualizar adeudo como pagado
    UPDATE adeudos_locales
    SET pagado = 1,
        id_pago = v_id_pago_local,
        fecha_pago = p_fecha_pago
    WHERE id_adeudo_local = p_id_adeudo_local;

    RETURN 1, 'Pago cargado correctamente', v_id_pago_local, v_total;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_ESTADISTICAS_CARGA
-- Obtener estadísticas de carga de pagos
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_ESTADISTICAS_CARGA(
    p_oficina VARCHAR(10),
    p_mercado VARCHAR(10),
    p_categoria VARCHAR(10),
    p_seccion VARCHAR(10),
    p_local VARCHAR(20)
)
RETURNING
    DECIMAL(12,2) AS importe_ingresado,
    DECIMAL(12,2) AS importe_capturado,
    DECIMAL(12,2) AS importe_por_capturar,
    INTEGER AS total_adeudos,
    INTEGER AS adeudos_ingresados,
    INTEGER AS adeudos_capturados,
    INTEGER AS adeudos_por_capturar;

    DEFINE v_importe_ingresado DECIMAL(12,2);
    DEFINE v_importe_capturado DECIMAL(12,2);
    DEFINE v_importe_por_capturar DECIMAL(12,2);
    DEFINE v_total_adeudos INTEGER;
    DEFINE v_adeudos_ingresados INTEGER;
    DEFINE v_adeudos_capturados INTEGER;
    DEFINE v_adeudos_por_capturar INTEGER;

    -- Adeudos ya ingresados (pagados)
    SELECT COUNT(*), COALESCE(SUM(importe + recargos), 0)
    INTO v_adeudos_ingresados, v_importe_ingresado
    FROM adeudos_locales al
    INNER JOIN locales l ON al.id_local = l.id_local
    WHERE al.pagado = 1
    AND (p_oficina IS NULL OR p_oficina = '' OR l.oficina = p_oficina)
    AND (p_mercado IS NULL OR p_mercado = '' OR l.mercado = p_mercado)
    AND (p_categoria IS NULL OR p_categoria = '' OR l.categoria = p_categoria)
    AND (p_seccion IS NULL OR p_seccion = '' OR l.seccion = p_seccion)
    AND (p_local IS NULL OR p_local = '' OR l.local_num = p_local);

    -- Por ahora, capturado y por capturar son los mismos que los pendientes
    SELECT COUNT(*), COALESCE(SUM(importe + recargos), 0)
    INTO v_adeudos_por_capturar, v_importe_por_capturar
    FROM adeudos_locales al
    INNER JOIN locales l ON al.id_local = l.id_local
    WHERE al.pagado = 0
    AND (p_oficina IS NULL OR p_oficina = '' OR l.oficina = p_oficina)
    AND (p_mercado IS NULL OR p_mercado = '' OR l.mercado = p_mercado)
    AND (p_categoria IS NULL OR p_categoria = '' OR l.categoria = p_categoria)
    AND (p_seccion IS NULL OR p_seccion = '' OR l.seccion = p_seccion)
    AND (p_local IS NULL OR p_local = '' OR l.local_num = p_local);

    LET v_adeudos_capturados = 0;
    LET v_importe_capturado = 0;
    LET v_total_adeudos = v_adeudos_ingresados + v_adeudos_por_capturar;

    RETURN
        v_importe_ingresado,
        v_importe_capturado,
        v_importe_por_capturar,
        v_total_adeudos,
        v_adeudos_ingresados,
        v_adeudos_capturados,
        v_adeudos_por_capturar;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_SECCIONES_BY_MERCADO_CARGA
-- Obtener secciones de un mercado con adeudos
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_SECCIONES_BY_MERCADO_CARGA(
    p_mercado VARCHAR(10)
)
RETURNING
    VARCHAR(10) AS seccion,
    VARCHAR(100) AS descripcion,
    INTEGER AS total_locales,
    INTEGER AS total_adeudos,
    DECIMAL(12,2) AS importe_total;

    DEFINE v_seccion VARCHAR(10);
    DEFINE v_descripcion VARCHAR(100);
    DEFINE v_total_locales INTEGER;
    DEFINE v_total_adeudos INTEGER;
    DEFINE v_importe_total DECIMAL(12,2);

    FOREACH
        SELECT
            l.seccion,
            s.descripcion,
            COUNT(DISTINCT l.id_local) AS total_locales,
            COUNT(al.id_adeudo_local) AS total_adeudos,
            SUM(al.importe + al.recargos) AS importe_total
        INTO
            v_seccion,
            v_descripcion,
            v_total_locales,
            v_total_adeudos,
            v_importe_total
        FROM locales l
        LEFT JOIN secciones s ON l.seccion = s.seccion AND l.mercado = s.mercado
        INNER JOIN adeudos_locales al ON l.id_local = al.id_local
        WHERE l.mercado = p_mercado
        AND al.pagado = 0
        GROUP BY l.seccion, s.descripcion
        ORDER BY l.seccion

        RETURN
            v_seccion,
            v_descripcion,
            v_total_locales,
            v_total_adeudos,
            v_importe_total
        WITH RESUME;
    END FOREACH;

END PROCEDURE;
