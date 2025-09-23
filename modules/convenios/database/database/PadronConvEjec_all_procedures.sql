-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: PadronConvEjec
-- Generado: 2025-08-27 15:03:48
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_padronconvejec_get_tipos
-- Tipo: Catalog
-- Descripción: Obtiene los tipos de convenio disponibles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_padronconvejec_get_tipos()
RETURNS TABLE(tipo smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_padronconvejec_get_subtipos
-- Tipo: Catalog
-- Descripción: Obtiene los subtipos de convenio para un tipo dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_padronconvejec_get_subtipos(p_tipo smallint)
RETURNS TABLE(subtipo smallint, desc_subtipo varchar) AS $$
BEGIN
  RETURN QUERY SELECT subtipo, desc_subtipo FROM ta_17_subtipo_conv WHERE tipo = p_tipo ORDER BY subtipo;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_padronconvejec_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene la lista de recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_padronconvejec_get_recaudadoras()
RETURNS TABLE(id_rec smallint, recaudadora varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_padronconvejec_get_ejecutores
-- Tipo: Catalog
-- Descripción: Obtiene la lista de ejecutores activos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_padronconvejec_get_ejecutores()
RETURNS TABLE(cveejecutor smallint, ejecutor varchar) AS $$
BEGIN
  RETURN QUERY SELECT cveejecutor, trim(paterno)||' '||trim(materno)||' '||trim(nombres) as ejecutor FROM ejecutor WHERE vigencia='V' ORDER BY cveejecutor;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_padronconvejec_list
-- Tipo: Report
-- Descripción: Obtiene el listado de convenios filtrado por tipo, subtipo, recaudadora, vigencia, ejecutor y rango de años.
-- --------------------------------------------

-- NOTA: Esta función debe ajustarse a la lógica de joins y filtros del Delphi original.
CREATE OR REPLACE FUNCTION sp_padronconvejec_list(
  p_tipo smallint,
  p_subtipo smallint,
  p_recaudadora smallint,
  p_vigencia varchar,
  p_ejecutor smallint,
  p_anio_ini integer,
  p_anio_fin integer
)
RETURNS TABLE(
  id_conv_resto integer,
  convenio varchar,
  folio integer,
  ejecutor integer,
  fprac date,
  fecha_inicio date,
  fecha_venc date,
  pago_parcial smallint,
  costo numeric,
  pagos numeric,
  adeudo numeric,
  vigencia varchar,
  vigfolio varchar,
  fpago varchar,
  importe_pago numeric,
  referencia varchar,
  impuesto numeric,
  recargos numeric,
  gastos numeric,
  multa numeric,
  periodos varchar
) AS $$
BEGIN
  -- Esta consulta es un ejemplo y debe ajustarse a la lógica de joins y filtros del Delphi
  RETURN QUERY
  SELECT 
    b.id_conv_resto,
    (a.letras_exp||'-'||a.numero_exp||'-'||a.axo_exp) as convenio,
    COALESCE(f.folio, 0) as folio,
    COALESCE(f.ejecutor, 0) as ejecutor,
    f.fecprac as fprac,
    b.fecha_inicio,
    b.fecha_venc,
    COALESCE(e.pago_parcial, 0) as pago_parcial,
    b.cantidad_total as costo,
    (SELECT SUM(importe_pago) FROM ta_17_conv_pagos WHERE id_conv_resto=b.id_conv_resto) as pagos,
    (b.cantidad_total - COALESCE((SELECT SUM(importe_pago) FROM ta_17_conv_pagos WHERE id_conv_resto=b.id_conv_resto),0)) as adeudo,
    CASE b.vigencia WHEN 'A' THEN 'VIGENTE' WHEN 'B' THEN 'BAJA' WHEN 'P' THEN 'PAGADO' ELSE b.vigencia END as vigencia,
    CASE WHEN f.vigencia='V' THEN 'VIGENTE' WHEN f.vigencia='P' THEN 'PAGADO' ELSE 'CANCELADO' END as vigfolio,
    COALESCE(f.fecpag::text, '') as fpago,
    COALESCE(e.importe_pago, 0) as importe_pago,
    e.referencia,
    e.impuesto,
    e.recargos,
    e.gastos,
    e.multa,
    (f.axodsd::text||'/'||f.mesdsd::text||' - '||f.axohst::text||'/'||f.meshst::text) as periodos
  FROM ta_17_conv_diverso a
  JOIN ta_17_conv_d_resto b ON a.tipo=b.tipo AND a.id_conv_diver=b.id_conv_diver
  JOIN ta_17_subtipo_conv d ON a.tipo=d.tipo AND a.subtipo=d.subtipo
  JOIN ta_17_tipos i ON a.tipo=i.tipo
  LEFT JOIN ta_17_conv_pagos e ON e.id_conv_resto=b.id_conv_resto
  LEFT JOIN spd_17_folreqconv(p_tipo, e.id_referencia, b.fecha_inicio, b.fecha_venc) f ON TRUE
  WHERE a.tipo = p_tipo
    AND (p_subtipo IS NULL OR a.subtipo = p_subtipo OR p_subtipo = 0)
    AND (p_recaudadora IS NULL OR a.letras_exp = (
      CASE p_recaudadora
        WHEN 1 THEN 'ZC1'
        WHEN 2 THEN 'ZO2'
        WHEN 3 THEN 'ZO3'
        WHEN 4 THEN 'ZM4'
        WHEN 5 THEN 'ZC5'
        ELSE a.letras_exp
      END
    ) OR p_recaudadora = 0)
    AND (a.axo_exp BETWEEN p_anio_ini AND p_anio_fin)
    AND (p_vigencia = '0' OR b.vigencia = p_vigencia)
    -- Filtro de ejecutor si aplica
    AND (p_ejecutor IS NULL OR f.ejecutor = p_ejecutor OR p_ejecutor = 0)
  ORDER BY a.tipo, a.subtipo, a.letras_exp, a.numero_exp, a.axo_exp, b.fecha_inicio;
END; $$ LANGUAGE plpgsql;

-- ============================================

