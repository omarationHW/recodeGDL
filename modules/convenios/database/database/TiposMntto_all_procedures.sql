-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: TiposMntto
-- Generado: 2025-08-27 16:03:12
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_tipos_list
-- Tipo: Catalog
-- Descripción: Devuelve todos los registros del catálogo de tipos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_list()
RETURNS TABLE(tipo integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_tipos_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro en el catálogo de tipos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_create(p_tipo integer, p_descripcion varchar)
RETURNS TABLE(tipo integer, descripcion varchar) AS $$
BEGIN
    INSERT INTO ta_17_tipos (tipo, descripcion) VALUES (p_tipo, p_descripcion);
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_tipos_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un tipo existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_update(p_tipo integer, p_descripcion varchar)
RETURNS TABLE(tipo integer, descripcion varchar) AS $$
BEGIN
    UPDATE ta_17_tipos SET descripcion = p_descripcion WHERE tipo = p_tipo;
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_tipos_get
-- Tipo: Catalog
-- Descripción: Obtiene un tipo específico por su clave.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_get(p_tipo integer)
RETURNS TABLE(tipo integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

