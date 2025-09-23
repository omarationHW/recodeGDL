-- Stored Procedure: sp_passwords_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de ta_12_passwords por id_usuario.
-- Generado para formulario: Dspasswords
-- Fecha: 2025-08-27 13:35:26

CREATE OR REPLACE FUNCTION sp_passwords_delete(
    p_id_usuario INTEGER
) RETURNS TABLE (
    deleted BOOLEAN
) AS $$
BEGIN
    DELETE FROM ta_12_passwords WHERE id_usuario = p_id_usuario;
    RETURN QUERY SELECT TRUE AS deleted;
END;
$$ LANGUAGE plpgsql;