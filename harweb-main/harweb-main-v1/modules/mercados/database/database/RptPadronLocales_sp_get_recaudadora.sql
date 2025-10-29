-- Stored Procedure: sp_get_recaudadora
-- Tipo: Catalog
-- Descripción: Obtiene información de la recaudadora por id.
-- Generado para formulario: RptPadronLocales
-- Fecha: 2025-08-27 01:27:45

CREATE OR REPLACE FUNCTION sp_get_recaudadora(p_oficina INTEGER)
RETURNS TABLE (
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR(40),
    domicilio VARCHAR(80),
    tel VARCHAR(15),
    recaudador VARCHAR(40)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador
    FROM ta_12_recaudadoras
    WHERE id_rec = p_oficina;
END;
$$ LANGUAGE plpgsql;