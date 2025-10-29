--
-- SP_CARGACARTERA_EJERCICIOS_GET.sql
-- Descripción: Obtiene los ejercicios disponibles para una tabla específica
-- Parámetros:
--   par_cve_tab: Clave de la tabla
-- Retorna: Lista de ejercicios agrupados
--

DROP PROCEDURE IF EXISTS SP_CARGACARTERA_EJERCICIOS_GET;

CREATE PROCEDURE SP_CARGACARTERA_EJERCICIOS_GET(
    par_cve_tab CHAR(1)
)

RETURNING
    INTEGER; -- ejercicio

DEFINE v_ejercicio INTEGER;

ON EXCEPTION
    IN (-1)
        RETURN;
END EXCEPTION;

FOREACH
    SELECT ejercicio
    INTO v_ejercicio
    FROM t34_unidades
    WHERE cve_tab = par_cve_tab
    GROUP BY ejercicio
    ORDER BY ejercicio

    RETURN v_ejercicio WITH RESUME;

END FOREACH;

END PROCEDURE;
