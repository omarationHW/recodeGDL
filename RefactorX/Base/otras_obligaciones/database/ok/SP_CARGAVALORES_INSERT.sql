--
-- SP_CARGAVALORES_INSERT.sql
-- Descripción: Inserta un nuevo valor/unidad en la tabla t34_unidades
-- Parámetros:
--   par_ejercicio: Ejercicio del valor
--   par_cve_unidad: Clave de unidad
--   par_cve_operatividad: Clave de operatividad
--   par_descripcion: Descripción de la unidad
--   par_costo: Costo del valor
--   par_cve_tab: Clave de la tabla
-- Retorna: success (1 = éxito, 0 = error), message (mensaje descriptivo)
--

DROP PROCEDURE IF EXISTS SP_CARGAVALORES_INSERT;

CREATE PROCEDURE SP_CARGAVALORES_INSERT(
    par_ejercicio INTEGER,
    par_cve_unidad CHAR(1),
    par_cve_operatividad CHAR(1),
    par_descripcion VARCHAR(100),
    par_costo DECIMAL(12,2),
    par_cve_tab CHAR(1)
)

RETURNING
    INTEGER,      -- success (1 = éxito, 0 = error)
    VARCHAR(255); -- message

DEFINE v_max_id INTEGER;
DEFINE v_success INTEGER;
DEFINE v_message VARCHAR(255);

ON EXCEPTION
    IN (-1)
        LET v_success = 0;
        LET v_message = 'Error al insertar el valor en la base de datos';
        RETURN v_success, v_message;
END EXCEPTION;

-- Validaciones
IF par_ejercicio IS NULL OR par_ejercicio < 2000 OR par_ejercicio > 2100 THEN
    LET v_success = 0;
    LET v_message = 'El ejercicio debe estar entre 2000 y 2100';
    RETURN v_success, v_message;
END IF;

IF par_cve_unidad IS NULL OR TRIM(par_cve_unidad) = '' THEN
    LET v_success = 0;
    LET v_message = 'La clave de unidad es requerida';
    RETURN v_success, v_message;
END IF;

IF par_cve_operatividad IS NULL OR TRIM(par_cve_operatividad) = '' THEN
    LET v_success = 0;
    LET v_message = 'La clave de operatividad es requerida';
    RETURN v_success, v_message;
END IF;

IF par_descripcion IS NULL OR TRIM(par_descripcion) = '' THEN
    LET v_success = 0;
    LET v_message = 'La descripción es requerida';
    RETURN v_success, v_message;
END IF;

IF par_costo IS NULL OR par_costo < 0 THEN
    LET v_success = 0;
    LET v_message = 'El costo debe ser mayor o igual a cero';
    RETURN v_success, v_message;
END IF;

IF par_cve_tab IS NULL OR TRIM(par_cve_tab) = '' THEN
    LET v_success = 0;
    LET v_message = 'La clave de tabla es requerida';
    RETURN v_success, v_message;
END IF;

-- Verificar si ya existe un registro con estos datos
IF EXISTS (
    SELECT 1 FROM t34_unidades
    WHERE ejercicio = par_ejercicio
      AND cve_tab = par_cve_tab
      AND cve_unidad = par_cve_unidad
      AND cve_operatividad = par_cve_operatividad
) THEN
    LET v_success = 0;
    LET v_message = 'Ya existe un registro con estos datos (ejercicio, tabla, unidad, operatividad)';
    RETURN v_success, v_message;
END IF;

-- Obtener el MAX(id_34_unidad) para el nuevo ID
SELECT NVL(MAX(id_34_unidad), 0) INTO v_max_id
FROM t34_unidades;

LET v_max_id = v_max_id + 1;

-- Insertar el nuevo registro
INSERT INTO t34_unidades (
    id_34_unidad,
    ejercicio,
    cve_unidad,
    cve_operatividad,
    descripcion,
    costo,
    cve_tab
) VALUES (
    v_max_id,
    par_ejercicio,
    par_cve_unidad,
    par_cve_operatividad,
    par_descripcion,
    par_costo,
    par_cve_tab
);

LET v_success = 1;
LET v_message = 'Valor insertado correctamente con ID: ' || v_max_id;

RETURN v_success, v_message;

END PROCEDURE;
