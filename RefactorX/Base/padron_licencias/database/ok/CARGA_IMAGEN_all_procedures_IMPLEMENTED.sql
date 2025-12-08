-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA SISTEMA DE CARGA DE IMÁGENES Y DOCUMENTOS DIGITALES
-- Convención: SP_CARGA_IMAGEN_XXX
-- Implementado: 2025-11-21
-- Tablas: c_doctos, digital_docs, tramitedocs, tramites
-- Componente: CARGA_IMAGEN - Batch 11
-- Total SPs: 6
-- ============================================

-- ============================================
-- SP 1/6: sp_get_document_types
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de tipos de documentos disponibles para carga
-- Parámetros: Ninguno
-- Retorna: Listado de tipos de documento ordenado alfabéticamente
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_get_document_types()
RETURNS TABLE(
    id INTEGER,
    documento VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.documento
    FROM c_doctos c
    WHERE c.id IS NOT NULL
    ORDER BY c.documento ASC;
END;
$$;

COMMENT ON FUNCTION public.sp_get_document_types() IS
'Obtiene el catálogo completo de tipos de documentos disponibles para asociar a trámites';

-- ============================================
-- SP 2/6: sp_get_tramite_docs
-- Tipo: Report
-- Descripción: Obtiene todos los documentos digitales asociados a un trámite específico
-- Parámetros: p_tramite_id - ID del trámite a consultar
-- Retorna: Lista de documentos con metadata
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_get_tramite_docs(p_tramite_id INTEGER)
RETURNS TABLE(
    id_imagen INTEGER,
    documento VARCHAR,
    id_licencia INTEGER,
    cvedocto INTEGER,
    feccap TIMESTAMP,
    capturista VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar que el trámite exista
    IF NOT EXISTS (SELECT 1 FROM tramites WHERE id_tramite = p_tramite_id) THEN
        RAISE EXCEPTION 'El trámite % no existe', p_tramite_id;
    END IF;

    RETURN QUERY
    SELECT
        td.id_imagen,
        d.documento,
        td.id_licencia,
        td.cvedocto,
        dd.feccap,
        dd.capturista
    FROM tramitedocs td
    INNER JOIN c_doctos d ON td.cvedocto = d.id
    INNER JOIN digital_docs dd ON td.id_imagen = dd.id_imagen
    WHERE td.id_tramite = p_tramite_id
    ORDER BY dd.feccap DESC;
END;
$$;

COMMENT ON FUNCTION public.sp_get_tramite_docs(INTEGER) IS
'Obtiene todos los documentos digitales asociados a un trámite con su metadata completa';

-- ============================================
-- SP 3/6: sp_get_image
-- Tipo: Report
-- Descripción: Obtiene el contenido binario de una imagen específica
-- Parámetros: p_id_imagen - ID de la imagen a recuperar
-- Retorna: Contenido binario (bytea) de la imagen
-- API Compatible: RETURNS bytea
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_get_image(p_id_imagen INTEGER)
RETURNS bytea
LANGUAGE plpgsql
AS $$
DECLARE
    v_imagen bytea;
BEGIN
    -- Validar que la imagen exista
    IF NOT EXISTS (SELECT 1 FROM digital_docs WHERE id_imagen = p_id_imagen) THEN
        RAISE EXCEPTION 'La imagen con ID % no existe', p_id_imagen;
    END IF;

    -- Obtener el contenido binario
    SELECT imagen
    INTO v_imagen
    FROM digital_docs
    WHERE id_imagen = p_id_imagen;

    -- Validar que la imagen tenga contenido
    IF v_imagen IS NULL THEN
        RAISE EXCEPTION 'La imagen con ID % no tiene contenido', p_id_imagen;
    END IF;

    RETURN v_imagen;
END;
$$;

COMMENT ON FUNCTION public.sp_get_image(INTEGER) IS
'Recupera el contenido binario de una imagen digital almacenada';

-- ============================================
-- SP 4/6: sp_upload_image
-- Tipo: CRUD (Create)
-- Descripción: Guarda una imagen binaria y la asocia a un trámite con metadata
-- Parámetros:
--   p_tramite_id - ID del trámite
--   p_document_type_id - ID del tipo de documento
--   p_id_licencia - ID de la licencia (puede ser NULL)
--   p_file - Contenido binario de la imagen
--   p_capturista - Usuario que carga la imagen
-- Retorna: success, message, id_imagen
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_upload_image(
    p_tramite_id INTEGER,
    p_document_type_id INTEGER,
    p_id_licencia INTEGER,
    p_file bytea,
    p_capturista VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_imagen INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_file_size INTEGER;
BEGIN
    -- Validar parámetros obligatorios
    IF p_tramite_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El ID del trámite es obligatorio', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_document_type_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El tipo de documento es obligatorio', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_file IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El archivo es obligatorio', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_capturista IS NULL OR TRIM(p_capturista) = '' THEN
        RETURN QUERY SELECT FALSE, 'El capturista es obligatorio', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que el trámite exista
    IF NOT EXISTS (SELECT 1 FROM tramites WHERE id_tramite = p_tramite_id) THEN
        RETURN QUERY SELECT FALSE, 'El trámite no existe', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que el tipo de documento exista
    IF NOT EXISTS (SELECT 1 FROM c_doctos WHERE id = p_document_type_id) THEN
        RETURN QUERY SELECT FALSE, 'El tipo de documento no existe', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar tamaño del archivo (máximo 10MB)
    v_file_size := octet_length(p_file);
    IF v_file_size > 10485760 THEN
        RETURN QUERY SELECT FALSE, 'El archivo excede el tamaño máximo permitido (10MB)', NULL::INTEGER;
        RETURN;
    END IF;

    -- Iniciar transacción implícita
    BEGIN
        -- Insertar en digital_docs
        INSERT INTO digital_docs (
            cvedocto,
            id_tramite,
            id_licencia,
            imagen,
            feccap,
            capturista
        )
        VALUES (
            p_document_type_id,
            p_tramite_id,
            p_id_licencia,
            p_file,
            CURRENT_TIMESTAMP,
            p_capturista
        )
        RETURNING digital_docs.id_imagen INTO v_new_id;

        -- Crear asociación en tramitedocs
        INSERT INTO tramitedocs (
            id_tramite,
            id_imagen,
            id_licencia,
            cvedocto
        )
        VALUES (
            p_tramite_id,
            v_new_id,
            p_id_licencia,
            p_document_type_id
        );

        -- Retornar éxito
        RETURN QUERY SELECT TRUE, 'Imagen cargada exitosamente', v_new_id;

    EXCEPTION WHEN OTHERS THEN
        -- Manejo de errores
        RETURN QUERY SELECT FALSE, 'Error al cargar la imagen: ' || SQLERRM, NULL::INTEGER;
    END;
END;
$$;

COMMENT ON FUNCTION public.sp_upload_image(INTEGER, INTEGER, INTEGER, bytea, VARCHAR) IS
'Carga una imagen digital y la asocia a un trámite con validaciones de tamaño y existencia';

-- ============================================
-- SP 5/6: sp_delete_image
-- Tipo: CRUD (Delete)
-- Descripción: Elimina una imagen y todas sus asociaciones de forma segura
-- Parámetros: p_id_imagen - ID de la imagen a eliminar
-- Retorna: success, message
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_delete_image(p_id_imagen INTEGER)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tramite_id INTEGER;
BEGIN
    -- Validar parámetro
    IF p_id_imagen IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El ID de la imagen es obligatorio'::TEXT;
        RETURN;
    END IF;

    -- Verificar que la imagen exista
    IF NOT EXISTS (SELECT 1 FROM digital_docs WHERE id_imagen = p_id_imagen) THEN
        RETURN QUERY SELECT FALSE, ('La imagen con ID ' || p_id_imagen || ' no existe')::TEXT;
        RETURN;
    END IF;

    -- Obtener información del trámite para log
    SELECT id_tramite INTO v_tramite_id
    FROM digital_docs
    WHERE id_imagen = p_id_imagen;

    -- Iniciar transacción implícita
    BEGIN
        -- Eliminar asociación en tramitedocs primero (integridad referencial)
        DELETE FROM tramitedocs WHERE id_imagen = p_id_imagen;

        -- Eliminar la imagen de digital_docs
        DELETE FROM digital_docs WHERE id_imagen = p_id_imagen;

        -- Retornar éxito
        RETURN QUERY SELECT TRUE, ('Imagen ' || p_id_imagen || ' eliminada exitosamente del trámite ' || v_tramite_id)::TEXT;

    EXCEPTION WHEN OTHERS THEN
        -- Manejo de errores
        RETURN QUERY SELECT FALSE, ('Error al eliminar la imagen: ' || SQLERRM)::TEXT;
    END;
END;
$$;

COMMENT ON FUNCTION public.sp_delete_image(INTEGER) IS
'Elimina una imagen digital y todas sus asociaciones de forma segura con manejo de transacciones';

-- ============================================
-- SP 6/6: sp_get_tramite_info
-- Tipo: Report
-- Descripción: Obtiene información básica de un trámite para contexto en la carga
-- Parámetros: p_tramite_id - ID del trámite a consultar
-- Retorna: Información básica del trámite
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_get_tramite_info(p_tramite_id INTEGER)
RETURNS TABLE(
    id_tramite INTEGER,
    cvecuenta INTEGER,
    recaud SMALLINT,
    existe BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar parámetro
    IF p_tramite_id IS NULL THEN
        RAISE EXCEPTION 'El ID del trámite es obligatorio';
    END IF;

    -- Verificar si existe y retornar información
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.cvecuenta,
        t.recaud,
        TRUE as existe
    FROM tramites t
    WHERE t.id_tramite = p_tramite_id
    LIMIT 1;

    -- Si no retornó nada, indicar que no existe
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            p_tramite_id,
            NULL::INTEGER,
            NULL::SMALLINT,
            FALSE;
    END IF;
END;
$$;

COMMENT ON FUNCTION public.sp_get_tramite_info(INTEGER) IS
'Obtiene información básica de un trámite para validar su existencia antes de cargar imágenes';

-- ============================================
-- ÍNDICES RECOMENDADOS
-- ============================================

-- Índice para búsquedas por trámite en digital_docs
-- CREATE INDEX IF NOT EXISTS idx_digital_docs_tramite ON digital_docs(id_tramite);

-- Índice para búsquedas por tipo de documento
-- CREATE INDEX IF NOT EXISTS idx_digital_docs_cvedocto ON digital_docs(cvedocto);

-- Índice para búsquedas por licencia
-- CREATE INDEX IF NOT EXISTS idx_digital_docs_licencia ON digital_docs(id_licencia) WHERE id_licencia IS NOT NULL;

-- Índice para ordenar por fecha de captura
-- CREATE INDEX IF NOT EXISTS idx_digital_docs_feccap ON digital_docs(feccap DESC);

-- Índice compuesto para tramitedocs (búsquedas frecuentes)
-- CREATE INDEX IF NOT EXISTS idx_tramitedocs_tramite_imagen ON tramitedocs(id_tramite, id_imagen);

-- Índice para búsquedas por imagen en tramitedocs
-- CREATE INDEX IF NOT EXISTS idx_tramitedocs_imagen ON tramitedocs(id_imagen);

-- ============================================
-- VERIFICACIÓN DE IMPLEMENTACIÓN
-- ============================================

-- Verificar que todas las funciones fueron creadas correctamente
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
    AND p.proname IN (
        'sp_get_document_types',
        'sp_get_tramite_docs',
        'sp_get_image',
        'sp_upload_image',
        'sp_delete_image',
        'sp_get_tramite_info'
    );

    IF v_count = 6 THEN
        RAISE NOTICE '✓ Las 6 stored procedures de CARGA_IMAGEN fueron creadas exitosamente';
    ELSE
        RAISE WARNING '⚠ Solo se crearon % de 6 stored procedures esperadas', v_count;
    END IF;
END $$;

-- Listar todas las funciones creadas con sus firmas
SELECT
    p.proname AS funcion,
    pg_get_function_arguments(p.oid) AS parametros,
    pg_get_function_result(p.oid) AS retorno
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN (
    'sp_get_document_types',
    'sp_get_tramite_docs',
    'sp_get_image',
    'sp_upload_image',
    'sp_delete_image',
    'sp_get_tramite_info'
)
ORDER BY p.proname;

-- ============================================
-- EJEMPLOS DE USO
-- ============================================

-- Ejemplo 1: Obtener catálogo de tipos de documento
-- SELECT * FROM public.sp_get_document_types();

-- Ejemplo 2: Obtener documentos de un trámite
-- SELECT * FROM public.sp_get_tramite_docs(12345);

-- Ejemplo 3: Obtener información de un trámite
-- SELECT * FROM public.sp_get_tramite_info(12345);

-- Ejemplo 4: Cargar una imagen (requiere bytea)
-- SELECT * FROM public.sp_upload_image(
--     12345,                    -- p_tramite_id
--     1,                        -- p_document_type_id
--     NULL,                     -- p_id_licencia
--     '\x89504E47...'::bytea,   -- p_file (contenido binario)
--     'USUARIO123'              -- p_capturista
-- );

-- Ejemplo 5: Obtener imagen binaria
-- SELECT public.sp_get_image(100);

-- Ejemplo 6: Eliminar una imagen
-- SELECT * FROM public.sp_delete_image(100);

-- ============================================
-- FIN DE IMPLEMENTACIÓN - CARGA_IMAGEN
-- Total: 6 Stored Procedures
-- Esquema: public
-- Estado: ✓ COMPLETADO
-- ============================================
