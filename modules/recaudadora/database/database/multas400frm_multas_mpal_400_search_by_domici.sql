-- Stored Procedure: multas_mpal_400_search_by_domici
-- Tipo: Report
-- Descripción: Busca multas municipales por domicilio (LIKE, mayúsculas).
-- Generado para formulario: multas400frm
-- Fecha: 2025-08-27 13:11:21

CREATE OR REPLACE FUNCTION multas_mpal_400_search_by_domici(
    p_domici VARCHAR
)
RETURNS SETOF multas_mpal_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM multas_mpal_400
    WHERE UPPER(domici) LIKE UPPER(p_domici)
    ORDER BY domici;
END;
$$ LANGUAGE plpgsql;