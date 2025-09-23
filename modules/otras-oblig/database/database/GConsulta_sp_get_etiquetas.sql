-- Stored Procedure: sp_get_etiquetas
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de la tabla t34_etiq para el tipo de contrato/tab seleccionado.
-- Generado para formulario: GConsulta
-- Fecha: 2025-08-27 16:02:36

CREATE OR REPLACE FUNCTION sp_get_etiquetas(par_tab integer)
RETURNS TABLE (
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