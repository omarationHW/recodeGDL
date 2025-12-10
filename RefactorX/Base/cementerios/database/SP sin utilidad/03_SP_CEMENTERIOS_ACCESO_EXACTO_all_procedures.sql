-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: Acceso (EXACTO del archivo original)
-- Archivo: 03_SP_CEMENTERIOS_ACCESO_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_acceso_login
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna datos del usuario si es correcto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_acceso_login(p_usuario TEXT, p_clave TEXT)
RETURNS TABLE(success BOOLEAN, usuario TEXT, id_usuario INT, nivel INT, nombre TEXT) AS $$
DECLARE
  v_usuario RECORD;
BEGIN
  SELECT id_usuario, usuario, nombre, nivel
    INTO v_usuario
    FROM public.ta_12_passwords
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

-- ============================================