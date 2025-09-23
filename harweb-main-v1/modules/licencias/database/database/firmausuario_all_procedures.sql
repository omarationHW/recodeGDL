-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: firmausuario
-- Generado: 2025-08-27 17:45:08
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_validate_firma_usuario
-- Tipo: CRUD
-- Descripción: Valida si el usuario y la firma electrónica coinciden en la base de datos. Retorna success=true/false y un mensaje.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_validate_firma_usuario(p_usuario VARCHAR, p_firma VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Suponiendo que existe una tabla usuarios con campos usuario y firma_digital
    SELECT COUNT(*) INTO v_count
    FROM usuarios
    WHERE usuario = p_usuario AND firma_digital = p_firma;

    IF v_count > 0 THEN
        RETURN QUERY SELECT TRUE, 'Firma validada correctamente.';
    ELSE
        RETURN QUERY SELECT FALSE, 'Usuario o firma incorrectos.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

