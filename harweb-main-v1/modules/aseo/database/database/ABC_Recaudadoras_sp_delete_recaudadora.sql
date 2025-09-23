-- Stored Procedure: sp_delete_recaudadora
-- Tipo: CRUD
-- Descripción: Elimina una recaudadora si no tiene contratos asociados.
-- Generado para formulario: ABC_Recaudadoras
-- Fecha: 2025-08-27 13:27:06

CREATE OR REPLACE FUNCTION sp_delete_recaudadora(p_num_rec SMALLINT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_16_contratos WHERE id_rec = p_num_rec;
    IF v_count > 0 THEN
        RETURN QUERY SELECT FALSE, 'No se puede eliminar: existen contratos asociados.';
    END IF;
    DELETE FROM ta_16_recaudadoras WHERE num_rec = p_num_rec;
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Recaudadora eliminada correctamente.';
    ELSE
        RETURN QUERY SELECT FALSE, 'No existe la recaudadora.';
    END IF;
END;
$$ LANGUAGE plpgsql;