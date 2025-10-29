--
-- SP_ETIQUETAS_GET.sql
-- Descripción: Obtiene las etiquetas personalizadas para una tabla específica
-- Parámetros:
--   p_cve_tab: Clave de la tabla (VARCHAR)
-- Retorna: Registro de etiquetas con todos sus campos
--

DROP PROCEDURE IF EXISTS SP_ETIQUETAS_GET;

CREATE PROCEDURE SP_ETIQUETAS_GET(
    p_cve_tab VARCHAR(2)
)

RETURNING
    VARCHAR(2),   -- cve_tab
    VARCHAR(4),   -- abreviatura
    VARCHAR(20),  -- etiq_control
    VARCHAR(20),  -- concesionario
    VARCHAR(20),  -- ubicacion
    VARCHAR(20),  -- superficie
    VARCHAR(20),  -- fecha_inicio
    VARCHAR(20),  -- fecha_fin
    VARCHAR(20),  -- recaudadora
    VARCHAR(20),  -- sector
    VARCHAR(20),  -- zona
    VARCHAR(20),  -- licencia
    VARCHAR(20),  -- fecha_cancelacion
    VARCHAR(20),  -- unidad
    VARCHAR(20),  -- categoria
    VARCHAR(20),  -- seccion
    VARCHAR(20),  -- bloque
    VARCHAR(20),  -- nombre_comercial
    VARCHAR(20),  -- lugar
    VARCHAR(20);  -- obs

DEFINE v_cve_tab VARCHAR(2);
DEFINE v_abreviatura VARCHAR(4);
DEFINE v_etiq_control VARCHAR(20);
DEFINE v_concesionario VARCHAR(20);
DEFINE v_ubicacion VARCHAR(20);
DEFINE v_superficie VARCHAR(20);
DEFINE v_fecha_inicio VARCHAR(20);
DEFINE v_fecha_fin VARCHAR(20);
DEFINE v_recaudadora VARCHAR(20);
DEFINE v_sector VARCHAR(20);
DEFINE v_zona VARCHAR(20);
DEFINE v_licencia VARCHAR(20);
DEFINE v_fecha_cancelacion VARCHAR(20);
DEFINE v_unidad VARCHAR(20);
DEFINE v_categoria VARCHAR(20);
DEFINE v_seccion VARCHAR(20);
DEFINE v_bloque VARCHAR(20);
DEFINE v_nombre_comercial VARCHAR(20);
DEFINE v_lugar VARCHAR(20);
DEFINE v_obs VARCHAR(20);

ON EXCEPTION
    IN (-1)
        RETURN;
END EXCEPTION;

FOREACH
    SELECT
        cve_tab,
        NVL(abreviatura, ' '),
        NVL(etiq_control, ' '),
        NVL(concesionario, ' '),
        NVL(ubicacion, ' '),
        NVL(superficie, ' '),
        NVL(fecha_inicio, ' '),
        NVL(fecha_fin, ' '),
        NVL(recaudadora, ' '),
        NVL(sector, ' '),
        NVL(zona, ' '),
        NVL(licencia, ' '),
        NVL(fecha_cancelacion, ' '),
        NVL(unidad, ' '),
        NVL(categoria, ' '),
        NVL(seccion, ' '),
        NVL(bloque, ' '),
        NVL(nombre_comercial, ' '),
        NVL(lugar, ' '),
        NVL(obs, ' ')
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
    WHERE cve_tab = p_cve_tab

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
