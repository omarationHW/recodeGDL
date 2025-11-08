-- Stored Procedure: sp_observacion_list
-- Tipo: Catalog
-- Descripción: Devuelve el listado de observaciones ordenadas por fecha descendente.
-- Generado para formulario: observacionfrm
-- Fecha: 2025-08-26 17:23:04

CREATE OR REPLACE FUNCTION sp_observacion_list()
RETURNS TABLE(id INTEGER, observacion TEXT, created_at TIMESTAMP) AS $$
BEGIN
  RETURN QUERY
    SELECT id, observacion, created_at
    FROM observaciones
    ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql;