-- Stored Procedure: sp_busca_cont
-- Tipo: Report
-- Descripción: Obtiene los datos completos de un control
-- Generado para formulario: GConsulta2
-- Fecha: 2025-08-27 16:06:00

CREATE OR REPLACE FUNCTION sp_busca_cont(par_tab VARCHAR, par_control VARCHAR)
RETURNS TABLE (
  status INTEGER,
  concepto_status VARCHAR,
  id_datos INTEGER,
  concesionario VARCHAR,
  ubicacion VARCHAR,
  nomcomercial VARCHAR,
  lugar VARCHAR,
  obs VARCHAR,
  adicionales VARCHAR,
  statusregistro VARCHAR,
  unidades VARCHAR,
  categoria VARCHAR,
  seccion VARCHAR,
  bloque VARCHAR,
  sector VARCHAR,
  superficie NUMERIC,
  fechainicio DATE,
  fechafin DATE,
  recaudadora INTEGER,
  zona INTEGER,
  licencia INTEGER,
  giro INTEGER,
  control VARCHAR,
  tipoobligacion VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    CASE WHEN a.id_34_datos IS NULL THEN 1 ELSE 0 END AS status,
    CASE WHEN a.id_34_datos IS NULL THEN 'No existe registro' ELSE 'OK' END AS concepto_status,
    a.id_34_datos,
    a.concesionario,
    a.ubicacion,
    a.nomcomercial,
    a.lugar,
    a.obs,
    a.adicionales,
    a.statusregistro,
    a.unidades,
    a.categoria,
    a.seccion,
    a.bloque,
    a.sector,
    a.superficie,
    a.fechainicio,
    a.fechafin,
    a.recaudadora,
    a.zona,
    a.licencia,
    a.giro,
    a.control,
    a.tipoobligacion
  FROM t34_datos a
  WHERE a.cve_tab = par_tab AND a.control = par_control
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;