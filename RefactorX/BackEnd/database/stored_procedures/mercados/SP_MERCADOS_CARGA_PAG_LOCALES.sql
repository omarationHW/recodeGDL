-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: CargaPagLocales.vue
-- DESCRIPCIÓN: Procedimientos almacenados para carga masiva de pagos de locales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_CARGA_ADEUDOS_LOCAL
-- Descripción: Obtiene los adeudos pendientes de un local específico
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CARGA_ADEUDOS_LOCAL(
    p_oficina SMALLINT,
    p_mercado SMALLINT,
    p_categoria SMALLINT,
    p_seccion VARCHAR(2),
    p_local SMALLINT
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
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DECIMAL(14,2) AS importe,
    DATETIME YEAR TO SECOND AS fecha_alta,
    VARCHAR(30) AS usuario,
    INT AS id_adeudo_local;

DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_axo SMALLINT;
DEFINE v_periodo SMALLINT;
DEFINE v_importe DECIMAL(14,2);
DEFINE v_fecha_alta DATETIME YEAR TO SECOND;
DEFINE v_usuario VARCHAR(30);
DEFINE v_id_adeudo_local INT;

FOREACH
    SELECT
        loc.id_local,
        loc.oficina,
        loc.num_mercado,
        loc.categoria,
        TRIM(loc.seccion),
        loc.local,
        TRIM(loc.letra_local),
        TRIM(loc.bloque),
        ade.axo,
        ade.periodo,
        ade.importe,
        ade.fecha_alta,
        TRIM(usr.usuario),
        ade.id_adeudo_local
    INTO
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_axo,
        v_periodo,
        v_importe,
        v_fecha_alta,
        v_usuario,
        v_id_adeudo_local
    FROM ta_11_adeudo_local ade
    INNER JOIN ta_11_locales loc
        ON ade.id_local = loc.id_local
    INNER JOIN ta_12_passwords usr
        ON ade.id_usuario = usr.id_usuario
    WHERE loc.oficina = p_oficina
      AND loc.num_mercado = p_mercado
      AND loc.categoria = p_categoria
      AND loc.seccion = p_seccion
      AND loc.local = p_local
      AND loc.vigencia = 'A'
      AND NVL(loc.bloqueo, 0) < 4
    ORDER BY ade.axo, ade.periodo

    RETURN
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_local,
        v_letra_local,
        v_bloque,
        v_axo,
        v_periodo,
        v_importe,
        v_fecha_alta,
        v_usuario,
        v_id_adeudo_local
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_CARGA_INGRESO_OPERACION
-- Descripción: Valida el ingreso de una operación de caja
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CARGA_INGRESO_OPERACION(
    p_fecha_ingreso DATE,
    p_oficina SMALLINT,
    p_caja VARCHAR(4),
    p_operacion INT,
    p_oficina_mercado SMALLINT,
    p_mercado SMALLINT
)

RETURNING
    SMALLINT AS num_mercado,
    INT AS cuenta_ingreso,
    INT AS cta_aplicacion,
    DECIMAL(14,2) AS ingreso;

DEFINE v_num_mercado SMALLINT;
DEFINE v_cuenta_ingreso INT;
DEFINE v_cta_aplicacion INT;
DEFINE v_ingreso DECIMAL(14,2);

FOREACH
    SELECT
        merc.num_mercado_nvo,
        merc.cuenta_ingreso,
        imp.cta_aplicacion,
        NVL(SUM(imp.importe_cta), 0)
    INTO
        v_num_mercado,
        v_cuenta_ingreso,
        v_cta_aplicacion,
        v_ingreso
    FROM ta_12_importes imp
    INNER JOIN ta_11_mercados merc
        ON merc.oficina = p_oficina_mercado
        AND merc.num_mercado_nvo = p_mercado
    WHERE imp.fecing = p_fecha_ingreso
      AND imp.recing = p_oficina
      AND imp.cajing = p_caja
      AND imp.opcaja = p_operacion
      AND (
          (imp.cta_aplicacion BETWEEN 44501 AND 44588)
          OR imp.cta_aplicacion = 44119
          OR imp.cta_aplicacion = 44214
      )
    GROUP BY
        merc.num_mercado_nvo,
        merc.cuenta_ingreso,
        imp.cta_aplicacion

    RETURN
        v_num_mercado,
        v_cuenta_ingreso,
        v_cta_aplicacion,
        v_ingreso
    WITH RESUME;

END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_CARGA_CAPTURA_OPERACION
-- Descripción: Obtiene el total capturado de una operación
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CARGA_CAPTURA_OPERACION(
    p_fecha_pago DATE,
    p_oficina SMALLINT,
    p_caja VARCHAR(4),
    p_operacion INT,
    p_mercado SMALLINT
)

RETURNING DECIMAL(14,2) AS capturado;

DEFINE v_capturado DECIMAL(14,2);
DEFINE v_mes_pago SMALLINT;

-- Extraer mes de la fecha de pago
LET v_mes_pago = MONTH(p_fecha_pago);

-- Calcular total capturado
SELECT NVL(SUM(pag.importe_pago), 0)
INTO v_capturado
FROM ta_11_pagos_local pag
INNER JOIN ta_11_locales loc
    ON pag.id_local = loc.id_local
WHERE MONTH(pag.fecha_pago) = v_mes_pago
  AND pag.oficina_pago = p_oficina
  AND pag.caja_pago = p_caja
  AND pag.operacion_pago = p_operacion
  AND loc.num_mercado = p_mercado;

RETURN v_capturado;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_CARGA_INSERTAR_PAGO
-- Descripción: Inserta un pago individual y elimina el adeudo correspondiente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CARGA_INSERTAR_PAGO(
    p_id_local INT,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_fecha_pago DATE,
    p_oficina SMALLINT,
    p_caja VARCHAR(4),
    p_operacion INT,
    p_importe DECIMAL(14,2),
    p_folio VARCHAR(20),
    p_id_usuario INT
)

RETURNING
    VARCHAR(10) AS status,
    VARCHAR(255) AS mensaje;

DEFINE v_fecha_modificacion DATETIME YEAR TO SECOND;

-- Validar que el folio no esté vacío
IF p_folio IS NULL OR TRIM(p_folio) = '' OR TRIM(p_folio) = '0' THEN
    RETURN 'ERROR', 'Folio no válido';
END IF;

-- Obtener fecha actual
LET v_fecha_modificacion = CURRENT YEAR TO SECOND;

-- Insertar el pago
INSERT INTO ta_11_pagos_local (
    id_local,
    axo,
    periodo,
    fecha_pago,
    oficina_pago,
    caja_pago,
    operacion_pago,
    importe_pago,
    folio,
    fecha_modificacion,
    id_usuario
) VALUES (
    p_id_local,
    p_axo,
    p_periodo,
    p_fecha_pago,
    p_oficina,
    p_caja,
    p_operacion,
    p_importe,
    p_folio,
    v_fecha_modificacion,
    p_id_usuario
);

-- Eliminar el adeudo correspondiente
DELETE FROM ta_11_adeudo_local
WHERE id_local = p_id_local
  AND axo = p_axo
  AND periodo = p_periodo;

RETURN 'OK', 'Pago registrado correctamente';

END PROCEDURE;

-- =============================================
-- SP 5: SP_MERCADOS_CARGA_ELIMINAR_ADEUDO
-- Descripción: Elimina un adeudo específico sin registrar pago
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CARGA_ELIMINAR_ADEUDO(
    p_id_local INT,
    p_axo SMALLINT,
    p_periodo SMALLINT
)

RETURNING
    VARCHAR(10) AS status,
    VARCHAR(255) AS mensaje;

DELETE FROM ta_11_adeudo_local
WHERE id_local = p_id_local
  AND axo = p_axo
  AND periodo = p_periodo;

RETURN 'OK', 'Adeudo eliminado correctamente';

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA CARGA DE PAGOS DE LOCALES
-- =============================================
