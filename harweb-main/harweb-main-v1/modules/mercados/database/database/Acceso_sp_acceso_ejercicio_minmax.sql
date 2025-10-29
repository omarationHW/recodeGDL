-- Stored Procedure: sp_acceso_ejercicio_minmax
-- Tipo: Catalog
-- Descripción: Devuelve el rango de ejercicios válidos para el sistema.
-- Generado para formulario: Acceso
-- Fecha: 2025-08-26 20:45:12

CREATE OR REPLACE FUNCTION sp_acceso_ejercicio_minmax()
RETURNS TABLE(min_ejercicio INTEGER, max_ejercicio INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT 2003, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
END;
$$ LANGUAGE plpgsql;