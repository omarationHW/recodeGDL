-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: TDMConection
-- Generado: 2025-08-26 18:15:59
-- Total SPs: 3
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

-- SP 2/3: sp_bitacora_lic_logout
-- Tipo: CRUD
-- Descripción: Registra el fin de sesión en la bitácora.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_bitacora_lic_logout(p_id_bitacora INTEGER, p_fecha_fin TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE bitacora_lic_login
    SET fecha_fin = p_fecha_fin
    WHERE id = p_id_bitacora;
END;
$$;

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

