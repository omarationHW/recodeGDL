-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: GruposAnunciosAbcfrm
-- Generado: 2025-08-27 18:15:03
-- Total SPs: 5
-- ============================================

-- SP 1/5: anuncios_grupos_list
-- Tipo: Catalog
-- Descripción: Lista todos los grupos de anuncios, con filtro opcional por descripción.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION anuncios_grupos_list(p_descripcion TEXT DEFAULT NULL)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM anuncios_grupos
    WHERE (p_descripcion IS NULL OR descripcion ILIKE '%' || p_descripcion || '%')
    ORDER BY descripcion;
END;
$$;

-- ============================================

-- SP 2/5: anuncios_grupos_get
-- Tipo: Catalog
-- Descripción: Obtiene un grupo de anuncio por su ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION anuncios_grupos_get(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM anuncios_grupos
    WHERE id = p_id;
END;
$$;

-- ============================================

-- SP 3/5: anuncios_grupos_insert
-- Tipo: CRUD
-- Descripción: Inserta un nuevo grupo de anuncio y retorna el registro insertado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION anuncios_grupos_insert(p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO anuncios_grupos(descripcion)
  VALUES (UPPER(TRIM(p_descripcion)))
  RETURNING id, descripcion INTO new_id, p_descripcion;
  RETURN QUERY SELECT new_id, p_descripcion;
END;
$$;

-- ============================================

-- SP 4/5: anuncios_grupos_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un grupo de anuncio por ID y retorna el registro actualizado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION anuncios_grupos_update(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE anuncios_grupos
  SET descripcion = UPPER(TRIM(p_descripcion))
  WHERE id = p_id;
  RETURN QUERY SELECT id, descripcion FROM anuncios_grupos WHERE id = p_id;
END;
$$;

-- ============================================

-- SP 5/5: anuncios_grupos_delete
-- Tipo: CRUD
-- Descripción: Elimina un grupo de anuncio por ID y retorna el registro eliminado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION anuncios_grupos_delete(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
DECLARE
  old_id INTEGER;
  old_desc TEXT;
BEGIN
  SELECT id, descripcion INTO old_id, old_desc FROM anuncios_grupos WHERE id = p_id;
  DELETE FROM anuncios_grupos WHERE id = p_id;
  RETURN QUERY SELECT old_id, old_desc;
END;
$$;

-- ============================================

