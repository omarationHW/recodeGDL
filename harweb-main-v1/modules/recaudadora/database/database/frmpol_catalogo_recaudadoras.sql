-- Stored Procedure: catalogo_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras disponibles.
-- Generado para formulario: frmpol
-- Fecha: 2025-08-27 12:14:54

CREATE OR REPLACE FUNCTION catalogo_recaudadoras()
RETURNS TABLE(
    cvectaapl VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT c.cvectaapl, c.ctaaplicacion AS descripcion
    FROM c_ctasapl c
    ORDER BY c.cvectaapl;
END;
$$ LANGUAGE plpgsql;