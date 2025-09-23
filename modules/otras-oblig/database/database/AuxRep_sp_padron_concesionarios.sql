-- Stored Procedure: sp_padron_concesionarios
-- Tipo: Report
-- Descripción: Devuelve el padrón de concesionarios filtrado por tabla y vigencia.
-- Generado para formulario: AuxRep
-- Fecha: 2025-08-27 23:08:15

CREATE OR REPLACE FUNCTION sp_padron_concesionarios(par_tabla integer, par_vigencia text)
RETURNS TABLE(
  id_34_datos integer,
  control text,
  concesionario text,
  ubicacion text,
  nomcomercial text,
  lugar text,
  obs text,
  statusregistro text,
  unidades text,
  categoria text,
  seccion text,
  bloque text,
  sector text,
  superficie numeric,
  fechainicio date,
  fechafin date,
  recaudadora integer,
  zona integer,
  licencia integer,
  giro integer,
  tipoobligacion text
) AS $$
BEGIN
  IF par_vigencia IS NULL OR par_vigencia = 'TODOS' THEN
    RETURN QUERY
      SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.nomcomercial, a.lugar, a.obs, b.descripcion as statusregistro,
             a.unidades, a.categoria, a.seccion, a.bloque, a.sector, a.superficie, a.fecha_inicio, a.fecha_fin, a.id_recaudadora,
             a.zona, a.licencia, a.giro, a.tipoobligacion
      FROM t34_datos a
      JOIN t34_status b ON b.id_34_stat = a.id_stat
      WHERE a.cve_tab = par_tabla
      ORDER BY a.control;
  ELSE
    RETURN QUERY
      SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.nomcomercial, a.lugar, a.obs, b.descripcion as statusregistro,
             a.unidades, a.categoria, a.seccion, a.bloque, a.sector, a.superficie, a.fecha_inicio, a.fecha_fin, a.id_recaudadora,
             a.zona, a.licencia, a.giro, a.tipoobligacion
      FROM t34_datos a
      JOIN t34_status b ON b.id_34_stat = a.id_stat
      WHERE a.cve_tab = par_tabla AND b.descripcion = par_vigencia
      ORDER BY a.control;
  END IF;
END;
$$ LANGUAGE plpgsql;