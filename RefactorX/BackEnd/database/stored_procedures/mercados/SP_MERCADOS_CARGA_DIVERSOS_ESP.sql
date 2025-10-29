-- ================================================================
-- STORED PROCEDURES PARA CARGA ESPECIAL DE PAGOS DIVERSOS
-- ================================================================

-- Obtener adeudos diversos especiales por fecha de pago
CREATE PROCEDURE SP_MERCADOS_GET_ADEUDOS_DIVERSOS_ESP(
    p_fecha_pago DATE
)
RETURNING
    DATE AS fecha,
    SMALLINT AS rec,
    INT AS caja,
    INT AS oper,
    SMALLINT AS anio,
    SMALLINT AS mes,
    DECIMAL(12,2) AS renta,
    SMALLINT AS ofn,
    SMALLINT AS mer,
    SMALLINT AS cat,
    CHAR(2) AS sec,
    VARCHAR(7) AS local_num,
    CHAR(1) AS let,
    INT AS id_pago_diversos;

    FOREACH
        SELECT
            pd.fecha_pago AS fecha,
            pd.recaudadora AS rec,
            NVL(pd.caja, 0) AS caja,
            NVL(pd.operacion, 0) AS oper,
            pd.axo AS anio,
            pd.periodo AS mes,
            NVL(pd.importe, 0) AS renta,
            pd.oficina AS ofn,
            pd.num_mercado AS mer,
            pd.categoria AS cat,
            NVL(pd.seccion, '  ') AS sec,
            NVL(pd.local, '       ') AS local_num,
            NVL(pd.letra_local, ' ') AS let,
            pd.id_pago_diversos
        INTO
            fecha, rec, caja, oper, anio, mes, renta,
            ofn, mer, cat, sec, local_num, let, id_pago_diversos
        FROM pagos_diversos pd
        WHERE pd.fecha_pago = p_fecha_pago
          AND NVL(pd.cargado, 'N') = 'N'
        ORDER BY pd.recaudadora, pd.num_mercado, pd.categoria,
                 pd.seccion, pd.local

        RETURN fecha, rec, caja, oper, anio, mes, renta,
               ofn, mer, cat, sec, local_num, let, id_pago_diversos WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Cargar pagos diversos especiales
CREATE PROCEDURE SP_MERCADOS_CARGAR_PAGOS_DIVERSOS(
    p_id_pago_diversos INT,
    p_partida VARCHAR(20),
    p_id_usuario INT,
    p_fecha_pago DATE
)
RETURNING INT AS resultado;

    DEFINE v_resultado INT;
    DEFINE v_id_local INT;
    DEFINE v_oficina SMALLINT;
    DEFINE v_num_mercado SMALLINT;
    DEFINE v_categoria SMALLINT;
    DEFINE v_seccion CHAR(2);
    DEFINE v_local VARCHAR(7);
    DEFINE v_letra_local CHAR(1);
    DEFINE v_axo SMALLINT;
    DEFINE v_periodo SMALLINT;
    DEFINE v_importe DECIMAL(12,2);
    DEFINE v_recaudadora SMALLINT;
    DEFINE v_caja INT;
    DEFINE v_operacion INT;

    ON EXCEPTION
        SET resultado
        LET v_resultado = -1;
        RETURN v_resultado;
    END EXCEPTION;

    -- Obtener datos del pago diverso
    SELECT
        oficina, num_mercado, categoria, seccion,
        local, letra_local, axo, periodo, importe,
        recaudadora, caja, operacion
    INTO
        v_oficina, v_num_mercado, v_categoria, v_seccion,
        v_local, v_letra_local, v_axo, v_periodo, v_importe,
        v_recaudadora, v_caja, v_operacion
    FROM pagos_diversos
    WHERE id_pago_diversos = p_id_pago_diversos;

    -- Buscar el local correspondiente
    SELECT id_local INTO v_id_local
    FROM locales
    WHERE oficina = v_oficina
      AND num_mercado = v_num_mercado
      AND categoria = v_categoria
      AND seccion = v_seccion
      AND local = v_local
      AND NVL(letra_local, ' ') = NVL(v_letra_local, ' ');

    IF v_id_local IS NULL THEN
        LET v_resultado = -2; -- Local no encontrado
        RETURN v_resultado;
    END IF;

    -- Insertar en pagos
    INSERT INTO pagos (
        id_local,
        axo,
        periodo,
        fecha_pago,
        importe,
        recaudadora,
        caja,
        operacion,
        partida,
        id_usuario,
        fecha_carga
    ) VALUES (
        v_id_local,
        v_axo,
        v_periodo,
        p_fecha_pago,
        v_importe,
        v_recaudadora,
        v_caja,
        v_operacion,
        TRIM(p_partida),
        p_id_usuario,
        CURRENT YEAR TO SECOND
    );

    -- Marcar como cargado
    UPDATE pagos_diversos
    SET cargado = 'S',
        partida = TRIM(p_partida),
        fecha_cargado = CURRENT YEAR TO SECOND,
        id_usuario_carga = p_id_usuario
    WHERE id_pago_diversos = p_id_pago_diversos;

    -- Actualizar adeudos (restar el pago)
    UPDATE adeudos
    SET importe = importe - v_importe
    WHERE id_local = v_id_local
      AND axo = v_axo
      AND periodo = v_periodo;

    LET v_resultado = 1;
    RETURN v_resultado;

END PROCEDURE;
