-- Stored Procedure: sp_padron_etiquetas
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas configurables para la tabla de padrones.
-- Generado para formulario: AuxRep
-- Fecha: 2025-08-27 23:08:15

CREATE OR REPLACE FUNCTION sp_padron_etiquetas(par_tab integer)
RETURNS TABLE(
  cve_tab integer, abreviatura text, etiq_control text, concesionario text, ubicacion text, superficie text,
  fecha_inicio text, fecha_fin text, recaudadora text, sector text, zona text, licencia text, fecha_cancelacion text,
  unidad text, categoria text, seccion text, bloque text, nombre_comercial text, lugar text, obs text
) AS $$
BEGIN
  RETURN QUERY
    SELECT cve_tab, abreviatura, etiq_control, concesionario, ubicacion, superficie, fecha_inicio, fecha_fin,
           recaudadora, sector, zona, licencia, fecha_cancelacion, unidad, categoria, seccion, bloque, nombre_comercial, lugar, obs
    FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;