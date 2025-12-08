-- =============================================
-- MÓDULO: CONSTANCIAFRM - GESTIÓN DE CONSTANCIAS
-- =============================================
-- Descripción: Sistema completo para gestión de constancias de licencias
-- Autor: RefactorX - Sistema de Migración Automática
-- Fecha: 2025-11-20
-- Esquema: public
--
-- TABLA PRINCIPAL:
--   public.constancias
--     - PK Compuesta: (axo, folio)
--     - Campos: id_licencia, solicita, propietario, partidapago,
--               domicilio, tipo, vigente ('V'=Vigente, 'C'=Cancelado),
--               observacion, feccap, capturista
--
-- RELACIÓN:
--   - JOIN con comun.licencias para obtener datos del propietario
--
-- STORED PROCEDURES:
--   1. constancias_estadisticas     - Estadísticas agregadas por estado
--   2. constancias_list             - Listado con filtros y paginación
--   3. constancias_get_next_folio   - Obtener siguiente folio disponible
--   4. constancias_create           - Crear nueva constancia
--   5. constancias_update           - Actualizar constancia existente
--   6. constancias_delete           - Cancelar constancia (soft delete)
-- =============================================

-- =============================================
-- SP: constancias_estadisticas
-- =============================================
-- Descripción: Obtiene estadísticas agregadas de constancias por estado
-- Parámetros: Ninguno
-- Retorna: Estadísticas con totales, descripciones y porcentajes
-- Uso: Dashboards y reportes de gestión
-- =============================================
DROP FUNCTION IF EXISTS public.constancias_estadisticas() CASCADE;

CREATE OR REPLACE FUNCTION public.constancias_estadisticas()
RETURNS TABLE(
    vigente VARCHAR,
    total BIGINT,
    descripcion VARCHAR,
    porcentaje NUMERIC
) AS $$
DECLARE
    v_total BIGINT;
BEGIN
    -- Calcular total general de constancias
    SELECT COUNT(*) INTO v_total
    FROM public.constancias;

    -- Retornar estadísticas agrupadas por estado de vigencia
    RETURN QUERY
    SELECT
        c.vigente,
        COUNT(*)::BIGINT as total,
        CASE c.vigente
            WHEN 'V' THEN 'Vigentes'::VARCHAR
            WHEN 'C' THEN 'Canceladas'::VARCHAR
            ELSE 'Desconocido'::VARCHAR
        END as descripcion,
        ROUND((COUNT(*) * 100.0 / NULLIF(v_total, 0))::NUMERIC, 1) as porcentaje
    FROM public.constancias c
    GROUP BY c.vigente
    ORDER BY c.vigente;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_estadisticas() IS
'Obtiene estadísticas agregadas de constancias por estado de vigencia (V=Vigente, C=Cancelado). Retorna totales, descripciones y porcentajes.';

-- =============================================
-- SP: constancias_list
-- =============================================
-- Descripción: Lista constancias con filtros múltiples y paginación
-- Parámetros:
--   @p_axo           INTEGER - Filtro por año (opcional)
--   @p_folio         INTEGER - Filtro por folio (opcional)
--   @p_id_licencia   INTEGER - Filtro por ID de licencia (opcional)
--   @p_solicita      VARCHAR - Filtro por nombre solicitante (parcial, opcional)
--   @p_vigente       VARCHAR - Filtro por estado: 'V'=Vigente, 'C'=Cancelado (opcional)
--   @p_fecha_desde   DATE    - Filtro por fecha inicio (opcional)
--   @p_fecha_hasta   DATE    - Filtro por fecha fin (opcional)
--   @p_page          INTEGER - Página actual (default: 1)
--   @p_limit         INTEGER - Registros por página (default: 10)
-- Retorna: Listado de constancias con datos de licencia y total de registros
-- =============================================
DROP FUNCTION IF EXISTS public.constancias_list(INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR, DATE, DATE, INTEGER, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION public.constancias_list(
    p_axo INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_solicita VARCHAR DEFAULT NULL,
    p_vigente VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    solicita VARCHAR,
    propietario VARCHAR,
    partidapago VARCHAR,
    domicilio VARCHAR,
    tipo SMALLINT,
    vigente VARCHAR,
    observacion TEXT,
    feccap TIMESTAMP,
    capturista VARCHAR,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Retornar listado con JOIN a licencias y filtros aplicados
    RETURN QUERY
    SELECT
        c.axo,
        c.folio,
        c.id_licencia,
        c.solicita,
        COALESCE(l.propietario, 'N/A'::VARCHAR) as propietario,
        c.partidapago,
        c.domicilio,
        c.tipo,
        c.vigente,
        c.observacion,
        c.feccap,
        c.capturista,
        COUNT(*) OVER() as total_records
    FROM public.constancias c
    LEFT JOIN comun.licencias l ON c.id_licencia = l.id_licencia
    WHERE (p_axo IS NULL OR c.axo = p_axo)
      AND (p_folio IS NULL OR c.folio = p_folio)
      AND (p_id_licencia IS NULL OR c.id_licencia = p_id_licencia)
      AND (p_solicita IS NULL OR UPPER(c.solicita) LIKE '%' || UPPER(p_solicita) || '%')
      AND (p_vigente IS NULL OR c.vigente = p_vigente)
      AND (p_fecha_desde IS NULL OR c.feccap::DATE >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR c.feccap::DATE <= p_fecha_hasta)
    ORDER BY c.axo DESC, c.folio DESC
    LIMIT p_limit
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_list(INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR, DATE, DATE, INTEGER, INTEGER) IS
'Lista constancias con múltiples filtros opcionales y paginación. Incluye JOIN con licencias para obtener datos del propietario. Retorna total_records para gestión de paginación.';

-- =============================================
-- SP: constancias_get_next_folio
-- =============================================
-- Descripción: Obtiene el siguiente folio disponible para un año específico
-- Parámetros:
--   @p_axo INTEGER - Año para el cual se solicita el siguiente folio
-- Retorna: Siguiente número de folio disponible (MAX + 1)
-- Uso: Asignación automática de folios en creación de constancias
-- =============================================
DROP FUNCTION IF EXISTS public.constancias_get_next_folio(INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION public.constancias_get_next_folio(
    p_axo INTEGER
)
RETURNS TABLE(next_folio INTEGER) AS $$
BEGIN
    -- Retornar el siguiente folio disponible para el año especificado
    -- Si no hay registros, retorna 1
    RETURN QUERY
    SELECT COALESCE(MAX(folio), 0) + 1 as next_folio
    FROM public.constancias
    WHERE axo = p_axo;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_get_next_folio(INTEGER) IS
'Obtiene el siguiente folio disponible para un año específico. Si no existen registros para ese año, retorna 1.';

-- =============================================
-- SP: constancias_create
-- =============================================
-- Descripción: Crea una nueva constancia con validaciones completas
-- Parámetros:
--   @p_axo          INTEGER  - Año de la constancia (requerido)
--   @p_folio        INTEGER  - Número de folio (requerido)
--   @p_id_licencia  INTEGER  - ID de la licencia asociada (requerido)
--   @p_solicita     VARCHAR  - Nombre del solicitante (requerido)
--   @p_partidapago  VARCHAR  - Código de partida de pago (opcional)
--   @p_domicilio    VARCHAR  - Domicilio (opcional)
--   @p_tipo         SMALLINT - Tipo de constancia (opcional)
--   @p_observacion  TEXT     - Observaciones adicionales (opcional)
--   @p_capturista   VARCHAR  - Usuario que captura (default: 'sistema')
-- Retorna: success (BOOLEAN) y message (TEXT)
-- Validaciones:
--   - Campos requeridos: axo, folio, id_licencia, solicita
--   - Verificación de duplicados (PK compuesta)
--   - Normalización: solicita en UPPERCASE
--   - Estado inicial: vigente = 'V'
--   - Timestamp automático: feccap = NOW()
-- =============================================
DROP FUNCTION IF EXISTS public.constancias_create(INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, SMALLINT, TEXT, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION public.constancias_create(
    p_axo INTEGER,
    p_folio INTEGER,
    p_id_licencia INTEGER,
    p_solicita VARCHAR,
    p_partidapago VARCHAR DEFAULT NULL,
    p_domicilio VARCHAR DEFAULT NULL,
    p_tipo SMALLINT DEFAULT NULL,
    p_observacion TEXT DEFAULT NULL,
    p_capturista VARCHAR DEFAULT 'sistema'
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    -- Validación 1: Año y folio son requeridos
    IF p_axo IS NULL OR p_folio IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Año y folio son requeridos'::TEXT;
        RETURN;
    END IF;

    -- Validación 2: ID de licencia es requerido
    IF p_id_licencia IS NULL THEN
        RETURN QUERY SELECT FALSE, 'ID de licencia es requerido'::TEXT;
        RETURN;
    END IF;

    -- Validación 3: Nombre del solicitante es requerido
    IF p_solicita IS NULL OR TRIM(p_solicita) = '' THEN
        RETURN QUERY SELECT FALSE, 'El nombre del solicitante es requerido'::TEXT;
        RETURN;
    END IF;

    -- Validación 4: Verificar que no exista constancia con mismo año/folio
    IF EXISTS (SELECT 1 FROM public.constancias WHERE axo = p_axo AND folio = p_folio) THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una constancia con ese año y folio'::TEXT;
        RETURN;
    END IF;

    -- Insertar nueva constancia
    INSERT INTO public.constancias (
        axo, folio, id_licencia, solicita, partidapago,
        domicilio, tipo, vigente, observacion, feccap, capturista
    ) VALUES (
        p_axo,
        p_folio,
        p_id_licencia,
        UPPER(TRIM(p_solicita)),  -- Normalizar a UPPERCASE
        p_partidapago,
        p_domicilio,
        p_tipo,
        'V',                      -- Estado inicial: Vigente
        p_observacion,
        NOW(),                    -- Timestamp automático
        p_capturista
    );

    -- Retornar éxito
    RETURN QUERY SELECT TRUE, 'Constancia creada exitosamente'::TEXT;

EXCEPTION
    WHEN foreign_key_violation THEN
        RETURN QUERY SELECT FALSE, 'La licencia especificada no existe en el sistema'::TEXT;
    WHEN unique_violation THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una constancia con ese año y folio'::TEXT;
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al crear constancia: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_create(INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, SMALLINT, TEXT, VARCHAR) IS
'Crea nueva constancia con validaciones completas. Valida campos requeridos, verifica duplicados por PK compuesta (axo, folio), normaliza datos y establece estado inicial como Vigente.';

-- =============================================
-- SP: constancias_update
-- =============================================
-- Descripción: Actualiza una constancia existente
-- Parámetros:
--   @p_axo          INTEGER  - Año de la constancia (PK parte 1, requerido)
--   @p_folio        INTEGER  - Número de folio (PK parte 2, requerido)
--   @p_id_licencia  INTEGER  - ID de la licencia asociada (requerido)
--   @p_solicita     VARCHAR  - Nombre del solicitante (requerido)
--   @p_partidapago  VARCHAR  - Código de partida de pago (opcional)
--   @p_domicilio    VARCHAR  - Domicilio (opcional)
--   @p_tipo         SMALLINT - Tipo de constancia (opcional)
--   @p_observacion  TEXT     - Observaciones adicionales (opcional)
-- Retorna: success (BOOLEAN) y message (TEXT)
-- Validaciones:
--   - Verifica existencia de la constancia
--   - Normalización: solicita en UPPERCASE
-- Notas:
--   - No permite cambiar axo/folio (son PK)
--   - No modifica campos: vigente, feccap, capturista
-- =============================================
DROP FUNCTION IF EXISTS public.constancias_update(INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, SMALLINT, TEXT) CASCADE;

CREATE OR REPLACE FUNCTION public.constancias_update(
    p_axo INTEGER,
    p_folio INTEGER,
    p_id_licencia INTEGER,
    p_solicita VARCHAR,
    p_partidapago VARCHAR DEFAULT NULL,
    p_domicilio VARCHAR DEFAULT NULL,
    p_tipo SMALLINT DEFAULT NULL,
    p_observacion TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    -- Validación 1: Verificar que la constancia existe
    IF NOT EXISTS (SELECT 1 FROM public.constancias WHERE axo = p_axo AND folio = p_folio) THEN
        RETURN QUERY SELECT FALSE, 'Constancia no encontrada'::TEXT;
        RETURN;
    END IF;

    -- Validación 2: Nombre del solicitante es requerido
    IF p_solicita IS NULL OR TRIM(p_solicita) = '' THEN
        RETURN QUERY SELECT FALSE, 'El nombre del solicitante es requerido'::TEXT;
        RETURN;
    END IF;

    -- Validación 3: ID de licencia es requerido
    IF p_id_licencia IS NULL THEN
        RETURN QUERY SELECT FALSE, 'ID de licencia es requerido'::TEXT;
        RETURN;
    END IF;

    -- Actualizar constancia
    UPDATE public.constancias
    SET id_licencia = p_id_licencia,
        solicita = UPPER(TRIM(p_solicita)),  -- Normalizar a UPPERCASE
        partidapago = p_partidapago,
        domicilio = p_domicilio,
        tipo = p_tipo,
        observacion = p_observacion
    WHERE axo = p_axo AND folio = p_folio;

    -- Retornar éxito
    RETURN QUERY SELECT TRUE, 'Constancia actualizada exitosamente'::TEXT;

EXCEPTION
    WHEN foreign_key_violation THEN
        RETURN QUERY SELECT FALSE, 'La licencia especificada no existe en el sistema'::TEXT;
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al actualizar constancia: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_update(INTEGER, INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, SMALLINT, TEXT) IS
'Actualiza constancia existente. Valida existencia, campos requeridos y normaliza datos. No permite modificar PK (axo, folio) ni campos de auditoría (vigente, feccap, capturista).';

-- =============================================
-- SP: constancias_delete
-- =============================================
-- Descripción: Cancela una constancia (soft delete)
-- Parámetros:
--   @p_axo   INTEGER - Año de la constancia (PK parte 1, requerido)
--   @p_folio INTEGER - Número de folio (PK parte 2, requerido)
-- Retorna: success (BOOLEAN) y message (TEXT)
-- Operación: Soft Delete
--   - NO elimina físicamente el registro
--   - Cambia campo vigente de 'V' a 'C' (Cancelado)
--   - Preserva histórico para auditoría
-- Validaciones:
--   - Verifica existencia de la constancia
-- =============================================
DROP FUNCTION IF EXISTS public.constancias_delete(INTEGER, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION public.constancias_delete(
    p_axo INTEGER,
    p_folio INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    -- Validación: Verificar que la constancia existe
    IF NOT EXISTS (SELECT 1 FROM public.constancias WHERE axo = p_axo AND folio = p_folio) THEN
        RETURN QUERY SELECT FALSE, 'Constancia no encontrada'::TEXT;
        RETURN;
    END IF;

    -- Soft delete: cambiar estado de vigente a cancelado
    UPDATE public.constancias
    SET vigente = 'C'  -- C = Cancelado
    WHERE axo = p_axo AND folio = p_folio;

    -- Retornar éxito
    RETURN QUERY SELECT TRUE, 'Constancia cancelada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al cancelar constancia: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.constancias_delete(INTEGER, INTEGER) IS
'Cancela constancia mediante soft delete (vigente = ''C''). Preserva registro para auditoría. No realiza eliminación física.';

-- =============================================
-- VERIFICACIÓN DE INSTALACIÓN
-- =============================================
-- Script para verificar que todos los SPs se crearon correctamente

DO $$
DECLARE
    v_count INTEGER;
    v_sp_name TEXT;
    v_missing TEXT := '';
    sp_list TEXT[] := ARRAY[
        'constancias_estadisticas',
        'constancias_list',
        'constancias_get_next_folio',
        'constancias_create',
        'constancias_update',
        'constancias_delete'
    ];
BEGIN
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'VERIFICACIÓN DE INSTALACIÓN - CONSTANCIAFRM';
    RAISE NOTICE '=================================================';
    RAISE NOTICE '';

    -- Verificar cada stored procedure
    FOREACH v_sp_name IN ARRAY sp_list
    LOOP
        SELECT COUNT(*) INTO v_count
        FROM pg_proc p
        INNER JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname = v_sp_name;

        IF v_count > 0 THEN
            RAISE NOTICE '[✓] % - INSTALADO', v_sp_name;
        ELSE
            RAISE NOTICE '[✗] % - FALTANTE', v_sp_name;
            v_missing := v_missing || v_sp_name || ', ';
        END IF;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE '=================================================';

    IF v_missing = '' THEN
        RAISE NOTICE 'RESULTADO: ✓ TODOS LOS SPs INSTALADOS CORRECTAMENTE';
        RAISE NOTICE 'Total de Stored Procedures: %', array_length(sp_list, 1);
    ELSE
        RAISE WARNING 'RESULTADO: ✗ FALTAN SPs: %', TRIM(TRAILING ', ' FROM v_missing);
    END IF;

    RAISE NOTICE '=================================================';
    RAISE NOTICE '';
END $$;

-- =============================================
-- EJEMPLOS DE USO
-- =============================================

-- Ejemplo 1: Obtener estadísticas de constancias
-- SELECT * FROM public.constancias_estadisticas();

-- Ejemplo 2: Listar constancias vigentes con paginación
-- SELECT * FROM public.constancias_list(
--     NULL,           -- p_axo
--     NULL,           -- p_folio
--     NULL,           -- p_id_licencia
--     NULL,           -- p_solicita
--     'V',            -- p_vigente (Vigentes)
--     NULL,           -- p_fecha_desde
--     NULL,           -- p_fecha_hasta
--     1,              -- p_page
--     10              -- p_limit
-- );

-- Ejemplo 3: Obtener siguiente folio para año 2025
-- SELECT * FROM public.constancias_get_next_folio(2025);

-- Ejemplo 4: Crear nueva constancia
-- SELECT * FROM public.constancias_create(
--     2025,                                    -- p_axo
--     1,                                       -- p_folio
--     1234,                                    -- p_id_licencia
--     'JUAN PEREZ GARCIA',                    -- p_solicita
--     'PART-2025-001',                        -- p_partidapago
--     'CALLE PRINCIPAL 123, COL. CENTRO',     -- p_domicilio
--     1,                                       -- p_tipo
--     'Constancia para trámite municipal',    -- p_observacion
--     'admin'                                  -- p_capturista
-- );

-- Ejemplo 5: Actualizar constancia existente
-- SELECT * FROM public.constancias_update(
--     2025,                                    -- p_axo
--     1,                                       -- p_folio
--     1234,                                    -- p_id_licencia
--     'JUAN PEREZ GARCIA ACTUALIZADO',        -- p_solicita
--     'PART-2025-001-MOD',                    -- p_partidapago
--     'CALLE PRINCIPAL 456, COL. CENTRO',     -- p_domicilio
--     2,                                       -- p_tipo
--     'Constancia actualizada'                 -- p_observacion
-- );

-- Ejemplo 6: Cancelar constancia (soft delete)
-- SELECT * FROM public.constancias_delete(2025, 1);

-- =============================================
-- FIN DEL SCRIPT
-- =============================================
-- Total de Stored Procedures: 6
-- Módulo: constanciafrm
-- Estado: COMPLETAMENTE IMPLEMENTADO
-- Compatibilidad: API Genérica RefactorX
-- Schema: public
-- =============================================
