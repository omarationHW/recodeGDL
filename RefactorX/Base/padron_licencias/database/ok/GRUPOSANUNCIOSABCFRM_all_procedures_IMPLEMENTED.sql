-- =============================================
-- STORED PROCEDURES CONSOLIDADOS - GRUPOS DE ANUNCIOS
-- Modulo: padron_licencias
-- Componente: GruposAnunciosAbcfrm
-- Schema: public (catalogos/grupos)
-- =============================================
-- Descripcion: Gestion completa CRUD para grupos de anuncios
-- Tabla principal: anun_grupos
-- Tabla relacional: anun_detgrupo
-- Generado: 2025-11-21
-- Total SPs: 5 (list, get, create, update, delete)
-- =============================================
-- INDICES RECOMENDADOS:
-- CREATE INDEX IF NOT EXISTS idx_anun_grupos_descripcion ON public.anun_grupos(UPPER(descripcion));
-- CREATE INDEX IF NOT EXISTS idx_anun_detgrupo_grupo_id ON public.anun_detgrupo(anun_grupos_id);
-- CREATE INDEX IF NOT EXISTS idx_anun_detgrupo_anuncio ON public.anun_detgrupo(anuncio);
-- =============================================


-- =============================================
-- SP 1/5: sp_grupos_anuncios_list
-- Tipo: CONSULTA (Listado con filtros)
-- Retorna: TABLE(id, descripcion)
-- =============================================
-- Descripcion:
--   Lista todos los grupos de anuncios del catalogo.
--   Permite filtrado opcional por descripcion (case-insensitive).
--   Ordenado alfabeticamente por descripcion.
-- Parametros:
--   p_descripcion TEXT - Filtro opcional para busqueda por descripcion (ILIKE)
-- Retorno:
--   id INTEGER - ID unico del grupo
--   descripcion TEXT - Descripcion del grupo
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_grupos_anuncios_list(
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
        g.descripcion::TEXT
    FROM public.anun_grupos g
    WHERE (
        p_descripcion IS NULL
        OR p_descripcion = ''
        OR UPPER(g.descripcion) LIKE '%' || UPPER(TRIM(p_descripcion)) || '%'
    )
    ORDER BY g.descripcion ASC;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION public.sp_grupos_anuncios_list(TEXT) IS
'Lista grupos de anuncios con filtro opcional por descripcion. Retorna id y descripcion ordenados alfabeticamente.';


-- =============================================
-- SP 2/5: sp_grupos_anuncios_get
-- Tipo: CONSULTA (Obtener por ID)
-- Retorna: TABLE(id, descripcion, success, message)
-- =============================================
-- Descripcion:
--   Obtiene un grupo de anuncios especifico por su ID.
--   Valida que el grupo exista antes de retornar.
-- Parametros:
--   p_id INTEGER - ID del grupo a obtener
-- Retorno:
--   id INTEGER - ID del grupo
--   descripcion TEXT - Descripcion del grupo
--   success BOOLEAN - Indica si se encontro el grupo
--   message TEXT - Mensaje descriptivo del resultado
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_grupos_anuncios_get(
    p_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    descripcion TEXT,
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_existe INTEGER;
    v_descripcion TEXT;
BEGIN
    -- Validacion: ID no nulo
    IF p_id IS NULL THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::TEXT,
            FALSE,
            'Error: ID del grupo no puede ser nulo'::TEXT;
        RETURN;
    END IF;

    -- Verificar existencia y obtener datos
    SELECT g.id, g.descripcion::TEXT
    INTO v_existe, v_descripcion
    FROM public.anun_grupos g
    WHERE g.id = p_id;

    IF v_existe IS NULL THEN
        RETURN QUERY SELECT
            p_id,
            NULL::TEXT,
            FALSE,
            'Error: El grupo especificado no existe'::TEXT;
        RETURN;
    END IF;

    -- Retornar el grupo encontrado
    RETURN QUERY SELECT
        v_existe,
        v_descripcion,
        TRUE,
        'Grupo encontrado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION public.sp_grupos_anuncios_get(INTEGER) IS
'Obtiene un grupo de anuncios por ID. Valida existencia y retorna id, descripcion, success y message.';


-- =============================================
-- SP 3/5: sp_grupos_anuncios_create
-- Tipo: INSERCION (Crear nuevo grupo)
-- Retorna: TABLE(id, descripcion, success, message)
-- =============================================
-- Descripcion:
--   Crea un nuevo grupo de anuncios en el catalogo.
--   Normaliza la descripcion (UPPER, TRIM).
--   Valida duplicados antes de insertar.
--   ID se genera automaticamente via SERIAL.
-- Validaciones:
--   - Descripcion no vacia
--   - No duplicados (case-insensitive)
-- Parametros:
--   p_descripcion TEXT - Descripcion del grupo (sera normalizada)
-- Retorno:
--   id INTEGER - ID del grupo creado
--   descripcion TEXT - Descripcion normalizada
--   success BOOLEAN - Indica si la operacion fue exitosa
--   message TEXT - Mensaje descriptivo del resultado
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_grupos_anuncios_create(
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
    -- Validacion: descripcion no vacia
    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::TEXT,
            FALSE,
            'Error: La descripcion no puede estar vacia'::TEXT;
        RETURN;
    END IF;

    -- Normalizar descripcion
    v_normalized_desc := UPPER(TRIM(p_descripcion));

    -- Validacion: verificar duplicados
    SELECT COUNT(*) INTO v_existe
    FROM public.anun_grupos
    WHERE UPPER(anun_grupos.descripcion) = v_normalized_desc;

    IF v_existe > 0 THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            v_normalized_desc,
            FALSE,
            'Error: Ya existe un grupo con esta descripcion'::TEXT;
        RETURN;
    END IF;

    -- Insertar nuevo grupo (ID auto-generado via SERIAL)
    BEGIN
        INSERT INTO public.anun_grupos(descripcion)
        VALUES (v_normalized_desc)
        RETURNING anun_grupos.id INTO v_new_id;

        RETURN QUERY SELECT
            v_new_id,
            v_normalized_desc,
            TRUE,
            'Grupo de anuncios creado exitosamente'::TEXT;
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

COMMENT ON FUNCTION public.sp_grupos_anuncios_create(TEXT) IS
'Crea un nuevo grupo de anuncios. Valida duplicados y normaliza la descripcion en UPPER. Retorna id, descripcion, success y message.';


-- =============================================
-- SP 4/5: sp_grupos_anuncios_update
-- Tipo: ACTUALIZACION (Modificar grupo existente)
-- Retorna: TABLE(id, descripcion, success, message)
-- =============================================
-- Descripcion:
--   Actualiza la descripcion de un grupo de anuncios existente.
--   Normaliza la nueva descripcion (UPPER, TRIM).
--   Valida que no genere duplicados con otros grupos.
-- Validaciones:
--   - ID existe
--   - Descripcion no vacia
--   - No duplicados con otros grupos (excluye el mismo ID)
-- Parametros:
--   p_id INTEGER - ID del grupo a actualizar
--   p_descripcion TEXT - Nueva descripcion (sera normalizada)
-- Retorno:
--   id INTEGER - ID del grupo actualizado
--   descripcion TEXT - Descripcion actualizada y normalizada
--   success BOOLEAN - Indica si la operacion fue exitosa
--   message TEXT - Mensaje descriptivo del resultado
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_grupos_anuncios_update(
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
    -- Validacion: ID no nulo
    IF p_id IS NULL THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::TEXT,
            FALSE,
            'Error: ID del grupo no puede ser nulo'::TEXT;
        RETURN;
    END IF;

    -- Validacion: descripcion no vacia
    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY SELECT
            p_id,
            NULL::TEXT,
            FALSE,
            'Error: La descripcion no puede estar vacia'::TEXT;
        RETURN;
    END IF;

    -- Normalizar descripcion
    v_normalized_desc := UPPER(TRIM(p_descripcion));

    -- Validacion: verificar que el grupo existe
    SELECT COUNT(*) INTO v_existe
    FROM public.anun_grupos
    WHERE anun_grupos.id = p_id;

    IF v_existe = 0 THEN
        RETURN QUERY SELECT
            p_id,
            v_normalized_desc,
            FALSE,
            'Error: El grupo especificado no existe'::TEXT;
        RETURN;
    END IF;

    -- Validacion: verificar duplicados (excluyendo el mismo registro)
    SELECT COUNT(*) INTO v_existe
    FROM public.anun_grupos
    WHERE UPPER(anun_grupos.descripcion) = v_normalized_desc
      AND anun_grupos.id <> p_id;

    IF v_existe > 0 THEN
        RETURN QUERY SELECT
            p_id,
            v_normalized_desc,
            FALSE,
            'Error: Ya existe otro grupo con esta descripcion'::TEXT;
        RETURN;
    END IF;

    -- Actualizar grupo
    BEGIN
        UPDATE public.anun_grupos
        SET descripcion = v_normalized_desc
        WHERE anun_grupos.id = p_id;

        GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

        IF v_rows_affected > 0 THEN
            RETURN QUERY SELECT
                p_id,
                v_normalized_desc,
                TRUE,
                'Grupo de anuncios actualizado exitosamente'::TEXT;
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

COMMENT ON FUNCTION public.sp_grupos_anuncios_update(INTEGER, TEXT) IS
'Actualiza un grupo de anuncios existente. Valida duplicados y normaliza la descripcion en UPPER. Retorna id, descripcion, success y message.';


-- =============================================
-- SP 5/5: sp_grupos_anuncios_delete
-- Tipo: ELIMINACION (Eliminar grupo)
-- Retorna: TABLE(id, success, message, anuncios_afectados)
-- =============================================
-- Descripcion:
--   Elimina un grupo de anuncios del catalogo.
--   Elimina en cascada los registros de anun_detgrupo asociados.
--   Valida que el grupo exista antes de eliminar.
-- Validaciones:
--   - ID existe
--   - Verifica y reporta anuncios asociados eliminados (desvinculados)
-- Dependencias:
--   - anun_detgrupo: Registros que relacionan anuncios con grupos
-- Parametros:
--   p_id INTEGER - ID del grupo a eliminar
-- Retorno:
--   id INTEGER - ID del grupo eliminado
--   success BOOLEAN - Indica si la operacion fue exitosa
--   message TEXT - Mensaje descriptivo del resultado
--   anuncios_afectados INTEGER - Cantidad de anuncios desvinculados del grupo
-- =============================================

CREATE OR REPLACE FUNCTION public.sp_grupos_anuncios_delete(
    p_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    success BOOLEAN,
    message TEXT,
    anuncios_afectados INTEGER
) AS $$
DECLARE
    v_existe INTEGER;
    v_anuncios_count INTEGER;
    v_rows_affected INTEGER;
    v_descripcion TEXT;
BEGIN
    -- Validacion: ID no nulo
    IF p_id IS NULL THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            FALSE,
            'Error: ID del grupo no puede ser nulo'::TEXT,
            0;
        RETURN;
    END IF;

    -- Validacion: verificar que el grupo existe
    SELECT COUNT(*), MAX(anun_grupos.descripcion)
    INTO v_existe, v_descripcion
    FROM public.anun_grupos
    WHERE anun_grupos.id = p_id;

    IF v_existe = 0 THEN
        RETURN QUERY SELECT
            p_id,
            FALSE,
            'Error: El grupo especificado no existe'::TEXT,
            0;
        RETURN;
    END IF;

    -- Contar anuncios asociados al grupo (dependencias)
    SELECT COUNT(*) INTO v_anuncios_count
    FROM public.anun_detgrupo
    WHERE anun_grupos_id = p_id;

    -- Eliminar operacion
    BEGIN
        -- Primero eliminar anuncios asociados en anun_detgrupo (desvinculacion)
        DELETE FROM public.anun_detgrupo
        WHERE anun_grupos_id = p_id;

        -- Luego eliminar el grupo
        DELETE FROM public.anun_grupos
        WHERE anun_grupos.id = p_id;

        GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

        IF v_rows_affected > 0 THEN
            RETURN QUERY SELECT
                p_id,
                TRUE,
                ('Grupo "' || v_descripcion || '" eliminado exitosamente')::TEXT,
                v_anuncios_count;
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
                'Error: El grupo tiene dependencias adicionales y no puede ser eliminado'::TEXT,
                v_anuncios_count;
        WHEN OTHERS THEN
            RETURN QUERY SELECT
                p_id,
                FALSE,
                ('Error al eliminar grupo: ' || SQLERRM)::TEXT,
                0;
    END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_grupos_anuncios_delete(INTEGER) IS
'Elimina un grupo de anuncios y sus asociaciones en anun_detgrupo. Retorna id, success, message y anuncios_afectados.';


-- =============================================
-- FIN DE STORED PROCEDURES - GruposAnunciosAbcfrm
-- =============================================
-- Resumen de implementacion:
-- [OK] sp_grupos_anuncios_list   - Listar grupos con filtro ILIKE
-- [OK] sp_grupos_anuncios_get    - Obtener grupo por ID con validacion
-- [OK] sp_grupos_anuncios_create - Crear nuevo grupo con validaciones
-- [OK] sp_grupos_anuncios_update - Actualizar grupo con validaciones
-- [OK] sp_grupos_anuncios_delete - Eliminar grupo (cascada anun_detgrupo)
--
-- Caracteristicas implementadas:
-- - Nomenclatura estandar: sp_grupos_anuncios_*
-- - Schema: public (catalogos/grupos)
-- - Normalizacion: UPPER(TRIM()) en descripciones
-- - Validaciones: duplicados, vacios, existencia, ID nulo
-- - Manejo de errores: EXCEPTION con mensajes descriptivos
-- - Retornos estructurados: (id, descripcion, success, message)
-- - Soft delete: NO (eliminacion fisica)
-- - Cascada: Elimina registros en anun_detgrupo
-- - Busqueda: ILIKE con comodines para filtros case-insensitive
--
-- Tablas utilizadas:
-- - public.anun_grupos: Tabla principal de grupos
-- - public.anun_detgrupo: Tabla relacional grupo-anuncio
--
-- Dependencias verificadas en DELETE:
-- - anun_detgrupo.anun_grupos_id -> anun_grupos.id
-- =============================================


-- =============================================
-- SCRIPTS DE PRUEBA (Comentados)
-- =============================================
-- -- Listar todos los grupos
-- SELECT * FROM public.sp_grupos_anuncios_list();
--
-- -- Listar con filtro
-- SELECT * FROM public.sp_grupos_anuncios_list('EXTERIOR');
--
-- -- Obtener grupo por ID
-- SELECT * FROM public.sp_grupos_anuncios_get(1);
--
-- -- Crear nuevo grupo
-- SELECT * FROM public.sp_grupos_anuncios_create('NUEVO GRUPO DE PRUEBA');
--
-- -- Actualizar grupo
-- SELECT * FROM public.sp_grupos_anuncios_update(1, 'GRUPO ACTUALIZADO');
--
-- -- Eliminar grupo
-- SELECT * FROM public.sp_grupos_anuncios_delete(1);
-- =============================================
