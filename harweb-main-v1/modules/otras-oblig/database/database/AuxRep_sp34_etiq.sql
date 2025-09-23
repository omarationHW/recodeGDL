-- Stored Procedure: sp34_etiq
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de la tabla.
-- Generado para formulario: AuxRep
-- Fecha: 2025-08-28 12:38:35

CREATE OR REPLACE FUNCTION sp34_etiq(par_tab integer)
RETURNS TABLE(
    cve_tab varchar,
    abreviatura varchar,
    etiq_control varchar,
    concesionario varchar,
    ubicacion varchar,
    superficie varchar,
    fecha_inicio varchar,
    fecha_fin varchar,
    recaudadora varchar,
    sector varchar,
    zona varchar,
    licencia varchar,
    fecha_cancelacion varchar,
    unidad varchar,
    categoria varchar,
    seccion varchar,
    bloque varchar,
    nombre_comercial varchar,
    lugar varchar,
    obs varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;