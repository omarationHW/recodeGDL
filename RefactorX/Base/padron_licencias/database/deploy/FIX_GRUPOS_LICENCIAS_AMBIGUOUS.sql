-- ============================================
-- FIX: Ambiguous column en grupos licencias
-- Base de datos: padron_licencias
-- Fecha: 2025-11-25
-- Problema: RETURNS TABLE crea variables que colisionan con columnas
-- Solución: Usar alias de tabla (g.) en todas las referencias
-- ============================================

-- SP 1: sp_list_grupos_licencias (CORREGIDO)
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

-- SP 2: sp_get_grupo_licencia (CORREGIDO)
CREATE OR REPLACE FUNCTION sp_get_grupo_licencia(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT g.id, g.descripcion
    FROM lic_grupos g
    WHERE g.id = p_id;
END;
$$ LANGUAGE plpgsql;

-- SP 3: sp_insert_grupo_licencia (CORREGIDO)
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

-- SP 4: sp_update_grupo_licencia (CORREGIDO)
CREATE OR REPLACE FUNCTION sp_update_grupo_licencia(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  UPDATE lic_grupos g
  SET descripcion = UPPER(TRIM(p_descripcion))
  WHERE g.id = p_id;
  RETURN QUERY SELECT g.id, g.descripcion FROM lic_grupos g WHERE g.id = p_id;
END;
$$ LANGUAGE plpgsql;

-- SP 5: sp_delete_grupo_licencia (CORREGIDO)
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
-- VERIFICACIÓN
-- ============================================
DO $$
BEGIN
  RAISE NOTICE 'FIX aplicado correctamente - Grupos Licencias ABC';
END $$;

-- Test rápido
-- SELECT * FROM sp_list_grupos_licencias('');
