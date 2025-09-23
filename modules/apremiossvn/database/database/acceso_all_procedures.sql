-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: acceso
-- Generado: 2025-08-27 13:30:49
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_acceso_login
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna datos de usuario si es correcto.
-- --------------------------------------------

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

-- ============================================

-- SP 2/3: sp_acceso_get_user
-- Tipo: Catalog
-- Descripción: Obtiene información de usuario por nombre de usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_acceso_get_user(p_usuario TEXT)
RETURNS TABLE(id_usuario INTEGER, usuario TEXT, nombre TEXT, nivel INTEGER, id_rec INTEGER, id_zona INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT id_usuario, usuario, nombre, nivel, id_rec, id_zona FROM usuarios WHERE usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_acceso_set_user_registry
-- Tipo: CRUD
-- Descripción: Guarda el usuario en la tabla de preferencias (registro local).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_acceso_set_user_registry(p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO user_registry(key, value, updated_at) VALUES ('usuario_sistema', p_usuario, NOW())
  ON CONFLICT (key) DO UPDATE SET value = p_usuario, updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- ============================================

