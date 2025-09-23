-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: CategoriaMntto
-- Generado: 2025-08-26 23:09:13
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_categoria_list
-- Tipo: Catalog
-- Descripción: Devuelve todas las categorías de la tabla ta_11_categoria.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_categoria_list()
RETURNS TABLE(categoria smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT categoria, descripcion FROM public.ta_11_categoria ORDER BY categoria ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_categoria_create
-- Tipo: CRUD
-- Descripción: Inserta una nueva categoría en ta_11_categoria.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_categoria_create(p_categoria smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.ta_11_categoria WHERE categoria = p_categoria) THEN
    RETURN QUERY SELECT false, 'La categoría ya existe';
  ELSE
    INSERT INTO public.ta_11_categoria (categoria, descripcion) VALUES (p_categoria, p_descripcion);
    RETURN QUERY SELECT true, 'Categoría creada correctamente';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_categoria_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una categoría existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_categoria_update(p_categoria smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.ta_11_categoria WHERE categoria = p_categoria) THEN
    RETURN QUERY SELECT false, 'La categoría no existe';
  ELSE
    UPDATE public.ta_11_categoria SET descripcion = p_descripcion WHERE categoria = p_categoria;
    RETURN QUERY SELECT true, 'Categoría actualizada correctamente';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_categoria_delete
-- Tipo: CRUD
-- Descripción: Elimina una categoría por su clave.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_categoria_delete(p_categoria smallint)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.ta_11_categoria WHERE categoria = p_categoria) THEN
    RETURN QUERY SELECT false, 'La categoría no existe';
  ELSE
    DELETE FROM public.ta_11_categoria WHERE categoria = p_categoria;
    RETURN QUERY SELECT true, 'Categoría eliminada correctamente';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

