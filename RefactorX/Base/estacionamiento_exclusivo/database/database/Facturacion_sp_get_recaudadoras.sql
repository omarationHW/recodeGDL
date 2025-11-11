-- Stored Procedure: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras.
-- Generado para formulario: Facturacion
-- Fecha: 2025-08-27 13:48:14

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(
    id_rec integer,
    recaudadora text
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_rec, recaudadora FROM padron_licencias.comun.ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;