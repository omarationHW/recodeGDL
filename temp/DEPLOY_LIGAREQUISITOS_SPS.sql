-- ============================================
-- STORED PROCEDURES PARA LIGA DE REQUISITOS
-- Componente: LigaRequisitos.vue
-- Fecha: 2025-11-06
-- Descripción: Gestión de asignación de requisitos a giros
-- ============================================

-- ============================================
-- SP 1/5: sp_ligarequisitos_giros
-- Descripción: Lista todos los giros disponibles
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_ligarequisitos_giros()
RETURNS TABLE (
    id_giro INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        g.id_giro::INTEGER,
        TRIM(COALESCE(g.descripcion, ''))::VARCHAR as descripcion
    FROM comun.c_giros g
    WHERE g.vigente = 'V'
    ORDER BY g.id_giro ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/5: sp_ligarequisitos_list
-- Descripción: Lista requisitos ASIGNADOS a un giro
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_ligarequisitos_list(
    p_id_giro INTEGER
)
RETURNS TABLE (
    req INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_requisito::INTEGER as req,
        TRIM(COALESCE(r.descripcion, ''))::VARCHAR as descripcion
    FROM public.liga_req lr
    INNER JOIN comun.requisitos_doc r ON lr.id_requisito = r.id_requisito
    WHERE lr.id_giro = p_id_giro
    ORDER BY r.id_requisito ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/5: sp_ligarequisitos_available
-- Descripción: Lista requisitos DISPONIBLES (no asignados) para un giro
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_ligarequisitos_available(
    p_id_giro INTEGER
)
RETURNS TABLE (
    req INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_requisito::INTEGER as req,
        TRIM(COALESCE(r.descripcion, ''))::VARCHAR as descripcion
    FROM comun.requisitos_doc r
    WHERE r.id_requisito NOT IN (
        SELECT lr.id_requisito
        FROM public.liga_req lr
        WHERE lr.id_giro = p_id_giro
    )
    ORDER BY r.id_requisito ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/5: sp_ligarequisitos_add
-- Descripción: Agrega un requisito a un giro
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_ligarequisitos_add(
    p_id_giro INTEGER,
    p_req INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_giro_exists INTEGER;
    v_req_exists INTEGER;
    v_liga_exists INTEGER;
BEGIN
    -- Verificar que el giro existe
    SELECT COUNT(*) INTO v_giro_exists
    FROM comun.c_giros
    WHERE id_giro = p_id_giro;

    IF v_giro_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El giro no existe'::TEXT;
        RETURN;
    END IF;

    -- Verificar que el requisito existe
    SELECT COUNT(*) INTO v_req_exists
    FROM comun.requisitos_doc
    WHERE id_requisito = p_req;

    IF v_req_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El requisito no existe'::TEXT;
        RETURN;
    END IF;

    -- Verificar si ya está asignado
    SELECT COUNT(*) INTO v_liga_exists
    FROM public.liga_req
    WHERE id_giro = p_id_giro
    AND id_requisito = p_req;

    IF v_liga_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'El requisito ya está asignado a este giro'::TEXT;
        RETURN;
    END IF;

    -- Insertar la relación
    INSERT INTO public.liga_req (id_giro, id_requisito)
    VALUES (p_id_giro, p_req);

    RETURN QUERY SELECT TRUE, 'Requisito agregado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 5/5: sp_ligarequisitos_remove
-- Descripción: Quita un requisito de un giro
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_ligarequisitos_remove(
    p_id_giro INTEGER,
    p_req INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_liga_exists INTEGER;
    v_deleted INTEGER;
BEGIN
    -- Verificar que la relación existe
    SELECT COUNT(*) INTO v_liga_exists
    FROM public.liga_req
    WHERE id_giro = p_id_giro
    AND id_requisito = p_req;

    IF v_liga_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El requisito no está asignado a este giro'::TEXT;
        RETURN;
    END IF;

    -- Eliminar la relación
    DELETE FROM public.liga_req
    WHERE id_giro = p_id_giro
    AND id_requisito = p_req;

    GET DIAGNOSTICS v_deleted = ROW_COUNT;

    IF v_deleted > 0 THEN
        RETURN QUERY SELECT TRUE, 'Requisito quitado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Error al quitar el requisito'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
