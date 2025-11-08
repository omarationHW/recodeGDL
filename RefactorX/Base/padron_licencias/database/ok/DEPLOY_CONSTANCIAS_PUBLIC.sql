-- =============================================
-- DEPLOYMENT: Stored Procedures para Gestión de Constancias
-- Módulo: Padron Licencias - constanciafrm.vue
-- Esquema: public
-- Database: padron_licencias
-- Fecha: 2025-11-05
-- Autor: Sistema RefactorX
-- =============================================
-- DESCRIPCIÓN:
-- CRUD completo para gestión de constancias
-- Incluye: listar, crear, actualizar, eliminar, estadísticas
-- =============================================

-- =============================================
-- 1. constancias_list
-- Búsqueda de constancias con filtros múltiples y paginación
-- =============================================

DROP FUNCTION IF EXISTS public.constancias_list CASCADE;

CREATE OR REPLACE FUNCTION public.constancias_list(
    p_axo INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_solicita VARCHAR DEFAULT NULL,
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
    solicita VARCHAR,
    partidapago VARCHAR,
    domicilio VARCHAR,
    tipo SMALLINT,
    observacion VARCHAR,
    vigente VARCHAR,
    feccap DATE,
    capturista VARCHAR,
    -- Datos relacionados de la licencia
    licencia INTEGER,
    propietario VARCHAR,
    total_records INTEGER
) AS $$
DECLARE
    v_offset INTEGER;
    v_total INTEGER;
    v_solicita VARCHAR;
    v_vigente VARCHAR;
BEGIN
    -- Convertir cadenas vacías a NULL
    v_solicita := NULLIF(TRIM(p_solicita), '');
    v_vigente := NULLIF(TRIM(p_vigente), '');

    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Contar total de registros (sin JOIN para evitar duplicados)
    SELECT COUNT(*) INTO v_total
    FROM public.constancias c
    WHERE
        (p_axo IS NULL OR c.axo = p_axo)
        AND (p_folio IS NULL OR c.folio = p_folio)
        AND (p_id_licencia IS NULL OR c.id_licencia = p_id_licencia)
        AND (v_solicita IS NULL OR UPPER(c.solicita) LIKE '%' || UPPER(v_solicita) || '%')
        AND (v_vigente IS NULL OR c.vigente = v_vigente)
        AND (p_fecha_desde IS NULL OR c.feccap >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR c.feccap <= p_fecha_hasta);

    -- Retornar datos paginados con LATERAL JOIN (trae solo 1 licencia por constancia)
    RETURN QUERY
    SELECT
        c.axo,
        c.folio,
        c.id_licencia,
        TRIM(c.solicita)::VARCHAR AS solicita,
        TRIM(c.partidapago)::VARCHAR AS partidapago,
        TRIM(c.domicilio)::VARCHAR AS domicilio,
        c.tipo,
        TRIM(c.observacion)::VARCHAR AS observacion,
        TRIM(c.vigente)::VARCHAR AS vigente,
        c.feccap,
        TRIM(c.capturista)::VARCHAR AS capturista,
        -- Datos de la licencia (LATERAL JOIN evita duplicados)
        l.licencia,
        TRIM(l.propietario)::VARCHAR AS propietario,
        v_total::INTEGER
    FROM public.constancias c
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
        AND (v_solicita IS NULL OR UPPER(c.solicita) LIKE '%' || UPPER(v_solicita) || '%')
        AND (v_vigente IS NULL OR c.vigente = v_vigente)
        AND (p_fecha_desde IS NULL OR c.feccap >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR c.feccap <= p_fecha_hasta)
    ORDER BY c.axo DESC, c.folio DESC
    LIMIT p_limit
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_list IS 'Lista constancias con filtros y paginación - FIX: LATERAL JOIN evita duplicados - Esquema public - Base padron_licencias';

-- =============================================
-- 2. constancias_create
-- Crear nueva constancia
-- =============================================

DROP FUNCTION IF EXISTS public.constancias_create CASCADE;

CREATE OR REPLACE FUNCTION public.constancias_create(
    p_axo INTEGER,
    p_folio INTEGER,
    p_id_licencia INTEGER,
    p_solicita VARCHAR,
    p_partidapago VARCHAR,
    p_domicilio VARCHAR,
    p_tipo SMALLINT,
    p_observacion VARCHAR,
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
    -- Verificar si ya existe la constancia (axo + folio)
    SELECT EXISTS(
        SELECT 1 FROM public.constancias
        WHERE axo = p_axo AND folio = p_folio
    ) INTO v_existe;

    IF v_existe THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una constancia con ese año y folio'::VARCHAR, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar constancia
    INSERT INTO public.constancias (
        axo,
        folio,
        id_licencia,
        solicita,
        partidapago,
        domicilio,
        tipo,
        observacion,
        vigente,
        feccap,
        capturista
    ) VALUES (
        p_axo,
        p_folio,
        p_id_licencia,
        p_solicita,
        p_partidapago,
        p_domicilio,
        p_tipo,
        p_observacion,
        'V', -- Vigente por defecto
        CURRENT_DATE,
        p_capturista
    );

    RETURN QUERY SELECT TRUE, 'Constancia creada exitosamente'::VARCHAR, p_axo, p_folio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_create IS 'Crear nueva constancia - Esquema public - Base padron_licencias';

-- =============================================
-- 3. constancias_update
-- Actualizar constancia existente
-- =============================================

DROP FUNCTION IF EXISTS public.constancias_update CASCADE;

CREATE OR REPLACE FUNCTION public.constancias_update(
    p_axo INTEGER,
    p_folio INTEGER,
    p_id_licencia INTEGER,
    p_solicita VARCHAR,
    p_partidapago VARCHAR,
    p_domicilio VARCHAR,
    p_tipo SMALLINT,
    p_observacion VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_existe BOOLEAN;
BEGIN
    -- Verificar si existe la constancia
    SELECT EXISTS(
        SELECT 1 FROM public.constancias
        WHERE axo = p_axo AND folio = p_folio
    ) INTO v_existe;

    IF NOT v_existe THEN
        RETURN QUERY SELECT FALSE, 'No existe la constancia especificada'::VARCHAR;
        RETURN;
    END IF;

    -- Actualizar constancia
    UPDATE public.constancias SET
        id_licencia = p_id_licencia,
        solicita = p_solicita,
        partidapago = p_partidapago,
        domicilio = p_domicilio,
        tipo = p_tipo,
        observacion = p_observacion
    WHERE axo = p_axo AND folio = p_folio;

    RETURN QUERY SELECT TRUE, 'Constancia actualizada exitosamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_update IS 'Actualizar constancia existente - Esquema public - Base padron_licencias';

-- =============================================
-- 4. constancias_delete
-- Cancelar constancia (soft delete)
-- =============================================

DROP FUNCTION IF EXISTS public.constancias_delete CASCADE;

CREATE OR REPLACE FUNCTION public.constancias_delete(
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
    -- Verificar si existe la constancia
    SELECT EXISTS(
        SELECT 1 FROM public.constancias
        WHERE axo = p_axo AND folio = p_folio
    ) INTO v_existe;

    IF NOT v_existe THEN
        RETURN QUERY SELECT FALSE, 'No existe la constancia especificada'::VARCHAR;
        RETURN;
    END IF;

    -- Cancelar constancia (soft delete)
    UPDATE public.constancias SET
        vigente = 'C' -- C = Cancelado
    WHERE axo = p_axo AND folio = p_folio;

    RETURN QUERY SELECT TRUE, 'Constancia cancelada exitosamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_delete IS 'Cancelar constancia (soft delete) - Esquema public - Base padron_licencias';

-- =============================================
-- 5. constancias_estadisticas
-- Estadísticas de constancias por vigencia
-- =============================================

DROP FUNCTION IF EXISTS public.constancias_estadisticas();

CREATE OR REPLACE FUNCTION public.constancias_estadisticas()
RETURNS TABLE (
    vigente VARCHAR,
    descripcion VARCHAR,
    total INTEGER,
    porcentaje NUMERIC
) AS $$
DECLARE
    v_total_general INTEGER;
BEGIN
    -- Obtener total general
    SELECT COUNT(*) INTO v_total_general FROM public.constancias;

    IF v_total_general = 0 THEN
        v_total_general := 1; -- Evitar división por cero
    END IF;

    -- Retornar estadísticas por vigencia
    RETURN QUERY
    SELECT
        TRIM(c.vigente)::VARCHAR AS vigente,
        CASE TRIM(c.vigente)
            WHEN 'V' THEN 'Vigente'::VARCHAR
            WHEN 'C' THEN 'Cancelado'::VARCHAR
            ELSE 'Otro'::VARCHAR
        END AS descripcion,
        COUNT(*)::INTEGER AS total,
        ROUND((COUNT(*)::NUMERIC / v_total_general::NUMERIC * 100), 2) AS porcentaje
    FROM public.constancias c
    GROUP BY TRIM(c.vigente)
    ORDER BY COUNT(*) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_estadisticas IS 'Estadísticas de constancias por vigencia - Esquema public - Base padron_licencias';

-- =============================================
-- 6. constancias_get_next_folio
-- Obtener siguiente folio disponible para un año
-- =============================================

DROP FUNCTION IF EXISTS public.constancias_get_next_folio CASCADE;

CREATE OR REPLACE FUNCTION public.constancias_get_next_folio(
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
    FROM public.constancias
    WHERE axo = p_axo;

    -- Retornar el siguiente folio
    RETURN QUERY SELECT (v_max_folio + 1)::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_get_next_folio IS 'Obtener siguiente folio disponible para un año - Esquema public - Base padron_licencias';

-- =============================================
-- VERIFICACIÓN DE INSTALACIÓN
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Verificando instalación de Stored Procedures...';
    RAISE NOTICE '================================================';

    -- Verificar constancias_list
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'constancias_list'
    ) THEN
        RAISE NOTICE '✓ public.constancias_list creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.constancias_list no se creó';
    END IF;

    -- Verificar constancias_create
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'constancias_create'
    ) THEN
        RAISE NOTICE '✓ public.constancias_create creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.constancias_create no se creó';
    END IF;

    -- Verificar constancias_update
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'constancias_update'
    ) THEN
        RAISE NOTICE '✓ public.constancias_update creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.constancias_update no se creó';
    END IF;

    -- Verificar constancias_delete
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'constancias_delete'
    ) THEN
        RAISE NOTICE '✓ public.constancias_delete creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.constancias_delete no se creó';
    END IF;

    -- Verificar constancias_estadisticas
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'constancias_estadisticas'
    ) THEN
        RAISE NOTICE '✓ public.constancias_estadisticas creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.constancias_estadisticas no se creó';
    END IF;

    -- Verificar constancias_get_next_folio
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname = 'constancias_get_next_folio'
    ) THEN
        RAISE NOTICE '✓ public.constancias_get_next_folio creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: public.constancias_get_next_folio no se creó';
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

-- Ejemplo 1: Listar todas las constancias vigentes
-- SELECT * FROM public.constancias_list(NULL, NULL, NULL, NULL, 'V', NULL, NULL, 1, 20);

-- Ejemplo 2: Buscar por ID de licencia
-- SELECT * FROM public.constancias_list(NULL, NULL, 205716, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 3: Buscar por solicitante
-- SELECT * FROM public.constancias_list(NULL, NULL, NULL, 'JUAN', NULL, NULL, NULL, 1, 20);

-- Ejemplo 4: Crear nueva constancia
-- SELECT * FROM public.constancias_create(2025, 1001, 123456, 'JOSE PEREZ', '12345', 'CALLE 123', 1, 'OBSERVACION', 'usuario');

-- Ejemplo 5: Actualizar constancia
-- SELECT * FROM public.constancias_update(2025, 1001, 123456, 'JOSE PEREZ UPDATED', '12345', 'CALLE 456', 1, 'NUEVA OBS');

-- Ejemplo 6: Cancelar constancia
-- SELECT * FROM public.constancias_delete(2025, 1001);

-- Ejemplo 7: Obtener estadísticas
-- SELECT * FROM public.constancias_estadisticas();

-- Ejemplo 8: Obtener siguiente folio del año 2025
-- SELECT * FROM public.constancias_get_next_folio(2025);

-- =============================================
-- FIN DEL SCRIPT
-- =============================================
