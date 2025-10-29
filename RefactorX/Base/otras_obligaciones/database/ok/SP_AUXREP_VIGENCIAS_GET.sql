--
-- SP_AUXREP_VIGENCIAS_GET.sql
-- Descripción: Obtiene las opciones de vigencia para filtrar el padrón
-- Parámetros:
--   par_tab: Clave de la tabla a consultar
-- Retorna: Lista de descripciones de vigencias (estados) disponibles
--

DROP PROCEDURE IF EXISTS SP_AUXREP_VIGENCIAS_GET;

CREATE PROCEDURE SP_AUXREP_VIGENCIAS_GET(
    par_tab INTEGER
)

RETURNING
    VARCHAR(50); -- descripcion

DEFINE v_descripcion VARCHAR(50);

ON EXCEPTION
    IN (-1)
        RETURN;
END EXCEPTION;

FOREACH
    SELECT DISTINCT
        b.descripcion
    INTO
        v_descripcion
    FROM t34_datos a
    INNER JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.cve_tab = par_tab
    ORDER BY b.descripcion

    RETURN
        v_descripcion
    WITH RESUME;

END FOREACH;

END PROCEDURE;
