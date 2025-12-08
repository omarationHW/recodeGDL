-- Stored Procedure: sp_get_etiquetas
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de la tabla seleccionada.
-- Generado para formulario: GFacturacion
-- Fecha: 2025-08-28 13:15:04

CREATE OR REPLACE FUNCTION sp_get_etiquetas(par_tab INTEGER)
RETURNS TABLE(
    cve_tab INTEGER,
    abreviatura VARCHAR,
    etiq_control VARCHAR,
    concesionario VARCHAR,
    ubicacion VARCHAR,
    superficie VARCHAR,
    fecha_inicio VARCHAR,
    fecha_fin VARCHAR,
    recaudadora VARCHAR,
    sector VARCHAR,
    zona VARCHAR,
    licencia VARCHAR,
    fecha_cancelacion VARCHAR,
    unidad VARCHAR,
    categoria VARCHAR,
    seccion VARCHAR,
    bloque VARCHAR,
    nombre_comercial VARCHAR,
    lugar VARCHAR,
    obs VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t34_etiq.cve_tab,
        t34_etiq.abreviatura,
        t34_etiq.etiq_control,
        t34_etiq.concesionario,
        t34_etiq.ubicacion,
        t34_etiq.superficie,
        t34_etiq.fecha_inicio,
        t34_etiq.fecha_fin,
        t34_etiq.recaudadora,
        t34_etiq.sector,
        t34_etiq.zona,
        t34_etiq.licencia,
        t34_etiq.fecha_cancelacion,
        t34_etiq.unidad,
        t34_etiq.categoria,
        t34_etiq.seccion,
        t34_etiq.bloque,
        t34_etiq.nombre_comercial,
        t34_etiq.lugar,
        t34_etiq.obs
    FROM t34_etiq
    WHERE t34_etiq.cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;