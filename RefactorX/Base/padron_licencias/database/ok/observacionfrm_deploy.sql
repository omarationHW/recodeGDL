-- ============================================
-- DEPLOY CONSOLIDADO: observacionfrm
-- Componente 80/95 - BATCH 16
-- Generado: 2025-11-20
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_save_observacion
CREATE OR REPLACE FUNCTION public.sp_save_observacion(p_observacion TEXT)
RETURNS TABLE(
    id BIGINT,
    observacion TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    INSERT INTO observaciones (observacion, created_at)
    VALUES (UPPER(p_observacion), NOW());

    RETURN QUERY
    SELECT o.id, o.observacion, o.created_at
    FROM observaciones o
    WHERE o.id = currval('observaciones_id_seq');
END;
$$ LANGUAGE plpgsql;

-- SP 2/2: sp_get_observaciones
CREATE OR REPLACE FUNCTION public.sp_get_observaciones()
RETURNS TABLE(
    id BIGINT,
    observacion TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT o.id, o.observacion, o.created_at
    FROM observaciones o
    ORDER BY o.created_at DESC;
END;
$$ LANGUAGE plpgsql;
