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
  superficie FLOAT,
  fechainicio DATE,
  fechafin DATE,
  recaudadora INTEGER,
  zona INTEGER,
  licencia INTEGER,
  giro INTEGER
) AS $$
BEGIN
  RETURN QUERY SELECT * FROM cob34_gdatosg_02(par_tab, par_control);
END;
$$ LANGUAGE plpgsql;