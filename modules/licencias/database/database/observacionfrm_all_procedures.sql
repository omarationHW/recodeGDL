-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: observacionfrm
-- Generado: 2025-08-27 18:48:48
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_save_observacion
-- Tipo: CRUD
-- Descripción: Guarda una nueva observación en la tabla observaciones y retorna el registro insertado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_save_observacion(p_observacion TEXT)
RETURNS TABLE(id BIGINT, observacion TEXT, created_at TIMESTAMP) AS $$
BEGIN
    INSERT INTO observaciones (observacion, created_at)
    VALUES (UPPER(p_observacion), NOW());
    RETURN QUERY
        SELECT id, observacion, created_at
        FROM observaciones
        WHERE id = currval('observaciones_id_seq');
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_get_observaciones
-- Tipo: Catalog
-- Descripción: Obtiene todas las observaciones registradas, ordenadas por fecha de creación descendente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_observaciones()
RETURNS TABLE(id BIGINT, observacion TEXT, created_at TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
        SELECT id, observacion, created_at
        FROM observaciones
        ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

