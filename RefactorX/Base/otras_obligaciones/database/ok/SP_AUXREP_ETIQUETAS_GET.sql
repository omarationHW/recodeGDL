--
-- SP_AUXREP_ETIQUETAS_GET.sql
-- Descripción: Obtiene las etiquetas de columnas para una tabla específica
-- Parámetros:
--   par_tab: Clave de la tabla a consultar
-- Retorna: Etiquetas personalizadas de las columnas
--

DROP PROCEDURE IF EXISTS SP_AUXREP_ETIQUETAS_GET;

CREATE PROCEDURE SP_AUXREP_ETIQUETAS_GET(
    par_tab INTEGER
)

RETURNING
    VARCHAR(10),  -- cve_tab
    VARCHAR(10),  -- abreviatura
    VARCHAR(50),  -- etiq_control
    VARCHAR(50),  -- concesionario
    VARCHAR(50),  -- ubicacion
    VARCHAR(50),  -- superficie
    VARCHAR(50),  -- fecha_inicio
    VARCHAR(50),  -- fecha_fin
    VARCHAR(50),  -- recaudadora
    VARCHAR(50),  -- sector
    VARCHAR(50),  -- zona
    VARCHAR(50),  -- licencia
    VARCHAR(50),  -- fecha_cancelacion
    VARCHAR(50),  -- unidad
    VARCHAR(50),  -- categoria
    VARCHAR(50),  -- seccion
    VARCHAR(50),  -- bloque
    VARCHAR(50),  -- nombre_comercial
    VARCHAR(50),  -- lugar
    VARCHAR(255); -- obs

DEFINE v_cve_tab VARCHAR(10);
DEFINE v_abreviatura VARCHAR(10);
DEFINE v_etiq_control VARCHAR(50);
DEFINE v_concesionario VARCHAR(50);
DEFINE v_ubicacion VARCHAR(50);
DEFINE v_superficie VARCHAR(50);
DEFINE v_fecha_inicio VARCHAR(50);
DEFINE v_fecha_fin VARCHAR(50);
DEFINE v_recaudadora VARCHAR(50);
DEFINE v_sector VARCHAR(50);
DEFINE v_zona VARCHAR(50);
DEFINE v_licencia VARCHAR(50);
DEFINE v_fecha_cancelacion VARCHAR(50);
DEFINE v_unidad VARCHAR(50);
DEFINE v_categoria VARCHAR(50);
DEFINE v_seccion VARCHAR(50);
DEFINE v_bloque VARCHAR(50);
DEFINE v_nombre_comercial VARCHAR(50);
DEFINE v_lugar VARCHAR(50);
DEFINE v_obs VARCHAR(255);

ON EXCEPTION
    IN (-1)
        RETURN;
END EXCEPTION;

FOREACH
    SELECT
        cve_tab,
        abreviatura,
        etiq_control,
        concesionario,
        ubicacion,
        superficie,
        fecha_inicio,
        fecha_fin,
        recaudadora,
        sector,
        zona,
        licencia,
        fecha_cancelacion,
        unidad,
        categoria,
        seccion,
        bloque,
        nombre_comercial,
        lugar,
        obs
    INTO
        v_cve_tab,
        v_abreviatura,
        v_etiq_control,
        v_concesionario,
        v_ubicacion,
        v_superficie,
        v_fecha_inicio,
        v_fecha_fin,
        v_recaudadora,
        v_sector,
        v_zona,
        v_licencia,
        v_fecha_cancelacion,
        v_unidad,
        v_categoria,
        v_seccion,
        v_bloque,
        v_nombre_comercial,
        v_lugar,
        v_obs
    FROM t34_etiq
    WHERE cve_tab = par_tab

    RETURN
        v_cve_tab,
        v_abreviatura,
        v_etiq_control,
        v_concesionario,
        v_ubicacion,
        v_superficie,
        v_fecha_inicio,
        v_fecha_fin,
        v_recaudadora,
        v_sector,
        v_zona,
        v_licencia,
        v_fecha_cancelacion,
        v_unidad,
        v_categoria,
        v_seccion,
        v_bloque,
        v_nombre_comercial,
        v_lugar,
        v_obs
    WITH RESUME;

END FOREACH;

END PROCEDURE;
