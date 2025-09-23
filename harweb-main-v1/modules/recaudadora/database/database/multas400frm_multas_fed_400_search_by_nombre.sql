-- Stored Procedure: multas_fed_400_search_by_nombre
-- Tipo: Report
-- Descripción: Busca multas federales por nombre (LIKE, mayúsculas).
-- Generado para formulario: multas400frm
-- Fecha: 2025-08-27 13:11:21

CREATE OR REPLACE FUNCTION multas_fed_400_search_by_nombre(
    p_nombre VARCHAR
)
RETURNS SETOF multas_fed_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM multas_fed_400
    WHERE UPPER(nombre) LIKE UPPER(p_nombre)
    ORDER BY nombre;
END;
$$ LANGUAGE plpgsql;