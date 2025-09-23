-- Stored Procedure: sp_colonias_delete
-- Tipo: CRUD
-- Descripción: Elimina una colonia de ta_17_colonias
-- Generado para formulario: ColoniasMntto
-- Fecha: 2025-08-27 14:07:19

CREATE OR REPLACE FUNCTION sp_colonias_delete(
    p_colonia integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_17_colonias WHERE colonia = p_colonia;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'La colonia no existe';
        RETURN;
    END IF;
    DELETE FROM ta_17_colonias WHERE colonia = p_colonia;
    RETURN QUERY SELECT true, 'Colonia eliminada correctamente';
END;
$$ LANGUAGE plpgsql;