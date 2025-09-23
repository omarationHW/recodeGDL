-- Stored Procedure: sp34_etiq_tabla
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de la tabla para mostrar en el frontend.
-- Generado para formulario: GRep_Padron
-- Fecha: 2025-08-28 13:21:45

CREATE OR REPLACE FUNCTION sp34_etiq_tabla(par_tab integer)
RETURNS TABLE(
    cve_tab text,
    abreviatura text,
    etiq_control text,
    concesionario text,
    ubicacion text,
    superficie text,
    fecha_inicio text,
    fecha_fin text,
    recaudadora text,
    sector text,
    zona text,
    licencia text,
    fecha_cancelacion text,
    unidad text,
    categoria text,
    seccion text,
    bloque text,
    nombre_comercial text,
    lugar text,
    obs text
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab::text;
END;
$$ LANGUAGE plpgsql;