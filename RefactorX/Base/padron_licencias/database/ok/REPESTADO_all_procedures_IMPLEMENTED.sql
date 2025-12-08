-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS - COMPONENTE REPESTADO
-- Módulo: Padron de Licencias
-- Componente: repestado - Reporte de estado de trámites
-- Schema: comun
-- Generado: 2025-11-20
-- Total SPs: 6
-- ============================================

-- DESCRIPCION DEL COMPONENTE:
-- El componente repestado permite consultar el estado actual de un trámite,
-- visualizar el historial de revisiones por dependencias, y obtener información
-- detallada del giro y dependencias involucradas en el proceso de revisión.

-- TABLAS PRINCIPALES:
-- - comun.tramites: Información general de trámites
-- - comun.revisiones: Revisiones realizadas a los trámites
-- - comun.seg_revision: Seguimiento detallado de cada revisión
-- - comun.c_dependencias: Catálogo de dependencias que revisan trámites
-- - comun.c_giros: Catálogo de giros comerciales

-- ============================================
-- SP 1/6: sp_repestado_get_tramite_estado
-- Descripción: Obtiene el estado completo de un trámite con información del propietario
-- Tipo: CONSULTA
-- ============================================

DROP FUNCTION IF EXISTS comun.sp_repestado_get_tramite_estado(INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_repestado_get_tramite_estado(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio INTEGER,
    id_giro INTEGER,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR(130),
    cvecuenta INTEGER,
    recaud SMALLINT,
    licencia_ref INTEGER,
    tramita_apoderado VARCHAR(1),
    propietario VARCHAR(80),
    rfc VARCHAR(13),
    curp VARCHAR(18),
    domicilio VARCHAR(50),
    numext_prop INTEGER,
    numint_prop VARCHAR(5),
    colonia_prop VARCHAR(25),
    telefono_prop VARCHAR(30),
    email VARCHAR(50),
    ubicacion VARCHAR(50),
    numext_ubic INTEGER,
    letraext_ubic VARCHAR(3),
    letraint_ubic VARCHAR(3),
    colonia_ubic VARCHAR(25),
    espubic VARCHAR(60),
    documentos TEXT,
    sup_construida DOUBLE PRECISION,
    sup_autorizada DOUBLE PRECISION,
    num_cajones SMALLINT,
    num_empleados SMALLINT,
    inversion NUMERIC,
    fecha_consejo DATE,
    id_fabricante INTEGER,
    texto_anuncio VARCHAR(50),
    medidas1 DOUBLE PRECISION,
    medidas2 DOUBLE PRECISION,
    area_anuncio DOUBLE PRECISION,
    num_caras SMALLINT,
    calificacion NUMERIC,
    usr_califica VARCHAR(10),
    estatus VARCHAR(1),
    id_licencia INTEGER,
    id_anuncio INTEGER,
    feccap DATE,
    capturista VARCHAR(10),
    numint_ubic VARCHAR(5),
    bloqueado SMALLINT,
    dictamen SMALLINT,
    tipo_tramite VARCHAR(2),
    observaciones TEXT,
    primer_ap VARCHAR(80),
    segundo_ap VARCHAR(80),
    propietarionvo VARCHAR(242)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar que el ID de trámite sea válido
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RAISE EXCEPTION 'ID de trámite inválido';
    END IF;

    -- Retornar información completa del trámite con propietario completo
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        t.id_giro,
        t.x,
        t.y,
        t.zona,
        t.subzona,
        t.actividad,
        t.cvecuenta,
        t.recaud,
        t.licencia_ref,
        t.tramita_apoderado,
        t.propietario,
        t.rfc,
        t.curp,
        t.domicilio,
        t.numext_prop,
        t.numint_prop,
        t.colonia_prop,
        t.telefono_prop,
        t.email,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.letraint_ubic,
        t.colonia_ubic,
        t.espubic,
        t.documentos,
        t.sup_construida,
        t.sup_autorizada,
        t.num_cajones,
        t.num_empleados,
        t.inversion,
        t.fecha_consejo,
        t.id_fabricante,
        t.texto_anuncio,
        t.medidas1,
        t.medidas2,
        t.area_anuncio,
        t.num_caras,
        t.calificacion,
        t.usr_califica,
        t.estatus,
        t.id_licencia,
        t.id_anuncio,
        t.feccap,
        t.capturista,
        t.numint_ubic,
        t.bloqueado,
        t.dictamen,
        t.tipo_tramite,
        t.observaciones,
        t.primer_ap,
        t.segundo_ap,
        -- Nombre completo del propietario concatenado
        TRIM(COALESCE(t.primer_ap, '') || ' ' || COALESCE(t.segundo_ap, '') || ' ' || COALESCE(t.propietario, ''))::VARCHAR(242) AS propietarionvo
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;

    -- Si no se encuentra el trámite, lanzar excepción
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Trámite con ID % no encontrado', p_id_tramite;
    END IF;
END;
$$;

COMMENT ON FUNCTION comun.sp_repestado_get_tramite_estado(INTEGER) IS
'Obtiene el estado completo de un trámite incluyendo información del propietario concatenada. Utilizado en el reporte de estado de trámites.';

-- ============================================
-- SP 2/6: sp_repestado_get_tramite_revisiones
-- Descripción: Obtiene historial completo de revisiones de un trámite
-- Tipo: CONSULTA
-- ============================================

DROP FUNCTION IF EXISTS comun.sp_repestado_get_tramite_revisiones(INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_repestado_get_tramite_revisiones(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_revision INTEGER,
    id_tramite INTEGER,
    id_dependencia INTEGER,
    feccap DATE,
    oficio VARCHAR(50),
    estatus VARCHAR(1),
    observacion TEXT,
    dependencia VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar parámetro de entrada
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RAISE EXCEPTION 'ID de trámite inválido';
    END IF;

    -- Retornar todas las revisiones del trámite ordenadas cronológicamente
    RETURN QUERY
    SELECT
        r.id_revision,
        r.id_tramite,
        r.id_dependencia,
        s.feccap,
        s.oficio,
        s.estatus,
        s.observacion,
        d.descripcion::VARCHAR(100) AS dependencia
    FROM comun.revisiones r
    INNER JOIN comun.seg_revision s ON s.id_revision = r.id_revision
    INNER JOIN comun.c_dependencias d ON d.id_dependencia = r.id_dependencia
    WHERE r.id_tramite = p_id_tramite
    ORDER BY r.id_revision ASC, s.feccap DESC;
END;
$$;

COMMENT ON FUNCTION comun.sp_repestado_get_tramite_revisiones(INTEGER) IS
'Obtiene el historial completo de revisiones de un trámite, incluyendo dependencia, fecha, oficio, estatus y observaciones. Ordenado cronológicamente.';

-- ============================================
-- SP 3/6: sp_repestado_get_revision_detalle
-- Descripción: Obtiene el detalle específico de una revisión
-- Tipo: CONSULTA
-- ============================================

DROP FUNCTION IF EXISTS comun.sp_repestado_get_revision_detalle(INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_repestado_get_revision_detalle(
    p_id_revision INTEGER
)
RETURNS TABLE(
    id_revision INTEGER,
    feccap DATE,
    oficio VARCHAR(50),
    estatus VARCHAR(1),
    observacion TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar parámetro de entrada
    IF p_id_revision IS NULL OR p_id_revision <= 0 THEN
        RAISE EXCEPTION 'ID de revisión inválido';
    END IF;

    -- Retornar detalle de la revisión específica
    RETURN QUERY
    SELECT
        s.id_revision,
        s.feccap,
        s.oficio,
        s.estatus,
        s.observacion
    FROM comun.seg_revision s
    WHERE s.id_revision = p_id_revision;

    -- Si no se encuentra la revisión, lanzar excepción
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Revisión con ID % no encontrada', p_id_revision;
    END IF;
END;
$$;

COMMENT ON FUNCTION comun.sp_repestado_get_revision_detalle(INTEGER) IS
'Obtiene el detalle completo de una revisión específica: fecha, oficio, estatus y observaciones.';

-- ============================================
-- SP 4/6: sp_repestado_get_dependencia
-- Descripción: Obtiene información de una dependencia
-- Tipo: CATALOGO
-- ============================================

DROP FUNCTION IF EXISTS comun.sp_repestado_get_dependencia(INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_repestado_get_dependencia(
    p_id_dependencia INTEGER
)
RETURNS TABLE(
    id_dependencia INTEGER,
    descripcion VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar parámetro de entrada
    IF p_id_dependencia IS NULL OR p_id_dependencia <= 0 THEN
        RAISE EXCEPTION 'ID de dependencia inválido';
    END IF;

    -- Retornar información de la dependencia
    RETURN QUERY
    SELECT
        d.id_dependencia,
        d.descripcion::VARCHAR(100)
    FROM comun.c_dependencias d
    WHERE d.id_dependencia = p_id_dependencia;

    -- Si no se encuentra la dependencia, lanzar excepción
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Dependencia con ID % no encontrada', p_id_dependencia;
    END IF;
END;
$$;

COMMENT ON FUNCTION comun.sp_repestado_get_dependencia(INTEGER) IS
'Obtiene la información de una dependencia específica del catálogo de dependencias.';

-- ============================================
-- SP 5/6: sp_repestado_get_giro
-- Descripción: Obtiene información de un giro comercial
-- Tipo: CATALOGO
-- ============================================

DROP FUNCTION IF EXISTS comun.sp_repestado_get_giro(INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_repestado_get_giro(
    p_id_giro INTEGER
)
RETURNS TABLE(
    id_giro INTEGER,
    descripcion VARCHAR(130)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar parámetro de entrada
    IF p_id_giro IS NULL OR p_id_giro <= 0 THEN
        RAISE EXCEPTION 'ID de giro inválido';
    END IF;

    -- Retornar información del giro
    RETURN QUERY
    SELECT
        g.id_giro,
        g.descripcion::VARCHAR(130)
    FROM comun.c_giros g
    WHERE g.id_giro = p_id_giro;

    -- Si no se encuentra el giro, lanzar excepción
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Giro con ID % no encontrado', p_id_giro;
    END IF;
END;
$$;

COMMENT ON FUNCTION comun.sp_repestado_get_giro(INTEGER) IS
'Obtiene la información de un giro comercial específico del catálogo de giros.';

-- ============================================
-- SP 6/6: sp_repestado_get_estado_completo
-- Descripción: Obtiene estado del trámite con todas sus revisiones en un solo resultado
-- Tipo: CONSULTA COMPUESTA
-- ============================================

DROP FUNCTION IF EXISTS comun.sp_repestado_get_estado_completo(INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_repestado_get_estado_completo(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    resultado JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tramite JSONB;
    v_revisiones JSONB;
BEGIN
    -- Validar parámetro de entrada
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RETURN QUERY
        SELECT jsonb_build_object(
            'success', false,
            'message', 'ID de trámite inválido',
            'data', NULL
        );
        RETURN;
    END IF;

    -- Obtener datos del trámite
    SELECT jsonb_build_object(
        'id_tramite', t.id_tramite,
        'folio', t.folio,
        'id_giro', t.id_giro,
        'actividad', t.actividad,
        'propietario', TRIM(COALESCE(t.primer_ap, '') || ' ' || COALESCE(t.segundo_ap, '') || ' ' || COALESCE(t.propietario, '')),
        'rfc', t.rfc,
        'curp', t.curp,
        'ubicacion', t.ubicacion,
        'numext_ubic', t.numext_ubic,
        'letraext_ubic', t.letraext_ubic,
        'numint_ubic', t.numint_ubic,
        'letraint_ubic', t.letraint_ubic,
        'colonia_ubic', t.colonia_ubic,
        'estatus', t.estatus,
        'feccap', t.feccap,
        'capturista', t.capturista,
        'tipo_tramite', t.tipo_tramite,
        'observaciones', t.observaciones
    )
    INTO v_tramite
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;

    -- Si no existe el trámite
    IF v_tramite IS NULL THEN
        RETURN QUERY
        SELECT jsonb_build_object(
            'success', false,
            'message', 'Trámite no encontrado',
            'data', NULL
        );
        RETURN;
    END IF;

    -- Obtener revisiones del trámite
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id_revision', r.id_revision,
            'id_dependencia', r.id_dependencia,
            'dependencia', d.descripcion,
            'feccap', s.feccap,
            'oficio', s.oficio,
            'estatus', s.estatus,
            'observacion', s.observacion
        ) ORDER BY r.id_revision ASC
    ), '[]'::jsonb)
    INTO v_revisiones
    FROM comun.revisiones r
    INNER JOIN comun.seg_revision s ON s.id_revision = r.id_revision
    LEFT JOIN comun.c_dependencias d ON d.id_dependencia = r.id_dependencia
    WHERE r.id_tramite = p_id_tramite;

    -- Retornar resultado consolidado
    RETURN QUERY
    SELECT jsonb_build_object(
        'success', true,
        'message', 'Estado del trámite obtenido exitosamente',
        'data', jsonb_build_object(
            'tramite', v_tramite,
            'revisiones', v_revisiones
        )
    );
END;
$$;

COMMENT ON FUNCTION comun.sp_repestado_get_estado_completo(INTEGER) IS
'Obtiene el estado completo del trámite incluyendo datos generales y todas sus revisiones en formato JSON consolidado. Útil para APIs que requieren toda la información en una sola llamada.';

-- ============================================
-- SCRIPT DE VERIFICACION
-- ============================================

DO $$
DECLARE
    v_count INTEGER;
    v_sp_name TEXT;
    v_sps TEXT[] := ARRAY[
        'sp_repestado_get_tramite_estado',
        'sp_repestado_get_tramite_revisiones',
        'sp_repestado_get_revision_detalle',
        'sp_repestado_get_dependencia',
        'sp_repestado_get_giro',
        'sp_repestado_get_estado_completo'
    ];
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'VERIFICACION DE STORED PROCEDURES - REPESTADO';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '';

    FOREACH v_sp_name IN ARRAY v_sps
    LOOP
        SELECT COUNT(*)
        INTO v_count
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = v_sp_name;

        IF v_count > 0 THEN
            RAISE NOTICE '[OK] % - Creado exitosamente', v_sp_name;
        ELSE
            RAISE NOTICE '[ERROR] % - NO encontrado', v_sp_name;
        END IF;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Total SPs esperados: %', array_length(v_sps, 1);

    SELECT COUNT(*)
    INTO v_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'comun'
    AND p.proname LIKE 'sp_repestado_%';

    RAISE NOTICE 'Total SPs encontrados: %', v_count;
    RAISE NOTICE '==============================================';
END;
$$;

-- ============================================
-- EJEMPLOS DE USO
-- ============================================

/*
-- 1. Obtener estado de un trámite
SELECT * FROM comun.sp_repestado_get_tramite_estado(12345);

-- 2. Obtener revisiones de un trámite
SELECT * FROM comun.sp_repestado_get_tramite_revisiones(12345);

-- 3. Obtener detalle de una revisión específica
SELECT * FROM comun.sp_repestado_get_revision_detalle(789);

-- 4. Obtener información de una dependencia
SELECT * FROM comun.sp_repestado_get_dependencia(5);

-- 5. Obtener información de un giro
SELECT * FROM comun.sp_repestado_get_giro(100);

-- 6. Obtener estado completo (trámite + revisiones en JSON)
SELECT * FROM comun.sp_repestado_get_estado_completo(12345);

-- 7. Ejemplo de uso desde la API genérica
SELECT resultado->>'success' as success,
       resultado->>'message' as message,
       resultado->'data'->'tramite'->>'folio' as folio,
       resultado->'data'->'tramite'->>'propietario' as propietario,
       jsonb_array_length(resultado->'data'->'revisiones') as total_revisiones
FROM comun.sp_repestado_get_estado_completo(12345);
*/

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
