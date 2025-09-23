-- Stored Procedure: sp_buscar_mercados_adeudos
-- Tipo: Report
-- Descripción: Busca adeudos de mercados según filtros.
-- Generado para formulario: Requerimientos
-- Fecha: 2025-08-27 14:28:57

CREATE OR REPLACE FUNCTION sp_buscar_mercados_adeudos(
  p_oficina INT,
  p_num_mercado_desde INT,
  p_num_mercado_hasta INT,
  p_local_desde INT,
  p_local_hasta INT,
  p_seccion TEXT,
  p_filtro_tipo TEXT,
  p_filtro_valor TEXT,
  p_adeudo_desde NUMERIC,
  p_adeudo_hasta NUMERIC,
  p_user_id INT
) RETURNS TABLE(
  id INT,
  descripcion TEXT,
  adeudo NUMERIC,
  periodo TEXT,
  importe NUMERIC,
  recargos NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT m.id_mercado, m.descripcion, SUM(a.importe) AS adeudo, '2024-1' AS periodo, SUM(a.importe) AS importe, SUM(a.recargos) AS recargos
  FROM mercados m
  JOIN adeudos a ON a.id_mercado = m.id_mercado
  WHERE m.oficina = p_oficina
    AND m.num_mercado BETWEEN p_num_mercado_desde AND p_num_mercado_hasta
    AND a.local BETWEEN p_local_desde AND p_local_hasta
    AND (p_seccion IS NULL OR m.seccion = p_seccion)
    AND (a.importe BETWEEN p_adeudo_desde AND p_adeudo_hasta)
  GROUP BY m.id_mercado, m.descripcion;
END;
$$ LANGUAGE plpgsql;