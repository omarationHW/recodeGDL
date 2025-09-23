-- Stored Procedure: get_recaudadora_zona
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora y zona para una oficina dada.
-- Generado para formulario: RprtListaxRegMer
-- Fecha: 2025-08-27 14:45:29

CREATE OR REPLACE FUNCTION get_recaudadora_zona(
    p_oficina SMALLINT
)
RETURNS TABLE (
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR,
    domicilio VARCHAR,
    tel VARCHAR,
    recaudador VARCHAR,
    sector VARCHAR,
    zona VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.zona
    FROM ta_12_recaudadoras a
    JOIN ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.id_rec = p_oficina;
END;
$$ LANGUAGE plpgsql;