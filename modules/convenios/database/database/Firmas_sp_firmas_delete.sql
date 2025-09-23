-- Stored Procedure: sp_firmas_delete
-- Tipo: CRUD
-- Descripción: Elimina una firma de convenio por recaudadora
-- Generado para formulario: Firmas
-- Fecha: 2025-08-27 14:37:21

CREATE OR REPLACE FUNCTION sp_firmas_delete(
    p_recaudadora integer
) RETURNS TABLE (result text) AS $$
BEGIN
    DELETE FROM ta_17_firmaconv WHERE recaudadora = p_recaudadora;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;