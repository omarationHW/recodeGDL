-- Stored Procedure: sp_get_etiquetas
-- Tipo: Catalog
-- Descripción: Obtiene las etiquetas de la tabla seleccionada
-- Generado para formulario: GConsulta2
-- Fecha: 2025-08-27 16:06:00

CREATE OR REPLACE FUNCTION sp_get_etiquetas(par_tab VARCHAR)
RETURNS TABLE (
  cve_tab VARCHAR,
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
  RETURN QUERY SELECT * FROM t34_etiq WHERE cve_tab = par_tab;
END;
$$ LANGUAGE plpgsql;