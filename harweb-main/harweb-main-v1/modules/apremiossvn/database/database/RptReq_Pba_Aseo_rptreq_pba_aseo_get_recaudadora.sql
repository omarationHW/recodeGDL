-- Stored Procedure: rptreq_pba_aseo_get_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la recaudadora y zona para un id_rec dado.
-- Generado para formulario: RptReq_Pba_Aseo
-- Fecha: 2025-08-27 15:15:15

CREATE OR REPLACE FUNCTION rptreq_pba_aseo_get_recaudadora(
    p_id_rec SMALLINT
)
RETURNS TABLE (
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora TEXT,
    domicilio TEXT,
    tel TEXT,
    recaudador TEXT,
    sector TEXT,
    recing SMALLINT,
    nomre TEXT,
    id_zona_1 INTEGER,
    zona TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.recing, b.nomre, c.id_zona AS id_zona_1, c.zona
    FROM ta_12_recaudadoras a
    JOIN ta_12_nombrerec b ON a.id_rec = b.recing
    JOIN ta_12_zonas c ON a.id_zona = c.id_zona
    WHERE a.id_rec = p_id_rec;
END;
$$ LANGUAGE plpgsql;