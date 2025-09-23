-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: GRUPOSLICENCIASABCFRM (EXACTO del archivo original)
-- Archivo: 17_SP_LICENCIAS_GRUPOSLICENCIASABCFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_list_grupos_licencias
-- Tipo: Catalog
-- Descripción: Lista todos los grupos de licencias, filtrando opcionalmente por descripción (LIKE, case-insensitive).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_list_grupos_licencias(p_descripcion TEXT DEFAULT '')
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM lic_grupos
    WHERE (p_descripcion IS NULL OR p_descripcion = '' OR descripcion ILIKE '%' || p_descripcion || '%')
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: GRUPOSLICENCIASABCFRM (EXACTO del archivo original)
-- Archivo: 17_SP_LICENCIAS_GRUPOSLICENCIASABCFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_insert_grupo_licencia
-- Tipo: CRUD
-- Descripción: Inserta un nuevo grupo de licencia y retorna el registro insertado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_grupo_licencia(p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO lic_grupos(descripcion)
  VALUES (UPPER(TRIM(p_descripcion)))
  RETURNING id, descripcion INTO new_id, p_descripcion;
  RETURN QUERY SELECT new_id, p_descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: GRUPOSLICENCIASABCFRM (EXACTO del archivo original)
-- Archivo: 17_SP_LICENCIAS_GRUPOSLICENCIASABCFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_delete_grupo_licencia
-- Tipo: CRUD
-- Descripción: Elimina un grupo de licencia por ID y retorna el ID eliminado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_grupo_licencia(p_id INTEGER)
RETURNS TABLE(id INTEGER) AS $$
BEGIN
  DELETE FROM lic_grupos WHERE id = p_id RETURNING id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

