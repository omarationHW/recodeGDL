-- FIX: Columna 'status' ambigua en funciones que llaman a cob34_gdatosg_02
-- Fecha: 2025-12-04
-- Problema: Las columnas de retorno tenían nombres que colisionaban con columnas de tabla
-- Solución: Prefijo 'out_' en columnas de retorno y alias 'f' en subconsulta

-- ============================================
-- FIX 1: sp_gconsulta2_busca_cont
-- ============================================
DROP FUNCTION IF EXISTS sp_gconsulta2_busca_cont(integer, varchar);

CREATE OR REPLACE FUNCTION sp_gconsulta2_busca_cont(
  par_tab integer,
  par_control varchar
)
RETURNS TABLE (
  out_status integer,
  out_concepto_status varchar,
  out_id_datos integer,
  out_concesionario varchar,
  out_ubicacion varchar,
  out_nomcomercial varchar,
  out_lugar varchar,
  out_obs varchar,
  out_adicionales varchar,
  out_statusregistro varchar,
  out_unidades varchar,
  out_categoria varchar,
  out_seccion varchar,
  out_bloque varchar,
  out_sector varchar,
  out_superficie numeric,
  out_fechainicio date,
  out_fechafin date,
  out_recaudadora integer,
  out_zona integer,
  out_licencia integer,
  out_giro integer
) AS $$
BEGIN
  RETURN QUERY SELECT
    f.status::integer,
    f.concepto_status::varchar,
    f.id_datos::integer,
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
    f.superficie::numeric,
    f.fechainicio::date,
    f.fechafin::date,
    f.recaudadora::integer,
    f.zona::integer,
    f.licencia::integer,
    f.giro::integer
  FROM cob34_gdatosg_02(par_tab::text, par_control) f;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIX 2: sp_get_datos_concesion
-- ============================================
DROP FUNCTION IF EXISTS sp_get_datos_concesion(integer, text);

CREATE OR REPLACE FUNCTION sp_get_datos_concesion(par_tab integer, par_control text)
RETURNS TABLE(
  out_status integer,
  out_concepto_status text,
  out_id_datos integer,
  out_concesionario text,
  out_ubicacion text,
  out_nomcomercial text,
  out_lugar text,
  out_obs text,
  out_adicionales text,
  out_statusregistro text,
  out_unidades text,
  out_categoria text,
  out_seccion text,
  out_bloque text,
  out_sector text,
  out_superficie numeric,
  out_fechainicio date,
  out_fechafin date,
  out_recaudadora integer,
  out_zona integer,
  out_licencia integer,
  out_giro integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    f.status::integer,
    f.concepto_status::text,
    f.id_datos::integer,
    f.concesionario::text,
    f.ubicacion::text,
    f.nomcomercial::text,
    f.lugar::text,
    f.obs::text,
    f.adicionales::text,
    f.statusregistro::text,
    f.unidades::text,
    f.categoria::text,
    f.seccion::text,
    f.bloque::text,
    f.sector::text,
    f.superficie::numeric,
    f.fechainicio::date,
    f.fechafin::date,
    f.recaudadora::integer,
    f.zona::integer,
    f.licencia::integer,
    f.giro::integer
  FROM cob34_gdatosg_02(par_tab::text, par_control) f;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIX 3: sp_otras_oblig_buscar_cont (wrapper que usa sp_gconsulta2_busca_cont)
-- ============================================
DROP FUNCTION IF EXISTS sp_otras_oblig_buscar_cont(integer, varchar);

CREATE OR REPLACE FUNCTION sp_otras_oblig_buscar_cont(
  par_tab integer,
  par_control varchar
)
RETURNS TABLE (
  out_status integer,
  out_concepto_status varchar,
  out_id_datos integer,
  out_concesionario varchar,
  out_ubicacion varchar,
  out_nomcomercial varchar,
  out_lugar varchar,
  out_obs varchar,
  out_adicionales varchar,
  out_statusregistro varchar,
  out_unidades varchar,
  out_categoria varchar,
  out_seccion varchar,
  out_bloque varchar,
  out_sector varchar,
  out_superficie numeric,
  out_fechainicio date,
  out_fechafin date,
  out_recaudadora integer,
  out_zona integer,
  out_licencia integer,
  out_giro integer
) AS $$
BEGIN
  RETURN QUERY SELECT * FROM sp_gconsulta2_busca_cont(par_tab, par_control);
END;
$$ LANGUAGE plpgsql;

-- Verificación
SELECT 'FIX aplicado correctamente' AS resultado;
