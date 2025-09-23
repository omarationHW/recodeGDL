-- Stored Procedure: sp_acceso_login
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna datos de usuario si es correcto.
-- Generado para formulario: acceso
-- Fecha: 2025-08-27 13:30:49

CREATE OR REPLACE FUNCTION sp_acceso_login(p_usuario TEXT, p_clave TEXT, p_ejercicio INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT, id_usuario INTEGER, usuario TEXT, nombre TEXT, nivel INTEGER, id_rec INTEGER, id_zona INTEGER) AS $$
DECLARE
  v_usuario RECORD;
BEGIN
  SELECT * INTO v_usuario FROM usuarios WHERE usuario = p_usuario AND clave = crypt(p_clave, clave);
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Acceso concedido', v_usuario.id_usuario, v_usuario.usuario, v_usuario.nombre, v_usuario.nivel, v_usuario.id_rec, v_usuario.id_zona;
  ELSE
    RETURN QUERY SELECT FALSE, 'Usuario o contraseña incorrectos', NULL, NULL, NULL, NULL, NULL, NULL;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;