-- Stored Procedure: fechasegfrm_list
-- Tipo: Catalog
-- Descripción: Lista los registros recientes de la tabla fechasegfrm.
-- Generado para formulario: fechasegfrm
-- Fecha: 2025-08-27 17:41:32

CREATE OR REPLACE FUNCTION fechasegfrm_list()
RETURNS TABLE(id INTEGER, fecha DATE, oficio VARCHAR, created_at TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
    SELECT id, fecha, oficio, created_at
    FROM fechasegfrm
    ORDER BY created_at DESC
    LIMIT 20;
END;
$$ LANGUAGE plpgsql;