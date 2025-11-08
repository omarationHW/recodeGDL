-- ============================================
-- STORED PROCEDURES PARA CATALOGO DE REQUISITOS
-- Componente: CatRequisitos.vue
-- Fecha: 2025-11-06
-- Descripción: CRUD completo para catálogo de requisitos
-- ============================================

-- ============================================
-- SP 1/4: sp_catrequisitos_list
-- Descripción: Lista todos los requisitos
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_catrequisitos_list()
RETURNS TABLE (
    id_requisito INTEGER,
    descripcion VARCHAR,
    requisitos TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_requisito::INTEGER,
        TRIM(COALESCE(r.descripcion, ''))::VARCHAR as descripcion,
        COALESCE(r.requisitos, '')::TEXT
    FROM comun.requisitos_doc r
    ORDER BY r.id_requisito ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/4: sp_catrequisitos_create
-- Descripción: Crea un nuevo requisito
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_catrequisitos_create(
    p_id_requisito INTEGER,
    p_descripcion VARCHAR,
    p_requisitos TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar si el ID ya existe
    SELECT COUNT(*) INTO v_exists
    FROM comun.requisitos_doc
    WHERE id_requisito = p_id_requisito;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'El ID de requisito ya existe'::TEXT;
        RETURN;
    END IF;

    -- Insertar el nuevo requisito
    INSERT INTO comun.requisitos_doc (
        id_requisito,
        descripcion,
        requisitos
    )
    VALUES (
        p_id_requisito,
        p_descripcion,
        p_requisitos
    );

    RETURN QUERY SELECT TRUE, 'Requisito creado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/4: sp_catrequisitos_update
-- Descripción: Actualiza un requisito existente
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_catrequisitos_update(
    p_id_requisito INTEGER,
    p_descripcion VARCHAR,
    p_requisitos TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists INTEGER;
    v_updated INTEGER;
BEGIN
    -- Verificar que el requisito existe
    SELECT COUNT(*) INTO v_exists
    FROM comun.requisitos_doc
    WHERE id_requisito = p_id_requisito;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El requisito no existe'::TEXT;
        RETURN;
    END IF;

    -- Actualizar el requisito
    UPDATE comun.requisitos_doc
    SET
        descripcion = p_descripcion,
        requisitos = p_requisitos
    WHERE id_requisito = p_id_requisito;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    IF v_updated > 0 THEN
        RETURN QUERY SELECT TRUE, 'Requisito actualizado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Error al actualizar el requisito'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/4: sp_catrequisitos_delete
-- Descripción: Elimina un requisito
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_catrequisitos_delete(
    p_id_requisito INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists INTEGER;
    v_deleted INTEGER;
BEGIN
    -- Verificar que el requisito existe
    SELECT COUNT(*) INTO v_exists
    FROM comun.requisitos_doc
    WHERE id_requisito = p_id_requisito;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El requisito no existe'::TEXT;
        RETURN;
    END IF;

    -- Eliminar el requisito
    DELETE FROM comun.requisitos_doc
    WHERE id_requisito = p_id_requisito;

    GET DIAGNOSTICS v_deleted = ROW_COUNT;

    IF v_deleted > 0 THEN
        RETURN QUERY SELECT TRUE, 'Requisito eliminado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Error al eliminar el requisito'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
