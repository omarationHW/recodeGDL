-- Stored Procedure: sp_firmas_list
-- Tipo: Catalog
-- Descripción: Devuelve todas las firmas de convenios
-- Generado para formulario: Firmas
-- Fecha: 2025-08-27 14:37:21

CREATE OR REPLACE FUNCTION sp_firmas_list()
RETURNS TABLE (
    recaudadora integer,
    titular varchar,
    cargotitular varchar,
    recaudador varchar,
    cargorecaudador varchar,
    testigo1 varchar,
    testigo2 varchar,
    letras varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT recaudadora, titular, cargotitular, recaudador, cargorecaudador, testigo1, testigo2, letras
    FROM ta_17_firmaconv
    ORDER BY recaudadora;
END;
$$ LANGUAGE plpgsql;