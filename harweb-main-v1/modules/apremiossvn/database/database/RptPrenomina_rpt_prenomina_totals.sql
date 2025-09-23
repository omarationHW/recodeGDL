-- Stored Procedure: rpt_prenomina_totals
-- Tipo: Report
-- Descripción: Devuelve los totales del reporte de prenomina: total de gastos, total de gastos al 75%, total requerimientos, totales por ejecutor y sistema.
-- Generado para formulario: RptPrenomina
-- Fecha: 2025-08-27 14:58:17

CREATE OR REPLACE FUNCTION rpt_prenomina_totals(
    fec1 DATE,
    fec2 DATE,
    recaud SMALLINT,
    recaud1 SMALLINT
)
RETURNS TABLE (
    total_gastos NUMERIC(18,2),
    total_gastos_75 NUMERIC(18,2),
    total_cuantos INTEGER,
    total_gastos_sistema NUMERIC(18,2),
    total_gastos_ejecutor NUMERIC(18,2),
    total_cuantos_sistema INTEGER,
    total_cuantos_ejecutor INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        SUM(gastos) AS total_gastos,
        SUM(gastos) * 0.75 AS total_gastos_75,
        SUM(cuantos)::INTEGER AS total_cuantos,
        SUM(CASE WHEN ejecutor > 990 THEN gastos ELSE 0 END) AS total_gastos_sistema,
        SUM(CASE WHEN ejecutor < 990 THEN gastos ELSE 0 END) AS total_gastos_ejecutor,
        SUM(CASE WHEN ejecutor > 990 THEN cuantos ELSE 0 END)::INTEGER AS total_cuantos_sistema,
        SUM(CASE WHEN ejecutor < 990 THEN cuantos ELSE 0 END)::INTEGER AS total_cuantos_ejecutor
    FROM rpt_prenomina(fec1, fec2, recaud, recaud1);
END;
$$ LANGUAGE plpgsql;