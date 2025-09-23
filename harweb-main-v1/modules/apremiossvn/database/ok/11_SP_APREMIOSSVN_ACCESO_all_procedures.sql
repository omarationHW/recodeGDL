-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Acceso y Autenticación
-- Archivo: 11_SP_APREMIOSSVN_ACCESO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 3
-- ============================================

-- SP 1/3: SP_APREMIOSSVN_ACCESO_LOGIN
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna datos de usuario si es correcto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_ACCESO_LOGIN(p_usuario TEXT, p_clave TEXT, p_ejercicio INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT, id_usuario INTEGER, usuario TEXT, nombre TEXT, nivel INTEGER, id_rec INTEGER, id_zona INTEGER) AS $$
DECLARE
  v_usuario RECORD;
BEGIN
  SELECT * INTO v_usuario FROM public.usuarios WHERE usuario = p_usuario AND clave = crypt(p_clave, clave);
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Acceso concedido', v_usuario.id_usuario, v_usuario.usuario, v_usuario.nombre, v_usuario.nivel, v_usuario.id_rec, v_usuario.id_zona;
  ELSE
    RETURN QUERY SELECT FALSE, 'Usuario o contraseña incorrectos', NULL, NULL, NULL, NULL, NULL, NULL;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================

-- SP 2/3: SP_APREMIOSSVN_ACCESO_GET_USER
-- Tipo: Catalog
-- Descripción: Obtiene información de usuario por nombre de usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_ACCESO_GET_USER(p_usuario TEXT)
RETURNS TABLE(id_usuario INTEGER, usuario TEXT, nombre TEXT, nivel INTEGER, id_rec INTEGER, id_zona INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT u.id_usuario, u.usuario, u.nombre, u.nivel, u.id_rec, u.id_zona FROM public.usuarios u WHERE u.usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: SP_APREMIOSSVN_ACCESO_SET_USER_REGISTRY
-- Tipo: CRUD
-- Descripción: Guarda el usuario en la tabla de preferencias (registro local).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_ACCESO_SET_USER_REGISTRY(p_usuario TEXT)
RETURNS VOID AS $$
BEGIN
  INSERT INTO public.user_registry(key, value, updated_at) VALUES ('usuario_sistema', p_usuario, NOW())
  ON CONFLICT (key) DO UPDATE SET value = p_usuario, updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- ============================================