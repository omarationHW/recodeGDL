-- =====================================================
-- STORED PROCEDURES - doctosfrm.vue
-- Módulo: Padrón de Licencias
-- Funcionalidad: Catálogo de Tipos de Documentos (CRUD)
-- Base de Datos: padron_licencias (192.168.6.146)
-- Esquema: comun
-- Usuario: refact
-- Fecha: 2025-11-07
-- =====================================================

-- TABLA: cat_doctos (catálogo de tipos de documentos)
-- Estructura asumida basada en el componente:
-- - cvedocto INTEGER PRIMARY KEY
-- - documento VARCHAR(30) NOT NULL
-- - feccap TIMESTAMP DEFAULT NOW()
-- - capturista VARCHAR(50)

-- =====================================================
-- SP 1: SP_DOCTOS_LIST
-- Descripción: Lista todos los tipos de documentos del catálogo
-- Autor: Sistema RefactorX
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_doctos_list();

CREATE OR REPLACE FUNCTION comun.sp_doctos_list()
RETURNS TABLE (
    cvedocto INTEGER,
    documento CHAR(30),
    feccap DATE,
    capturista CHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.cvedocto,
        d.documento,
        d.feccap,
        d.capturista
    FROM public.c_doctos d
    ORDER BY d.cvedocto;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 2: SP_DOCTOS_CREATE
-- Descripción: Crea un nuevo tipo de documento en el catálogo
-- Autor: Sistema RefactorX
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_doctos_create(INTEGER, CHAR);

CREATE OR REPLACE FUNCTION comun.sp_doctos_create(
    p_cvedocto INTEGER,
    p_documento CHAR(30)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    cvedocto INTEGER
) AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Verificar si ya existe la clave
    SELECT EXISTS(
        SELECT 1 FROM public.c_doctos WHERE c_doctos.cvedocto = p_cvedocto
    ) INTO v_exists;

    IF v_exists THEN
        RETURN QUERY SELECT
            FALSE,
            'Ya existe un documento con la clave ' || p_cvedocto::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar nuevo documento
    INSERT INTO public.c_doctos (cvedocto, documento, feccap, capturista)
    VALUES (
        p_cvedocto,
        TRIM(p_documento),
        NOW(),
        'SISTEMA'  -- O el usuario actual si está disponible
    );

    -- Retornar éxito
    RETURN QUERY SELECT
        TRUE,
        'Documento creado exitosamente',
        p_cvedocto;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 3: SP_DOCTOS_UPDATE
-- Descripción: Actualiza el nombre de un tipo de documento
-- Autor: Sistema RefactorX
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_doctos_update(INTEGER, CHAR);

CREATE OR REPLACE FUNCTION comun.sp_doctos_update(
    p_cvedocto INTEGER,
    p_documento CHAR(30)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Verificar si existe el documento
    SELECT EXISTS(
        SELECT 1 FROM public.c_doctos WHERE cvedocto = p_cvedocto
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN QUERY SELECT
            FALSE,
            'No existe un documento con la clave ' || p_cvedocto::TEXT;
        RETURN;
    END IF;

    -- Actualizar el documento
    UPDATE public.c_doctos
    SET
        documento = TRIM(p_documento),
        feccap = NOW()
    WHERE cvedocto = p_cvedocto;

    -- Retornar éxito
    RETURN QUERY SELECT
        TRUE,
        'Documento actualizado exitosamente';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP 4: SP_DOCTOS_DELETE
-- Descripción: Elimina un tipo de documento del catálogo
-- Autor: Sistema RefactorX
-- =====================================================

DROP FUNCTION IF EXISTS comun.sp_doctos_delete(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_doctos_delete(
    p_cvedocto INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists BOOLEAN;
    v_in_use BOOLEAN;
BEGIN
    -- Verificar si existe el documento
    SELECT EXISTS(
        SELECT 1 FROM public.c_doctos WHERE cvedocto = p_cvedocto
    ) INTO v_exists;

    IF NOT v_exists THEN
        RETURN QUERY SELECT
            FALSE,
            'No existe un documento con la clave ' || p_cvedocto::TEXT;
        RETURN;
    END IF;

    -- Opcional: Verificar si está en uso (descomentar si existe tabla de relación)
    -- SELECT EXISTS(
    --     SELECT 1 FROM comun.tramite_documentos WHERE cvedocto = p_cvedocto
    -- ) INTO v_in_use;
    --
    -- IF v_in_use THEN
    --     RETURN QUERY SELECT
    --         FALSE,
    --         'No se puede eliminar: el documento está siendo utilizado en trámites';
    --     RETURN;
    -- END IF;

    -- Eliminar el documento
    DELETE FROM public.c_doctos
    WHERE cvedocto = p_cvedocto;

    -- Retornar éxito
    RETURN QUERY SELECT
        TRUE,
        'Documento eliminado exitosamente';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS Y PERMISOS
-- =====================================================

COMMENT ON FUNCTION comun.sp_doctos_list() IS
'Lista todos los tipos de documentos del catálogo ordenados por clave';

COMMENT ON FUNCTION comun.sp_doctos_create(INTEGER, CHAR) IS
'Crea un nuevo tipo de documento en el catálogo. Valida que no exista la clave.';

COMMENT ON FUNCTION comun.sp_doctos_update(INTEGER, CHAR) IS
'Actualiza el nombre de un tipo de documento existente en el catálogo.';

COMMENT ON FUNCTION comun.sp_doctos_delete(INTEGER) IS
'Elimina un tipo de documento del catálogo. Valida que exista antes de eliminar.';

-- Otorgar permisos de ejecución
GRANT EXECUTE ON FUNCTION comun.sp_doctos_list() TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_doctos_list() TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_doctos_create(INTEGER, CHAR) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_doctos_create(INTEGER, CHAR) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_doctos_update(INTEGER, CHAR) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_doctos_update(INTEGER, CHAR) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_doctos_delete(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_doctos_delete(INTEGER) TO PUBLIC;

-- =====================================================
-- NOTAS DE IMPLEMENTACIÓN
-- =====================================================

/*
TABLA PRINCIPAL:
- public.c_doctos (catálogo de tipos de documentos)

ESTRUCTURA:
- cvedocto INTEGER PRIMARY KEY - Clave única del tipo de documento
- documento VARCHAR(30) NOT NULL - Nombre descriptivo del tipo
- feccap TIMESTAMP DEFAULT NOW() - Fecha de captura/modificación
- capturista VARCHAR(50) - Usuario que creó/modificó el registro

VALIDACIONES:
- No permitir claves duplicadas en CREATE
- Validar existencia antes de UPDATE y DELETE
- Trim de espacios en el nombre del documento
- Actualizar feccap en cada modificación

CASOS DE USO:
- Mantener catálogo de tipos de documentos requeridos para trámites
- Gestión CRUD completa desde interfaz Vue
- Soporte para búsqueda y filtrado en el frontend
*/

-- =====================================================
-- EJEMPLO DE USO
-- =====================================================

/*
-- Listar todos los documentos
SELECT * FROM comun.sp_doctos_list();

-- Crear un nuevo tipo de documento
SELECT * FROM comun.sp_doctos_create(
    1,  -- cvedocto
    'Acta de Nacimiento'  -- documento
);

-- Actualizar un tipo de documento
SELECT * FROM comun.sp_doctos_update(
    1,  -- cvedocto
    'Acta de Nacimiento Original'  -- nuevo nombre
);

-- Eliminar un tipo de documento
SELECT * FROM comun.sp_doctos_delete(1);
*/
