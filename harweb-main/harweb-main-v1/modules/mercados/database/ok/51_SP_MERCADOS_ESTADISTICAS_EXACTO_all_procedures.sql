-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Estadisticas
-- Generado: 2025-08-26 23:59:12
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_estadisticas_global
-- Tipo: Report
-- Descripción: Obtiene la estadística global de adeudos vencidos al periodo (año-mes)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_estadisticas_global(p_year INTEGER, p_month INTEGER)
RETURNS TABLE(oficina SMALLINT, num_mercado SMALLINT, local_count INTEGER, adeudo NUMERIC, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT a.oficina, a.num_mercado, COUNT(a.id_local) AS local_count,
      (
        SELECT SUM(m.importe)
        FROM public.ta_11_adeudo_local m
        JOIN public.ta_11_locales b ON m.id_local = b.id_local AND b.num_mercado = a.num_mercado
        WHERE ((m.axo = p_year AND m.periodo <= p_month) OR (m.axo < p_year))
      ) AS adeudo,
      f.descripcion
    FROM public.ta_11_locales a
    JOIN public.ta_11_mercados f ON f.oficina = a.oficina AND f.num_mercado_nvo = a.num_mercado
    WHERE a.id_local IN (
      SELECT c.id_local FROM public.ta_11_adeudo_local c
      WHERE ((c.axo = p_year AND c.periodo <= p_month) OR (c.axo < p_year))
      GROUP BY c.id_local
    )
    GROUP BY a.oficina, a.num_mercado, f.descripcion
    ORDER BY a.oficina, a.num_mercado;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_estadisticas_importe
-- Tipo: Report
-- Descripción: Obtiene la estadística global de adeudos vencidos al periodo (año-mes) con importe mayor o igual al parámetro
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_estadisticas_importe(p_year INTEGER, p_month INTEGER, p_importe NUMERIC)
RETURNS TABLE(oficina SMALLINT, num_mercado SMALLINT, local_count INTEGER, adeudo NUMERIC, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT a.oficina, a.num_mercado, COUNT(a.id_local) AS local_count,
      (
        SELECT SUM(m.importe)
        FROM public.ta_11_adeudo_local m
        JOIN public.ta_11_locales b ON m.id_local = b.id_local AND b.num_mercado = a.num_mercado
        WHERE ((m.axo = p_year AND m.periodo <= p_month) OR (m.axo < p_year))
      ) AS adeudo,
      f.descripcion
    FROM public.ta_11_locales a
    JOIN public.ta_11_mercados f ON f.oficina = a.oficina AND f.num_mercado_nvo = a.num_mercado
    WHERE a.id_local IN (
      SELECT c.id_local FROM public.ta_11_adeudo_local c
      WHERE ((c.axo = p_year AND c.periodo <= p_month) OR (c.axo < p_year))
      GROUP BY c.id_local
    )
    GROUP BY a.oficina, a.num_mercado, f.descripcion
    HAVING (
      SELECT SUM(m.importe)
      FROM public.ta_11_adeudo_local m
      JOIN public.ta_11_locales b ON m.id_local = b.id_local AND b.num_mercado = a.num_mercado
      WHERE ((m.axo = p_year AND m.periodo <= p_month) OR (m.axo < p_year))
    ) >= p_importe
    ORDER BY a.oficina, a.num_mercado;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_desgloce_adeudos_por_importe
-- Tipo: Report
-- Descripción: Desglosa los adeudos por año para locales con importe mayor o igual al parámetro
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_desgloce_adeudos_por_importe(p_year INTEGER, p_month INTEGER, p_importe NUMERIC)
RETURNS TABLE(
  id_local INTEGER,
  oficina SMALLINT,
  mercado SMALLINT,
  categoria SMALLINT,
  seccion VARCHAR,
  local SMALLINT,
  letra VARCHAR,
  bloque VARCHAR,
  nombre VARCHAR,
  descripcion VARCHAR,
  ade_ant NUMERIC,
  ade_2004 NUMERIC,
  ade_2005 NUMERIC,
  ade_2006 NUMERIC,
  ade_2007 NUMERIC,
  ade_2008 NUMERIC,
  tot_ade NUMERIC
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      l.id_local,
      l.oficina,
      l.num_mercado,
      l.categoria,
      l.seccion,
      l.local,
      l.letra_local,
      l.bloque,
      l.nombre,
      l.descripcion_local,
      COALESCE(SUM(CASE WHEN a.axo < 2004 THEN a.importe ELSE 0 END),0) AS ade_ant,
      COALESCE(SUM(CASE WHEN a.axo = 2004 THEN a.importe ELSE 0 END),0) AS ade_2004,
      COALESCE(SUM(CASE WHEN a.axo = 2005 THEN a.importe ELSE 0 END),0) AS ade_2005,
      COALESCE(SUM(CASE WHEN a.axo = 2006 THEN a.importe ELSE 0 END),0) AS ade_2006,
      COALESCE(SUM(CASE WHEN a.axo = 2007 THEN a.importe ELSE 0 END),0) AS ade_2007,
      COALESCE(SUM(CASE WHEN a.axo = 2008 THEN a.importe ELSE 0 END),0) AS ade_2008,
      SUM(a.importe) AS tot_ade
    FROM public.ta_11_locales l
    JOIN public.ta_11_adeudo_local a ON a.id_local = l.id_local
    WHERE ((a.axo = p_year AND a.periodo <= p_month) OR (a.axo < p_year))
    GROUP BY l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque, l.nombre, l.descripcion_local
    HAVING SUM(a.importe) >= p_importe
    ORDER BY l.oficina, l.num_mercado, l.id_local;
END;
$$ LANGUAGE plpgsql;

-- ============================================

