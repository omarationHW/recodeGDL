-- Stored Procedure: sp_gconsulta2_busca_cont
-- Tipo: CRUD
-- Descripción: Busca los datos principales de un control
-- Generado para formulario: GConsulta2
-- Fecha: 2025-08-28 13:11:34

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_cont(
  par_tab integer,
  par_control varchar
)
RETURNS TABLE (
  status integer,
  concepto_status varchar,
  id_datos integer,
  concesionario varchar,
  ubicacion varchar,
  nomcomercial varchar,
  lugar varchar,
  obs varchar,
  adicionales varchar,
  statusregistro varchar,
  unidades varchar,
  categoria varchar,
  seccion varchar,
  bloque varchar,
  sector varchar,
  superficie numeric,
  fechainicio date,
  fechafin date,
  recaudadora integer,
  zona integer,
  licencia integer,
  giro integer
) AS $func$
BEGIN
  RETURN QUERY SELECT
    f.status,
    f.concepto_status::varchar,
    f.id_datos,
    f.concesionario::varchar,
    f.ubicacion::varchar,
    f.nomcomercial::varchar,
    f.lugar::varchar,
    f.obs::varchar,
    f.adicionales::varchar,
    f.statusregistro::varchar,
    f.unidades::varchar,
    f.categoria::varchar,
    f.seccion::varchar,
    f.bloque::varchar,
    f.sector::varchar,
    f.superficie,
    f.fechainicio,
    f.fechafin,
    f.recaudadora,
    f.zona,
    f.licencia,
    f.giro
  FROM cob34_gdatosg_02(par_tab::text, par_control) f;
END;
$func$ LANGUAGE plpgsql;