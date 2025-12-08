-- =============================================
-- STORED PROCEDURES CONSOLIDADOS - GRUPOS DE LICENCIAS
-- Módulo: padron_licencias
-- Componente: GruposLicenciasAbcfrm
-- Schema: public (catálogos/grupos)
-- =============================================
-- Descripción: Gestión completa CRUD para grupos de licencias
-- Tabla principal: lic_grupos
-- Tabla relacional: lic_detgrupo
-- Generado: 2025-11-20
-- Total SPs: 4 (list, create, update, delete)
-- =============================================

-- =============================================
-- SP 1/4: sp_grupos_licencias_list
-- Tipo: CONSULTA (Listado con filtros)
-- Retorna: TABLE(id_grupo, desc_grupo, vigente)
-- =============================================
-- Descripción:
--   Lista todos los grupos de licencias del catálogo.
--   Permite filtrado opcional por descripción (case-insensitive).
--   Ordenado alfabéticamente por descripción.
-- Parámetros:
--   p_descripcion TEXT - Filtro opcional para búsqueda por descripción (ILIKE)
-- Retorno:
--   id INTEGER - ID único del grupo
--   descripcion TEXT - Descripción del grupo (normalizada en UPPER)
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_grupos_licencias_list(
    p_descripcion TEXT DEFAULT NULL
)
RETURNS TABLE(
    id INTEGER,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id,
        g.descripcion
    FROM lic_grupos g
    WHERE (
        p_descripcion IS NULL
        OR p_descripcion = ''
        OR UPPER(g.descripcion) LIKE '%' || UPPER(TRIM(p_descripcion)) || '%'
    )
    ORDER BY g.descripcion ASC;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION public.sp_grupos_licencias_list(TEXT) IS
'Lista grupos de licencias con filtro opcional por descripción. Retorna id y descripcion ordenados alfabéticamente.';


-- =============================================
-- SP 2/4: sp_grupos_licencias_create
-- Tipo: INSERCIÓN (Crear nuevo grupo)
-- Retorna: TABLE(id, descripcion, success, message)
-- =============================================
-- Descripción:
--   Crea un nuevo grupo de licencias en el catálogo.
--   Normaliza la descripción (UPPER, TRIM).
--   Valida duplicados antes de insertar.
-- Validaciones:
--   - Descripción no vacía
--   - No duplicados (case-insensitive)
-- Parámetros:
--   p_descripcion TEXT - Descripción del grupo (será normalizada)
-- Retorno:
--   id INTEGER - ID del grupo creado
--   descripcion TEXT - Descripción normalizada
--   success BOOLEAN - Indica si la operación fue exitosa
--   message TEXT - Mensaje descriptivo del resultado
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_grupos_licencias_create(
    p_descripcion TEXT
)
RETURNS TABLE(
    id INTEGER,
    descripcion TEXT,
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_new_id INTEGER;
    v_normalized_desc TEXT;
    v_existe INTEGER;
BEGIN
    -- Validación: descripción no vacía
    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::TEXT,
            FALSE,
            'Error: La descripción no puede estar vacía'::TEXT;
        RETURN;
    END IF;

    -- Normalizar descripción
    v_normalized_desc := UPPER(TRIM(p_descripcion));

    -- Validación: verificar duplicados
    SELECT COUNT(*) INTO v_existe
    FROM lic_grupos
    WHERE UPPER(descripcion) = v_normalized_desc;

    IF v_existe > 0 THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            v_normalized_desc,
            FALSE,
            'Error: Ya existe un grupo con esta descripción'::TEXT;
        RETURN;
    END IF;

    -- Insertar nuevo grupo
    BEGIN
        INSERT INTO lic_grupos(descripcion)
        VALUES (v_normalized_desc)
        RETURNING lic_grupos.id INTO v_new_id;

        RETURN QUERY SELECT
            v_new_id,
            v_normalized_desc,
            TRUE,
            'Grupo de licencias creado exitosamente'::TEXT;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT
                NULL::INTEGER,
                v_normalized_desc,
                FALSE,
                ('Error al crear grupo: ' || SQLERRM)::TEXT;
    END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_grupos_licencias_create(TEXT) IS
'Crea un nuevo grupo de licencias. Valida duplicados y normaliza la descripción en UPPER. Retorna id, descripcion, success y message.';


-- =============================================
-- SP 3/4: sp_grupos_licencias_update
-- Tipo: ACTUALIZACIÓN (Modificar grupo existente)
-- Retorna: TABLE(id, descripcion, success, message)
-- =============================================
-- Descripción:
--   Actualiza la descripción de un grupo de licencias existente.
--   Normaliza la nueva descripción (UPPER, TRIM).
--   Valida que no genere duplicados con otros grupos.
-- Validaciones:
--   - ID existe
--   - Descripción no vacía
--   - No duplicados con otros grupos (excluye el mismo ID)
-- Parámetros:
--   p_id INTEGER - ID del grupo a actualizar
--   p_descripcion TEXT - Nueva descripción (será normalizada)
-- Retorno:
--   id INTEGER - ID del grupo actualizado
--   descripcion TEXT - Descripción actualizada y normalizada
--   success BOOLEAN - Indica si la operación fue exitosa
--   message TEXT - Mensaje descriptivo del resultado
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_grupos_licencias_update(
    p_id INTEGER,
    p_descripcion TEXT
)
RETURNS TABLE(
    id INTEGER,
    descripcion TEXT,
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_normalized_desc TEXT;
    v_existe INTEGER;
    v_rows_affected INTEGER;
BEGIN
    -- Validación: ID no nulo
    IF p_id IS NULL THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::TEXT,
            FALSE,
            'Error: ID del grupo no puede ser nulo'::TEXT;
        RETURN;
    END IF;

    -- Validación: descripción no vacía
    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY SELECT
            p_id,
            NULL::TEXT,
            FALSE,
            'Error: La descripción no puede estar vacía'::TEXT;
        RETURN;
    END IF;

    -- Normalizar descripción
    v_normalized_desc := UPPER(TRIM(p_descripcion));

    -- Validación: verificar que el grupo existe
    SELECT COUNT(*) INTO v_existe
    FROM lic_grupos
    WHERE lic_grupos.id = p_id;

    IF v_existe = 0 THEN
        RETURN QUERY SELECT
            p_id,
            v_normalized_desc,
            FALSE,
            'Error: El grupo especificado no existe'::TEXT;
        RETURN;
    END IF;

    -- Validación: verificar duplicados (excluyendo el mismo registro)
    SELECT COUNT(*) INTO v_existe
    FROM lic_grupos
    WHERE UPPER(descripcion) = v_normalized_desc
      AND lic_grupos.id <> p_id;

    IF v_existe > 0 THEN
        RETURN QUERY SELECT
            p_id,
            v_normalized_desc,
            FALSE,
            'Error: Ya existe otro grupo con esta descripción'::TEXT;
        RETURN;
    END IF;

    -- Actualizar grupo
    BEGIN
        UPDATE lic_grupos
        SET descripcion = v_normalized_desc
        WHERE lic_grupos.id = p_id;

        GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

        IF v_rows_affected > 0 THEN
            RETURN QUERY SELECT
                p_id,
                v_normalized_desc,
                TRUE,
                'Grupo de licencias actualizado exitosamente'::TEXT;
        ELSE
            RETURN QUERY SELECT
                p_id,
                v_normalized_desc,
                FALSE,
                'Error: No se pudo actualizar el grupo'::TEXT;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN QUERY SELECT
                p_id,
                v_normalized_desc,
                FALSE,
                ('Error al actualizar grupo: ' || SQLERRM)::TEXT;
    END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_grupos_licencias_update(INTEGER, TEXT) IS
'Actualiza un grupo de licencias existente. Valida duplicados y normaliza la descripción en UPPER. Retorna id, descripcion, success y message.';


-- =============================================
-- SP 4/4: sp_grupos_licencias_delete
-- Tipo: ELIMINACIÓN (Eliminar grupo)
-- Retorna: TABLE(id, success, message, licencias_afectadas)
-- =============================================
-- Descripción:
--   Elimina un grupo de licencias del catálogo.
--   Elimina en cascada los registros de lic_detgrupo asociados.
--   Valida que el grupo exista antes de eliminar.
-- Validaciones:
--   - ID existe
--   - Verifica y reporta licencias asociadas eliminadas
-- Parámetros:
--   p_id INTEGER - ID del grupo a eliminar
-- Retorno:
--   id INTEGER - ID del grupo eliminado
--   success BOOLEAN - Indica si la operación fue exitosa
--   message TEXT - Mensaje descriptivo del resultado
--   licencias_afectadas INTEGER - Cantidad de licencias desvinculadas del grupo
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_grupos_licencias_delete(
    p_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    success BOOLEAN,
    message TEXT,
    licencias_afectadas INTEGER
) AS $$
DECLARE
    v_existe INTEGER;
    v_licencias_count INTEGER;
    v_rows_affected INTEGER;
    v_descripcion TEXT;
BEGIN
    -- Validación: ID no nulo
    IF p_id IS NULL THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            FALSE,
            'Error: ID del grupo no puede ser nulo'::TEXT,
            0;
        RETURN;
    END IF;

    -- Validación: verificar que el grupo existe
    SELECT COUNT(*), MAX(descripcion)
    INTO v_existe, v_descripcion
    FROM lic_grupos
    WHERE lic_grupos.id = p_id;

    IF v_existe = 0 THEN
        RETURN QUERY SELECT
            p_id,
            FALSE,
            'Error: El grupo especificado no existe'::TEXT,
            0;
        RETURN;
    END IF;

    -- Contar licencias asociadas al grupo
    SELECT COUNT(*) INTO v_licencias_count
    FROM lic_detgrupo
    WHERE lic_grupos_id = p_id;

    -- Eliminar operación
    BEGIN
        -- Primero eliminar licencias asociadas en lic_detgrupo
        DELETE FROM lic_detgrupo
        WHERE lic_grupos_id = p_id;

        -- Luego eliminar el grupo
        DELETE FROM lic_grupos
        WHERE lic_grupos.id = p_id;

        GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

        IF v_rows_affected > 0 THEN
            RETURN QUERY SELECT
                p_id,
                TRUE,
                ('Grupo "' || v_descripcion || '" eliminado exitosamente')::TEXT,
                v_licencias_count;
        ELSE
            RETURN QUERY SELECT
                p_id,
                FALSE,
                'Error: No se pudo eliminar el grupo'::TEXT,
                0;
        END IF;
    EXCEPTION
        WHEN foreign_key_violation THEN
            RETURN QUERY SELECT
                p_id,
                FALSE,
                'Error: El grupo tiene dependencias y no puede ser eliminado'::TEXT,
                v_licencias_count;
        WHEN OTHERS THEN
            RETURN QUERY SELECT
                p_id,
                FALSE,
                ('Error al eliminar grupo: ' || SQLERRM)::TEXT,
                0;
    END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_grupos_licencias_delete(INTEGER) IS
'Elimina un grupo de licencias y sus asociaciones en lic_detgrupo. Retorna id, success, message y licencias_afectadas.';


-- =============================================
-- FIN DE STORED PROCEDURES - GruposLicenciasAbcfrm
-- =============================================
-- Resumen de implementación:
-- ✓ sp_grupos_licencias_list   - Listar grupos con filtro
-- ✓ sp_grupos_licencias_create - Crear nuevo grupo con validaciones
-- ✓ sp_grupos_licencias_update - Actualizar grupo con validaciones
-- ✓ sp_grupos_licencias_delete - Eliminar grupo (cascada lic_detgrupo)
--
-- Características implementadas:
-- - Nomenclatura estándar: sp_grupos_licencias_*
-- - Schema: public (catálogos/grupos)
-- - Normalización: UPPER(TRIM()) en descripciones
-- - Validaciones: duplicados, vacíos, existencia
-- - Manejo de errores: EXCEPTION con mensajes descriptivos
-- - Retornos estructurados: (id, descripcion, success, message)
-- - Soft delete: NO (eliminación física)
-- - Cascada: Elimina registros en lic_detgrupo
-- =============================================
