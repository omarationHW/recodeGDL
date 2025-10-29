--
-- SP_AUXREP_PADRON_GET.sql
-- Descripción: Obtiene los datos del padrón según tabla y vigencia
-- Parámetros:
--   par_tabla: Clave de la tabla a consultar
--   par_vigencia: Filtro de vigencia ('TODOS' o descripción específica)
-- Retorna: Registros del padrón con información del concesionario
--

DROP PROCEDURE IF EXISTS SP_AUXREP_PADRON_GET;

CREATE PROCEDURE SP_AUXREP_PADRON_GET(
    par_tabla INTEGER,
    par_vigencia VARCHAR(50)
)

RETURNING
    INTEGER,      -- id_34_datos
    VARCHAR(50),  -- control
    VARCHAR(255), -- concesionario
    VARCHAR(255), -- ubicacion
    VARCHAR(100), -- nomcomercial
    VARCHAR(100), -- lugar
    VARCHAR(255), -- obs
    VARCHAR(50),  -- statusregistro
    VARCHAR(50),  -- unidades
    VARCHAR(50),  -- categoria
    VARCHAR(50),  -- seccion
    VARCHAR(50),  -- bloque
    VARCHAR(50),  -- sector
    DECIMAL(16,2), -- superficie
    DATE,         -- fechainicio
    DATE,         -- fechafin
    INTEGER,      -- recaudadora
    INTEGER,      -- zona
    INTEGER,      -- licencia
    INTEGER,      -- giro
    VARCHAR(50);  -- tipoobligacion

DEFINE v_id_34_datos INTEGER;
DEFINE v_control VARCHAR(50);
DEFINE v_concesionario VARCHAR(255);
DEFINE v_ubicacion VARCHAR(255);
DEFINE v_nomcomercial VARCHAR(100);
DEFINE v_lugar VARCHAR(100);
DEFINE v_obs VARCHAR(255);
DEFINE v_statusregistro VARCHAR(50);
DEFINE v_unidades VARCHAR(50);
DEFINE v_categoria VARCHAR(50);
DEFINE v_seccion VARCHAR(50);
DEFINE v_bloque VARCHAR(50);
DEFINE v_sector VARCHAR(50);
DEFINE v_superficie DECIMAL(16,2);
DEFINE v_fechainicio DATE;
DEFINE v_fechafin DATE;
DEFINE v_recaudadora INTEGER;
DEFINE v_zona INTEGER;
DEFINE v_licencia INTEGER;
DEFINE v_giro INTEGER;
DEFINE v_tipoobligacion VARCHAR(50);

ON EXCEPTION
    IN (-1)
        RETURN;
END EXCEPTION;

-- Si par_vigencia es 'TODOS', obtener todos los registros
-- Si no, filtrar por la vigencia específica
IF par_vigencia = 'TODOS' THEN
    FOREACH
        SELECT
            d.id_34_datos,
            d.control,
            d.concesionario,
            d.ubicacion,
            d.nomcomercial,
            d.lugar,
            d.obs,
            s.descripcion AS statusregistro,
            d.unidades,
            d.categoria,
            d.seccion,
            d.bloque,
            d.sector,
            d.superficie,
            d.fechainicio,
            d.fechafin,
            d.recaudadora,
            d.zona,
            d.licencia,
            d.giro,
            d.tipoobligacion
        INTO
            v_id_34_datos,
            v_control,
            v_concesionario,
            v_ubicacion,
            v_nomcomercial,
            v_lugar,
            v_obs,
            v_statusregistro,
            v_unidades,
            v_categoria,
            v_seccion,
            v_bloque,
            v_sector,
            v_superficie,
            v_fechainicio,
            v_fechafin,
            v_recaudadora,
            v_zona,
            v_licencia,
            v_giro,
            v_tipoobligacion
        FROM t34_datos d
        LEFT JOIN t34_status s ON s.id_34_stat = d.id_stat
        WHERE d.cve_tab = par_tabla
        ORDER BY d.control

        RETURN
            v_id_34_datos,
            v_control,
            v_concesionario,
            v_ubicacion,
            v_nomcomercial,
            v_lugar,
            v_obs,
            v_statusregistro,
            v_unidades,
            v_categoria,
            v_seccion,
            v_bloque,
            v_sector,
            v_superficie,
            v_fechainicio,
            v_fechafin,
            v_recaudadora,
            v_zona,
            v_licencia,
            v_giro,
            v_tipoobligacion
        WITH RESUME;
    END FOREACH;
ELSE
    FOREACH
        SELECT
            d.id_34_datos,
            d.control,
            d.concesionario,
            d.ubicacion,
            d.nomcomercial,
            d.lugar,
            d.obs,
            s.descripcion AS statusregistro,
            d.unidades,
            d.categoria,
            d.seccion,
            d.bloque,
            d.sector,
            d.superficie,
            d.fechainicio,
            d.fechafin,
            d.recaudadora,
            d.zona,
            d.licencia,
            d.giro,
            d.tipoobligacion
        INTO
            v_id_34_datos,
            v_control,
            v_concesionario,
            v_ubicacion,
            v_nomcomercial,
            v_lugar,
            v_obs,
            v_statusregistro,
            v_unidades,
            v_categoria,
            v_seccion,
            v_bloque,
            v_sector,
            v_superficie,
            v_fechainicio,
            v_fechafin,
            v_recaudadora,
            v_zona,
            v_licencia,
            v_giro,
            v_tipoobligacion
        FROM t34_datos d
        INNER JOIN t34_status s ON s.id_34_stat = d.id_stat
        WHERE d.cve_tab = par_tabla
          AND s.descripcion = par_vigencia
        ORDER BY d.control

        RETURN
            v_id_34_datos,
            v_control,
            v_concesionario,
            v_ubicacion,
            v_nomcomercial,
            v_lugar,
            v_obs,
            v_statusregistro,
            v_unidades,
            v_categoria,
            v_seccion,
            v_bloque,
            v_sector,
            v_superficie,
            v_fechainicio,
            v_fechafin,
            v_recaudadora,
            v_zona,
            v_licencia,
            v_giro,
            v_tipoobligacion
        WITH RESUME;
    END FOREACH;
END IF;

END PROCEDURE;
