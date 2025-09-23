-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: UNACCESO (EXACTO del archivo original)
-- Archivo: 119_SP_ASEO_UNACCESO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_login_usuario
-- Tipo: CRUD
-- Descripción: Autenticación de usuario: verifica usuario y contraseña y retorna datos básicos
-- --------------------------------------------

-- PostgreSQL stored procedure for login
CREATE OR REPLACE FUNCTION sp_login_usuario(p_usuario VARCHAR, p_contrasena VARCHAR)
RETURNS TABLE(
    autenticado BOOLEAN,
    usuario VARCHAR,
    nombre VARCHAR,
    nivel SMALLINT,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        CASE WHEN COUNT(*) > 0 THEN TRUE ELSE FALSE END AS autenticado,
        u.usuario,
        u.nombre,
        u.nivel,
        u.id_usuario
    FROM usuarios u
    WHERE u.usuario = p_usuario
      AND u.contrasena = crypt(p_contrasena, u.contrasena)
    GROUP BY u.usuario, u.nombre, u.nivel, u.id_usuario;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================

