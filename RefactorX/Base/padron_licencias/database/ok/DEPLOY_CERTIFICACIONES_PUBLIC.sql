-- =============================================
-- DEPLOYMENT: Stored Procedures para Gestión de Certificaciones
-- Módulo: Padron Licencias - certificacionesfrm.vue
-- Esquema: public
-- Database: padron_licencias
-- Fecha: 2025-11-05
-- Autor: Sistema RefactorX
-- =============================================
-- DESCRIPCIÓN:
-- CRUD completo para gestión de certificaciones
-- Incluye: listar, crear, actualizar, eliminar, estadísticas
-- FIX: LATERAL JOIN para evitar duplicados desde el inicio
-- =============================================

-- =============================================
-- 1. certificaciones_list
-- Búsqueda de certificaciones con filtros múltiples y paginación
-- =============================================

DROP FUNCTION IF EXISTS public.certificaciones_list CASCADE;

CREATE OR REPLACE FUNCTION public.certificaciones_list(
    p_axo INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_tipo VARCHAR DEFAULT NULL,
    p_vigente VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    partidapago VARCHAR,
    observacion VARCHAR,
    vigente VARCHAR,
    feccap DATE,
    capturista VARCHAR,
    tipo VARCHAR,
    -- Datos relacionados de la licencia
    licencia INTEGER,
    propietario VARCHAR,
    total_records INTEGER
) AS $$
DECLARE
    v_offset INTEGER;
    v_total INTEGER;
    v_tipo VARCHAR;
    v_vigente VARCHAR;
BEGIN
    -- Convertir cadenas vacías a NULL
    v_tipo := NULLIF(TRIM(p_tipo), '');
    v_vigente := NULLIF(TRIM(p_vigente), '');

    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Contar total de registros (sin JOIN para evitar duplicados)
    SELECT COUNT(*) INTO v_total
    FROM public.certificaciones c
    WHERE
        (p_axo IS NULL OR c.axo = p_axo)
        AND (p_folio IS NULL OR c.folio = p_folio)
        AND (p_id_licencia IS NULL OR c.id_licencia = p_id_licencia)
        AND (v_tipo IS NULL OR c.tipo = v_tipo)
        AND (v_vigente IS NULL OR c.vigente = v_vigente)
        AND (p_fecha_desde IS NULL OR c.feccap >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR c.feccap <= p_fecha_hasta);

    -- Retornar datos paginados con LATERAL JOIN (trae solo 1 licencia por certificación)
    RETURN QUERY
    SELECT
        c.axo,
        c.folio,
        c.id_licencia,
        TRIM(c.partidapago)::VARCHAR AS partidapago,
        TRIM(c.observacion)::VARCHAR AS observacion,
        TRIM(c.vigente)::VARCHAR AS vigente,
        c.feccap,
        TRIM(c.capturista)::VARCHAR AS capturista,
        TRIM(c.tipo)::VARCHAR AS tipo,
        -- Datos de la licencia (LATERAL JOIN evita duplicados)
        l.licencia,
        TRIM(l.propietario)::VARCHAR AS propietario,
        v_total::INTEGER
    FROM public.certificaciones c
    LEFT JOIN LATERAL (
        SELECT l2.licencia, l2.propietario
        FROM comun.licencias l2
        WHERE l2.id_licencia = c.id_licencia
        ORDER BY l2.licencia DESC
        LIMIT 1
    ) l ON true
    WHERE
        (p_axo IS NULL OR c.axo = p_axo)
        AND (p_folio IS NULL OR c.folio = p_folio)
        AND (p_id_licencia IS NULL OR c.id_licencia = p_id_licencia)
        AND (v_tipo IS NULL OR c.tipo = v_tipo)
        AND (v_vigente IS NULL OR c.vigente = v_vigente)
        AND (p_fecha_desde IS NULL OR c.feccap >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR c.feccap <= p_fecha_hasta)
    ORDER BY c.axo DESC, c.folio DESC
    LIMIT p_limit
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.certificaciones_list IS 'Lista certificaciones con filtros y paginación - LATERAL JOIN evita duplicados - Esquema public - Base padron_licencias';

-- =============================================
-- 2. certificaciones_create
-- Crear nueva certificación
-- =============================================

DROP FUNCTION IF EXISTS public.certificaciones_create CASCADE;

CREATE OR REPLACE FUNCTION public.certificaciones_create(
    p_axo INTEGER,
    p_folio INTEGER,
    p_id_licencia INTEGER,
    p_partidapago VARCHAR,
    p_observacion VARCHAR,
    p_tipo VARCHAR,
    p_capturista VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR,
    axo INTEGER,
    folio INTEGER
) AS $$
DECLARE
    v_existe BOOLEAN;
BEGIN
    -- Verificar si ya existe la certificación (axo + folio)
    SELECT EXISTS(
        SELECT 1 FROM public.certificaciones
        WHERE axo = p_axo AND folio = p_folio
    ) INTO v_existe;

    IF v_existe THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una certificación con ese año y folio'::VARCHAR, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar certificación
    INSERT INTO public.certificaciones (
        axo,
        folio,
        id_licencia,
        partidapago,
        observacion,
        vigente,
        feccap,
        capturista,
        tipo
    ) VALUES (
        p_axo,
        p_folio,
        p_id_licencia,
        p_partidapago,
        p_observacion,
        'V', -- Vigente por defecto
        CURRENT_DATE,
        p_capturista,
        p_tipo
    );

    RETURN QUERY SELECT TRUE, 'Certificación creada exitosamente'::VARCHAR, p_axo, p_folio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.certificaciones_create IS 'Crear nueva certificación - Esquema public - Base padron_licencias';

-- =============================================
-- 3. certificaciones_update
-- Actualizar certificación existente
-- =============================================

DROP FUNCTION IF EXISTS public.certificaciones_update CASCADE;

CREATE OR REPLACE FUNCTION public.certificaciones_update(
    p_axo INTEGER,
    p_folio INTEGER,
    p_id_licencia INTEGER,
    p_partidapago VARCHAR,
    p_observacion VARCHAR,
    p_tipo VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_existe BOOLEAN;
BEGIN
    -- Verificar si existe la certificación
    SELECT EXISTS(
        SELECT 1 FROM public.certificaciones
        WHERE axo = p_axo AND folio = p_folio
    ) INTO v_existe;

    IF NOT v_existe THEN
        RETURN QUERY SELECT FALSE, 'No existe la certificación especificada'::VARCHAR;
        RETURN;
    END IF;

    -- Actualizar certificación
    UPDATE public.certificaciones SET
        id_licencia = p_id_licencia,
        partidapago = p_partidapago,
        observacion = p_observacion,
        tipo = p_tipo
    WHERE axo = p_axo AND folio = p_folio;

    RETURN QUERY SELECT TRUE, 'Certificación actualizada exitosamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.certificaciones_update IS 'Actualizar certificación existente - Esquema public - Base padron_licencias';

-- =============================================
-- 4. certificaciones_delete
-- Cancelar certificación (soft delete)
-- =============================================

DROP FUNCTION IF EXISTS public.certificaciones_delete CASCADE;

CREATE OR REPLACE FUNCTION public.certificaciones_delete(
    p_axo INTEGER,
    p_folio INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_existe BOOLEAN;
BEGIN
    -- Verificar si existe la certificación
    SELECT EXISTS(
        SELECT 1 FROM public.certificaciones
        WHERE axo = p_axo AND folio = p_folio
    ) INTO v_existe;

    IF NOT v_existe THEN
        RETURN QUERY SELECT FALSE, 'No existe la certificación especificada'::VARCHAR;
        RETURN;
    END IF;

    -- Cancelar certificación (soft delete)
    UPDATE public.certificaciones SET
        vigente = 'C' -- C = Cancelado
    WHERE axo = p_axo AND folio = p_folio;

    RETURN QUERY SELECT TRUE, 'Certificación cancelada exitosamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.certificaciones_delete IS 'Cancelar certificación (soft delete) - Esquema public - Base padron_licencias';

-- =============================================
-- 5. certificaciones_estadisticas
-- Estadísticas de certificaciones por vigencia y tipo
-- =============================================

DROP FUNCTION IF EXISTS public.certificaciones_estadisticas();

CREATE OR REPLACE FUNCTION public.certificaciones_estadisticas()
RETURNS TABLE (
    categoria VARCHAR,
    descripcion VARCHAR,
    total INTEGER,
    porcentaje NUMERIC
) AS $$
DECLARE
    v_total_general INTEGER;
BEGIN
    -- Obtener total general
    SELECT COUNT(*) INTO v_total_general FROM public.certificaciones;

    IF v_total_general = 0 THEN
        v_total_general := 1; -- Evitar división por cero
    END IF;

    -- Retornar estadísticas por vigencia y tipo
    RETURN QUERY
    -- Estadísticas por vigencia
    SELECT
        'Vigencia'::VARCHAR AS categoria,
        CASE TRIM(c.vigente)
            WHEN 'V' THEN 'Vigente'::VARCHAR
            WHEN 'C' THEN 'Cancelado'::VARCHAR
            ELSE 'Otro'::VARCHAR
        END AS descripcion,
        COUNT(*)::INTEGER AS total,
        ROUND((COUNT(*)::NUMERIC / v_total_general::NUMERIC * 100), 2) AS porcentaje
    FROM public.certificaciones c
    GROUP BY TRIM(c.vigente)

    UNION ALL

    -- Estadísticas por tipo
    SELECT
        'Tipo'::VARCHAR AS categoria,
        CASE TRIM(c.tipo)
            WHEN 'L' THEN 'Licencia'::VARCHAR
            WHEN 'A' THEN 'Anuncio'::VARCHAR
            ELSE COALESCE(TRIM(c.tipo), 'Sin especificar')::VARCHAR
        END AS descripcion,
        COUNT(*)::INTEGER AS total,
        ROUND((COUNT(*)::NUMERIC / v_total_general::NUMERIC * 100), 2) AS porcentaje
    FROM public.certificaciones c
    GROUP BY TRIM(c.tipo)

    ORDER BY categoria, total DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.certificaciones_estadisticas IS 'Estadísticas de certificaciones por vigencia y tipo - Esquema public - Base padron_licencias';

-- =============================================
-- 6. certificaciones_get_next_folio
-- Obtener siguiente folio disponible para un año
-- =============================================

DROP FUNCTION IF EXISTS public.certificaciones_get_next_folio CASCADE;

CREATE OR REPLACE FUNCTION public.certificaciones_get_next_folio(
    p_axo INTEGER
)
RETURNS TABLE (
    next_folio INTEGER
) AS $$
DECLARE
    v_max_folio INTEGER;
BEGIN
    -- Obtener el folio máximo del año especificado
    SELECT COALESCE(MAX(folio), 0) INTO v_max_folio
    FROM public.certificaciones
    WHERE axo = p_axo;

    -- Retornar el siguiente folio
    RETURN QUERY SELECT (v_max_folio + 1)::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.certificaciones_get_next_folio IS 'Obtener siguiente folio disponible para un año - Esquema public - Base padron_licencias';

-- =============================================
-- VERIFICACIÓN DE INSTALACIÓN
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Verificando instalación de Stored Procedures...';
    RAISE NOTICE '================================================';

    -- Verificar certificaciones_list
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'certificaciones_list'
    ) THEN
        RAISE NOTICE '✓ public.certificaciones_list creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.certificaciones_list no se creó';
    END IF;

    -- Verificar certificaciones_create
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'certificaciones_create'
    ) THEN
        RAISE NOTICE '✓ public.certificaciones_create creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.certificaciones_create no se creó';
    END IF;

    -- Verificar certificaciones_update
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'certificaciones_update'
    ) THEN
        RAISE NOTICE '✓ public.certificaciones_update creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.certificaciones_update no se creó';
    END IF;

    -- Verificar certificaciones_delete
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'certificaciones_delete'
    ) THEN
        RAISE NOTICE '✓ public.certificaciones_delete creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.certificaciones_delete no se creó';
    END IF;

    -- Verificar certificaciones_estadisticas
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'certificaciones_estadisticas'
    ) THEN
        RAISE NOTICE '✓ public.certificaciones_estadisticas creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.certificaciones_estadisticas no se creó';
    END IF;

    -- Verificar certificaciones_get_next_folio
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'certificaciones_get_next_folio'
    ) THEN
        RAISE NOTICE '✓ public.certificaciones_get_next_folio creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.certificaciones_get_next_folio no se creó';
    END IF;

    RAISE NOTICE '================================================';
    RAISE NOTICE '✓ Instalación completada exitosamente';
    RAISE NOTICE '✓ Base de datos: padron_licencias';
    RAISE NOTICE '✓ Esquema: public';
    RAISE NOTICE '✓ 6 Stored Procedures creados';
    RAISE NOTICE '================================================';
END $$;

-- =============================================
-- EJEMPLOS DE USO
-- =============================================

-- Ejemplo 1: Listar todas las certificaciones vigentes
-- SELECT * FROM public.certificaciones_list(NULL, NULL, NULL, NULL, 'V', NULL, NULL, 1, 20);

-- Ejemplo 2: Buscar por ID de licencia
-- SELECT * FROM public.certificaciones_list(NULL, NULL, 309379, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 3: Buscar por tipo (L = Licencia, A = Anuncio)
-- SELECT * FROM public.certificaciones_list(NULL, NULL, NULL, 'L', NULL, NULL, NULL, 1, 20);

-- Ejemplo 4: Crear nueva certificación
-- SELECT * FROM public.certificaciones_create(2025, 20001, 123456, 'R-20106-12345', 'POR EXTRAVIO', 'L', 'usuario');

-- Ejemplo 5: Actualizar certificación
-- SELECT * FROM public.certificaciones_update(2025, 20001, 123456, 'R-20106-12345', 'POR REPOSICION', 'L');

-- Ejemplo 6: Cancelar certificación
-- SELECT * FROM public.certificaciones_delete(2025, 20001);

-- Ejemplo 7: Obtener estadísticas
-- SELECT * FROM public.certificaciones_estadisticas();

-- Ejemplo 8: Obtener siguiente folio del año 2025
-- SELECT * FROM public.certificaciones_get_next_folio(2025);

-- =============================================
-- FIN DEL SCRIPT
-- =============================================
