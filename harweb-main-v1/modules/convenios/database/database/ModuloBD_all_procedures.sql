-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ModuloBD
-- Generado: 2025-08-27 20:53:53
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_tipos
-- Tipo: Catalog
-- Descripción: Obtiene todos los registros del catálogo de tipos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipos()
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_add_tipo
-- Tipo: CRUD
-- Descripción: Agrega un nuevo tipo al catálogo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_tipo(p_descripcion VARCHAR)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
DECLARE
    new_tipo INTEGER;
BEGIN
    SELECT COALESCE(MAX(tipo), 0) + 1 INTO new_tipo FROM ta_17_tipos;
    INSERT INTO ta_17_tipos (tipo, descripcion) VALUES (new_tipo, p_descripcion);
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = new_tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_update_tipo
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un tipo existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_tipo(p_tipo INTEGER, p_descripcion VARCHAR)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
BEGIN
    UPDATE ta_17_tipos SET descripcion = p_descripcion WHERE tipo = p_tipo;
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_delete_tipo
-- Tipo: CRUD
-- Descripción: Elimina un tipo del catálogo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_tipo(p_tipo INTEGER)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
DECLARE
    old_tipo INTEGER;
    old_desc VARCHAR;
BEGIN
    SELECT tipo, descripcion INTO old_tipo, old_desc FROM ta_17_tipos WHERE tipo = p_tipo;
    DELETE FROM ta_17_tipos WHERE tipo = p_tipo;
    RETURN QUERY SELECT old_tipo, old_desc;
END;
$$ LANGUAGE plpgsql;

-- ============================================

