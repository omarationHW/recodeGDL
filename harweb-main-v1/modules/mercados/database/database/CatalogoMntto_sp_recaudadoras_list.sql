-- Stored Procedure: sp_recaudadoras_list
-- Tipo: Catalog
-- Descripción: Lista de recaudadoras
-- Generado para formulario: CatalogoMntto
-- Fecha: 2025-08-26 23:06:58

CREATE OR REPLACE FUNCTION sp_recaudadoras_list()
RETURNS TABLE (id_rec INTEGER, recaudadora VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;