-- Stored Procedure: sp_acceso_set_user_registry
-- Tipo: CRUD
-- Descripción: Guarda el usuario en la tabla de preferencias (registro local).
-- Generado para formulario: acceso
-- Fecha: 2025-08-27 13:30:49

CREATE OR REPLACE FUNCTION sp_acceso_set_user_registry(p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO user_registry(key, value, updated_at) VALUES ('usuario_sistema', p_usuario, NOW())
  ON CONFLICT (key) DO UPDATE SET value = p_usuario, updated_at = NOW();
END;
$$ LANGUAGE plpgsql;