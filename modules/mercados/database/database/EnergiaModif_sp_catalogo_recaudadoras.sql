-- Stored Procedure: sp_catalogo_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras
-- Generado para formulario: EnergiaModif
-- Fecha: 2025-08-26 23:56:17

CREATE OR REPLACE FUNCTION sp_catalogo_recaudadoras() RETURNS TABLE (
    id_rec integer,
    recaudadora varchar
) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;