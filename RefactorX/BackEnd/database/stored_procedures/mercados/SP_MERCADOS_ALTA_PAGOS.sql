-- =============================================
-- MÓDULO: MERCADOS
-- COMPONENTE: AltaPagos.vue
-- DESCRIPCIÓN: Procedimientos almacenados para registro de pagos de locales
-- ESQUEMA: INFORMIX
-- FECHA: 2025-10-23
-- =============================================

-- =============================================
-- SP 1: SP_MERCADOS_BUSCAR_LOCAL
-- Descripción: Busca un local vigente y no bloqueado
-- =============================================

CREATE PROCEDURE SP_MERCADOS_BUSCAR_LOCAL(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_categoria SMALLINT,
    p_seccion VARCHAR(2),
    p_local SMALLINT,
    p_letra_local VARCHAR(1),
    p_bloque VARCHAR(1)
)

RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    SMALLINT AS categoria,
    VARCHAR(2) AS seccion,
    SMALLINT AS num_local,
    VARCHAR(1) AS letra_local,
    VARCHAR(1) AS bloque,
    DECIMAL(10,2) AS superficie,
    SMALLINT AS clave_cuota,
    VARCHAR(30) AS nombre,
    VARCHAR(30) AS arrendatario,
    SMALLINT AS bloqueo;

DEFINE v_id_local INT;
DEFINE v_oficina SMALLINT;
DEFINE v_num_mercado SMALLINT;
DEFINE v_categoria SMALLINT;
DEFINE v_seccion VARCHAR(2);
DEFINE v_num_local SMALLINT;
DEFINE v_letra_local VARCHAR(1);
DEFINE v_bloque VARCHAR(1);
DEFINE v_superficie DECIMAL(10,2);
DEFINE v_clave_cuota SMALLINT;
DEFINE v_nombre VARCHAR(30);
DEFINE v_arrendatario VARCHAR(30);
DEFINE v_bloqueo SMALLINT;

FOREACH
    SELECT
        id_local,
        oficina,
        num_mercado,
        categoria,
        TRIM(seccion),
        local,
        TRIM(letra_local),
        TRIM(bloque),
        superficie,
        clave_cuota,
        TRIM(nombre),
        TRIM(arrendatario),
        bloqueo
    INTO
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_num_local,
        v_letra_local,
        v_bloque,
        v_superficie,
        v_clave_cuota,
        v_nombre,
        v_arrendatario,
        v_bloqueo
    FROM ta_11_locales
    WHERE oficina = p_oficina
      AND num_mercado = p_num_mercado
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND local = p_local
      AND (letra_local IS NULL OR letra_local = p_letra_local OR p_letra_local IS NULL OR p_letra_local = '')
      AND (bloque IS NULL OR bloque = p_bloque OR p_bloque IS NULL OR p_bloque = '')
      AND vigencia = 'A'
      AND NVL(bloqueo, 0) < 4

    RETURN
        v_id_local,
        v_oficina,
        v_num_mercado,
        v_categoria,
        v_seccion,
        v_num_local,
        v_letra_local,
        v_bloque,
        v_superficie,
        v_clave_cuota,
        v_nombre,
        v_arrendatario,
        v_bloqueo
    WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 2: SP_MERCADOS_CONSULTAR_PAGO
-- Descripción: Consulta si existe un pago para un local, año y periodo
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CONSULTAR_PAGO(
    p_id_local INT,
    p_axo SMALLINT,
    p_periodo SMALLINT
)

RETURNING
    INT AS id_pago_local,
    INT AS id_local,
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DATE AS fecha_pago,
    SMALLINT AS oficina_pago,
    VARCHAR(10) AS caja_pago,
    INT AS operacion_pago,
    DECIMAL(14,2) AS importe_pago,
    VARCHAR(20) AS folio,
    DATETIME YEAR TO SECOND AS fecha_modificacion,
    INT AS id_usuario;

DEFINE v_id_pago_local INT;
DEFINE v_id_local INT;
DEFINE v_axo SMALLINT;
DEFINE v_periodo SMALLINT;
DEFINE v_fecha_pago DATE;
DEFINE v_oficina_pago SMALLINT;
DEFINE v_caja_pago VARCHAR(10);
DEFINE v_operacion_pago INT;
DEFINE v_importe_pago DECIMAL(14,2);
DEFINE v_folio VARCHAR(20);
DEFINE v_fecha_modificacion DATETIME YEAR TO SECOND;
DEFINE v_id_usuario INT;

FOREACH
    SELECT
        id_pago_local,
        id_local,
        axo,
        periodo,
        fecha_pago,
        oficina_pago,
        TRIM(caja_pago),
        operacion_pago,
        importe_pago,
        TRIM(folio),
        fecha_modificacion,
        id_usuario
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
        v_id_usuario
    FROM ta_11_pagos_local
    WHERE id_local = p_id_local
      AND axo = p_axo
      AND periodo = p_periodo

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
        v_id_usuario
    WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 3: SP_MERCADOS_AGREGAR_PAGO
-- Descripción: Agrega un pago de local y elimina el adeudo correspondiente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_AGREGAR_PAGO(
    p_id_local INT,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR(10),
    p_operacion_pago INT,
    p_importe_pago DECIMAL(14,2),
    p_folio VARCHAR(20),
    p_id_usuario INT
)

RETURNING
    SMALLINT AS success,
    VARCHAR(255) AS message;

DEFINE v_fecha_mod DATETIME YEAR TO SECOND;
DEFINE v_adeudo_count INT;

-- Inicializar
LET v_fecha_mod = CURRENT YEAR TO SECOND;

-- Insertar el pago
BEGIN
    ON EXCEPTION
        RETURN 0, 'Error al dar de Alta el Pago';
    END EXCEPTION;

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
        p_oficina_pago,
        p_caja_pago,
        p_operacion_pago,
        p_importe_pago,
        p_folio,
        v_fecha_mod,
        p_id_usuario
    );

    -- Si existe adeudo, eliminarlo
    SELECT COUNT(*)
    INTO v_adeudo_count
    FROM ta_11_adeudo_local
    WHERE id_local = p_id_local
      AND axo = p_axo
      AND periodo = p_periodo;

    IF v_adeudo_count > 0 THEN
        DELETE FROM ta_11_adeudo_local
        WHERE id_local = p_id_local
          AND axo = p_axo
          AND periodo = p_periodo;
    END IF;

    RETURN 1, 'El Pago se dio de Alta Correctamente';
END;

END PROCEDURE;

-- =============================================
-- SP 4: SP_MERCADOS_MODIFICAR_PAGO
-- Descripción: Modifica un pago existente
-- =============================================

CREATE PROCEDURE SP_MERCADOS_MODIFICAR_PAGO(
    p_id_local INT,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR(10),
    p_operacion_pago INT,
    p_importe_pago DECIMAL(14,2),
    p_folio VARCHAR(20),
    p_id_usuario INT
)

RETURNING
    SMALLINT AS success,
    VARCHAR(255) AS message;

DEFINE v_fecha_mod DATETIME YEAR TO SECOND;

LET v_fecha_mod = CURRENT YEAR TO SECOND;

BEGIN
    ON EXCEPTION
        RETURN 0, 'Error al Modificar el Pago';
    END EXCEPTION;

    UPDATE ta_11_pagos_local
    SET
        fecha_pago = p_fecha_pago,
        oficina_pago = p_oficina_pago,
        caja_pago = p_caja_pago,
        operacion_pago = p_operacion_pago,
        importe_pago = p_importe_pago,
        folio = p_folio,
        fecha_modificacion = v_fecha_mod,
        id_usuario = p_id_usuario
    WHERE id_local = p_id_local
      AND axo = p_axo
      AND periodo = p_periodo;

    RETURN 1, 'El Pago se Modificó Correctamente';
END;

END PROCEDURE;

-- =============================================
-- SP 5: SP_MERCADOS_BORRAR_PAGO
-- Descripción: Elimina un pago y regenera el adeudo si corresponde
-- =============================================

CREATE PROCEDURE SP_MERCADOS_BORRAR_PAGO(
    p_id_local INT,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_id_usuario INT
)

RETURNING
    SMALLINT AS success,
    VARCHAR(255) AS message;

DEFINE v_importe_pago DECIMAL(14,2);
DEFINE v_adeudo_count INT;
DEFINE v_fecha_alta DATETIME YEAR TO SECOND;
DEFINE v_found INT;

LET v_fecha_alta = CURRENT YEAR TO SECOND;

BEGIN
    ON EXCEPTION
        RETURN 0, 'Error al Borrar el Pago';
    END EXCEPTION;

    -- Obtener importe del pago
    SELECT importe_pago
    INTO v_importe_pago
    FROM ta_11_pagos_local
    WHERE id_local = p_id_local
      AND axo = p_axo
      AND periodo = p_periodo;

    -- Verificar si se encontró el pago
    IF v_importe_pago IS NULL THEN
        RETURN 0, 'No existe el pago a borrar';
    END IF;

    -- Verificar si existe adeudo
    SELECT COUNT(*)
    INTO v_adeudo_count
    FROM ta_11_adeudo_local
    WHERE id_local = p_id_local
      AND axo = p_axo
      AND periodo = p_periodo;

    -- Regenerar adeudo si no existe
    IF v_adeudo_count = 0 THEN
        INSERT INTO ta_11_adeudo_local (
            id_local,
            axo,
            periodo,
            importe,
            fecha_alta,
            id_usuario
        ) VALUES (
            p_id_local,
            p_axo,
            p_periodo,
            v_importe_pago,
            v_fecha_alta,
            p_id_usuario
        );
    END IF;

    -- Eliminar el pago
    DELETE FROM ta_11_pagos_local
    WHERE id_local = p_id_local
      AND axo = p_axo
      AND periodo = p_periodo;

    RETURN 1, 'Se Eliminó Correctamente el Pago';
END;

END PROCEDURE;

-- =============================================
-- SP 6: SP_MERCADOS_CONSULTAR_ADEUDO
-- Descripción: Consulta el adeudo de un local para un periodo
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CONSULTAR_ADEUDO(
    p_id_local INT,
    p_axo SMALLINT,
    p_periodo SMALLINT
)

RETURNING
    INT AS id_adeudo_local,
    INT AS id_local,
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DECIMAL(14,2) AS importe,
    DATETIME YEAR TO SECOND AS fecha_alta,
    INT AS id_usuario;

DEFINE v_id_adeudo_local INT;
DEFINE v_id_local INT;
DEFINE v_axo SMALLINT;
DEFINE v_periodo SMALLINT;
DEFINE v_importe DECIMAL(14,2);
DEFINE v_fecha_alta DATETIME YEAR TO SECOND;
DEFINE v_id_usuario INT;

FOREACH
    SELECT
        id_adeudo_local,
        id_local,
        axo,
        periodo,
        importe,
        fecha_alta,
        id_usuario
    INTO
        v_id_adeudo_local,
        v_id_local,
        v_axo,
        v_periodo,
        v_importe,
        v_fecha_alta,
        v_id_usuario
    FROM ta_11_adeudo_local
    WHERE id_local = p_id_local
      AND axo = p_axo
      AND periodo = p_periodo

    RETURN
        v_id_adeudo_local,
        v_id_local,
        v_axo,
        v_periodo,
        v_importe,
        v_fecha_alta,
        v_id_usuario
    WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- SP 7: SP_MERCADOS_CAJAS_LIST
-- Descripción: Lista de cajas disponibles para pago
-- =============================================

CREATE PROCEDURE SP_MERCADOS_CAJAS_LIST()

RETURNING
    VARCHAR(10) AS caja,
    VARCHAR(50) AS descripcion;

DEFINE v_caja VARCHAR(10);
DEFINE v_descripcion VARCHAR(50);

FOREACH
    SELECT DISTINCT
        TRIM(caja_pago),
        TRIM(caja_pago)
    INTO
        v_caja,
        v_descripcion
    FROM ta_11_pagos_local
    WHERE caja_pago IS NOT NULL
    ORDER BY 1

    RETURN v_caja, v_descripcion WITH RESUME;
END FOREACH;

END PROCEDURE;

-- =============================================
-- FIN DE PROCEDIMIENTOS PARA ALTA DE PAGOS
-- =============================================
