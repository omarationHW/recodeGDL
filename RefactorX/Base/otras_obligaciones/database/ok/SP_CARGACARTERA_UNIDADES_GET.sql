--
-- SP_CARGACARTERA_UNIDADES_GET.sql
-- Descripción: Obtiene las unidades para una tabla y ejercicio específicos
-- Parámetros:
--   par_cve_tab: Clave de la tabla
--   par_ejer: Ejercicio
-- Retorna: Lista de unidades con sus datos
--

DROP PROCEDURE IF EXISTS SP_CARGACARTERA_UNIDADES_GET;

CREATE PROCEDURE SP_CARGACARTERA_UNIDADES_GET(
    par_cve_tab CHAR(1),
    par_ejer INTEGER
)

RETURNING
    INTEGER,      -- ejercicio
    CHAR(1),      -- cve_unidad
    CHAR(1),      -- cve_operatividad
    VARCHAR(100), -- descripcion
    DECIMAL(10,2); -- costo

DEFINE v_ejercicio INTEGER;
DEFINE v_cve_unidad CHAR(1);
DEFINE v_cve_operatividad CHAR(1);
DEFINE v_descripcion VARCHAR(100);
DEFINE v_costo DECIMAL(10,2);

ON EXCEPTION
    IN (-1)
        RETURN;
END EXCEPTION;

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
      AND ejercicio = par_ejer

    RETURN
        v_ejercicio,
        v_cve_unidad,
        v_cve_operatividad,
        v_descripcion,
        v_costo
    WITH RESUME;

END FOREACH;

END PROCEDURE;
