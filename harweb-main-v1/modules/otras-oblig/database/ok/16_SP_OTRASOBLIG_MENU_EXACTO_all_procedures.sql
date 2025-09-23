-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - OTRAS-OBLIG
-- Formulario: Menu (EXACTO del archivo original)
-- Archivo: 16_SP_OTRASOBLIG_MENU_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_menu_login
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna información de usuario si es correcto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_menu_login(p_usuario TEXT, p_password TEXT)
RETURNS TABLE(status TEXT, id_usuario INT, usuario TEXT, nombre TEXT, estado TEXT, id_rec SMALLINT, nivel SMALLINT, message TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      CASE WHEN t.usuario IS NOT NULL THEN 'ok' ELSE 'error' END AS status,
      t.id_usuario, t.usuario, t.nombre, t.estado, t.id_rec, t.nivel,
      CASE WHEN t.usuario IS NOT NULL THEN NULL ELSE 'Usuario o clave incorrecta' END AS message
    FROM otrasoblig.ta_12_passwords t
    WHERE t.usuario = p_usuario AND t.password = p_password;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_menu_get_menu
-- Tipo: Catalog
-- Descripción: Devuelve el menú de opciones disponibles para el usuario según su nivel.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_menu_get_menu(p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
  v_nivel SMALLINT;
  v_menu JSON;
BEGIN
  SELECT nivel INTO v_nivel FROM otrasoblig.ta_12_passwords WHERE usuario = p_usuario;
  -- Ejemplo de menú, debe adaptarse a la lógica real de permisos
  v_menu := json_build_array(
    json_build_object('nombre', 'Controles', 'opciones', json_build_array(
      json_build_object('id', 101, 'titulo', 'Alta de Fuente de Sodas', 'enabled', v_nivel >= 1),
      json_build_object('id', 102, 'titulo', 'Alta de Juegos Mecánicos', 'enabled', v_nivel >= 1)
    )),
    json_build_object('nombre', 'Reportes', 'opciones', json_build_array(
      json_build_object('id', 301, 'titulo', 'Edo. Cuenta', 'enabled', v_nivel >= 1)
    ))
  );
  RETURN v_menu;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_menu_get_ejercicios
-- Tipo: Catalog
-- Descripción: Devuelve la lista de ejercicios disponibles.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_menu_get_ejercicios()
RETURNS TABLE(ejercicio INT) AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT ejercicio_recolec AS ejercicio
    FROM otrasoblig.ta_16_unidades
    ORDER BY ejercicio_recolec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_menu_check_version
-- Tipo: CRUD
-- Descripción: Verifica si hay una nueva versión disponible para el proyecto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_menu_check_version(p_proyecto TEXT, p_version TEXT)
RETURNS TABLE(update_required BOOLEAN) AS $$
BEGIN
  RETURN QUERY
    SELECT NOT EXISTS (
      SELECT 1 FROM otrasoblig.ta_versiones WHERE proyecto = p_proyecto AND version = p_version
    ) AS update_required;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_menu_get_user_info
-- Tipo: Catalog
-- Descripción: Devuelve información detallada del usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_menu_get_user_info(p_usuario TEXT)
RETURNS TABLE(id_usuario INT, usuario TEXT, nombre TEXT, estado TEXT, id_rec SMALLINT, nivel SMALLINT) AS $$
BEGIN
  RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
    FROM otrasoblig.ta_12_passwords
    WHERE usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================