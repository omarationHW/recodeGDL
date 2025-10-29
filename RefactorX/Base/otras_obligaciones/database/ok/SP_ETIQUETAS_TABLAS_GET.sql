--
-- SP_ETIQUETAS_TABLAS_GET.sql
-- Descripción: Obtiene todas las tablas disponibles del sistema ordenadas por auto_tab
-- Parámetros: Ninguno
-- Retorna: Lista de tablas (id_34_tab, cve_tab, nombre, cajero, auto_tab)
--

DROP PROCEDURE IF EXISTS SP_ETIQUETAS_TABLAS_GET;

CREATE PROCEDURE SP_ETIQUETAS_TABLAS_GET()

RETURNING
    INTEGER,      -- id_34_tab
    VARCHAR(1),   -- cve_tab
    VARCHAR(100), -- nombre
    VARCHAR(1),   -- cajero
    SMALLINT;     -- auto_tab

DEFINE v_id_34_tab INTEGER;
DEFINE v_cve_tab VARCHAR(1);
DEFINE v_nombre VARCHAR(100);
DEFINE v_cajero VARCHAR(1);
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
