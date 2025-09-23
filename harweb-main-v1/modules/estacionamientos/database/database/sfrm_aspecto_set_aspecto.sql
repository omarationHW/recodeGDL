-- Stored Procedure: set_aspecto
-- Tipo: CRUD
-- Descripción: Establece el aspecto visual actual para el usuario/sistema.
-- Generado para formulario: sfrm_aspecto
-- Fecha: 2025-08-27 14:09:01

CREATE OR REPLACE FUNCTION set_aspecto(p_nombre TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    -- Aquí se podría guardar en una tabla de configuración por usuario
    -- Para demo, solo simula éxito
    -- UPDATE configuracion SET aspecto = p_nombre WHERE usuario_id = current_user_id;
    RETURN QUERY SELECT TRUE, 'Aspecto cambiado correctamente';
END;
$$ LANGUAGE plpgsql;