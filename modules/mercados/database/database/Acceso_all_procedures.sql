-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Acceso
-- Generado: 2025-08-26 20:45:12
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_acceso_login
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna datos de usuario si es correcto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_acceso_login(p_usuario TEXT, p_contrasena TEXT, p_ejercicio INTEGER)
RETURNS TABLE(success BOOLEAN, usuario TEXT, id_usuario INTEGER, nivel INTEGER, message TEXT) AS $$
DECLARE
  v_usuario RECORD;
BEGIN
  SELECT id_usuario, usuario, nivel
    INTO v_usuario
    FROM ta_12_passwords
   WHERE usuario = p_usuario AND clave = p_contrasena AND estado = 'A';
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, v_usuario.usuario, v_usuario.id_usuario, v_usuario.nivel, NULL;
  ELSE
    RETURN QUERY SELECT FALSE, NULL, NULL, NULL, 'Usuario y/o contraseña incorrectos';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_acceso_ejercicio_minmax
-- Tipo: Catalog
-- Descripción: Devuelve el rango de ejercicios válidos para el sistema.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_acceso_ejercicio_minmax()
RETURNS TABLE(min_ejercicio INTEGER, max_ejercicio INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT 2003, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- ============================================

