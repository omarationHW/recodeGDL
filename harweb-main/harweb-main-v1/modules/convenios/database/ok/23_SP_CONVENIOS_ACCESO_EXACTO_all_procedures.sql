-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ACCESO (EXACTO del archivo original)
-- Archivo: 23_SP_CONVENIOS_ACCESO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_login_usuario
-- Tipo: Catalog
-- Descripción: Autenticación de usuario. Devuelve datos del usuario si username/password son correctos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_login_usuario(p_username TEXT, p_password TEXT)
RETURNS TABLE(
    success BOOLEAN,
    id_usuario INTEGER,
    usuario TEXT,
    nombre TEXT,
    estado TEXT,
    id_rec SMALLINT,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE WHEN COUNT(*) = 1 THEN TRUE ELSE FALSE END AS success,
        u.id_usuario,
        u.usuario,
        u.nombre,
        u.estado,
        u.id_rec,
        u.nivel
    FROM public.ta_12_passwords u
    WHERE lower(u.usuario) = lower(trim(p_username))
      AND u.estado = 'A'
      AND u.password = crypt(p_password, u.password)
    GROUP BY u.id_usuario, u.usuario, u.nombre, u.estado, u.id_rec, u.nivel;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================

