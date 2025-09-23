-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: TDMCONECTION (EXACTO del archivo original)
-- Archivo: 32_SP_LICENCIAS_TDMCONECTION_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: fn_bitacora_lic_login
-- Tipo: CRUD
-- Descripción: Registra el inicio de sesión en la bitácora y retorna el id insertado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION fn_bitacora_lic_login(p_fecha_inicio TIMESTAMP, p_usuario VARCHAR, p_ip VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO bitacora_lic_login (fecha_inicio, usuario, nombre_pc, ip)
    VALUES (p_fecha_inicio, p_usuario, inet_client_host(), p_ip)
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: TDMCONECTION (EXACTO del archivo original)
-- Archivo: 32_SP_LICENCIAS_TDMCONECTION_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_get_usuario
-- Tipo: Catalog
-- Descripción: Obtiene información de usuario por nombre de usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_usuario(p_usuario VARCHAR)
RETURNS TABLE(id INTEGER, usuario VARCHAR, nombres VARCHAR, password VARCHAR, cvedepto INTEGER, cvedependencia INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT id, usuario, nombres, password, cvedepto, cvedependencia FROM usuarios WHERE usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

