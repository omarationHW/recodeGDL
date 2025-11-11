-- Stored Procedure: get_recaudadora_zona
-- Tipo: Catalog
-- Descripción: Obtiene información de la recaudadora y zona por id_rec.
-- Generado para formulario: RprtListaxRegEstacionometro
-- Fecha: 2025-08-27 14:43:30

CREATE OR REPLACE FUNCTION get_recaudadora_zona(p_rec SMALLINT)
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
    FROM padron_licencias.comun.ta_12_recaudadoras a
    JOIN padron_licencias.comun.ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.id_rec = p_rec;
END;
$$ LANGUAGE plpgsql;