-- ============================================
-- STORED PROCEDURES - REGISTRO SOLICITUD
-- Componente: RegistroSolicitud
-- Schema: comun
-- Generado: 2025-11-20
-- Total SPs: 2
-- ============================================

-- ============================================
-- SP 1/2: sp_registro_solicitud
-- Tipo: CRUD
-- Descripción: Registra una nueva solicitud de trámite con validaciones completas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_registro_solicitud(
    p_tipo_tramite INTEGER,
    p_id_giro INTEGER,
    p_actividad TEXT,
    p_propietario TEXT,
    p_telefono TEXT DEFAULT NULL,
    p_email TEXT DEFAULT NULL,
    p_calle TEXT DEFAULT NULL,
    p_colonia TEXT DEFAULT NULL,
    p_cp TEXT DEFAULT NULL,
    p_numext TEXT DEFAULT NULL,
    p_numint TEXT DEFAULT NULL,
    p_letraext TEXT DEFAULT NULL,
    p_letraint TEXT DEFAULT NULL,
    p_zona INTEGER DEFAULT NULL,
    p_subzona INTEGER DEFAULT NULL,
    p_sup_const NUMERIC DEFAULT NULL,
    p_sup_autorizada NUMERIC DEFAULT NULL,
    p_num_cajones INTEGER DEFAULT NULL,
    p_num_empleados INTEGER DEFAULT NULL,
    p_inversion NUMERIC DEFAULT NULL,
    p_rfc TEXT DEFAULT NULL,
    p_curp TEXT DEFAULT NULL,
    p_especificaciones TEXT DEFAULT NULL,
    p_usuario TEXT DEFAULT CURRENT_USER
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio INTEGER,
    success BOOLEAN,
    mensaje TEXT
) AS $$
DECLARE
    v_id_tramite INTEGER;
    v_folio INTEGER;
    v_giro_existe BOOLEAN;
    v_giro_vigente BOOLEAN;
BEGIN
    -- Validación 1: Datos obligatorios
    IF p_tipo_tramite IS NULL OR p_id_giro IS NULL OR p_actividad IS NULL OR p_propietario IS NULL THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::INTEGER,
            FALSE,
            'Error: Faltan datos obligatorios (tipo_tramite, id_giro, actividad, propietario)'::TEXT;
        RETURN;
    END IF;

    -- Validación 2: Tipo de trámite válido (1=LICENCIA, 2=ANUNCIO, 3=PERMISO)
    IF p_tipo_tramite NOT IN (1, 2, 3) THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::INTEGER,
            FALSE,
            'Error: Tipo de trámite no válido. Valores permitidos: 1=LICENCIA, 2=ANUNCIO, 3=PERMISO'::TEXT;
        RETURN;
    END IF;

    -- Validación 3: Giro existe
    SELECT EXISTS (
        SELECT 1 FROM comun.giros WHERE id_giro = p_id_giro
    ) INTO v_giro_existe;

    IF NOT v_giro_existe THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::INTEGER,
            FALSE,
            'Error: El giro especificado no existe'::TEXT;
        RETURN;
    END IF;

    -- Validación 4: Giro vigente
    SELECT COALESCE(vigencia, TRUE)
    INTO v_giro_vigente
    FROM comun.giros
    WHERE id_giro = p_id_giro;

    IF NOT v_giro_vigente THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::INTEGER,
            FALSE,
            'Error: El giro no está vigente'::TEXT;
        RETURN;
    END IF;

    -- Validación 5: RFC formato válido (si se proporciona)
    IF p_rfc IS NOT NULL AND LENGTH(TRIM(p_rfc)) > 0 THEN
        IF LENGTH(TRIM(p_rfc)) NOT BETWEEN 12 AND 13 THEN
            RETURN QUERY SELECT
                NULL::INTEGER,
                NULL::INTEGER,
                FALSE,
                'Error: RFC inválido. Debe tener 12 o 13 caracteres'::TEXT;
            RETURN;
        END IF;
    END IF;

    -- Validación 6: CURP formato válido (si se proporciona)
    IF p_curp IS NOT NULL AND LENGTH(TRIM(p_curp)) > 0 THEN
        IF LENGTH(TRIM(p_curp)) != 18 THEN
            RETURN QUERY SELECT
                NULL::INTEGER,
                NULL::INTEGER,
                FALSE,
                'Error: CURP inválido. Debe tener 18 caracteres'::TEXT;
            RETURN;
        END IF;
    END IF;

    -- Validación 7: Valores numéricos positivos
    IF p_sup_const IS NOT NULL AND p_sup_const < 0 THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::INTEGER,
            FALSE,
            'Error: La superficie construida no puede ser negativa'::TEXT;
        RETURN;
    END IF;

    IF p_sup_autorizada IS NOT NULL AND p_sup_autorizada < 0 THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::INTEGER,
            FALSE,
            'Error: La superficie autorizada no puede ser negativa'::TEXT;
        RETURN;
    END IF;

    IF p_num_cajones IS NOT NULL AND p_num_cajones < 0 THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::INTEGER,
            FALSE,
            'Error: El número de cajones no puede ser negativo'::TEXT;
        RETURN;
    END IF;

    IF p_num_empleados IS NOT NULL AND p_num_empleados < 0 THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::INTEGER,
            FALSE,
            'Error: El número de empleados no puede ser negativo'::TEXT;
        RETURN;
    END IF;

    IF p_inversion IS NOT NULL AND p_inversion < 0 THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::INTEGER,
            FALSE,
            'Error: La inversión no puede ser negativa'::TEXT;
        RETURN;
    END IF;

    -- Generar folio (usando secuencia si existe, sino autogenerar)
    BEGIN
        SELECT nextval('comun.tramites_folio_seq') INTO v_folio;
    EXCEPTION WHEN OTHERS THEN
        -- Si no existe la secuencia, usar max + 1
        SELECT COALESCE(MAX(folio), 0) + 1 INTO v_folio FROM comun.tramites;
    END;

    -- Insertar trámite
    BEGIN
        INSERT INTO comun.tramites (
            folio,
            tipo_tramite,
            id_giro,
            actividad,
            propietario,
            telefono_prop,
            email,
            ubicacion,
            colonia_ubic,
            cp,
            numext_ubic,
            numint_ubic,
            letraext_ubic,
            letrain_ubic,
            zona,
            subzona,
            sup_construida,
            sup_autorizada,
            num_cajones,
            num_empleados,
            inversion,
            rfc,
            curp,
            espubic,
            feccap,
            capturista,
            estatus
        ) VALUES (
            v_folio,
            p_tipo_tramite,
            p_id_giro,
            TRIM(p_actividad),
            TRIM(p_propietario),
            TRIM(p_telefono),
            TRIM(p_email),
            TRIM(p_calle),
            TRIM(p_colonia),
            TRIM(p_cp),
            TRIM(p_numext),
            TRIM(p_numint),
            TRIM(p_letraext),
            TRIM(p_letraint),
            p_zona,
            p_subzona,
            p_sup_const,
            p_sup_autorizada,
            p_num_cajones,
            p_num_empleados,
            p_inversion,
            UPPER(TRIM(p_rfc)),
            UPPER(TRIM(p_curp)),
            TRIM(p_especificaciones),
            NOW(),
            p_usuario,
            'T'
        ) RETURNING id_tramite INTO v_id_tramite;

        -- Retornar éxito
        RETURN QUERY SELECT
            v_id_tramite,
            v_folio,
            TRUE,
            'Solicitud registrada correctamente con folio: ' || v_folio::TEXT;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::INTEGER,
            FALSE,
            'Error al registrar solicitud: ' || SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- Comentario
COMMENT ON FUNCTION comun.sp_registro_solicitud(INTEGER, INTEGER, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, INTEGER, INTEGER, NUMERIC, NUMERIC, INTEGER, INTEGER, NUMERIC, TEXT, TEXT, TEXT, TEXT)
IS 'Registra una nueva solicitud de trámite con todas las validaciones de negocio. Genera folio automático y valida giro vigente.';

-- ============================================
-- SP 2/2: sp_registro_solicitud_agregar_documento
-- Tipo: CRUD
-- Descripción: Agrega un documento a una solicitud/trámite existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_registro_solicitud_agregar_documento(
    p_id_tramite INTEGER,
    p_nombre TEXT,
    p_ruta TEXT,
    p_tipo_documento VARCHAR DEFAULT 'GENERAL',
    p_usuario TEXT DEFAULT CURRENT_USER
)
RETURNS TABLE(
    id_documento INTEGER,
    success BOOLEAN,
    mensaje TEXT
) AS $$
DECLARE
    v_id_documento INTEGER;
    v_tramite_existe BOOLEAN;
    v_documento_duplicado BOOLEAN;
BEGIN
    -- Validación 1: Parámetros obligatorios
    IF p_id_tramite IS NULL OR p_nombre IS NULL OR p_ruta IS NULL THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            FALSE,
            'Error: Faltan datos obligatorios (id_tramite, nombre, ruta)'::TEXT;
        RETURN;
    END IF;

    -- Validación 2: Nombre no vacío
    IF LENGTH(TRIM(p_nombre)) = 0 THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            FALSE,
            'Error: El nombre del documento no puede estar vacío'::TEXT;
        RETURN;
    END IF;

    -- Validación 3: Ruta no vacía
    IF LENGTH(TRIM(p_ruta)) = 0 THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            FALSE,
            'Error: La ruta del documento no puede estar vacía'::TEXT;
        RETURN;
    END IF;

    -- Validación 4: Trámite existe
    SELECT EXISTS (
        SELECT 1 FROM comun.tramites WHERE id_tramite = p_id_tramite
    ) INTO v_tramite_existe;

    IF NOT v_tramite_existe THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            FALSE,
            'Error: El trámite especificado no existe'::TEXT;
        RETURN;
    END IF;

    -- Validación 5: Documento no duplicado (mismo nombre y ruta)
    SELECT EXISTS (
        SELECT 1
        FROM comun.tramitedocs
        WHERE id_tramite = p_id_tramite
          AND nombre = TRIM(p_nombre)
          AND ruta = TRIM(p_ruta)
    ) INTO v_documento_duplicado;

    IF v_documento_duplicado THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            FALSE,
            'Error: Ya existe un documento con el mismo nombre y ruta para este trámite'::TEXT;
        RETURN;
    END IF;

    -- Insertar documento
    BEGIN
        INSERT INTO comun.tramitedocs (
            id_tramite,
            nombre,
            ruta,
            tipo_documento,
            feccap,
            capturista
        ) VALUES (
            p_id_tramite,
            TRIM(p_nombre),
            TRIM(p_ruta),
            UPPER(TRIM(p_tipo_documento)),
            NOW(),
            p_usuario
        ) RETURNING id_documento INTO v_id_documento;

        -- Retornar éxito
        RETURN QUERY SELECT
            v_id_documento,
            TRUE,
            'Documento agregado correctamente'::TEXT;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            FALSE,
            'Error al agregar documento: ' || SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- Comentario
COMMENT ON FUNCTION comun.sp_registro_solicitud_agregar_documento(INTEGER, TEXT, TEXT, VARCHAR, TEXT)
IS 'Agrega un documento a un trámite existente. Valida que el trámite exista y que no se dupliquen documentos.';

-- ============================================
-- INDICES RECOMENDADOS
-- ============================================

-- Índice para búsqueda de documentos por trámite
CREATE INDEX IF NOT EXISTS idx_tramitedocs_id_tramite
ON comun.tramitedocs(id_tramite);

-- Índice para búsqueda de trámites por folio
CREATE INDEX IF NOT EXISTS idx_tramites_folio
ON comun.tramites(folio);

-- Índice para búsqueda de trámites por giro
CREATE INDEX IF NOT EXISTS idx_tramites_id_giro
ON comun.tramites(id_giro);

-- Índice para búsqueda de trámites por RFC
CREATE INDEX IF NOT EXISTS idx_tramites_rfc
ON comun.tramites(rfc) WHERE rfc IS NOT NULL;

-- Índice para búsqueda de trámites por estatus
CREATE INDEX IF NOT EXISTS idx_tramites_estatus
ON comun.tramites(estatus);

-- Índice para búsqueda de trámites por fecha
CREATE INDEX IF NOT EXISTS idx_tramites_feccap
ON comun.tramites(feccap);

-- ============================================
-- EJEMPLOS DE USO
-- ============================================

/*
-- Ejemplo 1: Registrar una nueva solicitud de licencia
SELECT * FROM comun.sp_registro_solicitud(
    p_tipo_tramite := 1,
    p_id_giro := 123,
    p_actividad := 'Restaurante',
    p_propietario := 'Juan Pérez García',
    p_telefono := '3312345678',
    p_email := 'juan.perez@example.com',
    p_calle := 'Av. Juárez',
    p_colonia := 'Centro',
    p_cp := '44100',
    p_numext := '123',
    p_numint := 'A',
    p_zona := 1,
    p_subzona := 1,
    p_sup_const := 150.50,
    p_sup_autorizada := 200.00,
    p_num_cajones := 5,
    p_num_empleados := 10,
    p_inversion := 500000.00,
    p_rfc := 'PEGJ800101ABC',
    p_curp := 'PEGJ800101HJCRNN01',
    p_especificaciones := 'Apertura de nuevo restaurante',
    p_usuario := 'admin'
);

-- Ejemplo 2: Agregar documento a solicitud
SELECT * FROM comun.sp_registro_solicitud_agregar_documento(
    p_id_tramite := 1,
    p_nombre := 'Acta Constitutiva',
    p_ruta := '/documentos/tramites/2025/acta_constitutiva_001.pdf',
    p_tipo_documento := 'LEGAL',
    p_usuario := 'admin'
);

-- Ejemplo 3: Registrar solicitud mínima (solo campos obligatorios)
SELECT * FROM comun.sp_registro_solicitud(
    p_tipo_tramite := 2,
    p_id_giro := 456,
    p_actividad := 'Anuncio Publicitario',
    p_propietario := 'María López Sánchez'
);

-- Ejemplo 4: Agregar múltiples documentos
SELECT * FROM comun.sp_registro_solicitud_agregar_documento(1, 'Identificación Oficial', '/docs/id_001.pdf', 'IDENTIFICACION');
SELECT * FROM comun.sp_registro_solicitud_agregar_documento(1, 'Comprobante de Domicilio', '/docs/comp_dom_001.pdf', 'DOMICILIO');
SELECT * FROM comun.sp_registro_solicitud_agregar_documento(1, 'RFC', '/docs/rfc_001.pdf', 'FISCAL');

-- Ejemplo 5: Validación de errores - Giro inexistente
SELECT * FROM comun.sp_registro_solicitud(
    p_tipo_tramite := 1,
    p_id_giro := 99999,
    p_actividad := 'Test',
    p_propietario := 'Test User'
);

-- Ejemplo 6: Validación de errores - RFC inválido
SELECT * FROM comun.sp_registro_solicitud(
    p_tipo_tramite := 1,
    p_id_giro := 123,
    p_actividad := 'Test',
    p_propietario := 'Test User',
    p_rfc := 'INVALID'
);

-- Ejemplo 7: Validación de errores - Documento duplicado
SELECT * FROM comun.sp_registro_solicitud_agregar_documento(1, 'Acta Constitutiva', '/documentos/tramites/2025/acta_constitutiva_001.pdf');
SELECT * FROM comun.sp_registro_solicitud_agregar_documento(1, 'Acta Constitutiva', '/documentos/tramites/2025/acta_constitutiva_001.pdf');
*/

-- ============================================
-- FIN DE ARCHIVO
-- ============================================
