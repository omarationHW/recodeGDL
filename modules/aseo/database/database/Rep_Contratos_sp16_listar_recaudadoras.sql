-- Stored Procedure: sp16_listar_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve todas las recaudadoras activas.
-- Generado para formulario: Rep_Contratos
-- Fecha: 2025-08-27 15:07:54

CREATE OR REPLACE FUNCTION sp16_listar_recaudadoras()
RETURNS TABLE(id_rec INTEGER, recaudadora TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT id_rec, recaudadora
  FROM ta_12_recaudadoras
  WHERE id_rec NOT IN (6,8)
  ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;