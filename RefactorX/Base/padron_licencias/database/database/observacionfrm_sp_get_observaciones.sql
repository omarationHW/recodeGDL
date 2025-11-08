-- Stored Procedure: sp_get_observaciones
-- Tipo: Catalog
-- Descripción: Obtiene todas las observaciones registradas, ordenadas por fecha de creación descendente.
-- Generado para formulario: observacionfrm
-- Fecha: 2025-08-27 18:48:48

CREATE OR REPLACE FUNCTION sp_get_observaciones()
RETURNS TABLE(id BIGINT, observacion TEXT, created_at TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
        SELECT id, observacion, created_at
        FROM observaciones
        ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql;