-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: PagosIndividual.vue
-- DESCRIPCIÓN: Procedimientos almacenados para consulta individual de pagos
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP: SP_MERCADOS_PAGO_INDIVIDUAL
-- Descripción: Obtiene el detalle completo de un pago específico
-- =============================================

CREATE PROCEDURE SP_MERCADOS_PAGO_INDIVIDUAL(
    p_id_local INT,
    p_axo SMALLINT,
    p_periodo SMALLINT
)

RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    VARCHAR(50) AS descripcion_local,
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DATE AS fecha_pago,
    SMALLINT AS oficina_pago,
    SMALLINT AS caja_pago,
    INT AS operacion_pago,
    DECIMAL(14,2) AS importe_pago,
    VARCHAR(20) AS folio,
    DATETIME YEAR TO SECOND AS fecha_modificacion_1,
    VARCHAR(50) AS usuario;

DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_descripcion_local VARCHAR(50);
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

SELECT
    l.id_local,
    l.oficina,
    l.num_mercado,
    l.categoria,
    TRIM(l.seccion),
    l.local,
    TRIM(l.letra_local),
    TRIM(l.bloque),
    TRIM(l.descripcion_local),
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
    v_id_local,
    v_oficina,
    v_num_mercado,
    v_categoria,
    v_seccion,
    v_local,
    v_letra_local,
    v_bloque,
    v_descripcion_local,
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
INNER JOIN ta_11_locales l ON p.id_local = l.id_local
LEFT JOIN ta_usuarios u ON p.id_usuario = u.id_usuario
WHERE p.id_local = p_id_local
  AND p.axo = p_axo
  AND p.periodo = p_periodo;

IF v_id_local IS NULL THEN
    RAISE EXCEPTION 'No se encontró el pago especificado';
END IF;

RETURN
    v_id_local,
    v_oficina,
    v_num_mercado,
    v_categoria,
    v_seccion,
    v_local,
    v_letra_local,
    v_bloque,
    v_descripcion_local,
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

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA PAGO INDIVIDUAL
-- =============================================
