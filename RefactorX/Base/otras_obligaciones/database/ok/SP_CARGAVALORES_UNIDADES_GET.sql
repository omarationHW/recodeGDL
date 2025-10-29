--
-- SP_CARGAVALORES_UNIDADES_GET.sql
-- Descripción: Obtiene las unidades existentes para una tabla específica del ejercicio actual
--              Para pre-cargar los datos en el grid de carga de valores del siguiente ejercicio
-- Parámetros:
--   par_cve_tab: Clave de la tabla
-- Retorna: Lista de unidades del ejercicio actual (ejercicio, cve_unidad, cve_operatividad, descripcion, costo)
--

DROP PROCEDURE IF EXISTS SP_CARGAVALORES_UNIDADES_GET;

CREATE PROCEDURE SP_CARGAVALORES_UNIDADES_GET(
    par_cve_tab CHAR(1)
)

RETURNING
    INTEGER,      -- ejercicio
    CHAR(1),      -- cve_unidad
    CHAR(1),      -- cve_operatividad
    VARCHAR(100), -- descripcion
    DECIMAL(12,2); -- costo

DEFINE v_ejercicio INTEGER;
DEFINE v_cve_unidad CHAR(1);
DEFINE v_cve_operatividad CHAR(1);
DEFINE v_descripcion VARCHAR(100);
DEFINE v_costo DECIMAL(12,2);
DEFINE v_ejercicio_actual INTEGER;

ON EXCEPTION
    IN (-1)
        RETURN;
END EXCEPTION;

-- Obtener el ejercicio actual
LET v_ejercicio_actual = YEAR(CURRENT);

FOREACH
    SELECT
        ejercicio,
        cve_unidad,
        cve_operatividad,
        descripcion,
        costo
    INTO
        v_ejercicio,
        v_cve_unidad,
        v_cve_operatividad,
        v_descripcion,
        v_costo
    FROM t34_unidades
    WHERE cve_tab = par_cve_tab
      AND ejercicio = v_ejercicio_actual
    ORDER BY cve_unidad, cve_operatividad

    RETURN
        v_ejercicio,
        v_cve_unidad,
        v_cve_operatividad,
        v_descripcion,
        v_costo
    WITH RESUME;

END FOREACH;

END PROCEDURE;
