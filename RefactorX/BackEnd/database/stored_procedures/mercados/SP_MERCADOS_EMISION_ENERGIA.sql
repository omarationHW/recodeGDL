-- =============================================
-- SP_MERCADOS_EMISION_ENERGIA
-- Procedimientos para emisión de recibos de energía eléctrica
-- =============================================

-- Obtener recaudadoras
CREATE PROCEDURE SP_MERCADOS_GET_RECAUDADORAS()
RETURNING
    SMALLINT AS id_rec,
    VARCHAR(100) AS recaudadora;

    FOREACH
        SELECT oficina, descripcion
        INTO id_rec, recaudadora
        FROM recaudadoras
        WHERE oficina > 0
        ORDER BY oficina

        RETURN id_rec, recaudadora WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Obtener mercados por recaudadora
CREATE PROCEDURE SP_MERCADOS_GET_MERCADOS_BY_RECAUDADORA(
    p_oficina SMALLINT
)
RETURNING
    SMALLINT AS num_mercado_nvo,
    VARCHAR(100) AS descripcion;

    FOREACH
        SELECT num_mercado_nvo, descripcion
        INTO num_mercado_nvo, descripcion
        FROM mercados
        WHERE oficina = p_oficina
        ORDER BY num_mercado_nvo

        RETURN num_mercado_nvo, descripcion WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Obtener emisión de energía
CREATE PROCEDURE SP_MERCADOS_GET_EMISION_ENERGIA(
    p_oficina SMALLINT,
    p_mercado SMALLINT,
    p_axo SMALLINT,
    p_periodo SMALLINT
)
RETURNING
    INT AS id_energia,
    INT AS id_local,
    VARCHAR(100) AS local,
    VARCHAR(200) AS nombre,
    VARCHAR(200) AS descripcion,
    DECIMAL(12,2) AS importe,
    VARCHAR(10) AS cve_consumo,
    DECIMAL(12,2) AS cantidad,
    DECIMAL(12,2) AS importe_energia;

    FOREACH
        SELECT
            e.id_energia,
            e.id_local,
            l.local,
            l.nombre,
            l.descripcion_local,
            e.importe,
            e.cve_consumo,
            e.cantidad,
            e.importe_energia
        INTO
            id_energia,
            id_local,
            local,
            nombre,
            descripcion,
            importe,
            cve_consumo,
            cantidad,
            importe_energia
        FROM energia e
        INNER JOIN locales l ON e.id_local = l.id_local
        WHERE l.oficina = p_oficina
          AND l.num_mercado = p_mercado
          AND e.axo = p_axo
          AND e.periodo = p_periodo
        ORDER BY l.local

        RETURN id_energia, id_local, local, nombre, descripcion,
               importe, cve_consumo, cantidad, importe_energia WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Grabar emisión de energía
CREATE PROCEDURE SP_MERCADOS_GRABAR_EMISION_ENERGIA(
    p_oficina SMALLINT,
    p_mercado SMALLINT,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_usuario INT
)

    DEFINE v_count INT;
    DEFINE v_id_local INT;
    DEFINE v_importe DECIMAL(12,2);

    -- Verificar si ya existe emisión
    SELECT COUNT(*) INTO v_count
    FROM energia e
    INNER JOIN locales l ON e.id_local = l.id_local
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_mercado
      AND e.axo = p_axo
      AND e.periodo = p_periodo
      AND e.facturado = 'S';

    IF v_count > 0 THEN
        RAISE EXCEPTION -746, 0, 'Ya existe una emisión facturada para este periodo';
    END IF;

    -- Marcar como facturado
    UPDATE energia
    SET facturado = 'S',
        fecha_modificacion = CURRENT,
        id_usuario = p_usuario
    WHERE id_local IN (
        SELECT l.id_local
        FROM locales l
        WHERE l.oficina = p_oficina
          AND l.num_mercado = p_mercado
    )
    AND axo = p_axo
    AND periodo = p_periodo;

END PROCEDURE;

-- Generar facturación
CREATE PROCEDURE SP_MERCADOS_FACTURACION_ENERGIA(
    p_oficina SMALLINT,
    p_mercado SMALLINT,
    p_axo SMALLINT,
    p_periodo SMALLINT
)
RETURNING
    INT AS id_local,
    VARCHAR(100) AS local,
    VARCHAR(200) AS nombre,
    DECIMAL(12,2) AS importe_energia,
    VARCHAR(10) AS cve_consumo,
    DECIMAL(12,2) AS cantidad;

    FOREACH
        SELECT
            e.id_local,
            l.local,
            l.nombre,
            e.importe_energia,
            e.cve_consumo,
            e.cantidad
        INTO
            id_local,
            local,
            nombre,
            importe_energia,
            cve_consumo,
            cantidad
        FROM energia e
        INNER JOIN locales l ON e.id_local = l.id_local
        WHERE l.oficina = p_oficina
          AND l.num_mercado = p_mercado
          AND e.axo = p_axo
          AND e.periodo = p_periodo
          AND NVL(e.facturado, 'N') = 'S'
        ORDER BY l.local

        RETURN id_local, local, nombre, importe_energia, cve_consumo, cantidad WITH RESUME;
    END FOREACH;

END PROCEDURE;
