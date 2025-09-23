-- Stored Procedure: sp_listxFec_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene la lista de recaudadoras
-- Generado para formulario: ListxFec
-- Fecha: 2025-08-27 20:48:46

CREATE OR REPLACE FUNCTION sp_listxFec_get_recaudadoras()
RETURNS TABLE(id_rec INT, recaudadora VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;