-- Stored Procedure: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve la lista de recaudadoras para combos.
-- Generado para formulario: RptPagosLocales
-- Fecha: 2025-08-27 01:28:57

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE (
    id_rec INT,
    recaudadora VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_rec, recaudadora
    FROM ta_12_recaudadoras
    ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;