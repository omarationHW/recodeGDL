-- Stored Procedure: sp_acceso_login
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna datos del usuario si es correcto.
-- Generado para formulario: Acceso
-- Fecha: 2025-08-28 17:41:13

CREATE OR REPLACE FUNCTION sp_acceso_login(p_usuario TEXT, p_clave TEXT)
RETURNS TABLE(success BOOLEAN, usuario TEXT, id_usuario INT, nivel INT, nombre TEXT) AS $$
DECLARE
  v_usuario RECORD;
BEGIN
  SELECT id_usuario, usuario, nombre, nivel
    INTO v_usuario
    FROM ta_12_passwords
   WHERE usuario = p_usuario
     AND clave = p_clave
     AND estado = 'A'
   LIMIT 1;
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, v_usuario.usuario, v_usuario.id_usuario, v_usuario.nivel, v_usuario.nombre;
  ELSE
    RETURN QUERY SELECT FALSE, NULL, NULL, NULL, NULL;
  END IF;
END;
$$ LANGUAGE plpgsql;