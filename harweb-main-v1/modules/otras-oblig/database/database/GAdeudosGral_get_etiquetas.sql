-- Stored Procedure: get_etiquetas
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de la tabla
-- Generado para formulario: GAdeudosGral
-- Fecha: 2025-08-27 13:49:09

CREATE OR REPLACE FUNCTION get_etiquetas(par_tab TEXT)
RETURNS TABLE(
  cve_tab TEXT,
  abreviatura TEXT,
  etiq_control TEXT,
  concesionario TEXT,
  ubicacion TEXT,
  superficie TEXT,
  fecha_inicio TEXT,
  fecha_fin TEXT,
  recaudadora TEXT,
  sector TEXT,
  zona TEXT,
  licencia TEXT,
  fecha_cancelacion TEXT,
  unidad TEXT,
  categoria TEXT,
  seccion TEXT,
  bloque TEXT,
  nombre_comercial TEXT,
  lugar TEXT,
  obs TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;