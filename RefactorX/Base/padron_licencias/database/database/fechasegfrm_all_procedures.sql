-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: fechasegfrm
-- Generado: 2025-08-27 17:41:32
-- Total SPs: 2
-- ============================================

-- SP 1/2: fechasegfrm_save
-- Tipo: CRUD
-- Descripción: Guarda un registro de fecha y oficio en la tabla fechasegfrm.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION fechasegfrm_save(p_fecha DATE, p_oficio VARCHAR)
RETURNS TABLE(id INTEGER, fecha DATE, oficio VARCHAR, created_at TIMESTAMP) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO fechasegfrm (fecha, oficio, created_at)
    VALUES (p_fecha, p_oficio, NOW())
    RETURNING id, fecha, oficio, created_at INTO new_id, fechasegfrm_save.fecha, fechasegfrm_save.oficio, fechasegfrm_save.created_at;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: fechasegfrm_list
-- Tipo: Catalog
-- Descripción: Lista los registros recientes de la tabla fechasegfrm.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION fechasegfrm_list()
RETURNS TABLE(id INTEGER, fecha DATE, oficio VARCHAR, created_at TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
    SELECT id, fecha, oficio, created_at
    FROM fechasegfrm
    ORDER BY created_at DESC
    LIMIT 20;
END;
$$ LANGUAGE plpgsql;

-- ============================================

