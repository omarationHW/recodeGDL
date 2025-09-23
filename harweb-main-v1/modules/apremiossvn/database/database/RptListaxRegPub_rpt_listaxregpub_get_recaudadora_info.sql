-- Stored Procedure: rpt_listaxregpub_get_recaudadora_info
-- Tipo: Catalog
-- Descripción: Obtiene información de la recaudadora y zona para el usuario actual.
-- Generado para formulario: RptListaxRegPub
-- Fecha: 2025-08-27 14:53:31

CREATE OR REPLACE FUNCTION rpt_listaxregpub_get_recaudadora_info(
    p_usuario_id_rec SMALLINT
)
RETURNS TABLE (
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora TEXT,
    domicilio TEXT,
    tel TEXT,
    recaudador TEXT,
    sector TEXT,
    zona TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_rec, a.id_zona, a.recaudadora, a.domicilio, a.tel, a.recaudador, a.sector, b.zona
    FROM ta_12_recaudadoras a
    JOIN ta_12_zonas b ON a.id_zona = b.id_zona
    WHERE a.id_rec = p_usuario_id_rec;
END;
$$ LANGUAGE plpgsql;