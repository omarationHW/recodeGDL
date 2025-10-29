-- =============================================
-- SP_MERCADOS_GET_ADEUDOS_ESPECIALES
-- Buscar adeudos de años anteriores sin fecha de ingreso
-- para carga especial de pagos
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_ADEUDOS_ESPECIALES(
    p_mercado VARCHAR(10),
    p_local VARCHAR(20)
)
RETURNING
    INTEGER AS id_adeudo_local,
    INTEGER AS id_local,
    VARCHAR(10) AS mercado,
    VARCHAR(10) AS categoria,
    VARCHAR(10) AS seccion,
    VARCHAR(20) AS local_num,
    VARCHAR(100) AS nombre_titular,
    INTEGER AS anio,
    INTEGER AS periodo,
    DECIMAL(12,2) AS importe,
    DATE AS fecha_vencimiento,
    VARCHAR(50) AS concepto;

    DEFINE v_id_adeudo_local INTEGER;
    DEFINE v_id_local INTEGER;
    DEFINE v_mercado VARCHAR(10);
    DEFINE v_categoria VARCHAR(10);
    DEFINE v_seccion VARCHAR(10);
    DEFINE v_local_num VARCHAR(20);
    DEFINE v_nombre_titular VARCHAR(100);
    DEFINE v_anio INTEGER;
    DEFINE v_periodo INTEGER;
    DEFINE v_importe DECIMAL(12,2);
    DEFINE v_fecha_vencimiento DATE;
    DEFINE v_concepto VARCHAR(50);

    FOREACH
        SELECT
            al.id_adeudo_local,
            al.id_local,
            l.mercado,
            l.categoria,
            l.seccion,
            l.local_num,
            l.nombre_titular,
            al.anio,
            al.periodo,
            al.importe,
            al.fecha_vencimiento,
            al.concepto
        INTO
            v_id_adeudo_local,
            v_id_local,
            v_mercado,
            v_categoria,
            v_seccion,
            v_local_num,
            v_nombre_titular,
            v_anio,
            v_periodo,
            v_importe,
            v_fecha_vencimiento,
            v_concepto
        FROM adeudos_locales al
        INNER JOIN locales l ON al.id_local = l.id_local
        WHERE al.pagado = 0
        AND al.fecha_ingreso IS NULL
        AND (p_mercado IS NULL OR p_mercado = '' OR l.mercado = p_mercado)
        AND (p_local IS NULL OR p_local = '' OR l.local_num = p_local)
        AND al.anio < YEAR(CURRENT)
        ORDER BY l.mercado, l.local_num, al.anio, al.periodo

        RETURN
            v_id_adeudo_local,
            v_id_local,
            v_mercado,
            v_categoria,
            v_seccion,
            v_local_num,
            v_nombre_titular,
            v_anio,
            v_periodo,
            v_importe,
            v_fecha_vencimiento,
            v_concepto
        WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_CARGAR_PAGO_ESPECIAL
-- Cargar pago especial de años anteriores
-- Permite modificar el importe del pago
-- =============================================
CREATE PROCEDURE SP_MERCADOS_CARGAR_PAGO_ESPECIAL(
    p_id_adeudo_local INTEGER,
    p_importe_pago DECIMAL(12,2),
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

    DEFINE v_id_pago_local INTEGER;
    DEFINE v_importe_adeudo DECIMAL(12,2);
    DEFINE v_id_local INTEGER;
    DEFINE v_anio INTEGER;
    DEFINE v_periodo INTEGER;
    DEFINE v_ya_pagado INTEGER;
    DEFINE v_fecha_ingreso DATE;

    -- Validar partida
    IF p_partida IS NULL OR p_partida = '' OR p_partida = '0' THEN
        RETURN 0, 'Número de partida inválido', 0;
    END IF;

    -- Validar importe
    IF p_importe_pago IS NULL OR p_importe_pago <= 0 THEN
        RETURN 0, 'Importe de pago inválido', 0;
    END IF;

    -- Verificar si el adeudo existe y cumple condiciones
    SELECT COUNT(*), importe, id_local, anio, periodo, fecha_ingreso
    INTO v_ya_pagado, v_importe_adeudo, v_id_local, v_anio, v_periodo, v_fecha_ingreso
    FROM adeudos_locales
    WHERE id_adeudo_local = p_id_adeudo_local
    AND pagado = 0;

    IF v_ya_pagado = 0 THEN
        RETURN 0, 'El adeudo no existe o ya está pagado', 0;
    END IF;

    IF v_fecha_ingreso IS NOT NULL THEN
        RETURN 0, 'El adeudo ya tiene fecha de ingreso registrada', 0;
    END IF;

    -- Insertar pago especial
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
        importe_original,
        tipo_pago,
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
        p_importe_pago,
        v_importe_adeudo,
        'ESPECIAL',
        p_id_usuario,
        CURRENT
    );

    SELECT MAX(id_pago_local) INTO v_id_pago_local FROM pagos_locales;

    -- Actualizar adeudo como pagado
    UPDATE adeudos_locales
    SET pagado = 1,
        id_pago = v_id_pago_local,
        fecha_pago = p_fecha_pago,
        fecha_ingreso = p_fecha_pago,
        importe_pagado = p_importe_pago
    WHERE id_adeudo_local = p_id_adeudo_local;

    RETURN 1, 'Pago especial cargado correctamente', v_id_pago_local;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_LOCALES_BY_MERCADO_ESPECIAL
-- Obtener locales de un mercado con adeudos especiales
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_LOCALES_BY_MERCADO_ESPECIAL(
    p_mercado VARCHAR(10)
)
RETURNING
    INTEGER AS id_local,
    VARCHAR(20) AS local_num,
    VARCHAR(100) AS nombre_titular,
    INTEGER AS total_adeudos,
    DECIMAL(12,2) AS importe_total;

    DEFINE v_id_local INTEGER;
    DEFINE v_local_num VARCHAR(20);
    DEFINE v_nombre_titular VARCHAR(100);
    DEFINE v_total_adeudos INTEGER;
    DEFINE v_importe_total DECIMAL(12,2);

    FOREACH
        SELECT
            l.id_local,
            l.local_num,
            l.nombre_titular,
            COUNT(al.id_adeudo_local) AS total_adeudos,
            SUM(al.importe) AS importe_total
        INTO
            v_id_local,
            v_local_num,
            v_nombre_titular,
            v_total_adeudos,
            v_importe_total
        FROM locales l
        INNER JOIN adeudos_locales al ON l.id_local = al.id_local
        WHERE l.mercado = p_mercado
        AND al.pagado = 0
        AND al.fecha_ingreso IS NULL
        AND al.anio < YEAR(CURRENT)
        GROUP BY l.id_local, l.local_num, l.nombre_titular
        HAVING COUNT(al.id_adeudo_local) > 0
        ORDER BY l.local_num

        RETURN
            v_id_local,
            v_local_num,
            v_nombre_titular,
            v_total_adeudos,
            v_importe_total
        WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_VALIDAR_PAGO_ESPECIAL
-- Validar que un pago especial pueda procesarse
-- =============================================
CREATE PROCEDURE SP_MERCADOS_VALIDAR_PAGO_ESPECIAL(
    p_id_adeudo_local INTEGER,
    p_importe_pago DECIMAL(12,2)
)
RETURNING
    INTEGER AS valido,
    VARCHAR(255) AS mensaje;

    DEFINE v_existe INTEGER;
    DEFINE v_pagado INTEGER;
    DEFINE v_fecha_ingreso DATE;
    DEFINE v_anio INTEGER;
    DEFINE v_anio_actual INTEGER;

    SELECT COUNT(*)
    INTO v_existe
    FROM adeudos_locales
    WHERE id_adeudo_local = p_id_adeudo_local;

    IF v_existe = 0 THEN
        RETURN 0, 'El adeudo no existe';
    END IF;

    SELECT pagado, fecha_ingreso, anio
    INTO v_pagado, v_fecha_ingreso, v_anio
    FROM adeudos_locales
    WHERE id_adeudo_local = p_id_adeudo_local;

    IF v_pagado = 1 THEN
        RETURN 0, 'El adeudo ya está pagado';
    END IF;

    IF v_fecha_ingreso IS NOT NULL THEN
        RETURN 0, 'El adeudo ya tiene fecha de ingreso';
    END IF;

    LET v_anio_actual = YEAR(CURRENT);
    IF v_anio >= v_anio_actual THEN
        RETURN 0, 'El adeudo no corresponde a años anteriores';
    END IF;

    IF p_importe_pago IS NULL OR p_importe_pago <= 0 THEN
        RETURN 0, 'El importe de pago es inválido';
    END IF;

    RETURN 1, 'Validación exitosa';

END PROCEDURE;
