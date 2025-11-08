-- =====================================================
-- SP: sp_catalogogiros_estadisticas
-- Descripción: Estadísticas del catálogo de giros
-- Esquema: comun
-- Tabla: comun.c_giros
-- Fecha: 2025-11-05
-- =====================================================

CREATE OR REPLACE FUNCTION comun.sp_catalogogiros_estadisticas()
RETURNS TABLE (
    total_giros BIGINT,
    giros_vigentes BIGINT,
    giros_cancelados BIGINT,
    giros_licencias BIGINT,
    giros_anuncios BIGINT,
    giros_reglamentados BIGINT,
    clasificacion_a BIGINT,
    clasificacion_b BIGINT,
    clasificacion_c BIGINT,
    clasificacion_d BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::BIGINT as total_giros,
        COUNT(*) FILTER (WHERE vigente = 'V')::BIGINT as giros_vigentes,
        COUNT(*) FILTER (WHERE vigente = 'C')::BIGINT as giros_cancelados,
        COUNT(*) FILTER (WHERE tipo = 'L')::BIGINT as giros_licencias,
        COUNT(*) FILTER (WHERE tipo = 'A')::BIGINT as giros_anuncios,
        COUNT(*) FILTER (WHERE reglamentada = 'S')::BIGINT as giros_reglamentados,
        COUNT(*) FILTER (WHERE clasificacion = 'A')::BIGINT as clasificacion_a,
        COUNT(*) FILTER (WHERE clasificacion = 'B')::BIGINT as clasificacion_b,
        COUNT(*) FILTER (WHERE clasificacion = 'C')::BIGINT as clasificacion_c,
        COUNT(*) FILTER (WHERE clasificacion = 'D')::BIGINT as clasificacion_d
    FROM comun.c_giros;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION comun.sp_catalogogiros_estadisticas IS 'Estadísticas generales del catálogo de giros';
