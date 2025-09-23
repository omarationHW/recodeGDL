-- Stored Procedure: sp_imprime_oficio_firma
-- Tipo: Catalog
-- Descripción: Obtiene los datos de firma para la recaudadora correspondiente.
-- Generado para formulario: ImprimeOficio
-- Fecha: 2025-08-27 14:41:11

CREATE OR REPLACE FUNCTION sp_imprime_oficio_firma(
    p_recaudadora INTEGER
) RETURNS TABLE (
    recaudadora INTEGER,
    titular TEXT,
    cargotitular TEXT,
    recaudador TEXT,
    cargorecaudador TEXT,
    testigo1 TEXT,
    testigo2 TEXT,
    letras TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT recaudadora, titular, cargotitular, recaudador, cargorecaudador, testigo1, testigo2, letras
    FROM ta_17_firmaconv WHERE recaudadora=p_recaudadora;
END;
$$ LANGUAGE plpgsql;