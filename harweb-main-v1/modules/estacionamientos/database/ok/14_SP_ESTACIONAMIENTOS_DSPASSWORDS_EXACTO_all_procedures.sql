-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: DSPASSWORDS (EXACTO del archivo original)
-- Archivo: 14_SP_ESTACIONAMIENTOS_DSPASSWORDS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_passwords_list
-- Tipo: Catalog
-- Descripción: Lista los registros de ta_12_passwords filtrando por usuario (si se provee).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_passwords_list(p_usuario VARCHAR)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario VARCHAR(10),
    nombre VARCHAR(50),
    estado CHAR(1),
    id_rec SMALLINT,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
    FROM public.ta_12_passwords
    WHERE (p_usuario IS NULL OR usuario = p_usuario);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: DSPASSWORDS (EXACTO del archivo original)
-- Archivo: 14_SP_ESTACIONAMIENTOS_DSPASSWORDS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_passwords_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente en ta_12_passwords.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_passwords_update(
    p_id_usuario INTEGER,
    p_usuario VARCHAR,
    p_nombre VARCHAR,
    p_estado CHAR(1),
    p_id_rec SMALLINT,
    p_nivel SMALLINT
) RETURNS TABLE (
    id_usuario INTEGER,
    usuario VARCHAR(10),
    nombre VARCHAR(50),
    estado CHAR(1),
    id_rec SMALLINT,
    nivel SMALLINT
) AS $$
BEGIN
    UPDATE public.ta_12_passwords
    SET usuario = p_usuario,
        nombre = p_nombre,
        estado = p_estado,
        id_rec = p_id_rec,
        nivel = p_nivel
    WHERE id_usuario = p_id_usuario;

    RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
    FROM public.ta_12_passwords WHERE id_usuario = p_id_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: DSPASSWORDS (EXACTO del archivo original)
-- Archivo: 14_SP_ESTACIONAMIENTOS_DSPASSWORDS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

