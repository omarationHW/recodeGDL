-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FRMIMPLICENCIAREGLAMENTADA (EXACTO del archivo original)
-- Archivo: 68_SP_LICENCIAS_FRMIMPLICENCIAREGLAMENTADA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_get_licencias_reglamentadas
-- Tipo: Catalog
-- Descripción: Obtiene todas las licencias reglamentadas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_licencias_reglamentadas()
RETURNS TABLE(
    id INTEGER,
    nombre VARCHAR,
    descripcion TEXT,
    usuario_id INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY SELECT id, nombre, descripcion, usuario_id, created_at, updated_at FROM licencias_reglamentadas ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FRMIMPLICENCIAREGLAMENTADA (EXACTO del archivo original)
-- Archivo: 68_SP_LICENCIAS_FRMIMPLICENCIAREGLAMENTADA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_update_licencia_reglamentada
-- Tipo: CRUD
-- Descripción: Actualiza una licencia reglamentada existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_licencia_reglamentada(
    p_id INTEGER,
    p_nombre VARCHAR,
    p_descripcion TEXT,
    p_usuario_id INTEGER
) RETURNS TABLE(
    id INTEGER,
    nombre VARCHAR,
    descripcion TEXT,
    usuario_id INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    UPDATE licencias_reglamentadas
    SET nombre = p_nombre,
        descripcion = p_descripcion,
        usuario_id = p_usuario_id,
        updated_at = NOW()
    WHERE id = p_id;
    RETURN QUERY SELECT id, nombre, descripcion, usuario_id, created_at, updated_at FROM licencias_reglamentadas WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FRMIMPLICENCIAREGLAMENTADA (EXACTO del archivo original)
-- Archivo: 68_SP_LICENCIAS_FRMIMPLICENCIAREGLAMENTADA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

