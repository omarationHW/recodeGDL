-- Stored Procedure: sp_connect_estacion
-- Tipo: CRUD
-- Descripción: Simula la conexión a la base de datos de estación usando credenciales fijas.
-- Generado para formulario: DsDBGasto
-- Fecha: 2025-08-27 13:34:39

CREATE OR REPLACE FUNCTION sp_connect_estacion()
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Simulación: Verifica si el usuario 'estacion' existe en la tabla de usuarios de estación
    SELECT COUNT(*) INTO v_exists FROM estacion_usuarios WHERE username = 'estacion' AND password = '3st4c10n';
    IF v_exists > 0 THEN
        RETURN QUERY SELECT TRUE, 'Conexión a estación exitosa';
    ELSE
        RETURN QUERY SELECT FALSE, 'No se pudo conectar a estación';
    END IF;
END;
$$ LANGUAGE plpgsql;