-- Stored Procedure: multas_fed_400_search_by_acta
-- Tipo: Report
-- Descripción: Busca multas federales por dependencia, año y número de acta.
-- Generado para formulario: multas400frm
-- Fecha: 2025-08-27 13:11:21

CREATE OR REPLACE FUNCTION multas_fed_400_search_by_acta(
    p_depfed VARCHAR,
    p_axofed INTEGER,
    p_numacta INTEGER
)
RETURNS SETOF multas_fed_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM multas_fed_400
    WHERE depfed = p_depfed
      AND axofed = p_axofed
      AND numacta = p_numacta;
END;
$$ LANGUAGE plpgsql;