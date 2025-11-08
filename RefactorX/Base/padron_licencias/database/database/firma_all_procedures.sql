-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: firma
-- Generado: 2025-08-27 17:42:48
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_firma_validate
-- Tipo: CRUD
-- Descripción: Valida si la firma digital ingresada es correcta para el usuario actual (puede ser extendido para validar contra una tabla de usuarios/firma). Retorna is_valid boolean.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_firma_validate(p_firma_digital TEXT)
RETURNS TABLE(is_valid BOOLEAN, usuario_id INTEGER, nombre TEXT) AS $$
BEGIN
    -- Ejemplo: Validar contra tabla de usuarios
    RETURN QUERY
    SELECT TRUE AS is_valid, id AS usuario_id, nombre
    FROM usuarios
    WHERE firma_digital = p_firma_digital
    LIMIT 1;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL, NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_firma_save
-- Tipo: CRUD
-- Descripción: Guarda o actualiza la firma digital de un usuario.
-- --------------------------------------------

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

-- ============================================

