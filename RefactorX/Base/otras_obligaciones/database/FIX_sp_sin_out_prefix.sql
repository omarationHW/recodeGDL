-- FIX: Quitar prefijo out_ de las columnas de retorno
-- Fecha: 2025-12-04

-- Corregir sp_gconsulta2_busca_cont sin prefijo out_
DROP FUNCTION IF EXISTS sp_gconsulta2_busca_cont(integer, varchar);

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

-- Corregir sp_otras_oblig_buscar_cont sin prefijo out_
DROP FUNCTION IF EXISTS sp_otras_oblig_buscar_cont(integer, varchar);

CREATE OR REPLACE FUNCTION sp_otras_oblig_buscar_cont(
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
  RETURN QUERY SELECT * FROM sp_gconsulta2_busca_cont(par_tab, par_control);
END;
$func$ LANGUAGE plpgsql;

-- Corregir sp_get_datos_concesion
DROP FUNCTION IF EXISTS sp_get_datos_concesion(integer, text);

CREATE OR REPLACE FUNCTION sp_get_datos_concesion(par_tab integer, par_control text)
RETURNS TABLE(
  status integer,
  concepto_status text,
  id_datos integer,
  concesionario text,
  ubicacion text,
  nomcomercial text,
  lugar text,
  obs text,
  adicionales text,
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
  giro integer
) AS $func$
BEGIN
  RETURN QUERY
  SELECT
    f.status,
    f.concepto_status,
    f.id_datos,
    f.concesionario,
    f.ubicacion,
    f.nomcomercial,
    f.lugar,
    f.obs,
    f.adicionales,
    f.statusregistro,
    f.unidades,
    f.categoria,
    f.seccion,
    f.bloque,
    f.sector,
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
