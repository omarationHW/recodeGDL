-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - MERCADOS
-- Formulario: Acceso (EXACTO del archivo original)
-- Archivo: 01_SP_MERCADOS_ACCESO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
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
    FROM public.ta_12_passwords
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