-- =============================================
-- SP_MERCADOS_DATOS_INDIVIDUALES
-- Consulta individual de datos generales de un local
-- =============================================

-- Obtener datos principales del local
CREATE PROCEDURE SP_MERCADOS_GET_DATOS_INDIVIDUALES(
    p_id_local INT
)
RETURNING
    INT AS id_local,
    SMALLINT AS oficina,
    SMALLINT AS num_mercado,
    VARCHAR(200) AS nombre,
    VARCHAR(200) AS arrendatario,
    VARCHAR(255) AS domicilio,
    VARCHAR(50) AS sector,
    VARCHAR(50) AS zona,
    VARCHAR(200) AS descripcion_local,
    DECIMAL(10,2) AS superficie,
    VARCHAR(100) AS giro,
    DATE AS fecha_alta,
    DATE AS fecha_baja,
    DATETIME YEAR TO SECOND AS fecha_modificacion,
    VARCHAR(20) AS vigencia,
    INT AS id_usuario,
    SMALLINT AS categoria,
    SMALLINT AS seccion,
    SMALLINT AS clave_cuota,
    VARCHAR(100) AS local;

    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        NVL(TRIM(l.nombre), '') AS nombre,
        NVL(TRIM(l.arrendatario), '') AS arrendatario,
        NVL(TRIM(l.calle || ' ' || l.num_exterior || ' ' || l.num_interior), '') AS domicilio,
        NVL(l.sector, '') AS sector,
        NVL(l.zona, '') AS zona,
        NVL(l.descripcion_local, '') AS descripcion_local,
        NVL(l.superficie, 0) AS superficie,
        NVL(l.giro, '') AS giro,
        l.fecha_alta,
        l.fecha_baja,
        l.fecha_modificacion,
        CASE WHEN l.vigencia = 'S' THEN 'VIGENTE' ELSE 'BAJA' END AS vigencia,
        l.id_usuario,
        l.categoria,
        l.seccion,
        l.clave_cuota,
        l.local
    INTO
        id_local, oficina, num_mercado, nombre, arrendatario, domicilio,
        sector, zona, descripcion_local, superficie, giro, fecha_alta,
        fecha_baja, fecha_modificacion, vigencia, id_usuario, categoria,
        seccion, clave_cuota, local
    FROM locales l
    WHERE l.id_local = p_id_local;

    RETURN id_local, oficina, num_mercado, nombre, arrendatario, domicilio,
           sector, zona, descripcion_local, superficie, giro, fecha_alta,
           fecha_baja, fecha_modificacion, vigencia, id_usuario, categoria,
           seccion, clave_cuota, local;

END PROCEDURE;

-- Obtener adeudos del local
CREATE PROCEDURE SP_MERCADOS_GET_ADEUDOS(
    p_id_local INT
)
RETURNING
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DECIMAL(12,2) AS importe,
    DECIMAL(12,2) AS recargos;

    FOREACH
        SELECT
            a.axo,
            a.periodo,
            NVL(a.importe, 0) AS importe,
            NVL(a.recargos, 0) AS recargos
        INTO axo, periodo, importe, recargos
        FROM adeudos a
        WHERE a.id_local = p_id_local
        ORDER BY a.axo DESC, a.periodo DESC

        RETURN axo, periodo, importe, recargos WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Obtener requerimientos del local
CREATE PROCEDURE SP_MERCADOS_GET_REQUERIMIENTOS(
    p_id_local INT
)
RETURNING
    VARCHAR(50) AS folio,
    DATE AS fecha_emision,
    DECIMAL(12,2) AS importe_multa,
    DECIMAL(12,2) AS importe_gastos,
    VARCHAR(20) AS vigencia;

    FOREACH
        SELECT
            NVL(r.folio, '') AS folio,
            r.fecha_emision,
            NVL(r.importe_multa, 0) AS importe_multa,
            NVL(r.importe_gastos, 0) AS importe_gastos,
            CASE WHEN r.vigencia = 'S' THEN 'VIGENTE' ELSE 'NO VIGENTE' END AS vigencia
        INTO folio, fecha_emision, importe_multa, importe_gastos, vigencia
        FROM requerimientos r
        WHERE r.id_local = p_id_local
        ORDER BY r.fecha_emision DESC

        RETURN folio, fecha_emision, importe_multa, importe_gastos, vigencia WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Obtener movimientos del local
CREATE PROCEDURE SP_MERCADOS_GET_MOVIMIENTOS(
    p_id_local INT
)
RETURNING
    INT AS id_movimiento,
    SMALLINT AS axo_memo,
    INT AS numero_memo,
    VARCHAR(200) AS nombre,
    VARCHAR(100) AS tipo_movimiento,
    DATE AS fecha;

    FOREACH
        SELECT
            m.id_movimiento,
            NVL(m.axo_memo, 0) AS axo_memo,
            NVL(m.numero_memo, 0) AS numero_memo,
            NVL(TRIM(m.nombre), '') AS nombre,
            NVL(tm.descripcion, '') AS tipo_movimiento,
            m.fecha
        INTO id_movimiento, axo_memo, numero_memo, nombre, tipo_movimiento, fecha
        FROM movimientos m
        LEFT JOIN tipos_movimiento tm ON m.tipo_movimiento = tm.tipo_movimiento
        WHERE m.id_local = p_id_local
        ORDER BY m.fecha DESC

        RETURN id_movimiento, axo_memo, numero_memo, nombre, tipo_movimiento, fecha WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Obtener datos de mercado
CREATE PROCEDURE SP_MERCADOS_GET_MERCADO_INFO(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT
)
RETURNING VARCHAR(200) AS descripcion;

    SELECT NVL(descripcion, '') INTO descripcion
    FROM mercados
    WHERE oficina = p_oficina
      AND num_mercado_nvo = p_num_mercado;

    RETURN descripcion;

END PROCEDURE;

-- Obtener cuota actual
CREATE PROCEDURE SP_MERCADOS_GET_CUOTA_ACTUAL(
    p_axo SMALLINT,
    p_categoria SMALLINT,
    p_seccion SMALLINT,
    p_clave_cuota SMALLINT
)
RETURNING DECIMAL(12,2) AS renta;

    SELECT NVL(importe, 0) INTO renta
    FROM cuotas
    WHERE axo = p_axo
      AND categoria = p_categoria
      AND seccion = p_seccion
      AND clave_cuota = p_clave_cuota;

    RETURN renta;

END PROCEDURE;
