-- Stored Procedure: colonias_delete
-- Tipo: CRUD
-- Descripción: Elimina una colonia del catálogo.
-- Generado para formulario: Colonias
-- Fecha: 2025-08-27 14:05:29

CREATE OR REPLACE FUNCTION colonias_delete(
    p_colonia SMALLINT
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
BEGIN
    DELETE FROM ta_17_colonias WHERE colonia = p_colonia;
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Colonia eliminada correctamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'Colonia no encontrada';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;