-- Stored Procedure: sp_get_etiq
-- Tipo: Catalog
-- Descripción: Obtiene los datos de etiquetas para la tabla especificada.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-28 13:01:07

CREATE OR REPLACE FUNCTION sp_get_etiq(par_tab integer)
RETURNS TABLE(
  cve_tab integer,
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
  SELECT cve_tab, abreviatura, etiq_control, concesionario, ubicacion, superficie, fecha_inicio, fecha_fin, recaudadora, sector, zona, licencia, fecha_cancelacion, unidad, categoria, seccion, bloque, nombre_comercial, lugar, obs
  FROM t34_etiq
  WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;