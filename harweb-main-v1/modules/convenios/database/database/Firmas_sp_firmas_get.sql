-- Stored Procedure: sp_firmas_get
-- Tipo: Catalog
-- Descripción: Obtiene una firma de convenio por recaudadora
-- Generado para formulario: Firmas
-- Fecha: 2025-08-27 14:37:21

CREATE OR REPLACE FUNCTION sp_firmas_get(
    p_recaudadora integer
) RETURNS TABLE (
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
    WHERE recaudadora = p_recaudadora;
END;
$$ LANGUAGE plpgsql;