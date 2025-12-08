-- ============================================
-- STORED PROCEDURES: LigaRequisitos
-- Módulo: padron_licencias
-- Schema: comun
-- Total SPs: 5
-- Fecha: 2025-11-20
-- ============================================
-- Descripción: Gestión de requisitos por giro (liga entre giros y requisitos)
-- ============================================

-- ============================================
-- SP 1/5: sp_liga_requisitos_giros
-- Tipo: CONSULTA
-- Descripción: Lista de giros con conteo de requisitos asociados
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_liga_requisitos_giros()
RETURNS TABLE(
    id_giro INTEGER,
    descripcion_giro VARCHAR,
    codigo_giro VARCHAR,
    total_requisitos BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id_giro,
        g.descripcion,
        g.cod_giro,
        COUNT(lgr.req) as total_requisitos
    FROM comun.c_giros g
    LEFT JOIN public.giro_req lgr ON g.id_giro = lgr.id_giro
    WHERE g.vigente = 'V'
        AND g.tipo = 'L'
        AND g.id_giro > 500
    GROUP BY g.id_giro, g.descripcion, g.cod_giro
    ORDER BY g.descripcion;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_liga_requisitos_giros() IS
'Lista de giros vigentes con conteo de requisitos asociados - LigaRequisitos';

-- ============================================
-- SP 2/5: sp_liga_requisitos_list
-- Tipo: CONSULTA
-- Descripción: Lista de requisitos asignados a un giro específico
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_liga_requisitos_list(
    p_id_giro INTEGER
)
RETURNS TABLE(
    req INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    -- Validar que el giro existe y está vigente
    IF NOT EXISTS (
        SELECT 1 FROM comun.c_giros
        WHERE id_giro = p_id_giro AND vigente = 'V'
    ) THEN
        RAISE EXCEPTION 'El giro % no existe o no está vigente', p_id_giro;
    END IF;

    RETURN QUERY
    SELECT
        gr.req,
        cgr.descripcion
    FROM public.giro_req gr
    INNER JOIN public.c_girosreq cgr ON gr.req = cgr.req
    WHERE gr.id_giro = p_id_giro
    ORDER BY gr.req;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_liga_requisitos_list(INTEGER) IS
'Lista requisitos asignados a un giro específico - LigaRequisitos';

-- ============================================
-- SP 3/5: sp_liga_requisitos_available
-- Tipo: CONSULTA
-- Descripción: Requisitos disponibles para agregar a un giro (no asignados)
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_liga_requisitos_available(
    p_id_giro INTEGER
)
RETURNS TABLE(
    req INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    -- Validar que el giro existe y está vigente
    IF NOT EXISTS (
        SELECT 1 FROM comun.c_giros
        WHERE id_giro = p_id_giro AND vigente = 'V'
    ) THEN
        RAISE EXCEPTION 'El giro % no existe o no está vigente', p_id_giro;
    END IF;

    RETURN QUERY
    SELECT
        cgr.req,
        cgr.descripcion
    FROM public.c_girosreq cgr
    WHERE cgr.req NOT IN (
        SELECT req
        FROM public.giro_req
        WHERE id_giro = p_id_giro
    )
    ORDER BY cgr.req;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_liga_requisitos_available(INTEGER) IS
'Requisitos disponibles para agregar a un giro (no asignados) - LigaRequisitos';

-- ============================================
-- SP 4/5: sp_liga_requisitos_add
-- Tipo: INSERCIÓN
-- Descripción: Agregar requisito a un giro
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_liga_requisitos_add(
    p_id_giro INTEGER,
    p_req INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_giro_existe BOOLEAN;
    v_req_existe BOOLEAN;
    v_ya_ligado BOOLEAN;
BEGIN
    -- Validar que el giro existe y está vigente
    SELECT EXISTS (
        SELECT 1 FROM comun.c_giros
        WHERE id_giro = p_id_giro AND vigente = 'V'
    ) INTO v_giro_existe;

    IF NOT v_giro_existe THEN
        RETURN QUERY SELECT FALSE, 'El giro no existe o no está vigente'::TEXT;
        RETURN;
    END IF;

    -- Validar que el requisito existe
    SELECT EXISTS (
        SELECT 1 FROM public.c_girosreq
        WHERE req = p_req
    ) INTO v_req_existe;

    IF NOT v_req_existe THEN
        RETURN QUERY SELECT FALSE, 'El requisito no existe'::TEXT;
        RETURN;
    END IF;

    -- Validar que no esté ya ligado
    SELECT EXISTS (
        SELECT 1 FROM public.giro_req
        WHERE id_giro = p_id_giro AND req = p_req
    ) INTO v_ya_ligado;

    IF v_ya_ligado THEN
        RETURN QUERY SELECT FALSE, 'El requisito ya está ligado a este giro'::TEXT;
        RETURN;
    END IF;

    -- Insertar la liga
    INSERT INTO public.giro_req (id_giro, req)
    VALUES (p_id_giro, p_req);

    RETURN QUERY SELECT TRUE, 'Requisito agregado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_liga_requisitos_add(INTEGER, INTEGER) IS
'Agregar requisito a un giro con validaciones - LigaRequisitos';

-- ============================================
-- SP 5/5: sp_liga_requisitos_remove
-- Tipo: ELIMINACIÓN
-- Descripción: Remover requisito de un giro
-- ============================================
CREATE OR REPLACE FUNCTION comun.sp_liga_requisitos_remove(
    p_id_giro INTEGER,
    p_req INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_existe BOOLEAN;
    v_rows_affected INTEGER;
BEGIN
    -- Validar que la liga existe
    SELECT EXISTS (
        SELECT 1 FROM public.giro_req
        WHERE id_giro = p_id_giro AND req = p_req
    ) INTO v_existe;

    IF NOT v_existe THEN
        RETURN QUERY SELECT FALSE, 'El requisito no está ligado a este giro'::TEXT;
        RETURN;
    END IF;

    -- Eliminar la liga
    DELETE FROM public.giro_req
    WHERE id_giro = p_id_giro AND req = p_req;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT TRUE, 'Requisito eliminado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'No se pudo eliminar el requisito'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_liga_requisitos_remove(INTEGER, INTEGER) IS
'Remover requisito de un giro - LigaRequisitos';

-- ============================================
-- FIN: LigaRequisitos - 5 SPs implementados
-- ============================================
