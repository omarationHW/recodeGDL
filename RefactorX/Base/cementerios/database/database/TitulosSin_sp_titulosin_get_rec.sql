-- Stored Procedure: sp_titulosin_get_rec
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora.
-- Generado para formulario: TitulosSin
-- Fecha: 2025-08-27 14:58:45

CREATE OR REPLACE FUNCTION sp_titulosin_get_rec(
    p_rec SMALLINT
) RETURNS TABLE(
    recing SMALLINT,
    nomre VARCHAR,
    titulo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT recing, UPPER(nomre), titulo
    FROM ta_12_nombrerec
    WHERE recing = p_rec;
END;
$$ LANGUAGE plpgsql;