-- ============================================================================
-- DEPLOY: Stored Procedures para Giros Vigentes por Contribuyente
-- Schema: comun
-- Database: padron_licencias
-- Fecha: 2025-11-08
-- Descripción: SPs para consulta de licencias vigentes agrupadas por giro
-- ============================================================================

-- Drop functions if exist (para permitir re-deploy)
DROP FUNCTION IF EXISTS comun.sp_get_catalogo_giros();
DROP FUNCTION IF EXISTS comun.sp_get_giros_vigentes_by_giro(INTEGER, INTEGER, INTEGER, SMALLINT, DATE, DATE);

-- ============================================================================
-- FUNCTION: sp_get_catalogo_giros
-- Descripción: Obtiene el catálogo de giros para el filtro
-- Retorna: Lista de giros con clave y nombre
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_get_catalogo_giros()
RETURNS TABLE (
    clave INTEGER,
    nombre VARCHAR,
    total_licencias BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.giro::INTEGER AS clave,
        TRIM(g.descripcion)::VARCHAR AS nombre,
        COUNT(DISTINCT l.id_licencia)::BIGINT AS total_licencias
    FROM comun.liccat_giros g
    LEFT JOIN comun.licencias l ON l.id_giro = g.giro AND TRIM(l.vigente) = 'V'
    GROUP BY g.giro, g.descripcion
    HAVING COUNT(DISTINCT l.id_licencia) > 0
    ORDER BY g.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNCTION: sp_get_giros_vigentes_by_giro
-- Descripción: Obtiene licencias vigentes filtradas por giro, zona y fechas
-- Parámetros:
--   - p_page: Página actual (para paginación)
--   - p_limit: Registros por página
--   - p_giro: ID del giro (opcional)
--   - p_zona: Zona (opcional)
--   - p_fecha_inicio: Fecha inicio otorgamiento (opcional)
--   - p_fecha_fin: Fecha fin otorgamiento (opcional)
-- Retorna: Licencias vigentes con paginación
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_get_giros_vigentes_by_giro(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 25,
    p_giro INTEGER DEFAULT NULL,
    p_zona SMALLINT DEFAULT NULL,
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL
)
RETURNS TABLE (
    numero_licencia INTEGER,
    contribuyente VARCHAR,
    giro VARCHAR,
    id_giro INTEGER,
    domicilio VARCHAR,
    zona SMALLINT,
    fecha_expedicion DATE,
    fecha_vigencia DATE,
    estatus VARCHAR,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
    v_total_count BIGINT;
BEGIN
    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Contar total de registros que cumplen el filtro
    SELECT COUNT(*) INTO v_total_count
    FROM comun.licencias l
    LEFT JOIN comun.liccat_giros g ON g.giro = l.id_giro
    WHERE TRIM(l.vigente) = 'V'
      AND (p_giro IS NULL OR l.id_giro = p_giro)
      AND (p_zona IS NULL OR l.zona = p_zona)
      AND (p_fecha_inicio IS NULL OR l.fecha_otorgamiento >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR l.fecha_otorgamiento <= p_fecha_fin);

    -- Retornar resultados paginados
    RETURN QUERY
    SELECT
        l.licencia::INTEGER AS numero_licencia,
        TRIM(COALESCE(l.propietario || ' ' || l.primer_ap || ' ' || l.segundo_ap, l.propietario, 'N/A'))::VARCHAR AS contribuyente,
        TRIM(COALESCE(g.descripcion, 'Sin Giro'))::VARCHAR AS giro,
        l.id_giro::INTEGER,
        TRIM(COALESCE(l.ubicacion || ' #' || l.numext_ubic::TEXT, l.ubicacion, 'N/A'))::VARCHAR AS domicilio,
        l.zona::SMALLINT,
        l.fecha_otorgamiento::DATE AS fecha_expedicion,
        l.fecha_otorgamiento::DATE AS fecha_vigencia,
        'Vigente'::VARCHAR AS estatus,
        v_total_count::BIGINT AS total_records
    FROM comun.licencias l
    LEFT JOIN comun.liccat_giros g ON g.giro = l.id_giro
    WHERE TRIM(l.vigente) = 'V'
      AND (p_giro IS NULL OR l.id_giro = p_giro)
      AND (p_zona IS NULL OR l.zona = p_zona)
      AND (p_fecha_inicio IS NULL OR l.fecha_otorgamiento >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR l.fecha_otorgamiento <= p_fecha_fin)
    ORDER BY l.licencia DESC
    LIMIT p_limit
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Mensajes de confirmación
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '✓ comun.sp_get_catalogo_giros creado correctamente';
    RAISE NOTICE '✓ comun.sp_get_giros_vigentes_by_giro creado correctamente';
    RAISE NOTICE '✓ Instalación completada exitosamente';
END $$;

-- ============================================================================
-- COMENTARIOS Y PERMISOS
-- ============================================================================

COMMENT ON FUNCTION comun.sp_get_catalogo_giros() IS
'Obtiene el catálogo de giros con el total de licencias vigentes por cada giro';

COMMENT ON FUNCTION comun.sp_get_giros_vigentes_by_giro(INTEGER, INTEGER, INTEGER, SMALLINT, DATE, DATE) IS
'Obtiene licencias vigentes filtradas por giro, zona y fechas con paginación';

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION comun.sp_get_catalogo_giros() TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_get_catalogo_giros() TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_get_giros_vigentes_by_giro(INTEGER, INTEGER, INTEGER, SMALLINT, DATE, DATE) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_get_giros_vigentes_by_giro(INTEGER, INTEGER, INTEGER, SMALLINT, DATE, DATE) TO PUBLIC;
