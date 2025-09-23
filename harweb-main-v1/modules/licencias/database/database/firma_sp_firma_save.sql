-- Stored Procedure: sp_firma_save
-- Tipo: CRUD
-- Descripción: Guarda o actualiza la firma digital de un usuario.
-- Generado para formulario: firma
-- Fecha: 2025-08-27 17:42:48

CREATE OR REPLACE FUNCTION sp_firma_save(p_usuario_id INTEGER, p_firma_digital TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE usuarios SET firma_digital = p_firma_digital WHERE id = p_usuario_id;
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Firma actualizada correctamente.';
    ELSE
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado.';
    END IF;
END;
$$ LANGUAGE plpgsql;