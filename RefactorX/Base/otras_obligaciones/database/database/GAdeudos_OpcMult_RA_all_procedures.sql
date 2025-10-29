-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: GAdeudos_OpcMult_RA
-- Generado: 2025-08-28 13:01:07
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_get_tabla_info
-- Tipo: Catalog
-- Descripción: Obtiene información de la tabla y su descripción para la clave dada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tabla_info(par_tab integer)
RETURNS TABLE(cve_tab integer, nombre text, descripcion text) AS $$
BEGIN
  RETURN QUERY
  SELECT a.cve_tab, a.nombre, b.descripcion
  FROM t34_tablas a
  JOIN t34_unidades b ON b.cve_tab = a.cve_tab
  WHERE a.cve_tab = par_tab
  GROUP BY a.cve_tab, a.nombre, b.descripcion
  ORDER BY a.cve_tab, a.nombre, b.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_get_etiq
-- Tipo: Catalog
-- Descripción: Obtiene los datos de etiquetas para la tabla especificada.
-- --------------------------------------------

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

-- ============================================

-- SP 3/6: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(
  id_rec smallint,
  id_zona integer,
  recaudadora text,
  domicilio text,
  tel text,
  recaudador text,
  sector text
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador, sector
  FROM ta_12_recaudadoras
  ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_get_operaciones
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de operaciones de caja.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_operaciones()
RETURNS TABLE(
  id_rec smallint,
  caja text,
  operacion integer,
  id_usuario integer,
  tip_impresora text
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_rec, caja, operacion, id_usuario, tip_impresora
  FROM ta_12_operaciones
  ORDER BY id_rec, caja;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_get_pagados
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados para un control dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pagados(p_Control integer)
RETURNS TABLE(
  id_34_pagos integer,
  id_datos integer,
  periodo timestamp,
  importe numeric,
  recargo numeric,
  fecha_hora_pago timestamp,
  id_recaudadora integer,
  caja text,
  operacion integer,
  folio_recibo text,
  usuario text,
  id_stat integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago, a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
  FROM t34_pagos a
  JOIN t34_status b ON b.id_34_stat = a.id_stat AND b.cve_stat = 'P'
  WHERE a.id_datos = p_Control
  ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_get_datos_concesion
-- Tipo: CRUD
-- Descripción: Obtiene los datos generales de la concesión para la tabla y control dados.
-- --------------------------------------------

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
) AS $$
BEGIN
  RETURN QUERY
  SELECT status, concepto_status, id_datos, concesionario, ubicacion, nomcomercial, lugar, obs, adicionales, statusregistro, unidades, categoria, seccion, bloque, sector, superficie, fechainicio, fechafin, recaudadora, zona, licencia, giro
  FROM cob34_gdatosg_02(par_tab, par_control);
END;
$$ LANGUAGE plpgsql;

-- ============================================

