-- Stored Procedure: sp_cat_unidades_delete
-- Tipo: Catalog
-- Descripción: Elimina una unidad de recolección si no tiene contratos asociados.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_cat_unidades_delete(p_id INTEGER)
RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_contratos WHERE ctrol_recolec = p_id;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'ERROR: Existen contratos asociados, no se puede eliminar';
        RETURN;
    END IF;
    DELETE FROM ta_16_unidades WHERE id = p_id;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;