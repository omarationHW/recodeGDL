-- =============================================
-- SP_MERCADOS_CONDONACION
-- Gestión de condonaciones de adeudos
-- =============================================

CREATE PROCEDURE SP_MERCADOS_GET_LOCAL_BY_KEY(
    p_oficina SMALLINT,
    p_num_mercado SMALLINT,
    p_categoria SMALLINT,
    p_seccion VARCHAR(2),
    p_local VARCHAR(7),
    p_letra_local VARCHAR(1),
    p_bloque VARCHAR(1)
)
RETURNING
    INT AS id_local,
    VARCHAR(200) AS nombre,
    VARCHAR(200) AS descripcion_local,
    DECIMAL(10,2) AS superficie,
    SMALLINT AS clave_cuota;

    SELECT
        l.id_local,
        NVL(TRIM(l.nombre), '') AS nombre,
        NVL(TRIM(l.descripcion_local), '') AS descripcion_local,
        NVL(l.superficie, 0) AS superficie,
        NVL(l.clave_cuota, 0) AS clave_cuota
    INTO id_local, nombre, descripcion_local, superficie, clave_cuota
    FROM locales l
    WHERE l.oficina = p_oficina
      AND l.num_mercado = p_num_mercado
      AND l.categoria = p_categoria
      AND l.seccion = p_seccion
      AND l.local = p_local
      AND (p_letra_local IS NULL OR l.letra_local = p_letra_local)
      AND (p_bloque IS NULL OR l.bloque = p_bloque);

    RETURN id_local, nombre, descripcion_local, superficie, clave_cuota;

END PROCEDURE;

CREATE PROCEDURE SP_MERCADOS_LISTAR_ADEUDOS_CONDONAR(
    p_id_local INT
)
RETURNING
    SMALLINT AS expression_1,
    SMALLINT AS expression_2,
    DECIMAL(12,2) AS expression_3,
    VARCHAR(100) AS expression_4;

    FOREACH
        SELECT
            a.axo AS expression_1,
            a.periodo AS expression_2,
            NVL(a.importe, 0) AS expression_3,
            TRIM(TO_CHAR(a.axo)) || '/' || TRIM(TO_CHAR(a.periodo)) AS expression_4
        INTO expression_1, expression_2, expression_3, expression_4
        FROM adeudos a
        WHERE a.id_local = p_id_local
        ORDER BY a.axo, a.periodo

        RETURN expression_1, expression_2, expression_3, expression_4 WITH RESUME;
    END FOREACH;

END PROCEDURE;

CREATE PROCEDURE SP_MERCADOS_CONDONAR_ADEUDOS(
    p_id_local INT,
    p_oficio VARCHAR(13),
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_importe DECIMAL(12,2),
    p_id_usuario INT
)

    -- Insertar en tabla de condonaciones/cancelaciones
    INSERT INTO cancelaciones (
        id_local,
        axo,
        periodo,
        importe,
        observacion,
        fecha_alta,
        id_usuario
    ) VALUES (
        p_id_local,
        p_axo,
        p_periodo,
        p_importe,
        'CONDONACION: ' || p_oficio,
        CURRENT,
        p_id_usuario
    );

    -- Eliminar de adeudos
    DELETE FROM adeudos
    WHERE id_local = p_id_local
      AND axo = p_axo
      AND periodo = p_periodo;

END PROCEDURE;

CREATE PROCEDURE SP_MERCADOS_LISTAR_CONDONADOS(
    p_id_local INT
)
RETURNING
    INT AS id_cancelacion,
    INT AS id_local,
    SMALLINT AS axo,
    SMALLINT AS periodo,
    DECIMAL(12,2) AS importe,
    VARCHAR(255) AS observacion;

    FOREACH
        SELECT
            c.id_cancelacion,
            c.id_local,
            c.axo,
            c.periodo,
            NVL(c.importe, 0) AS importe,
            NVL(TRIM(c.observacion), '') AS observacion
        INTO id_cancelacion, id_local, axo, periodo, importe, observacion
        FROM cancelaciones c
        WHERE c.id_local = p_id_local
        ORDER BY c.axo DESC, c.periodo DESC

        RETURN id_cancelacion, id_local, axo, periodo, importe, observacion WITH RESUME;
    END FOREACH;

END PROCEDURE;

CREATE PROCEDURE SP_MERCADOS_DESHACER_CONDONACION(
    p_id_cancelacion INT,
    p_id_local INT,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_importe DECIMAL(12,2)
)

    -- Restaurar adeudo
    INSERT INTO adeudos (
        id_local,
        axo,
        periodo,
        importe,
        recargos
    ) VALUES (
        p_id_local,
        p_axo,
        p_periodo,
        p_importe,
        0
    );

    -- Eliminar condonación
    DELETE FROM cancelaciones
    WHERE id_cancelacion = p_id_cancelacion;

END PROCEDURE;
