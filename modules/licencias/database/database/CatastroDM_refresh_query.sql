-- Stored Procedure: refresh_query
-- Tipo: CRUD
-- Descripción: Refresca un dataset (dummy, para compatibilidad)
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-26 15:24:46

CREATE OR REPLACE FUNCTION refresh_query(p_dataset text)
RETURNS TABLE(result text) AS $$
BEGIN
  RETURN QUERY SELECT 'Refreshed: ' || p_dataset;
END;
$$ LANGUAGE plpgsql;