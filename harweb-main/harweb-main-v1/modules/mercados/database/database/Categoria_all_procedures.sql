-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Categoria
-- Generado: 2025-08-26 23:08:08
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_categoria_list
-- Tipo: Catalog
-- Descripción: Lista todas las categorías
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_categoria_list()
RETURNS TABLE(categoria smallint, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria ORDER BY categoria ASC;
END;$$;

-- ============================================

-- SP 2/4: sp_categoria_create
-- Tipo: CRUD
-- Descripción: Crea una nueva categoría
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_categoria_create(p_categoria smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text)
LANGUAGE plpgsql AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_11_categoria WHERE categoria = p_categoria;
  IF existe > 0 THEN
    RETURN QUERY SELECT false, 'La categoría ya existe';
    RETURN;
  END IF;
  INSERT INTO ta_11_categoria (categoria, descripcion) VALUES (p_categoria, UPPER(p_descripcion));
  RETURN QUERY SELECT true, 'Categoría creada correctamente';
END;$$;

-- ============================================

-- SP 3/4: sp_categoria_update
-- Tipo: CRUD
-- Descripción: Actualiza una categoría existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_categoria_update(p_categoria smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text)
LANGUAGE plpgsql AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_11_categoria WHERE categoria = p_categoria;
  IF existe = 0 THEN
    RETURN QUERY SELECT false, 'La categoría no existe';
    RETURN;
  END IF;
  UPDATE ta_11_categoria SET descripcion = UPPER(p_descripcion) WHERE categoria = p_categoria;
  RETURN QUERY SELECT true, 'Categoría actualizada correctamente';
END;$$;

-- ============================================

-- SP 4/4: sp_categoria_delete
-- Tipo: CRUD
-- Descripción: Elimina una categoría
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_categoria_delete(p_categoria smallint)
RETURNS TABLE(success boolean, message text)
LANGUAGE plpgsql AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_11_categoria WHERE categoria = p_categoria;
  IF existe = 0 THEN
    RETURN QUERY SELECT false, 'La categoría no existe';
    RETURN;
  END IF;
  DELETE FROM ta_11_categoria WHERE categoria = p_categoria;
  RETURN QUERY SELECT true, 'Categoría eliminada correctamente';
END;$$;

-- ============================================

