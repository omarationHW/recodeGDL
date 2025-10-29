-- Stored Procedure: sp_get_oficinas
-- Tipo: Catalog
-- Descripción: Obtiene la lista de oficinas recaudadoras.
-- Generado para formulario: ConsCapturaFecha
-- Fecha: 2025-08-26 23:13:33

CREATE OR REPLACE FUNCTION sp_get_oficinas()
RETURNS TABLE (id_rec INTEGER, recaudadora VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;