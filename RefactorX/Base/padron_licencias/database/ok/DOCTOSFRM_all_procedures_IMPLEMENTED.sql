-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS - PADRON LICENCIAS
-- ============================================
-- Componente: doctosfrm (Gestión de Documentos de Trámites)
-- Módulo: padron_licencias
-- Schema: public
-- Total SPs: 5
-- Fecha Implementación: 2025-11-20
-- ============================================
-- DESCRIPCIÓN:
-- Este módulo gestiona los documentos requeridos para los trámites
-- de licencias. Permite catalogar, registrar y administrar la
-- documentación asociada a cada trámite.
-- ============================================

-- ============================================
-- CONFIGURACIÓN DE BASE DE DATOS
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- SP 1/5: sp_doctosfrm_catalog
-- ============================================
-- Tipo: Catálogo
-- Descripción: Devuelve el catálogo completo de tipos de documentos
--              disponibles para los trámites de licencias
-- Retorna: TABLE(codigo TEXT, descripcion TEXT)
-- Uso: SELECT * FROM sp_doctosfrm_catalog();
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_doctosfrm_catalog()
RETURNS TABLE(
    codigo TEXT,
    descripcion TEXT
) AS $$
BEGIN
    -- Catálogo estático de tipos de documentos
    -- Estos códigos se utilizan en la interfaz para identificar
    -- cada tipo de documento requerido

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

COMMENT ON FUNCTION public.sp_doctosfrm_catalog() IS
'Catálogo de tipos de documentos para trámites de licencias. Retorna código y descripción de cada documento.';

-- ============================================
-- SP 2/5: sp_doctosfrm_get
-- ============================================
-- Tipo: Consulta
-- Descripción: Obtiene la lista de documentos registrados para un trámite
-- Parámetros:
--   p_tramite_id: ID del trámite a consultar
-- Retorna: TABLE(documentos TEXT[], otro TEXT)
-- Uso: SELECT * FROM sp_doctosfrm_get(123);
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_doctosfrm_get(
    p_tramite_id INTEGER
)
RETURNS TABLE(
    documentos TEXT[],
    otro TEXT
) AS $$
BEGIN
    -- Validación de parámetros obligatorios
    IF p_tramite_id IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_tramite_id es obligatorio';
    END IF;

    IF p_tramite_id <= 0 THEN
        RAISE EXCEPTION 'El parámetro p_tramite_id debe ser mayor a 0';
    END IF;

    -- Retorna los documentos del trámite
    -- Si no existe registro, retorna array vacío y NULL
    RETURN QUERY
        SELECT
            COALESCE(d.documentos, ARRAY[]::TEXT[]) AS documentos,
            d.otro
        FROM doctosfrm_tramite d
        WHERE d.tramite_id = p_tramite_id;

    -- Si no se encontró el trámite, retornar registro vacío
    IF NOT FOUND THEN
        RETURN QUERY SELECT ARRAY[]::TEXT[], NULL::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION public.sp_doctosfrm_get(INTEGER) IS
'Obtiene los documentos registrados para un trámite específico. Retorna array de códigos de documentos y campo de texto libre.';

-- ============================================
-- SP 3/5: sp_doctosfrm_save
-- ============================================
-- Tipo: CRUD (Create/Update)
-- Descripción: Guarda o actualiza los documentos de un trámite
-- Parámetros:
--   p_tramite_id: ID del trámite
--   p_documentos: JSON array con códigos de documentos
--   p_otro: Texto libre para información adicional
-- Retorna: TABLE(success BOOLEAN, message TEXT)
-- Uso: SELECT * FROM sp_doctosfrm_save(123, '["fotofachada","recibopredial"]'::json, 'Observaciones');
-- ============================================

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
    -- Validación de parámetros obligatorios
    IF p_tramite_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_tramite_id es obligatorio'::TEXT;
        RETURN;
    END IF;

    IF p_tramite_id <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_tramite_id debe ser mayor a 0'::TEXT;
        RETURN;
    END IF;

    -- Convertir JSON a array de texto
    -- Si p_documentos es NULL, usar array vacío
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

    -- Verificar si ya existe un registro para este trámite
    SELECT COUNT(*) INTO v_count
    FROM doctosfrm_tramite
    WHERE tramite_id = p_tramite_id;

    -- UPDATE o INSERT según corresponda
    IF v_count > 0 THEN
        -- Actualizar registro existente
        UPDATE doctosfrm_tramite
        SET
            documentos = v_doc_array,
            otro = p_otro,
            fecmod = CURRENT_TIMESTAMP
        WHERE tramite_id = p_tramite_id;

        RETURN QUERY SELECT TRUE, 'Documentos actualizados correctamente'::TEXT;
    ELSE
        -- Insertar nuevo registro
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

COMMENT ON FUNCTION public.sp_doctosfrm_save(INTEGER, JSON, TEXT) IS
'Guarda o actualiza los documentos asociados a un trámite. Realiza UPSERT automático.';

-- ============================================
-- SP 4/5: sp_doctosfrm_clear
-- ============================================
-- Tipo: CRUD (Update)
-- Descripción: Limpia la selección de documentos de un trámite
-- Parámetros:
--   p_tramite_id: ID del trámite a limpiar
-- Retorna: TABLE(success BOOLEAN, message TEXT)
-- Uso: SELECT * FROM sp_doctosfrm_clear(123);
-- ============================================

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
    -- Validación de parámetros obligatorios
    IF p_tramite_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_tramite_id es obligatorio'::TEXT;
        RETURN;
    END IF;

    IF p_tramite_id <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El parámetro p_tramite_id debe ser mayor a 0'::TEXT;
        RETURN;
    END IF;

    -- Verificar si existe el registro
    SELECT COUNT(*) INTO v_count
    FROM doctosfrm_tramite
    WHERE tramite_id = p_tramite_id;

    IF v_count = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe registro de documentos para el trámite especificado'::TEXT;
        RETURN;
    END IF;

    -- Limpiar la selección de documentos
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

COMMENT ON FUNCTION public.sp_doctosfrm_clear(INTEGER) IS
'Limpia todos los documentos seleccionados para un trámite, estableciendo array vacío y NULL en campo otro.';

-- ============================================
-- SP 5/5: sp_doctosfrm_delete
-- ============================================
-- Tipo: CRUD (Update)
-- Descripción: Elimina un documento específico de la selección de un trámite
-- Parámetros:
--   p_tramite_id: ID del trámite
--   p_documento: Código del documento a eliminar
-- Retorna: TABLE(success BOOLEAN, message TEXT)
-- Uso: SELECT * FROM sp_doctosfrm_delete(123, 'fotofachada');
-- ============================================

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
    -- Validación de parámetros obligatorios
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

    -- Verificar si existe el registro
    SELECT COUNT(*) INTO v_count
    FROM doctosfrm_tramite
    WHERE tramite_id = p_tramite_id;

    IF v_count = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe registro de documentos para el trámite especificado'::TEXT;
        RETURN;
    END IF;

    -- Verificar si el documento está en la lista
    SELECT p_documento = ANY(documentos) INTO v_found
    FROM doctosfrm_tramite
    WHERE tramite_id = p_tramite_id;

    IF NOT v_found THEN
        RETURN QUERY SELECT FALSE, 'El documento especificado no está en la lista del trámite'::TEXT;
        RETURN;
    END IF;

    -- Eliminar el documento del array
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

COMMENT ON FUNCTION public.sp_doctosfrm_delete(INTEGER, TEXT) IS
'Elimina un documento específico de la lista de documentos de un trámite. Usa array_remove para la operación.';

-- ============================================
-- FIN DE STORED PROCEDURES - DOCTOSFRM
-- ============================================
-- RESUMEN:
-- ✓ 5 Stored Procedures implementados
-- ✓ Todas las validaciones de parámetros incluidas
-- ✓ Manejo de excepciones completo
-- ✓ Comentarios y documentación
-- ✓ Uso de RETURNS TABLE en todos los SPs
-- ✓ Parámetros con prefijo p_
-- ✓ Variables con prefijo v_
-- ✓ Schema público especificado
-- ============================================
