-- Stored Procedure: rpt_titulos_get_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora por id_rec.
-- Generado para formulario: RptTitulos
-- Fecha: 2025-08-27 14:51:51

CREATE OR REPLACE FUNCTION rpt_titulos_get_recaudadora(rec smallint)
RETURNS TABLE (
    recing smallint,
    nomre varchar,
    titulo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT recing, nomre, titulo
    FROM ta_12_nombrerec
    WHERE recing = rec;
END;
$$ LANGUAGE plpgsql;