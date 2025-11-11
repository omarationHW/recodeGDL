-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Listados
-- Generado: 2025-08-27 13:56:06
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_listados_get_claves
-- Tipo: Catalog
-- Descripción: Obtiene todas las claves de tipo_clave<>4 para el formulario de Listados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_listados_get_claves()
RETURNS TABLE(id_clave integer, tipo_clave smallint, concepto_tipo varchar, clave varchar, descrip varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_clave, tipo_clave, concepto_tipo, clave, descrip FROM ta_15_claves WHERE tipo_clave <> 4 ORDER BY tipo_clave, clave;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_listados_get_vigencias
-- Tipo: Catalog
-- Descripción: Obtiene todas las claves de vigencia (tipo_clave=5) para el formulario de Listados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_listados_get_vigencias()
RETURNS TABLE(id_clave integer, tipo_clave smallint, concepto_tipo varchar, clave varchar, descrip varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_clave, tipo_clave, concepto_tipo, clave, descrip FROM ta_15_claves WHERE tipo_clave = 5 ORDER BY clave;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_listados_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene todas las recaudadoras para el formulario de Listados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_listados_get_recaudadoras()
RETURNS TABLE(id_rec smallint, id_zona integer, recaudadora varchar, domicilio varchar, tel varchar, recaudador varchar, sector varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador, sector FROM padron_licencias.comun.ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_listados_get_listados
-- Tipo: Report
-- Descripción: Obtiene el listado de folios según los filtros seleccionados en el formulario Listados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_listados_get_listados(
  p_id_rec integer,
  p_modulo integer,
  p_folio_desde integer,
  p_folio_hasta integer,
  p_clave varchar,
  p_vigencia varchar,
  p_fecha_prac_desde date DEFAULT NULL,
  p_fecha_prac_hasta date DEFAULT NULL
)
RETURNS TABLE(
  id_control integer,
  zona smallint,
  modulo smallint,
  control_otr integer,
  folio integer,
  diligencia varchar,
  importe_global numeric,
  importe_multa numeric,
  importe_recargo numeric,
  importe_gastos numeric,
  zona_apremio smallint,
  fecha_emision date,
  clave_practicado varchar,
  fecha_practicado date,
  fecha_entrega1 date,
  fecha_entrega2 date,
  fecha_citatorio date,
  hora timestamp,
  ejecutor smallint,
  clave_secuestro smallint,
  clave_remate varchar,
  fecha_remate date,
  porcentaje_multa smallint,
  observaciones varchar,
  fecha_pago date,
  recaudadora smallint,
  caja varchar,
  operacion integer,
  importe_pago numeric,
  vigencia varchar,
  fecha_actualiz date,
  usuario integer,
  clave_mov varchar,
  hora_practicado timestamp,
  nombre varchar,
  datos varchar,
  recaudadora_1 varchar,
  zona_1 varchar,
  descripcion varchar,
  estado varchar,
  axoini smallint,
  mesini integer,
  axofin smallint,
  mesfin integer,
  imp_pagado numeric
) AS $$
DECLARE
  sql text;
BEGIN
  sql := '
    SELECT a.*, b.nombre, c.recaudadora as recaudadora_1, d.zona as zona_1, e.descripcion,
      CASE a.vigencia WHEN ''1'' THEN ''VIG'' WHEN ''2'' THEN ''PAG'' WHEN ''3'' THEN ''CAN'' ELSE ''SUS'' END as estado,
      (SELECT min(ayo) FROM ta_15_periodos WHERE control_otr=a.id_control) as axoini,
      (SELECT min(periodo) FROM ta_15_periodos WHERE control_otr=a.id_control) as mesini,
      (SELECT max(ayo) FROM ta_15_periodos WHERE control_otr=a.id_control) as axofin,
      (SELECT max(periodo) FROM ta_15_periodos WHERE control_otr=a.id_control) as mesfin,
      0 as imp_pagado
    FROM ta_15_apremios a
      LEFT JOIN ta_15_ejecutores b ON a.ejecutor = b.cve_eje AND a.zona = b.id_rec
      LEFT JOIN padron_licencias.comun.ta_12_recaudadoras c ON a.zona = c.id_rec
      LEFT JOIN padron_licencias.comun.ta_12_zonas d ON c.id_zona = d.id_zona
      LEFT JOIN padron_licencias.comun.ta_12_modulos e ON a.modulo = e.id_modulo
    WHERE a.zona = $1 AND a.modulo = $2 AND a.folio BETWEEN $3 AND $4';

  IF p_clave IS NOT NULL AND p_clave <> 'todas' THEN
    IF p_clave = 'P' AND p_fecha_prac_desde IS NOT NULL AND p_fecha_prac_hasta IS NOT NULL THEN
      sql := sql || ' AND a.clave_practicado = ''''P'''' AND a.fecha_practicado BETWEEN $5 AND $6';
    ELSE
      sql := sql || ' AND a.clave_practicado = $5';
    END IF;
  END IF;
  IF p_vigencia IS NOT NULL AND p_vigencia <> 'todas' THEN
    IF p_vigencia = '2' THEN
      sql := sql || ' AND (a.vigencia = ''2'' OR a.vigencia = ''P'')';
    ELSE
      sql := sql || ' AND a.vigencia = $7';
    END IF;
  END IF;
  RETURN QUERY EXECUTE sql USING p_id_rec, p_modulo, p_folio_desde, p_folio_hasta, p_clave, p_fecha_prac_desde, p_fecha_prac_hasta, p_vigencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

