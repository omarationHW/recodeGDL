-- Stored Procedure: rpt_lista_mercados_resumen
-- Tipo: Report
-- Descripción: Resumen de totales por mercado (importe, recargos, multas, gastos, total).
-- Generado para formulario: RptLista_mercados
-- Fecha: 2025-08-27 14:55:43

CREATE OR REPLACE FUNCTION rpt_lista_mercados_resumen(
    vofna integer,
    vmerc1 integer,
    vmerc2 integer,
    vlocal1 integer,
    vlocal2 integer,
    vsecc text
)
RETURNS TABLE (
    num_mercado smallint,
    total_importe numeric,
    total_recargos numeric,
    total_multas numeric,
    total_gastos numeric,
    total numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
      t.num_mercado,
      SUM(t.importe) AS total_importe,
      SUM(t.recargos) AS total_recargos,
      SUM(t.importe)*0.5 AS total_multas,
      SUM(t.total_gasto) AS total_gastos,
      SUM(t.importe) + SUM(t.recargos) + SUM(t.importe)*0.5 + SUM(t.total_gasto) AS total
    FROM rpt_lista_mercados(vofna, vmerc1, vmerc2, vlocal1, vlocal2, vsecc) t
    GROUP BY t.num_mercado;
END;
$$ LANGUAGE plpgsql;
