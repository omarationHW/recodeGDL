-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: AltaPagosEnergia.vue
-- DESCRIPCIÓN: Procedimientos almacenados para alta de pagos de energía
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP: SP_MERCADOS_ENERGIA_CREATE_PAGO
-- Descripción: Registra un nuevo pago de energía
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ENERGIA_CREATE_PAGO(
    p_id_energia INT,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago SMALLINT,
    p_operacion_pago INT,
    p_importe_pago DECIMAL(14,2),
    p_folio VARCHAR(20),
    p_id_usuario INT
)

RETURNING
    VARCHAR(100) AS resultado;

-- Verificar que el servicio de energía existe
DEFINE v_existe INT;

SELECT COUNT(*)
INTO v_existe
FROM ta_11_energia
WHERE id_energia = p_id_energia;

IF v_existe = 0 THEN
    RAISE EXCEPTION 'El servicio de energía no existe';
END IF;

-- Verificar que no existe un pago duplicado
SELECT COUNT(*)
INTO v_existe
FROM ta_11_pago_energ
WHERE id_energia = p_id_energia
  AND axo = p_axo
  AND periodo = p_periodo;

IF v_existe > 0 THEN
    RAISE EXCEPTION 'Ya existe un pago registrado para este periodo';
END IF;

-- Insertar el pago
INSERT INTO ta_11_pago_energ (
    id_energia,
    axo,
    periodo,
    fecha_pago,
    oficina_pago,
    caja_pago,
    operacion_pago,
    importe_pago,
    folio,
    fecha_modificacion_1,
    id_usuario
) VALUES (
    p_id_energia,
    p_axo,
    p_periodo,
    p_fecha_pago,
    p_oficina_pago,
    p_caja_pago,
    p_operacion_pago,
    p_importe_pago,
    p_folio,
    CURRENT,
    p_id_usuario
);

RETURN 'Pago de energía registrado correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP: SP_MERCADOS_ENERGIA_LIST_PAGOS
-- Descripción: Lista los pagos de un servicio de energía
-- =============================================

CREATE PROCEDURE SP_MERCADOS_ENERGIA_LIST_PAGOS(
    p_id_energia INT
)

RETURNING
    INT AS id_pago_energ,
    INT AS id_energia,
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DATE AS fecha_pago,
    SMALLINT AS oficina_pago,
    SMALLINT AS caja_pago,
    INT AS operacion_pago,
    DECIMAL(14,2) AS importe_pago,
    VARCHAR(20) AS folio,
    DATETIME YEAR TO SECOND AS fecha_modificacion_1;

DEFINE v_id_pago_energ INT;
DEFINE v_id_energia INT;
DEFINE v_axo SMALLINT;
DEFINE v_periodo SMALLINT;
DEFINE v_fecha_pago DATE;
DEFINE v_oficina_pago SMALLINT;
DEFINE v_caja_pago SMALLINT;
DEFINE v_operacion_pago INT;
DEFINE v_importe_pago DECIMAL(14,2);
DEFINE v_folio VARCHAR(20);
DEFINE v_fecha_modificacion DATETIME YEAR TO SECOND;

FOREACH
    SELECT
        id_pago_energ,
        id_energia,
        axo,
        periodo,
        fecha_pago,
        oficina_pago,
        caja_pago,
        operacion_pago,
        importe_pago,
        TRIM(folio),
        fecha_modificacion_1
    INTO
        v_id_pago_energ,
        v_id_energia,
        v_axo,
        v_periodo,
        v_fecha_pago,
        v_oficina_pago,
        v_caja_pago,
        v_operacion_pago,
        v_importe_pago,
        v_folio,
        v_fecha_modificacion
    FROM ta_11_pago_energ
    WHERE id_energia = p_id_energia
    ORDER BY axo DESC, periodo DESC

    RETURN
        v_id_pago_energ,
        v_id_energia,
        v_axo,
        v_periodo,
        v_fecha_pago,
        v_oficina_pago,
        v_caja_pago,
        v_operacion_pago,
        v_importe_pago,
        v_folio,
        v_fecha_modificacion
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA ALTA DE PAGOS DE ENERGÍA
-- =============================================
