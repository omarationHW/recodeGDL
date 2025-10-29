-- Stored Procedure: sp_desgloce_adeudos_por_importe
-- Tipo: Report
-- Descripción: Desglosa los adeudos por año para locales con importe mayor o igual al parámetro
-- Generado para formulario: Estadisticas
-- Fecha: 2025-08-26 23:59:12

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
    FROM ta_11_locales l
    JOIN ta_11_adeudo_local a ON a.id_local = l.id_local
    WHERE ((a.axo = p_year AND a.periodo <= p_month) OR (a.axo < p_year))
    GROUP BY l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque, l.nombre, l.descripcion_local
    HAVING SUM(a.importe) >= p_importe
    ORDER BY l.oficina, l.num_mercado, l.id_local;
END;
$$ LANGUAGE plpgsql;