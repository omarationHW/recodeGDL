-- Stored Procedure: fechasegfrm_get
-- Tipo: Catalog
-- Descripción: Obtiene una entrada de fechasegfrm por id, o todas si id es null.
-- Generado para formulario: fechasegfrm
-- Fecha: 2025-08-26 16:17:49

CREATE OR REPLACE FUNCTION fechasegfrm_get(p_id INTEGER DEFAULT NULL)
RETURNS TABLE(id INTEGER, fecha DATE, oficio VARCHAR) AS $$
BEGIN
    IF p_id IS NULL THEN
        RETURN QUERY SELECT id, fecha, oficio FROM fechasegfrm ORDER BY id DESC;
    ELSE
        RETURN QUERY SELECT id, fecha, oficio FROM fechasegfrm WHERE id = p_id;
    END IF;
END;
$$ LANGUAGE plpgsql;