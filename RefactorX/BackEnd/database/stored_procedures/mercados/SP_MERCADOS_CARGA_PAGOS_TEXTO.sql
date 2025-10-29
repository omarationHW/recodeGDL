-- =============================================
-- SP_MERCADOS_IMPORT_PAGOS_TEXTO
-- Importar pagos desde archivo de texto
-- Formato esperado: LOCAL|PERIODO|IMPORTE|PARTIDA|FECHA
-- =============================================
CREATE PROCEDURE SP_MERCADOS_IMPORT_PAGOS_TEXTO(
    p_linea_texto VARCHAR(500),
    p_id_usuario INTEGER
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje,
    INTEGER AS id_pago,
    VARCHAR(20) AS local_num,
    INTEGER AS periodo,
    DECIMAL(12,2) AS importe;

    DEFINE v_local_num VARCHAR(20);
    DEFINE v_periodo INTEGER;
    DEFINE v_importe DECIMAL(12,2);
    DEFINE v_partida VARCHAR(20);
    DEFINE v_fecha_pago DATE;
    DEFINE v_id_local INTEGER;
    DEFINE v_id_adeudo_local INTEGER;
    DEFINE v_id_pago_local INTEGER;
    DEFINE v_anio INTEGER;
    DEFINE v_count_local INTEGER;
    DEFINE v_count_adeudo INTEGER;

    -- Parsear línea de texto (formato: LOCAL|PERIODO|IMPORTE|PARTIDA|FECHA)
    -- Nota: Esta es una implementación simplificada
    -- En producción se necesitaría una función más robusta para parsear

    -- Por ahora retornamos error indicando que se necesita implementar en capa de aplicación
    RETURN 0, 'Procesamiento debe hacerse en capa de aplicación', 0, '', 0, 0;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_VALIDAR_PAGO_TEXTO
-- Validar un pago desde texto antes de importar
-- =============================================
CREATE PROCEDURE SP_MERCADOS_VALIDAR_PAGO_TEXTO(
    p_local_num VARCHAR(20),
    p_anio INTEGER,
    p_periodo INTEGER,
    p_importe DECIMAL(12,2),
    p_partida VARCHAR(20)
)
RETURNING
    INTEGER AS valido,
    VARCHAR(255) AS mensaje,
    INTEGER AS id_adeudo_local;

    DEFINE v_id_local INTEGER;
    DEFINE v_id_adeudo_local INTEGER;
    DEFINE v_count_local INTEGER;
    DEFINE v_count_adeudo INTEGER;
    DEFINE v_pagado INTEGER;
    DEFINE v_importe_adeudo DECIMAL(12,2);

    -- Validar que el local existe
    SELECT COUNT(*), id_local
    INTO v_count_local, v_id_local
    FROM locales
    WHERE local_num = p_local_num;

    IF v_count_local = 0 THEN
        RETURN 0, 'Local ' || p_local_num || ' no encontrado', 0;
    END IF;

    -- Validar que el adeudo existe
    SELECT COUNT(*), id_adeudo_local, pagado, importe
    INTO v_count_adeudo, v_id_adeudo_local, v_pagado, v_importe_adeudo
    FROM adeudos_locales
    WHERE id_local = v_id_local
    AND anio = p_anio
    AND periodo = p_periodo;

    IF v_count_adeudo = 0 THEN
        RETURN 0, 'Adeudo no encontrado para local ' || p_local_num || ' periodo ' || p_periodo, 0;
    END IF;

    IF v_pagado = 1 THEN
        RETURN 0, 'Adeudo ya está pagado', v_id_adeudo_local;
    END IF;

    -- Validar partida
    IF p_partida IS NULL OR p_partida = '' OR p_partida = '0' THEN
        RETURN 0, 'Partida inválida', v_id_adeudo_local;
    END IF;

    -- Advertir si el importe no coincide
    IF p_importe != v_importe_adeudo THEN
        RETURN 2, 'Advertencia: importe difiere del adeudo ($' || v_importe_adeudo || ')', v_id_adeudo_local;
    END IF;

    RETURN 1, 'Validación exitosa', v_id_adeudo_local;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_INSERTAR_PAGO_DESDE_TEXTO
-- Insertar pago validado desde importación de texto
-- =============================================
CREATE PROCEDURE SP_MERCADOS_INSERTAR_PAGO_DESDE_TEXTO(
    p_id_adeudo_local INTEGER,
    p_partida VARCHAR(20),
    p_fecha_pago DATE,
    p_importe DECIMAL(12,2),
    p_id_usuario INTEGER
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje,
    INTEGER AS id_pago;

    DEFINE v_id_pago_local INTEGER;
    DEFINE v_id_local INTEGER;
    DEFINE v_anio INTEGER;
    DEFINE v_periodo INTEGER;
    DEFINE v_importe_adeudo DECIMAL(12,2);
    DEFINE v_recargos DECIMAL(12,2);
    DEFINE v_total DECIMAL(12,2);
    DEFINE v_ya_pagado INTEGER;

    -- Verificar que el adeudo no esté pagado
    SELECT COUNT(*), id_local, anio, periodo, importe, recargos
    INTO v_ya_pagado, v_id_local, v_anio, v_periodo, v_importe_adeudo, v_recargos
    FROM adeudos_locales
    WHERE id_adeudo_local = p_id_adeudo_local
    AND pagado = 0;

    IF v_ya_pagado = 0 THEN
        RETURN 0, 'Adeudo no encontrado o ya pagado', 0;
    END IF;

    LET v_total = p_importe + v_recargos;

    -- Insertar pago
    INSERT INTO pagos_locales (
        id_local,
        anio,
        periodo,
        fecha_pago,
        partida,
        importe,
        recargos,
        total,
        tipo_pago,
        id_usuario,
        fecha_registro
    ) VALUES (
        v_id_local,
        v_anio,
        v_periodo,
        p_fecha_pago,
        p_partida,
        p_importe,
        v_recargos,
        v_total,
        'IMPORTACION',
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

    RETURN 1, 'Pago importado correctamente', v_id_pago_local;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_GET_RESUMEN_IMPORTACION
-- Obtener resumen de importación de pagos
-- =============================================
CREATE PROCEDURE SP_MERCADOS_GET_RESUMEN_IMPORTACION(
    p_fecha_importacion DATE,
    p_id_usuario INTEGER
)
RETURNING
    INTEGER AS total_registros,
    INTEGER AS pagos_grabados,
    INTEGER AS pagos_ya_existentes,
    INTEGER AS pagos_con_error,
    DECIMAL(12,2) AS importe_total;

    DEFINE v_total_registros INTEGER;
    DEFINE v_pagos_grabados INTEGER;
    DEFINE v_pagos_ya_existentes INTEGER;
    DEFINE v_pagos_con_error INTEGER;
    DEFINE v_importe_total DECIMAL(12,2);

    -- Contar pagos grabados hoy por el usuario
    SELECT COUNT(*), COALESCE(SUM(total), 0)
    INTO v_pagos_grabados, v_importe_total
    FROM pagos_locales
    WHERE id_usuario = p_id_usuario
    AND DATE(fecha_registro) = p_fecha_importacion
    AND tipo_pago = 'IMPORTACION';

    LET v_total_registros = v_pagos_grabados;
    LET v_pagos_ya_existentes = 0;
    LET v_pagos_con_error = 0;

    RETURN
        v_total_registros,
        v_pagos_grabados,
        v_pagos_ya_existentes,
        v_pagos_con_error,
        v_importe_total;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_PREVIEW_PAGO_TEXTO
-- Vista previa de un pago desde texto
-- =============================================
CREATE PROCEDURE SP_MERCADOS_PREVIEW_PAGO_TEXTO(
    p_local_num VARCHAR(20),
    p_anio INTEGER,
    p_periodo INTEGER,
    p_importe DECIMAL(12,2),
    p_partida VARCHAR(20),
    p_fecha_pago DATE
)
RETURNING
    VARCHAR(20) AS local_num,
    VARCHAR(100) AS nombre_titular,
    INTEGER AS anio,
    INTEGER AS periodo,
    DECIMAL(12,2) AS importe_archivo,
    DECIMAL(12,2) AS importe_sistema,
    VARCHAR(20) AS partida,
    DATE AS fecha_pago,
    VARCHAR(20) AS estado;

    DEFINE v_id_local INTEGER;
    DEFINE v_nombre_titular VARCHAR(100);
    DEFINE v_id_adeudo INTEGER;
    DEFINE v_importe_sistema DECIMAL(12,2);
    DEFINE v_pagado INTEGER;
    DEFINE v_estado VARCHAR(20);
    DEFINE v_count_local INTEGER;
    DEFINE v_count_adeudo INTEGER;

    -- Buscar local
    SELECT COUNT(*), id_local, nombre_titular
    INTO v_count_local, v_id_local, v_nombre_titular
    FROM locales
    WHERE local_num = p_local_num;

    IF v_count_local = 0 THEN
        LET v_estado = 'LOCAL NO EXISTE';
        RETURN
            p_local_num,
            'N/A',
            p_anio,
            p_periodo,
            p_importe,
            0,
            p_partida,
            p_fecha_pago,
            v_estado;
    END IF;

    -- Buscar adeudo
    SELECT COUNT(*), id_adeudo_local, importe, pagado
    INTO v_count_adeudo, v_id_adeudo, v_importe_sistema, v_pagado
    FROM adeudos_locales
    WHERE id_local = v_id_local
    AND anio = p_anio
    AND periodo = p_periodo;

    IF v_count_adeudo = 0 THEN
        LET v_estado = 'ADEUDO NO EXISTE';
    ELIF v_pagado = 1 THEN
        LET v_estado = 'YA PAGADO';
    ELIF p_importe != v_importe_sistema THEN
        LET v_estado = 'IMPORTE DIFIERE';
    ELSE
        LET v_estado = 'LISTO';
    END IF;

    RETURN
        p_local_num,
        v_nombre_titular,
        p_anio,
        p_periodo,
        p_importe,
        v_importe_sistema,
        p_partida,
        p_fecha_pago,
        v_estado;

END PROCEDURE;

-- =============================================
-- SP_MERCADOS_LIMPIAR_IMPORTACION_FALLIDA
-- Eliminar pagos de importación fallida
-- =============================================
CREATE PROCEDURE SP_MERCADOS_LIMPIAR_IMPORTACION_FALLIDA(
    p_id_usuario INTEGER,
    p_fecha_importacion DATE
)
RETURNING
    INTEGER AS resultado,
    VARCHAR(255) AS mensaje,
    INTEGER AS registros_eliminados;

    DEFINE v_count INTEGER;

    -- Primero, revertir los adeudos a estado no pagado
    UPDATE adeudos_locales
    SET pagado = 0,
        id_pago = NULL,
        fecha_pago = NULL
    WHERE id_pago IN (
        SELECT id_pago_local
        FROM pagos_locales
        WHERE id_usuario = p_id_usuario
        AND DATE(fecha_registro) = p_fecha_importacion
        AND tipo_pago = 'IMPORTACION'
    );

    -- Eliminar los pagos
    DELETE FROM pagos_locales
    WHERE id_usuario = p_id_usuario
    AND DATE(fecha_registro) = p_fecha_importacion
    AND tipo_pago = 'IMPORTACION';

    LET v_count = SQLCA.SQLERRD[3]; -- Número de filas afectadas

    RETURN 1, 'Importación revertida correctamente', v_count;

END PROCEDURE;
