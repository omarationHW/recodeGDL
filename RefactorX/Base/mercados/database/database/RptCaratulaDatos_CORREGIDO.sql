-- ============================================
-- SP CORREGIDO: RptCaratulaDatos
-- Esquemas corregidos según postgreok.csv
-- ============================================

-- SP 1/5: sp_get_locales_by_id
CREATE OR REPLACE FUNCTION public.sp_get_locales_by_id(p_id_local INTEGER)
RETURNS TABLE(
  id_local INTEGER,
  oficina SMALLINT,
  num_mercado SMALLINT,
  categoria SMALLINT,
  seccion VARCHAR,
  letra_local VARCHAR,
  bloque VARCHAR,
  id_contribuy_prop INTEGER,
  id_contribuy_renta INTEGER,
  nombre VARCHAR,
  arrendatario VARCHAR,
  domicilio VARCHAR,
  sector VARCHAR,
  zona SMALLINT,
  descripcion_local VARCHAR,
  superficie FLOAT,
  giro SMALLINT,
  fecha_alta DATE,
  fecha_baja DATE,
  fecha_modificacion TIMESTAMP,
  vigencia VARCHAR,
  id_usuario INTEGER,
  clave_cuota SMALLINT,
  descripcion VARCHAR,
  usuario VARCHAR,
  vigdescripcion VARCHAR,
  renta NUMERIC,
  adeudo NUMERIC,
  recargos NUMERIC,
  gastos NUMERIC,
  multa NUMERIC,
  total NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT l.*, m.descripcion, u.usuario,
    CASE l.vigencia
      WHEN 'B' THEN 'BAJA'
      WHEN 'C' THEN 'BAJA POR ACUERDO'
      WHEN 'D' THEN 'BAJA ADMINISTRATIVA'
      ELSE 'VIGENTE'
    END AS vigdescripcion,
    0::NUMERIC AS renta, 0::NUMERIC AS adeudo, 0::NUMERIC AS recargos, 0::NUMERIC AS gastos, 0::NUMERIC AS multa, 0::NUMERIC AS total
  FROM padron_licencias.comun.ta_11_locales l
  JOIN padron_licencias.comun.ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
  JOIN padron_licencias.comun.ta_12_passwords u ON l.id_usuario = u.id_usuario
  WHERE l.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;

-- SP 2/5: sp_get_adeudos_by_local
CREATE OR REPLACE FUNCTION public.sp_get_adeudos_by_local(p_id_local INTEGER)
RETURNS TABLE(
  id_local INTEGER,
  axo SMALLINT,
  periodo SMALLINT,
  importe NUMERIC,
  recargos NUMERIC,
  percadena VARCHAR,
  impcalc NUMERIC,
  leyenda VARCHAR
) AS $$
DECLARE
  per TEXT;
BEGIN
  FOR id_local, axo, periodo, importe IN
    SELECT id_local, axo, periodo, importe FROM padron_licencias.comun.ta_11_adeudo_local WHERE id_local = p_id_local ORDER BY axo, periodo
  LOOP
    IF periodo < 10 THEN
      per := '0';
    ELSE
      per := '';
    END IF;
    percadena := axo::TEXT || '-' || per || periodo::TEXT;
    recargos := 0;
    impcalc := importe;
    leyenda := '';
    RETURN NEXT;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- SP 3/5: sp_get_vencimiento_rec
CREATE OR REPLACE FUNCTION public.sp_get_vencimiento_rec(p_mes SMALLINT)
RETURNS TABLE(
  mes SMALLINT,
  fecha_recargos DATE,
  fecha_descuento DATE,
  fecha_alta TIMESTAMP,
  id_usuario INTEGER,
  trimestre SMALLINT,
  sabados SMALLINT,
  sabadosacum SMALLINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT mes, fecha_recargos, fecha_descuento, fecha_alta, id_usuario, trimestre, sabados, sabadosacum
  FROM padron_licencias.comun.ta_11_fecha_desc WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- SP 4/5: sp_get_recargos
CREATE OR REPLACE FUNCTION public.sp_get_recargos(
  p_axo_adeudo SMALLINT,
  p_periodo_adeudo SMALLINT,
  p_axo_actual SMALLINT,
  p_mes_actual SMALLINT
) RETURNS NUMERIC AS $$
DECLARE
  porcentaje NUMERIC := 0;
BEGIN
  SELECT COALESCE(SUM(porcentaje_mes),0) INTO porcentaje
  FROM padron_licencias.comun.ta_12_recargos
  WHERE (axo = p_axo_adeudo AND mes >= p_periodo_adeudo)
    OR (axo = p_axo_actual AND mes <= p_mes_actual)
    OR (axo > p_axo_adeudo AND axo < p_axo_actual);
  RETURN porcentaje;
END;
$$ LANGUAGE plpgsql;

-- SP 5/5: sp_rpt_caratula_datos
CREATE OR REPLACE FUNCTION public.sp_rpt_caratula_datos(
  p_id_local INTEGER,
  p_renta NUMERIC,
  p_adeudo NUMERIC,
  p_recargos NUMERIC,
  p_gastos NUMERIC,
  p_multa NUMERIC,
  p_total NUMERIC,
  p_folios TEXT,
  p_leyenda TEXT
) RETURNS JSON AS $$
DECLARE
  local_row RECORD;
  adeudos_rows JSON;
BEGIN
  SELECT * INTO local_row FROM mercados.sp_get_locales_by_id(p_id_local) LIMIT 1;
  SELECT json_agg(row_to_json(a)) INTO adeudos_rows FROM mercados.sp_get_adeudos_by_local(p_id_local) a;
  RETURN json_build_object(
    'id_local', local_row.id_local,
    'nombre', local_row.nombre,
    'domicilio', local_row.domicilio,
    'sector', local_row.sector,
    'zona', local_row.zona,
    'descripcion_local', local_row.descripcion_local,
    'superficie', local_row.superficie,
    'giro', local_row.giro,
    'fecha_alta', local_row.fecha_alta,
    'vigdescripcion', local_row.vigdescripcion,
    'usuario', local_row.usuario,
    'renta', p_renta,
    'adeudo', p_adeudo,
    'recargos', p_recargos,
    'gastos', p_gastos,
    'multa', p_multa,
    'total', p_total,
    'folios', p_folios,
    'leyenda', p_leyenda,
    'adeudos', adeudos_rows
  );
END;
$$ LANGUAGE plpgsql;
