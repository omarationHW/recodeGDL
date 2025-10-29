--
-- SP_AUXREP_TABLAS_GET.sql
-- Descripción: Obtiene información de una tabla específica del padrón
-- Parámetros:
--   par_tab: Clave de la tabla a consultar
-- Retorna: Información de la tabla (cve_tab, nombre, descripción)
--

DROP PROCEDURE IF EXISTS SP_AUXREP_TABLAS_GET;

CREATE PROCEDURE SP_AUXREP_TABLAS_GET(
    par_tab INTEGER
)

RETURNING
    VARCHAR(10),  -- cve_tab
    VARCHAR(100), -- nombre
    VARCHAR(255); -- descripcion

DEFINE v_cve_tab VARCHAR(10);
DEFINE v_nombre VARCHAR(100);
DEFINE v_descripcion VARCHAR(255);

ON EXCEPTION
    IN (-1)
        RETURN;
END EXCEPTION;

FOREACH
    SELECT
        a.cve_tab,
        a.nombre,
        b.descripcion
    INTO
        v_cve_tab,
        v_nombre,
        v_descripcion
    FROM t34_tablas a
    INNER JOIN t34_unidades b ON a.cve_tab = b.cve_tab
    WHERE a.cve_tab = par_tab

    RETURN
        v_cve_tab,
        v_nombre,
        v_descripcion
    WITH RESUME;

END FOREACH;

END PROCEDURE;
