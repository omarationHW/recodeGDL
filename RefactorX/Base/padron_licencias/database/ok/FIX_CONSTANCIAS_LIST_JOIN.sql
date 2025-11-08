-- =============================================
-- FIX: Corrección de duplicados en constancias_list
-- Problema: LEFT JOIN con comun.licencias causa duplicados
-- Solución: Usar subconsulta con DISTINCT ON
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

    -- Retornar datos paginados con JOIN corregido
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
        -- Subconsulta para traer solo UNA licencia por id_licencia
        (
            SELECT l2.licencia
            FROM comun.licencias l2
            WHERE l2.id_licencia = c.id_licencia
            ORDER BY l2.licencia DESC
            LIMIT 1
        ) as licencia,
        (
            SELECT TRIM(l2.propietario)::VARCHAR
            FROM comun.licencias l2
            WHERE l2.id_licencia = c.id_licencia
            ORDER BY l2.licencia DESC
            LIMIT 1
        ) as propietario,
        v_total::INTEGER
    FROM public.constancias c
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

COMMENT ON FUNCTION public.constancias_list IS 'Lista constancias con filtros y paginación - FIX: Evita duplicados en JOIN - Esquema public - Base padron_licencias';

-- =============================================
-- VERIFICACIÓN
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE '✓ SP constancias_list actualizado';
    RAISE NOTICE '✓ FIX: Subconsultas para evitar duplicados';
    RAISE NOTICE '========================================';
END $$;

-- =============================================
-- TEST
-- =============================================

-- Probar con el caso que causaba duplicados (año 2025, folio 8079)
SELECT
    'TEST: Constancia 2025-8079' as descripcion,
    COUNT(*) as filas_retornadas,
    CASE
        WHEN COUNT(*) = 1 THEN '✓ OK - Sin duplicados'
        ELSE '✗ ERROR - Hay ' || COUNT(*) || ' filas'
    END as resultado
FROM public.constancias_list(2025, 8079, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- =============================================
-- FIN DEL SCRIPT
-- =============================================
