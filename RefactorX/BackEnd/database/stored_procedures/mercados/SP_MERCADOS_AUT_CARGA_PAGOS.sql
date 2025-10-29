-- ================================================================
-- STORED PROCEDURES PARA AUTORIZACIÓN DE CARGA DE PAGOS
-- ================================================================

-- Listar autorizaciones de carga de pagos
CREATE PROCEDURE SP_MERCADOS_GET_AUT_CARGA_PAGOS()
RETURNING
    DATE AS fecha_ingreso,
    SMALLINT AS oficina,
    CHAR(1) AS autorizar,
    DATE AS fecha_limite,
    INT AS id_usupermiso,
    VARCHAR(100) AS nombre,
    VARCHAR(50) AS usuario,
    DATETIME YEAR TO SECOND AS actualizacion,
    VARCHAR(500) AS comentarios;

    FOREACH
        SELECT
            acp.fecha_ingreso,
            acp.oficina,
            NVL(acp.autorizar, 'N') AS autorizar,
            acp.fecha_limite,
            acp.id_usupermiso,
            NVL(u.nombre, ' ') AS nombre,
            NVL(u.usuario, ' ') AS usuario,
            acp.actualizacion,
            NVL(acp.comentarios, ' ') AS comentarios
        INTO
            fecha_ingreso, oficina, autorizar, fecha_limite,
            id_usupermiso, nombre, usuario, actualizacion, comentarios
        FROM aut_carga_pagos acp
        LEFT JOIN usuarios u ON u.id_usuario = acp.id_usupermiso
        ORDER BY acp.fecha_ingreso DESC

        RETURN fecha_ingreso, oficina, autorizar, fecha_limite,
               id_usupermiso, nombre, usuario, actualizacion,
               comentarios WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Insertar autorización de carga de pagos
CREATE PROCEDURE SP_MERCADOS_INSERT_AUT_CARGA_PAGOS(
    p_fecha_ingreso DATE,
    p_oficina SMALLINT,
    p_autorizar CHAR(1),
    p_fecha_limite DATE,
    p_id_usupermiso INT,
    p_comentarios VARCHAR(500)
)
RETURNING INT AS resultado;

    DEFINE v_resultado INT;

    ON EXCEPTION
        SET resultado
        LET v_resultado = -1;
        RETURN v_resultado;
    END EXCEPTION;

    INSERT INTO aut_carga_pagos (
        fecha_ingreso,
        oficina,
        autorizar,
        fecha_limite,
        id_usupermiso,
        comentarios,
        actualizacion
    ) VALUES (
        p_fecha_ingreso,
        p_oficina,
        p_autorizar,
        p_fecha_limite,
        p_id_usupermiso,
        TRIM(p_comentarios),
        CURRENT YEAR TO SECOND
    );

    LET v_resultado = 1;
    RETURN v_resultado;

END PROCEDURE;

-- Actualizar autorización de carga de pagos
CREATE PROCEDURE SP_MERCADOS_UPDATE_AUT_CARGA_PAGOS(
    p_fecha_ingreso DATE,
    p_oficina SMALLINT,
    p_autorizar CHAR(1),
    p_fecha_limite DATE,
    p_id_usupermiso INT,
    p_comentarios VARCHAR(500)
)
RETURNING INT AS resultado;

    DEFINE v_resultado INT;

    ON EXCEPTION
        SET resultado
        LET v_resultado = -1;
        RETURN v_resultado;
    END EXCEPTION;

    UPDATE aut_carga_pagos
    SET autorizar = p_autorizar,
        fecha_limite = p_fecha_limite,
        id_usupermiso = p_id_usupermiso,
        comentarios = TRIM(p_comentarios),
        actualizacion = CURRENT YEAR TO SECOND
    WHERE fecha_ingreso = p_fecha_ingreso
      AND oficina = p_oficina;

    LET v_resultado = 1;
    RETURN v_resultado;

END PROCEDURE;
