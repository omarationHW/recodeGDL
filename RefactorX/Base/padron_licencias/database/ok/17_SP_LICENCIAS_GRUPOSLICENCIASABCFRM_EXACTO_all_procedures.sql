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
-- FIX: Alias de tabla para evitar ambiguedad con RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_list_grupos_licencias(p_descripcion TEXT DEFAULT '')
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT g.id, g.descripcion
    FROM lic_grupos g
    WHERE (p_descripcion IS NULL OR p_descripcion = '' OR g.descripcion ILIKE '%' || p_descripcion || '%')
    ORDER BY g.descripcion;
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
-- FIX: Variables con prefijo v_ para evitar ambiguedad
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_grupo_licencia(p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
DECLARE
  v_new_id INTEGER;
  v_descripcion TEXT;
BEGIN
  INSERT INTO lic_grupos(descripcion)
  VALUES (UPPER(TRIM(p_descripcion)))
  RETURNING lic_grupos.id, lic_grupos.descripcion INTO v_new_id, v_descripcion;

  RETURN QUERY SELECT v_new_id, v_descripcion;
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
-- FIX: Alias de tabla y variable para evitar ambiguedad
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_grupo_licencia(p_id INTEGER)
RETURNS TABLE(id INTEGER) AS $$
DECLARE
  v_deleted_id INTEGER;
BEGIN
  DELETE FROM lic_grupos g WHERE g.id = p_id RETURNING g.id INTO v_deleted_id;

  IF v_deleted_id IS NOT NULL THEN
    RETURN QUERY SELECT v_deleted_id;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

