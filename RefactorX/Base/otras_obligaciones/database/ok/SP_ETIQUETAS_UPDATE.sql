--
-- SP_ETIQUETAS_UPDATE.sql
-- Descripción: Actualiza las etiquetas personalizadas para una tabla específica
-- Parámetros: Todos los campos de la tabla t34_etiq
-- Retorna: success (1 = éxito, 0 = error), message
--

DROP PROCEDURE IF EXISTS SP_ETIQUETAS_UPDATE;

CREATE PROCEDURE SP_ETIQUETAS_UPDATE(
    p_cve_tab VARCHAR(2),
    p_abreviatura VARCHAR(4),
    p_etiq_control VARCHAR(20),
    p_concesionario VARCHAR(20),
    p_ubicacion VARCHAR(20),
    p_superficie VARCHAR(20),
    p_fecha_inicio VARCHAR(20),
    p_fecha_fin VARCHAR(20),
    p_recaudadora VARCHAR(20),
    p_sector VARCHAR(20),
    p_zona VARCHAR(20),
    p_licencia VARCHAR(20),
    p_fecha_cancelacion VARCHAR(20),
    p_unidad VARCHAR(20),
    p_categoria VARCHAR(20),
    p_seccion VARCHAR(20),
    p_bloque VARCHAR(20),
    p_nombre_comercial VARCHAR(20),
    p_lugar VARCHAR(20),
    p_obs VARCHAR(20)
)

RETURNING
    INTEGER,     -- success (1 = éxito, 0 = error)
    VARCHAR(255); -- message

DEFINE v_success INTEGER;
DEFINE v_message VARCHAR(255);
DEFINE v_exists INTEGER;

ON EXCEPTION
    IN (-1)
        LET v_success = 0;
        LET v_message = 'Error al actualizar las etiquetas: ' || SQLERRMESSAGE;
        RETURN v_success, v_message;
END EXCEPTION;

-- Verificar si existe el registro
SELECT COUNT(*)
INTO v_exists
FROM t34_etiq
WHERE cve_tab = p_cve_tab;

-- Si existe, actualizar
IF v_exists > 0 THEN
    UPDATE t34_etiq
    SET
        abreviatura = CASE WHEN TRIM(p_abreviatura) = '' THEN ' ' ELSE p_abreviatura END,
        etiq_control = CASE WHEN TRIM(p_etiq_control) = '' THEN ' ' ELSE p_etiq_control END,
        concesionario = CASE WHEN TRIM(p_concesionario) = '' THEN ' ' ELSE p_concesionario END,
        ubicacion = CASE WHEN TRIM(p_ubicacion) = '' THEN ' ' ELSE p_ubicacion END,
        superficie = CASE WHEN TRIM(p_superficie) = '' THEN ' ' ELSE p_superficie END,
        fecha_inicio = CASE WHEN TRIM(p_fecha_inicio) = '' THEN ' ' ELSE p_fecha_inicio END,
        fecha_fin = CASE WHEN TRIM(p_fecha_fin) = '' THEN ' ' ELSE p_fecha_fin END,
        recaudadora = CASE WHEN TRIM(p_recaudadora) = '' THEN ' ' ELSE p_recaudadora END,
        sector = CASE WHEN TRIM(p_sector) = '' THEN ' ' ELSE p_sector END,
        zona = CASE WHEN TRIM(p_zona) = '' THEN ' ' ELSE p_zona END,
        licencia = CASE WHEN TRIM(p_licencia) = '' THEN ' ' ELSE p_licencia END,
        fecha_cancelacion = CASE WHEN TRIM(p_fecha_cancelacion) = '' THEN ' ' ELSE p_fecha_cancelacion END,
        unidad = CASE WHEN TRIM(p_unidad) = '' THEN ' ' ELSE p_unidad END,
        categoria = CASE WHEN TRIM(p_categoria) = '' THEN ' ' ELSE p_categoria END,
        seccion = CASE WHEN TRIM(p_seccion) = '' THEN ' ' ELSE p_seccion END,
        bloque = CASE WHEN TRIM(p_bloque) = '' THEN ' ' ELSE p_bloque END,
        nombre_comercial = CASE WHEN TRIM(p_nombre_comercial) = '' THEN ' ' ELSE p_nombre_comercial END,
        lugar = CASE WHEN TRIM(p_lugar) = '' THEN ' ' ELSE p_lugar END,
        obs = CASE WHEN TRIM(p_obs) = '' THEN ' ' ELSE p_obs END
    WHERE cve_tab = p_cve_tab;

    LET v_success = 1;
    LET v_message = 'Etiquetas actualizadas correctamente';
ELSE
    -- Si no existe, insertar nuevo registro
    INSERT INTO t34_etiq (
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
    ) VALUES (
        p_cve_tab,
        CASE WHEN TRIM(p_abreviatura) = '' THEN ' ' ELSE p_abreviatura END,
        CASE WHEN TRIM(p_etiq_control) = '' THEN ' ' ELSE p_etiq_control END,
        CASE WHEN TRIM(p_concesionario) = '' THEN ' ' ELSE p_concesionario END,
        CASE WHEN TRIM(p_ubicacion) = '' THEN ' ' ELSE p_ubicacion END,
        CASE WHEN TRIM(p_superficie) = '' THEN ' ' ELSE p_superficie END,
        CASE WHEN TRIM(p_fecha_inicio) = '' THEN ' ' ELSE p_fecha_inicio END,
        CASE WHEN TRIM(p_fecha_fin) = '' THEN ' ' ELSE p_fecha_fin END,
        CASE WHEN TRIM(p_recaudadora) = '' THEN ' ' ELSE p_recaudadora END,
        CASE WHEN TRIM(p_sector) = '' THEN ' ' ELSE p_sector END,
        CASE WHEN TRIM(p_zona) = '' THEN ' ' ELSE p_zona END,
        CASE WHEN TRIM(p_licencia) = '' THEN ' ' ELSE p_licencia END,
        CASE WHEN TRIM(p_fecha_cancelacion) = '' THEN ' ' ELSE p_fecha_cancelacion END,
        CASE WHEN TRIM(p_unidad) = '' THEN ' ' ELSE p_unidad END,
        CASE WHEN TRIM(p_categoria) = '' THEN ' ' ELSE p_categoria END,
        CASE WHEN TRIM(p_seccion) = '' THEN ' ' ELSE p_seccion END,
        CASE WHEN TRIM(p_bloque) = '' THEN ' ' ELSE p_bloque END,
        CASE WHEN TRIM(p_nombre_comercial) = '' THEN ' ' ELSE p_nombre_comercial END,
        CASE WHEN TRIM(p_lugar) = '' THEN ' ' ELSE p_lugar END,
        CASE WHEN TRIM(p_obs) = '' THEN ' ' ELSE p_obs END
    );

    LET v_success = 1;
    LET v_message = 'Etiquetas creadas correctamente';
END IF;

RETURN v_success, v_message;

END PROCEDURE;
