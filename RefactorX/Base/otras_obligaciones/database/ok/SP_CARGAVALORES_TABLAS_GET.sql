--
-- SP_CARGAVALORES_TABLAS_GET.sql
-- Descripción: Obtiene el listado de tablas disponibles para carga de valores
-- Parámetros: Ninguno
-- Retorna: Lista de tablas (id_34_tab, cve_tab, nombre, cajero, auto_tab)
--

DROP PROCEDURE IF EXISTS SP_CARGAVALORES_TABLAS_GET;

CREATE PROCEDURE SP_CARGAVALORES_TABLAS_GET()

RETURNING
    INTEGER,    -- id_34_tab
    CHAR(1),    -- cve_tab
    VARCHAR(100), -- nombre
    CHAR(1),    -- cajero
    SMALLINT;   -- auto_tab

DEFINE v_id_34_tab INTEGER;
DEFINE v_cve_tab CHAR(1);
DEFINE v_nombre VARCHAR(100);
DEFINE v_cajero CHAR(1);
DEFINE v_auto_tab SMALLINT;

ON EXCEPTION
    IN (-1)
        RETURN;
END EXCEPTION;

FOREACH
    SELECT
        id_34_tab,
        cve_tab,
        nombre,
        cajero,
        auto_tab
    INTO
        v_id_34_tab,
        v_cve_tab,
        v_nombre,
        v_cajero,
        v_auto_tab
    FROM t34_tablas
    WHERE auto_tab > 0
    ORDER BY auto_tab

    RETURN
        v_id_34_tab,
        v_cve_tab,
        v_nombre,
        v_cajero,
        v_auto_tab
    WITH RESUME;

END FOREACH;

END PROCEDURE;
