-- Stored Procedure: multas_mpal_400_search_by_acta
-- Tipo: Report
-- Descripción: Busca multas municipales por dependencia, año y número de acta.
-- Generado para formulario: multas400frm
-- Fecha: 2025-08-27 13:11:21

CREATE OR REPLACE FUNCTION multas_mpal_400_search_by_acta(
    p_depen VARCHAR,
    p_axoacta INTEGER,
    p_numacta INTEGER
)
RETURNS SETOF multas_mpal_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM multas_mpal_400
    WHERE depen = p_depen
      AND axoacta = p_axoacta
      AND numacta = p_numacta;
END;
$$ LANGUAGE plpgsql;