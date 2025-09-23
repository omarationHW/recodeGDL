-- Stored Procedure: sp_estadisticas_importe
-- Tipo: Report
-- Descripción: Obtiene la estadística global de adeudos vencidos al periodo (año-mes) con importe mayor o igual al parámetro
-- Generado para formulario: Estadisticas
-- Fecha: 2025-08-26 23:59:12

CREATE OR REPLACE FUNCTION sp_estadisticas_importe(p_year INTEGER, p_month INTEGER, p_importe NUMERIC)
RETURNS TABLE(oficina SMALLINT, num_mercado SMALLINT, local_count INTEGER, adeudo NUMERIC, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT a.oficina, a.num_mercado, COUNT(a.id_local) AS local_count,
      (
        SELECT SUM(m.importe)
        FROM ta_11_adeudo_local m
        JOIN ta_11_locales b ON m.id_local = b.id_local AND b.num_mercado = a.num_mercado
        WHERE ((m.axo = p_year AND m.periodo <= p_month) OR (m.axo < p_year))
      ) AS adeudo,
      f.descripcion
    FROM ta_11_locales a
    JOIN ta_11_mercados f ON f.oficina = a.oficina AND f.num_mercado_nvo = a.num_mercado
    WHERE a.id_local IN (
      SELECT c.id_local FROM ta_11_adeudo_local c
      WHERE ((c.axo = p_year AND c.periodo <= p_month) OR (c.axo < p_year))
      GROUP BY c.id_local
    )
    GROUP BY a.oficina, a.num_mercado, f.descripcion
    HAVING (
      SELECT SUM(m.importe)
      FROM ta_11_adeudo_local m
      JOIN ta_11_locales b ON m.id_local = b.id_local AND b.num_mercado = a.num_mercado
      WHERE ((m.axo = p_year AND m.periodo <= p_month) OR (m.axo < p_year))
    ) >= p_importe
    ORDER BY a.oficina, a.num_mercado;
END;
$$ LANGUAGE plpgsql;