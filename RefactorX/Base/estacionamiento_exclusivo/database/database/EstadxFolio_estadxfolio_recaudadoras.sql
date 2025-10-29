-- Stored Procedure: estadxfolio_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras.
-- Generado para formulario: EstadxFolio
-- Fecha: 2025-08-27 13:45:25

CREATE OR REPLACE FUNCTION estadxfolio_recaudadoras()
RETURNS TABLE (
    id_rec integer,
    recaudadora text
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;