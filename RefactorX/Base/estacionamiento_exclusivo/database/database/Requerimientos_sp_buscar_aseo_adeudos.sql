-- Stored Procedure: sp_buscar_aseo_adeudos
-- Tipo: Report
-- Descripción: Busca adeudos de aseo según filtros.
-- Generado para formulario: Requerimientos
-- Fecha: 2025-08-27 14:28:57

CREATE OR REPLACE FUNCTION sp_buscar_aseo_adeudos(
  p_tipo_aseo TEXT,
  p_contrato_desde INT,
  p_contrato_hasta INT,
  p_filtro_tipo TEXT,
  p_filtro_valor TEXT,
  p_adeudo_desde NUMERIC,
  p_adeudo_hasta NUMERIC,
  p_user_id INT
) RETURNS TABLE(
  id INT,
  tipo_aseo TEXT,
  num_contrato INT,
  adeudo NUMERIC,
  periodo TEXT,
  importe NUMERIC,
  recargos NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.id_contrato, c.tipo_aseo, c.num_contrato, SUM(a.importe) AS adeudo, '2024-1' AS periodo, SUM(a.importe) AS importe, SUM(a.recargos) AS recargos
  FROM contratos_aseo c
  JOIN adeudos_aseo a ON a.id_contrato = c.id_contrato
  WHERE c.tipo_aseo = p_tipo_aseo
    AND c.num_contrato BETWEEN p_contrato_desde AND p_contrato_hasta
    AND (a.importe BETWEEN p_adeudo_desde AND p_adeudo_hasta)
  GROUP BY c.id_contrato, c.tipo_aseo, c.num_contrato;
END;
$$ LANGUAGE plpgsql;