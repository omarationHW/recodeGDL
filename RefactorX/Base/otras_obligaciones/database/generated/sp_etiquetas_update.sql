-- ================================================================
-- SP: sp_etiquetas_update
-- Módulo: otras_obligaciones
-- BD Destino: otras_obligaciones (esquema public)
-- Fecha: 2025-11-26
-- ================================================================
-- Descripción: Actualiza las etiquetas de una tabla en t34_etiq
-- Basado en: Delphi Etiquetas.pas - QryUpd_Etiq UPDATE
-- ================================================================

DROP FUNCTION IF EXISTS sp_etiquetas_update(
    INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR
);

CREATE OR REPLACE FUNCTION sp_etiquetas_update(
    par_cve_tab INTEGER,
    par_abreviatura VARCHAR,
    par_etiq_control VARCHAR,
    par_concesionario VARCHAR,
    par_ubicacion VARCHAR,
    par_superficie VARCHAR,
    par_fecha_inicio VARCHAR,
    par_fecha_fin VARCHAR,
    par_recaudadora VARCHAR,
    par_sector VARCHAR,
    par_zona VARCHAR,
    par_licencia VARCHAR,
    par_fecha_cancelacion VARCHAR,
    par_unidad VARCHAR,
    par_categoria VARCHAR,
    par_seccion VARCHAR,
    par_bloque VARCHAR,
    par_nombre_comercial VARCHAR,
    par_lugar VARCHAR,
    par_obs VARCHAR
)
RETURNS TABLE (
    success INTEGER,
    message VARCHAR
) AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Verificar si existe el registro
    SELECT EXISTS(SELECT 1 FROM t34_etiq WHERE cve_tab = par_cve_tab) INTO v_exists;

    IF v_exists THEN
        -- UPDATE si existe
        UPDATE t34_etiq SET
            abreviatura = par_abreviatura,
            etiq_control = par_etiq_control,
            concesionario = par_concesionario,
            ubicacion = par_ubicacion,
            superficie = par_superficie,
            fecha_inicio = par_fecha_inicio,
            fecha_fin = par_fecha_fin,
            recaudadora = par_recaudadora,
            sector = par_sector,
            zona = par_zona,
            licencia = par_licencia,
            fecha_cancelacion = par_fecha_cancelacion,
            unidad = par_unidad,
            categoria = par_categoria,
            seccion = par_seccion,
            bloque = par_bloque,
            nombre_comercial = par_nombre_comercial,
            lugar = par_lugar,
            obs = par_obs
        WHERE cve_tab = par_cve_tab;

        success := 1;
        message := 'Etiquetas actualizadas correctamente';
    ELSE
        -- INSERT si no existe
        INSERT INTO t34_etiq (
            cve_tab, abreviatura, etiq_control, concesionario, ubicacion,
            superficie, fecha_inicio, fecha_fin, recaudadora, sector,
            zona, licencia, fecha_cancelacion, unidad, categoria,
            seccion, bloque, nombre_comercial, lugar, obs
        ) VALUES (
            par_cve_tab, par_abreviatura, par_etiq_control, par_concesionario, par_ubicacion,
            par_superficie, par_fecha_inicio, par_fecha_fin, par_recaudadora, par_sector,
            par_zona, par_licencia, par_fecha_cancelacion, par_unidad, par_categoria,
            par_seccion, par_bloque, par_nombre_comercial, par_lugar, par_obs
        );

        success := 1;
        message := 'Etiquetas creadas correctamente';
    END IF;

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_etiquetas_update(
    INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR
) IS 'Actualiza o inserta las etiquetas de una tabla en t34_etiq - BD: otras_obligaciones';
