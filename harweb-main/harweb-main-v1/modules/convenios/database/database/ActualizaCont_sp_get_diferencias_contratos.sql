-- Stored Procedure: sp_get_diferencias_contratos
-- Tipo: Report
-- Descripción: Obtiene las diferencias de contratos que no existen en el catálogo de calles.
-- Generado para formulario: ActualizaCont
-- Fecha: 2025-08-27 13:33:08

CREATE OR REPLACE FUNCTION sp_get_diferencias_contratos()
RETURNS TABLE(colonia smallint, calle smallint, contratos integer) AS $$
BEGIN
  RETURN QUERY
    SELECT a.colonia, a.calle, COUNT(*) AS contratos
    FROM ta_17_paso_cont a
    WHERE NOT EXISTS (
      SELECT 1 FROM ta_17_calles c WHERE c.colonia = a.colonia AND c.calle = a.calle
    )
    GROUP BY a.colonia, a.calle
    ORDER BY a.colonia ASC, a.calle ASC;
END;
$$ LANGUAGE plpgsql;