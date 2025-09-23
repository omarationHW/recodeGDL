-- Stored Procedure: rpt_recaudadora_zona
-- Tipo: Catalog
-- Descripción: Obtiene información de la recaudadora y zona asociada.
-- Generado para formulario: RprtEstadxfolio
-- Fecha: 2025-08-27 14:32:03

CREATE OR REPLACE FUNCTION rpt_recaudadora_zona(
    p_reca integer
)
RETURNS TABLE (
    id_rec smallint,
    id_zona integer,
    recaudadora varchar,
    domicilio varchar,
    tel varchar,
    recaudador varchar,
    sector varchar,
    id_zona_1 integer,
    zona varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.id_zona AS id_zona_1, b.zona
    FROM ta_12_recaudadoras a
    JOIN ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.id_rec = p_reca;
END;
$$ LANGUAGE plpgsql;