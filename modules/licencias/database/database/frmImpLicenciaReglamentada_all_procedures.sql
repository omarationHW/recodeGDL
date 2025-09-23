-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: frmImpLicenciaReglamentada
-- Generado: 2025-08-27 18:04:38
-- Total SPs: 4
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

-- SP 2/4: sp_create_licencia_reglamentada
-- Tipo: CRUD
-- Descripción: Crea una nueva licencia reglamentada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_create_licencia_reglamentada(
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
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO licencias_reglamentadas (nombre, descripcion, usuario_id, created_at, updated_at)
    VALUES (p_nombre, p_descripcion, p_usuario_id, NOW(), NOW())
    RETURNING id INTO new_id;
    RETURN QUERY SELECT id, nombre, descripcion, usuario_id, created_at, updated_at FROM licencias_reglamentadas WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;

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

-- SP 4/4: sp_delete_licencia_reglamentada
-- Tipo: CRUD
-- Descripción: Elimina una licencia reglamentada por ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_licencia_reglamentada(
    p_id INTEGER
) RETURNS TABLE(
    deleted BOOLEAN
) AS $$
BEGIN
    DELETE FROM licencias_reglamentadas WHERE id = p_id;
    RETURN QUERY SELECT TRUE AS deleted;
END;
$$ LANGUAGE plpgsql;

-- ============================================

