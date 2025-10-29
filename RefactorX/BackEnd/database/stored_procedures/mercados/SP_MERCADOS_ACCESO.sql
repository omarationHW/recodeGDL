-- =============================================
-- SP_MERCADOS_ACCESO
-- Procedimientos para control de acceso al sistema
-- =============================================

-- Obtener rango de ejercicios disponibles
CREATE PROCEDURE SP_MERCADOS_GET_EJERCICIO_MIN_MAX()
RETURNING
    SMALLINT AS min_ejercicio,
    SMALLINT AS max_ejercicio;

    SELECT
        2003 AS min_ejercicio,
        YEAR(CURRENT) AS max_ejercicio
    INTO min_ejercicio, max_ejercicio
    FROM DUAL;

    RETURN min_ejercicio, max_ejercicio;

END PROCEDURE;

-- Login al sistema de mercados
CREATE PROCEDURE SP_MERCADOS_LOGIN(
    p_usuario VARCHAR(50),
    p_contrasena VARCHAR(100),
    p_ejercicio SMALLINT
)
RETURNING
    INT AS id_usuario,
    VARCHAR(100) AS nombre_usuario,
    VARCHAR(50) AS username,
    SMALLINT AS ejercicio,
    VARCHAR(1) AS autorizado;

    DEFINE v_count INT;
    DEFINE v_pass_hash VARCHAR(100);

    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_count
    FROM usuarios
    WHERE TRIM(usuario) = TRIM(p_usuario)
      AND activo = 'S';

    IF v_count = 0 THEN
        -- Usuario no existe o inactivo
        SELECT
            0 AS id_usuario,
            '' AS nombre_usuario,
            '' AS username,
            0 AS ejercicio,
            'N' AS autorizado
        INTO id_usuario, nombre_usuario, username, ejercicio, autorizado
        FROM DUAL;

        RETURN id_usuario, nombre_usuario, username, ejercicio, autorizado;
    END IF;

    -- Verificar contraseña (en producción usar hash)
    SELECT
        u.id_usuario,
        NVL(TRIM(u.nombre), '') AS nombre_usuario,
        TRIM(u.usuario) AS username,
        p_ejercicio AS ejercicio,
        CASE
            WHEN TRIM(u.contrasena) = TRIM(p_contrasena) THEN 'S'
            ELSE 'N'
        END AS autorizado
    INTO id_usuario, nombre_usuario, username, ejercicio, autorizado
    FROM usuarios u
    WHERE TRIM(u.usuario) = TRIM(p_usuario)
      AND u.activo = 'S';

    RETURN id_usuario, nombre_usuario, username, ejercicio, autorizado;

END PROCEDURE;
