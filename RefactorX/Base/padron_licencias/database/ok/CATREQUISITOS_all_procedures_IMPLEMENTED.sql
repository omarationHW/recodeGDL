-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS
-- Componente: CatRequisitos
-- Módulo: padron_licencias
-- Schema: comun
-- Generado: 2025-11-21
-- Total SPs: 5
-- ============================================
-- Descripción: CRUD completo del catálogo de requisitos para giros
-- Tabla principal: c_girosreq (req INTEGER, descripcion VARCHAR)
-- ============================================

-- ============================================
-- CONFIGURACIÓN DE ESQUEMA
-- ============================================
-- Schema: comun (funcionalidad compartida)
-- Tabla principal: c_girosreq
-- Columnas:
--   - req: INTEGER (PK, auto-generado con MAX+1)
--   - descripcion: VARCHAR (descripción del requisito)
-- ============================================

-- ============================================
-- ÍNDICES RECOMENDADOS (ejecutar si no existen)
-- ============================================
-- CREATE INDEX IF NOT EXISTS idx_c_girosreq_req ON c_girosreq(req);
-- CREATE INDEX IF NOT EXISTS idx_c_girosreq_descripcion ON c_girosreq(descripcion);
-- CREATE INDEX IF NOT EXISTS idx_c_girosreq_descripcion_upper ON c_girosreq(UPPER(descripcion));
-- ============================================

-- ============================================
-- SP 1/5: sp_catrequisitos_list
-- Tipo: CONSULTA
-- Descripción: Lista todos los requisitos del catálogo ordenados por ID
-- Parámetros: Ninguno
-- Retorna: Lista completa de requisitos (req, descripcion)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_catrequisitos_list()
RETURNS TABLE(
    req INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cgr.req,
        cgr.descripcion
    FROM c_girosreq cgr
    ORDER BY cgr.req;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al listar requisitos: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_catrequisitos_list() IS
'Lista todos los requisitos del catálogo ordenados por ID - CatRequisitos';

-- ============================================
-- SP 2/5: sp_catrequisitos_search
-- Tipo: CONSULTA
-- Descripción: Busca requisitos por descripción (ILIKE case-insensitive)
-- Parámetros:
--   p_descripcion: Texto a buscar en la descripción (parcial)
-- Retorna: Lista de requisitos que coinciden con la búsqueda
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_catrequisitos_search(
    p_descripcion VARCHAR
)
RETURNS TABLE(
    req INTEGER,
    descripcion VARCHAR
) AS $$
DECLARE
    v_search_term VARCHAR;
BEGIN
    -- Validación: Si el parámetro está vacío o nulo, devolver todos los registros
    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY
        SELECT
            cgr.req,
            cgr.descripcion
        FROM c_girosreq cgr
        ORDER BY cgr.req;
        RETURN;
    END IF;

    -- Normalizar término de búsqueda
    v_search_term := TRIM(p_descripcion);

    RETURN QUERY
    SELECT
        cgr.req,
        cgr.descripcion
    FROM c_girosreq cgr
    WHERE cgr.descripcion ILIKE '%' || v_search_term || '%'
    ORDER BY cgr.req;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al buscar requisitos: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_catrequisitos_search(VARCHAR) IS
'Busca requisitos por descripción con ILIKE (case-insensitive) - CatRequisitos';

-- ============================================
-- SP 3/5: sp_catrequisitos_create
-- Tipo: INSERCIÓN
-- Descripción: Crea un nuevo requisito con ID auto-generado (MAX+1)
-- Parámetros:
--   p_descripcion: Descripción del nuevo requisito
-- Retorna: success (BOOLEAN), message (TEXT), req (INTEGER)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_catrequisitos_create(
    p_descripcion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    req INTEGER
) AS $$
DECLARE
    v_new_req INTEGER;
    v_descripcion_normalizada VARCHAR;
    v_descripcion_existe BOOLEAN;
BEGIN
    -- Validación: Descripción requerida
    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY SELECT
            FALSE,
            'La descripción del requisito es requerida'::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- Normalizar descripción (UPPER y TRIM)
    v_descripcion_normalizada := UPPER(TRIM(p_descripcion));

    -- Validación: Verificar que la descripción no exista ya (evitar duplicados)
    SELECT EXISTS (
        SELECT 1 FROM c_girosreq
        WHERE UPPER(TRIM(descripcion)) = v_descripcion_normalizada
    ) INTO v_descripcion_existe;

    IF v_descripcion_existe THEN
        RETURN QUERY SELECT
            FALSE,
            'Ya existe un requisito con la misma descripción'::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- Generar nuevo ID (MAX + 1)
    SELECT COALESCE(MAX(cgr.req), 0) + 1 INTO v_new_req FROM c_girosreq cgr;

    -- Insertar el nuevo requisito
    INSERT INTO c_girosreq (req, descripcion)
    VALUES (v_new_req, v_descripcion_normalizada);

    -- Retorno exitoso
    RETURN QUERY SELECT
        TRUE,
        'Requisito creado exitosamente'::TEXT,
        v_new_req;

EXCEPTION
    WHEN unique_violation THEN
        RETURN QUERY SELECT
            FALSE,
            'Error: Ya existe un requisito con ese ID'::TEXT,
            NULL::INTEGER;
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error al crear requisito: ' || SQLERRM)::TEXT,
            NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_catrequisitos_create(VARCHAR) IS
'Crea un nuevo requisito con ID auto-generado y descripción normalizada - CatRequisitos';

-- ============================================
-- SP 4/5: sp_catrequisitos_update
-- Tipo: ACTUALIZACIÓN
-- Descripción: Actualiza la descripción de un requisito existente
-- Parámetros:
--   p_req: ID del requisito a actualizar
--   p_descripcion: Nueva descripción del requisito
-- Retorna: success (BOOLEAN), message (TEXT), rows_affected (INTEGER)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_catrequisitos_update(
    p_req INTEGER,
    p_descripcion VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    rows_affected INTEGER
) AS $$
DECLARE
    v_rows_affected INTEGER;
    v_requisito_existe BOOLEAN;
    v_descripcion_normalizada VARCHAR;
    v_descripcion_duplicada BOOLEAN;
BEGIN
    -- Validación: ID requerido
    IF p_req IS NULL OR p_req <= 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'El ID del requisito es requerido y debe ser mayor a cero'::TEXT,
            0;
        RETURN;
    END IF;

    -- Validación: Descripción requerida
    IF p_descripcion IS NULL OR TRIM(p_descripcion) = '' THEN
        RETURN QUERY SELECT
            FALSE,
            'La descripción del requisito es requerida'::TEXT,
            0;
        RETURN;
    END IF;

    -- Normalizar descripción (UPPER y TRIM)
    v_descripcion_normalizada := UPPER(TRIM(p_descripcion));

    -- Validación: Verificar que el requisito existe
    SELECT EXISTS (
        SELECT 1 FROM c_girosreq WHERE req = p_req
    ) INTO v_requisito_existe;

    IF NOT v_requisito_existe THEN
        RETURN QUERY SELECT
            FALSE,
            ('El requisito con ID ' || p_req || ' no existe')::TEXT,
            0;
        RETURN;
    END IF;

    -- Validación: Verificar que la descripción no exista en otro requisito
    SELECT EXISTS (
        SELECT 1 FROM c_girosreq
        WHERE UPPER(TRIM(descripcion)) = v_descripcion_normalizada
        AND req != p_req
    ) INTO v_descripcion_duplicada;

    IF v_descripcion_duplicada THEN
        RETURN QUERY SELECT
            FALSE,
            'Ya existe otro requisito con la misma descripción'::TEXT,
            0;
        RETURN;
    END IF;

    -- Actualizar el requisito
    UPDATE c_girosreq
    SET descripcion = v_descripcion_normalizada
    WHERE req = p_req;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    -- Retorno exitoso
    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT
            TRUE,
            'Requisito actualizado exitosamente'::TEXT,
            v_rows_affected;
    ELSE
        RETURN QUERY SELECT
            FALSE,
            'No se realizaron cambios'::TEXT,
            0;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error al actualizar requisito: ' || SQLERRM)::TEXT,
            0;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_catrequisitos_update(INTEGER, VARCHAR) IS
'Actualiza la descripción de un requisito existente con validaciones - CatRequisitos';

-- ============================================
-- SP 5/5: sp_catrequisitos_delete
-- Tipo: ELIMINACIÓN
-- Descripción: Elimina un requisito del catálogo
-- Parámetros:
--   p_req: ID del requisito a eliminar
-- Retorna: success (BOOLEAN), message (TEXT), deleted_req (INTEGER), deleted_descripcion (VARCHAR)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_catrequisitos_delete(
    p_req INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    deleted_req INTEGER,
    deleted_descripcion VARCHAR
) AS $$
DECLARE
    v_requisito_existe BOOLEAN;
    v_descripcion_anterior VARCHAR;
    v_en_uso BOOLEAN;
    v_rows_affected INTEGER;
BEGIN
    -- Validación: ID requerido
    IF p_req IS NULL OR p_req <= 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'El ID del requisito es requerido y debe ser mayor a cero'::TEXT,
            NULL::INTEGER,
            NULL::VARCHAR;
        RETURN;
    END IF;

    -- Validación: Verificar que el requisito existe
    SELECT EXISTS (
        SELECT 1 FROM c_girosreq WHERE req = p_req
    ) INTO v_requisito_existe;

    IF NOT v_requisito_existe THEN
        RETURN QUERY SELECT
            FALSE,
            ('El requisito con ID ' || p_req || ' no existe')::TEXT,
            NULL::INTEGER,
            NULL::VARCHAR;
        RETURN;
    END IF;

    -- Obtener la descripción antes de eliminar (para el log)
    SELECT descripcion INTO v_descripcion_anterior
    FROM c_girosreq WHERE req = p_req;

    -- Validación: Verificar que el requisito no esté en uso (ligado a giros)
    SELECT EXISTS (
        SELECT 1 FROM giro_req WHERE req = p_req
    ) INTO v_en_uso;

    IF v_en_uso THEN
        RETURN QUERY SELECT
            FALSE,
            ('El requisito está asignado a uno o más giros. Debe desligarlo primero.')::TEXT,
            NULL::INTEGER,
            NULL::VARCHAR;
        RETURN;
    END IF;

    -- Eliminar el requisito
    DELETE FROM c_girosreq WHERE req = p_req;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    -- Retorno exitoso
    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT
            TRUE,
            'Requisito eliminado exitosamente'::TEXT,
            p_req,
            v_descripcion_anterior;
    ELSE
        RETURN QUERY SELECT
            FALSE,
            'No se pudo eliminar el requisito'::TEXT,
            NULL::INTEGER,
            NULL::VARCHAR;
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RETURN QUERY SELECT
            FALSE,
            'No se puede eliminar: el requisito está referenciado por otros registros'::TEXT,
            NULL::INTEGER,
            NULL::VARCHAR;
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            ('Error al eliminar requisito: ' || SQLERRM)::TEXT,
            NULL::INTEGER,
            NULL::VARCHAR;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_catrequisitos_delete(INTEGER) IS
'Elimina un requisito del catálogo con validación de uso - CatRequisitos';

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
-- Total SPs implementados: 5
--
-- Lista de SPs:
-- 1. sp_catrequisitos_list    - CONSULTA     - Lista todos los requisitos
-- 2. sp_catrequisitos_search  - CONSULTA     - Busca por descripción (ILIKE)
-- 3. sp_catrequisitos_create  - INSERCIÓN    - Crea nuevo requisito (auto-ID)
-- 4. sp_catrequisitos_update  - ACTUALIZACIÓN - Actualiza descripción
-- 5. sp_catrequisitos_delete  - ELIMINACIÓN  - Elimina requisito
--
-- Schema: comun
--
-- Tablas utilizadas:
-- - c_girosreq (principal)
-- - giro_req (validación de uso en delete)
--
-- Características implementadas:
-- [x] Nomenclatura estándar (p_ para parámetros, v_ para variables)
-- [x] Validaciones completas de parámetros requeridos
-- [x] RAISE EXCEPTION descriptivos
-- [x] Retorno estructurado (success, message, data)
-- [x] Auto-generación de ID con MAX(req)+1
-- [x] Normalización de entrada con UPPER(TRIM())
-- [x] Validación de duplicados en CREATE y UPDATE
-- [x] Validación de uso antes de DELETE
-- [x] Manejo robusto de errores con EXCEPTION
-- [x] Comentarios descriptivos en cada función
-- [x] Índices recomendados documentados
-- ============================================

-- ============================================
-- SCRIPT DE PRUEBA (comentado para referencia)
-- ============================================
-- -- Test 1: Listar todos los requisitos
-- SELECT * FROM comun.sp_catrequisitos_list();
--
-- -- Test 2: Buscar requisitos
-- SELECT * FROM comun.sp_catrequisitos_search('ACTA');
--
-- -- Test 3: Crear nuevo requisito
-- SELECT * FROM comun.sp_catrequisitos_create('NUEVO REQUISITO DE PRUEBA');
--
-- -- Test 4: Actualizar requisito
-- SELECT * FROM comun.sp_catrequisitos_update(999, 'REQUISITO MODIFICADO');
--
-- -- Test 5: Eliminar requisito
-- SELECT * FROM comun.sp_catrequisitos_delete(999);
-- ============================================
