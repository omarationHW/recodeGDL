-- Stored Procedure: sp_firma_validate
-- Tipo: CRUD
-- Descripción: Valida si la firma digital ingresada es correcta para el usuario actual (puede ser extendido para validar contra una tabla de usuarios/firma). Retorna is_valid boolean.
-- Generado para formulario: firma
-- Fecha: 2025-08-27 17:42:48

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