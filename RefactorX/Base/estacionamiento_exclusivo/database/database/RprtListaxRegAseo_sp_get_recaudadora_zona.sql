-- Stored Procedure: sp_get_recaudadora_zona
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora y zona para una oficina (id_rec).
-- Generado para formulario: RprtListaxRegAseo
-- Fecha: 2025-08-27 14:41:01

CREATE OR REPLACE FUNCTION sp_get_recaudadora_zona(
    p_id_rec integer
)
RETURNS TABLE (
    id_rec smallint,
    id_zona integer,
    recaudadora text,
    domicilio text,
    tel text,
    recaudador text,
    sector text,
    zona text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.zona
    FROM padron_licencias.comun.ta_12_recaudadoras a
    JOIN padron_licencias.comun.ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.id_rec = p_id_rec;
END;
$$ LANGUAGE plpgsql;