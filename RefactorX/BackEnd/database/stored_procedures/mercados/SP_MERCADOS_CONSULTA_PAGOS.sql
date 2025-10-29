-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: ConsPagos.vue
-- DESCRIPCIÓN: Procedimientos almacenados para consulta de pagos
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP: SP_MERCADOS_PAGOS_BY_LOCAL
-- Descripción: Obtiene los pagos de un local específico
-- =============================================

CREATE PROCEDURE SP_MERCADOS_PAGOS_BY_LOCAL(
    p_id_local INT
)

RETURNING
    INT AS id_pago_local,
    INT AS id_local,
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DATE AS fecha_pago,
    SMALLINT AS oficina_pago,
    SMALLINT AS caja_pago,
    INT AS operacion_pago,
    DECIMAL(14,2) AS importe_pago,
    VARCHAR(20) AS folio,
    DATETIME YEAR TO SECOND AS fecha_modificacion,
    VARCHAR(50) AS usuario;

DEFINE v_id_pago_local INT;
DEFINE v_id_local INT;
DEFINE v_axo SMALLINT;
DEFINE v_periodo SMALLINT;
DEFINE v_fecha_pago DATE;
DEFINE v_oficina_pago SMALLINT;
DEFINE v_caja_pago SMALLINT;
DEFINE v_operacion_pago INT;
DEFINE v_importe_pago DECIMAL(14,2);
DEFINE v_folio VARCHAR(20);
DEFINE v_fecha_modificacion DATETIME YEAR TO SECOND;
DEFINE v_usuario VARCHAR(50);

FOREACH
    SELECT
        p.id_pago_local,
        p.id_local,
        p.axo,
        p.periodo,
        p.fecha_pago,
        p.oficina_pago,
        p.caja_pago,
        p.operacion_pago,
        p.importe_pago,
        TRIM(p.folio),
        p.fecha_modificacion_1,
        TRIM(u.nombre)
    INTO
        v_id_pago_local,
        v_id_local,
        v_axo,
        v_periodo,
        v_fecha_pago,
        v_oficina_pago,
        v_caja_pago,
        v_operacion_pago,
        v_importe_pago,
        v_folio,
        v_fecha_modificacion,
        v_usuario
    FROM ta_11_pago_local p
    LEFT JOIN ta_usuarios u ON p.id_usuario = u.id_usuario
    WHERE p.id_local = p_id_local
    ORDER BY p.axo DESC, p.periodo DESC

    RETURN
        v_id_pago_local,
        v_id_local,
        v_axo,
        v_periodo,
        v_fecha_pago,
        v_oficina_pago,
        v_caja_pago,
        v_operacion_pago,
        v_importe_pago,
        v_folio,
        v_fecha_modificacion,
        v_usuario
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP: SP_MERCADOS_PAGOS_ADD
-- Descripción: Agrega un nuevo pago a un local
-- =============================================

CREATE PROCEDURE SP_MERCADOS_PAGOS_ADD(
    p_id_local INT,
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

-- Verificar que el local existe
DEFINE v_existe INT;

SELECT COUNT(*)
INTO v_existe
FROM ta_11_locales
WHERE id_local = p_id_local;

IF v_existe = 0 THEN
    RAISE EXCEPTION 'El local no existe';
END IF;

-- Verificar duplicado
SELECT COUNT(*)
INTO v_existe
FROM ta_11_pago_local
WHERE id_local = p_id_local
  AND axo = p_axo
  AND periodo = p_periodo;

IF v_existe > 0 THEN
    RAISE EXCEPTION 'Ya existe un pago para este periodo';
END IF;

-- Insertar el pago
INSERT INTO ta_11_pago_local (
    id_local,
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
    p_id_local,
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

RETURN 'Pago agregado correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- SP: SP_MERCADOS_PAGOS_DELETE
-- Descripción: Elimina un pago
-- =============================================

CREATE PROCEDURE SP_MERCADOS_PAGOS_DELETE(
    p_id_pago_local INT
)

RETURNING
    VARCHAR(100) AS resultado;

DELETE FROM ta_11_pago_local
WHERE id_pago_local = p_id_pago_local;

RETURN 'Pago eliminado correctamente'
WITH RESUME;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA CONSULTA DE PAGOS
-- =============================================
