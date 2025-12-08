-- ============================================
-- DESPLIEGUE COMPLETO - COMPONENTE DOCTOSFRM
-- ============================================
-- Componente: doctosfrm (Gestión de Documentos de Trámites)
-- Módulo: padron_licencias
-- Base de Datos: padron_licencias
-- Schema: public
-- Fecha: 2025-11-20
-- ============================================
-- CONTENIDO:
-- 1. Creación de tabla doctosfrm_tramite
-- 2. Índices y constraints
-- 3. Triggers de auditoría
-- 4. 5 Stored Procedures
-- 5. Comentarios de documentación
-- ============================================

-- Conectar a la base de datos
\c padron_licencias;
SET search_path TO public;
SET client_encoding = 'UTF8';

\echo '============================================'
\echo 'INICIO DE DESPLIEGUE - DOCTOSFRM'
\echo '============================================'

-- ============================================
-- SECCIÓN 1: CREACIÓN DE TABLA
-- ============================================
\echo ''
\echo '[1/5] Creando tabla doctosfrm_tramite...'

CREATE TABLE IF NOT EXISTS public.doctosfrm_tramite (
    id SERIAL PRIMARY KEY,
    tramite_id INTEGER NOT NULL,
    documentos TEXT[] DEFAULT ARRAY[]::TEXT[],
    otro TEXT,
    fecalt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecmod TIMESTAMP,
    capturo INTEGER,
    modifico INTEGER,
    CONSTRAINT uk_doctosfrm_tramite UNIQUE (tramite_id)
);

\echo '   ✓ Tabla creada exitosamente'

-- ============================================
-- SECCIÓN 2: ÍNDICES
-- ============================================
\echo ''
\echo '[2/5] Creando índices...'

CREATE INDEX IF NOT EXISTS idx_doctosfrm_tramite_tramite_id
    ON public.doctosfrm_tramite(tramite_id);

CREATE INDEX IF NOT EXISTS idx_doctosfrm_tramite_documentos
    ON public.doctosfrm_tramite USING GIN(documentos);

CREATE INDEX IF NOT EXISTS idx_doctosfrm_tramite_fecalt
    ON public.doctosfrm_tramite(fecalt);

\echo '   ✓ Índices creados exitosamente'

-- ============================================
-- SECCIÓN 3: TRIGGERS
-- ============================================
\echo ''
\echo '[3/5] Creando triggers de auditoría...'

CREATE OR REPLACE FUNCTION public.trg_doctosfrm_tramite_update_fecmod()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecmod := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_fecmod ON public.doctosfrm_tramite;

CREATE TRIGGER trg_update_fecmod
    BEFORE UPDATE ON public.doctosfrm_tramite
    FOR EACH ROW
    EXECUTE FUNCTION public.trg_doctosfrm_tramite_update_fecmod();

\echo '   ✓ Triggers creados exitosamente'

-- ============================================
-- SECCIÓN 4: STORED PROCEDURES
-- ============================================
\echo ''
\echo '[4/5] Creando stored procedures...'

-- ============================================
-- SP 1/5: sp_doctosfrm_catalog
-- ============================================
\echo '   Creando sp_doctosfrm_catalog...'

CREATE OR REPLACE FUNCTION public.sp_doctosfrm_catalog()
RETURNS TABLE(
    codigo TEXT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY VALUES
        ('fotofachada'::TEXT, 'Fotografías de la fachada'::TEXT),
        ('recibopredial'::TEXT, 'Recibo de predial'::TEXT),
        ('ident_titular'::TEXT, 'Identificación del titular'::TEXT),
        ('ident_dueno_finca'::TEXT, 'Identificación del dueño de la finca'::TEXT),
        ('ident_r1'::TEXT, 'Identificación R1 (alta de Hacienda)'::TEXT),
        ('contrato_arrend'::TEXT, 'Contrato de arrendamiento'::TEXT),
        ('solic_lic_usosuelo'::TEXT, 'Solicitud de licencia y uso de suelo'::TEXT),
        ('solic_mod_padron'::TEXT, 'Solicitud de modificación al padrón y uso de suelo'::TEXT),
        ('licencia_vigente'::TEXT, 'Licencia original vigente'::TEXT),
        ('carta_policia'::TEXT, 'Carta de policía'::TEXT),
        ('carta_poder'::TEXT, 'Carta de poder simple'::TEXT),
        ('memoria_calculo'::TEXT, 'Memoria de cálculo'::TEXT),
        ('poliza_responsabilidad'::TEXT, 'Póliza vigente de responsabilidad civil del anuncio'::TEXT),
        ('acta_constitutiva'::TEXT, 'Acta constitutiva'::TEXT),
        ('poder_notarial'::TEXT, 'Poder notarial'::TEXT),
        ('asignacion_numeros'::TEXT, 'Asignación de números oficiales'::TEXT),
        ('copia_licencia'::TEXT, 'Copia de licencia'::TEXT),
        ('solic_lic_anuncio'::TEXT, 'Solicitud de licencia de anuncio'::TEXT),
        ('solic_dictamen_anuncio'::TEXT, 'Solicitud de dictamen de anuncio'::TEXT);
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================
-- SP 2/5: sp_doctosfrm_get
-- ============================================
\echo '   Creando sp_doctosfrm_get...'

CREATE OR REPLACE FUNCTION public.sp_doctosfrm_get(
    p_tramite_id INTEGER
)
RETURNS TABLE(
    documentos TEXT[],
    otro TEXT
) AS $$
BEGIN
    IF p_tramite_id IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_tramite_id es obligatorio';
    END IF;

    IF p_tramite_id <= 0 THEN
        RAISE EXCEPTION 'El parámetro p_tramite_id debe ser mayor a 0';
    END IF;

    RETURN QUERY
        SELECT
            COALESCE(d.documentos, ARRAY[]::TEXT[]) AS documentos,
            d.otro
        FROM doctosfrm_tramite d
        WHERE d.tramite_id = p_tramite_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT ARRAY[]::TEXT[], NULL::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================
-- SP 3/5: sp_doctosfrm_save
-- ============================================
\echo '   Creando sp_doctosfrm_save...'

CREATE OR REPLACE FUNCTION public.sp_doctosfrm_save(
    p_tramite_id INTEGER,
    p_documentos JSON,
    p_otro TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_count INTEGER;
    v_doc_array TEXT[];
BEGIN
    IF p_tramite_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_tramite_id es obligatorio'::TEXT;
        RETURN;
    END IF;

    IF p_tramite_id <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_tramite_id debe ser mayor a 0'::TEXT;
        RETURN;
    END IF;

    BEGIN
        IF p_documentos IS NULL THEN
            v_doc_array := ARRAY[]::TEXT[];
        ELSE
            v_doc_array := ARRAY(SELECT json_array_elements_text(p_documentos));
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Formato JSON inválido en p_documentos'::TEXT;
        RETURN;
    END;

    SELECT COUNT(*) INTO v_count
    FROM doctosfrm_tramite
    WHERE tramite_id = p_tramite_id;

    IF v_count > 0 THEN
        UPDATE doctosfrm_tramite
        SET
            documentos = v_doc_array,
            otro = p_otro,
            fecmod = CURRENT_TIMESTAMP
        WHERE tramite_id = p_tramite_id;

        RETURN QUERY SELECT TRUE, 'Documentos actualizados correctamente'::TEXT;
    ELSE
        INSERT INTO doctosfrm_tramite (
            tramite_id,
            documentos,
            otro,
            fecalt
        ) VALUES (
            p_tramite_id,
            v_doc_array,
            p_otro,
            CURRENT_TIMESTAMP
        );

        RETURN QUERY SELECT TRUE, 'Documentos guardados correctamente'::TEXT;
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RETURN QUERY SELECT FALSE, 'El trámite especificado no existe'::TEXT;
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al guardar documentos: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/5: sp_doctosfrm_clear
-- ============================================
\echo '   Creando sp_doctosfrm_clear...'

CREATE OR REPLACE FUNCTION public.sp_doctosfrm_clear(
    p_tramite_id INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    IF p_tramite_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_tramite_id es obligatorio'::TEXT;
        RETURN;
    END IF;

    IF p_tramite_id <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_tramite_id debe ser mayor a 0'::TEXT;
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM doctosfrm_tramite
    WHERE tramite_id = p_tramite_id;

    IF v_count = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe registro de documentos para el trámite especificado'::TEXT;
        RETURN;
    END IF;

    UPDATE doctosfrm_tramite
    SET
        documentos = ARRAY[]::TEXT[],
        otro = NULL,
        fecmod = CURRENT_TIMESTAMP
    WHERE tramite_id = p_tramite_id;

    RETURN QUERY SELECT TRUE, 'Selección de documentos limpiada correctamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al limpiar documentos: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 5/5: sp_doctosfrm_delete
-- ============================================
\echo '   Creando sp_doctosfrm_delete...'

CREATE OR REPLACE FUNCTION public.sp_doctosfrm_delete(
    p_tramite_id INTEGER,
    p_documento TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_count INTEGER;
    v_found BOOLEAN;
BEGIN
    IF p_tramite_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_tramite_id es obligatorio'::TEXT;
        RETURN;
    END IF;

    IF p_tramite_id <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_tramite_id debe ser mayor a 0'::TEXT;
        RETURN;
    END IF;

    IF p_documento IS NULL OR TRIM(p_documento) = '' THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_documento es obligatorio'::TEXT;
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM doctosfrm_tramite
    WHERE tramite_id = p_tramite_id;

    IF v_count = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe registro de documentos para el trámite especificado'::TEXT;
        RETURN;
    END IF;

    SELECT p_documento = ANY(documentos) INTO v_found
    FROM doctosfrm_tramite
    WHERE tramite_id = p_tramite_id;

    IF NOT v_found THEN
        RETURN QUERY SELECT FALSE, 'El documento especificado no está en la lista del trámite'::TEXT;
        RETURN;
    END IF;

    UPDATE doctosfrm_tramite
    SET
        documentos = array_remove(documentos, p_documento),
        fecmod = CURRENT_TIMESTAMP
    WHERE tramite_id = p_tramite_id;

    RETURN QUERY SELECT TRUE, 'Documento eliminado correctamente de la selección'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al eliminar documento: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

\echo '   ✓ 5 Stored Procedures creados exitosamente'

-- ============================================
-- SECCIÓN 5: COMENTARIOS DE DOCUMENTACIÓN
-- ============================================
\echo ''
\echo '[5/5] Agregando comentarios de documentación...'

COMMENT ON TABLE public.doctosfrm_tramite IS
'Almacena los documentos asociados a cada trámite de licencias';

COMMENT ON COLUMN public.doctosfrm_tramite.tramite_id IS
'ID del trámite asociado (debe existir en tabla tramites)';

COMMENT ON COLUMN public.doctosfrm_tramite.documentos IS
'Array de códigos de documentos. Los códigos válidos se obtienen del catálogo sp_doctosfrm_catalog()';

COMMENT ON FUNCTION public.sp_doctosfrm_catalog() IS
'Catálogo de tipos de documentos para trámites de licencias';

COMMENT ON FUNCTION public.sp_doctosfrm_get(INTEGER) IS
'Obtiene los documentos registrados para un trámite específico';

COMMENT ON FUNCTION public.sp_doctosfrm_save(INTEGER, JSON, TEXT) IS
'Guarda o actualiza los documentos asociados a un trámite (UPSERT)';

COMMENT ON FUNCTION public.sp_doctosfrm_clear(INTEGER) IS
'Limpia todos los documentos seleccionados para un trámite';

COMMENT ON FUNCTION public.sp_doctosfrm_delete(INTEGER, TEXT) IS
'Elimina un documento específico de la lista de documentos de un trámite';

\echo '   ✓ Comentarios agregados exitosamente'

-- ============================================
-- VERIFICACIÓN DE DESPLIEGUE
-- ============================================
\echo ''
\echo '============================================'
\echo 'VERIFICACIÓN DE DESPLIEGUE'
\echo '============================================'

\echo ''
\echo 'Tabla creada:'
SELECT
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'doctosfrm_tramite';

\echo ''
\echo 'Stored Procedures creados:'
SELECT
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE 'sp_doctosfrm_%'
ORDER BY routine_name;

\echo ''
\echo 'Índices creados:'
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'doctosfrm_tramite'
ORDER BY indexname;

\echo ''
\echo 'Triggers creados:'
SELECT
    trigger_name,
    event_manipulation,
    event_object_table
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'doctosfrm_tramite';

-- ============================================
-- PRUEBA RÁPIDA
-- ============================================
\echo ''
\echo '============================================'
\echo 'PRUEBA RÁPIDA DE FUNCIONALIDAD'
\echo '============================================'

\echo ''
\echo 'Test 1: Catálogo (debe retornar 19 documentos):'
SELECT COUNT(*) AS total_documentos FROM sp_doctosfrm_catalog();

-- ============================================
-- FIN DE DESPLIEGUE
-- ============================================
\echo ''
\echo '============================================'
\echo 'DESPLIEGUE COMPLETADO EXITOSAMENTE'
\echo '============================================'
\echo 'Componente: doctosfrm'
\echo 'Tabla: doctosfrm_tramite (1)'
\echo 'Stored Procedures: 5'
\echo 'Índices: 3'
\echo 'Triggers: 1'
\echo '============================================'
\echo ''
\echo 'Siguiente paso:'
\echo '  psql -U usuario -d padron_licencias -f DOCTOSFRM_test_procedures.sql'
\echo ''
\echo '============================================'
