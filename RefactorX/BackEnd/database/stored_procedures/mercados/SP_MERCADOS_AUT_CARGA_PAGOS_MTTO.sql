-- ================================================================
-- STORED PROCEDURES PARA MANTENIMIENTO DE FECHAS AUTORIZADAS
-- ================================================================

-- Obtener usuarios con permiso
CREATE PROCEDURE SP_MERCADOS_GET_USUARIOS_PERMISO()
RETURNING
    INT AS id_usuario,
    VARCHAR(100) AS nombre,
    VARCHAR(50) AS usuario;

    FOREACH
        SELECT
            id_usuario,
            NVL(nombre, ' ') AS nombre,
            NVL(usuario, ' ') AS usuario
        INTO id_usuario, nombre, usuario
        FROM usuarios
        WHERE activo = 'S'
        ORDER BY nombre

        RETURN id_usuario, nombre, usuario WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Obtener fechas autorizadas
CREATE PROCEDURE SP_MERCADOS_GET_FECHAS_AUTORIZADAS(
    p_oficina SMALLINT
)
RETURNING
    DATE AS fecha_ingreso,
    CHAR(1) AS autorizar,
    DATE AS fecha_limite,
    INT AS id_usupermiso,
    VARCHAR(100) AS nombre,
    VARCHAR(500) AS comentarios,
    DATETIME YEAR TO SECOND AS actualizacion;

    FOREACH
        SELECT
            fa.fecha_ingreso,
            NVL(fa.autorizar, 'S') AS autorizar,
            fa.fecha_limite,
            fa.id_usupermiso,
            NVL(u.nombre, ' ') AS nombre,
            NVL(fa.comentarios, ' ') AS comentarios,
            fa.actualizacion
        INTO
            fecha_ingreso, autorizar, fecha_limite,
            id_usupermiso, nombre, comentarios, actualizacion
        FROM aut_carga_pagos fa
        LEFT JOIN usuarios u ON u.id_usuario = fa.id_usupermiso
        WHERE fa.oficina = p_oficina
        ORDER BY fa.fecha_ingreso DESC

        RETURN fecha_ingreso, autorizar, fecha_limite,
               id_usupermiso, nombre, comentarios, actualizacion WITH RESUME;
    END FOREACH;

END PROCEDURE;

-- Insertar fecha autorizada
CREATE PROCEDURE SP_MERCADOS_INSERT_FECHA_AUTORIZADA(
    p_fecha_ingreso DATE,
    p_oficina SMALLINT,
    p_autorizar CHAR(1),
    p_fecha_limite DATE,
    p_id_usupermiso INT,
    p_comentarios VARCHAR(500)
)
RETURNING INT AS resultado;

    DEFINE v_resultado INT;
    DEFINE v_count INT;

    ON EXCEPTION
        SET resultado
        LET v_resultado = -1;
        RETURN v_resultado;
    END EXCEPTION;

    -- Verificar si ya existe
    SELECT COUNT(*) INTO v_count
    FROM aut_carga_pagos
    WHERE fecha_ingreso = p_fecha_ingreso
      AND oficina = p_oficina;

    IF v_count > 0 THEN
        LET v_resultado = -2; -- Ya existe
        RETURN v_resultado;
    END IF;

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
        TRIM(UPPER(p_comentarios)),
        CURRENT YEAR TO SECOND
    );

    LET v_resultado = 1;
    RETURN v_resultado;

END PROCEDURE;

-- Actualizar fecha autorizada
CREATE PROCEDURE SP_MERCADOS_UPDATE_FECHA_AUTORIZADA(
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
        comentarios = TRIM(UPPER(p_comentarios)),
        actualizacion = CURRENT YEAR TO SECOND
    WHERE fecha_ingreso = p_fecha_ingreso
      AND oficina = p_oficina;

    LET v_resultado = 1;
    RETURN v_resultado;

END PROCEDURE;
