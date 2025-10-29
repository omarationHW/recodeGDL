-- =============================================
-- SP_MERCADOS_DATOS_CONVENIO
-- Consulta de datos de convenios
-- =============================================

-- Obtener datos del convenio por ID
CREATE PROCEDURE SP_MERCADOS_GET_CONVENIO_BY_ID(
    p_id_conv INT
)
RETURNING
    INT AS id_conv,
    INT AS id_local,
    VARCHAR(100) AS descripcion,
    VARCHAR(100) AS desc_subtipo,
    VARCHAR(200) AS nombre,
    VARCHAR(100) AS calle,
    VARCHAR(20) AS num_exterior,
    VARCHAR(20) AS num_interior,
    VARCHAR(10) AS inciso,
    VARCHAR(50) AS convenio,
    VARCHAR(20) AS estado,
    VARCHAR(255) AS observaciones,
    SMALLINT AS periodos,
    DECIMAL(12,2) AS total,
    DECIMAL(12,2) AS importe,
    DECIMAL(12,2) AS cantidad_inicio,
    DECIMAL(12,2) AS pago_parcial,
    DECIMAL(12,2) AS pago_final,
    DECIMAL(12,2) AS recargos,
    DECIMAL(12,2) AS gastos,
    DECIMAL(12,2) AS multa,
    DECIMAL(12,2) AS total_pagos,
    VARCHAR(50) AS tipodesc,
    DATE AS fecha_inicio,
    DATE AS fecha_venc;

    SELECT
        c.id_conv,
        c.id_local,
        NVL(t.descripcion, '') AS descripcion,
        NVL(st.descripcion, '') AS desc_subtipo,
        NVL(l.nombre, '') AS nombre,
        NVL(l.calle, '') AS calle,
        NVL(l.num_exterior, '') AS num_exterior,
        NVL(l.num_interior, '') AS num_interior,
        NVL(c.inciso, '') AS inciso,
        NVL(c.convenio, '') AS convenio,
        CASE WHEN c.vigencia = 'S' THEN 'VIGENTE' ELSE 'NO VIGENTE' END AS estado,
        NVL(c.observaciones, '') AS observaciones,
        NVL(c.periodos, 0) AS periodos,
        NVL(c.total, 0) AS total,
        NVL(c.importe, 0) AS importe,
        NVL(c.cantidad_inicio, 0) AS cantidad_inicio,
        NVL(c.pago_parcial, 0) AS pago_parcial,
        NVL(c.pago_final, 0) AS pago_final,
        NVL(c.recargos, 0) AS recargos,
        NVL(c.gastos, 0) AS gastos,
        NVL(c.multa, 0) AS multa,
        NVL(c.total_pagos, 0) AS total_pagos,
        NVL(tp.descripcion, '') AS tipodesc,
        c.fecha_inicio,
        c.fecha_venc
    INTO
        id_conv, id_local, descripcion, desc_subtipo, nombre, calle,
        num_exterior, num_interior, inciso, convenio, estado, observaciones,
        periodos, total, importe, cantidad_inicio, pago_parcial, pago_final,
        recargos, gastos, multa, total_pagos, tipodesc, fecha_inicio, fecha_venc
    FROM convenios c
    LEFT JOIN locales l ON c.id_local = l.id_local
    LEFT JOIN tipos_convenio t ON c.tipo = t.tipo
    LEFT JOIN subtipos_convenio st ON c.subtipo = st.subtipo
    LEFT JOIN tipos_pago tp ON c.tipo_pago = tp.tipo_pago
    WHERE c.id_conv = p_id_conv;

    RETURN id_conv, id_local, descripcion, desc_subtipo, nombre, calle,
           num_exterior, num_interior, inciso, convenio, estado, observaciones,
           periodos, total, importe, cantidad_inicio, pago_parcial, pago_final,
           recargos, gastos, multa, total_pagos, tipodesc, fecha_inicio, fecha_venc;

END PROCEDURE;

-- Obtener parcialidades del convenio
CREATE PROCEDURE SP_MERCADOS_GET_CONVENIO_PARCIALES(
    p_id_conv INT
)
RETURNING
    SMALLINT AS pago_parcial_1,
    VARCHAR(50) AS descparc,
    DECIMAL(12,2) AS importe,
    VARCHAR(100) AS peradeudos,
    DATE AS fecha_pago,
    SMALLINT AS oficina_pago,
    SMALLINT AS caja_pago,
    INT AS operacion_pago;

    FOREACH
        SELECT
            p.pago_parcial_1,
            NVL(p.descparc, '') AS descparc,
            NVL(p.importe, 0) AS importe,
            NVL(p.peradeudos, '') AS peradeudos,
            p.fecha_pago,
            NVL(p.oficina_pago, 0) AS oficina_pago,
            NVL(p.caja_pago, 0) AS caja_pago,
            NVL(p.operacion_pago, 0) AS operacion_pago
        INTO
            pago_parcial_1,
            descparc,
            importe,
            peradeudos,
            fecha_pago,
            oficina_pago,
            caja_pago,
            operacion_pago
        FROM parcialidades p
        WHERE p.id_conv = p_id_conv
        ORDER BY p.pago_parcial_1

        RETURN pago_parcial_1, descparc, importe, peradeudos,
               fecha_pago, oficina_pago, caja_pago, operacion_pago WITH RESUME;
    END FOREACH;

END PROCEDURE;
