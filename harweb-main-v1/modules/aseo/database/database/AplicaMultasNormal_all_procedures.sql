-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: AplicaMultasNormal
-- Generado: 2025-08-27 13:58:05
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_get_aplicareq
-- Tipo: Catalog
-- Descripción: Obtiene la configuración actual de aplicación de requerimientos normales.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_aplicareq()
RETURNS TABLE(descripcion TEXT, aplica CHAR(1), porc INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT descripcion, aplica, porc FROM ta_aplicareq LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_update_aplicareq
-- Tipo: CRUD
-- Descripción: Actualiza la configuración de aplicación de requerimientos normales.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_aplicareq(p_aplica CHAR(1), p_porc INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE ta_aplicareq SET aplica = p_aplica, porc = p_porc;
END;
$$ LANGUAGE plpgsql;

-- ============================================

