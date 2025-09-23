-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: consobsmulfrm
-- Generado: 2025-08-26 23:35:31
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_observaciones_multa
-- Tipo: CRUD
-- Descripción: Obtiene las observaciones y comentario de una multa por su ID
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_observaciones_multa(p_id_multa INTEGER)
RETURNS TABLE(id_multa INTEGER, observacion TEXT, comentario TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_multa, observacion, comentario FROM multas WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_update_observaciones_multa
-- Tipo: CRUD
-- Descripción: Actualiza las observaciones y comentario de una multa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_observaciones_multa(p_id_multa INTEGER, p_observacion TEXT, p_comentario TEXT)
RETURNS INTEGER AS $$
BEGIN
  UPDATE multas SET observacion = p_observacion, comentario = p_comentario WHERE id_multa = p_id_multa;
  RETURN 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_search_multas
-- Tipo: Report
-- Descripción: Busca multas por criterio y valor (contribuyente, domicilio, num_acta, axo_acta)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_search_multas(p_criterio TEXT, p_valor TEXT)
RETURNS TABLE(id_multa INTEGER, contribuyente TEXT, domicilio TEXT, axo_acta INTEGER, num_acta INTEGER, observacion TEXT, comentario TEXT) AS $$
DECLARE
  sql TEXT;
BEGIN
  IF p_criterio NOT IN ('contribuyente', 'domicilio', 'num_acta', 'axo_acta') THEN
    RAISE EXCEPTION 'Criterio no permitido';
  END IF;
  sql := format('SELECT id_multa, contribuyente, domicilio, axo_acta, num_acta, observacion, comentario FROM multas WHERE %I ILIKE $1 LIMIT 50', p_criterio);
  RETURN QUERY EXECUTE sql USING '%' || p_valor || '%';
END;
$$ LANGUAGE plpgsql;

-- ============================================

