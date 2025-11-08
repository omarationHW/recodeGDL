-- =====================================================
-- SP: sp_catalogogiros_list
-- Descripción: Listado de giros con filtros y paginación
-- Esquema: comun
-- Tabla: comun.c_giros
-- Fecha: 2025-11-05
-- =====================================================

CREATE OR REPLACE FUNCTION comun.sp_catalogogiros_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 10,
    p_codigo TEXT DEFAULT NULL,
    p_descripcion TEXT DEFAULT NULL,
    p_clasificacion VARCHAR(1) DEFAULT NULL,
    p_tipo VARCHAR(1) DEFAULT NULL,
    p_vigente VARCHAR(1) DEFAULT NULL
)
RETURNS TABLE (
    id_giro INTEGER,
    cod_giro INTEGER,
    cod_anun VARCHAR(5),
    descripcion VARCHAR(96),
    caracteristicas VARCHAR(130),
    clasificacion VARCHAR(1),
    tipo VARCHAR(1),
    reglamentada VARCHAR(1),
    vigente VARCHAR(1),
    ctaaplic INTEGER,
    ctaaplic_rez INTEGER,
    total_count BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    RETURN QUERY
    WITH filtered_giros AS (
        SELECT
            g.id_giro,
            g.cod_giro,
            g.cod_anun,
            g.descripcion,
            g.caracteristicas,
            g.clasificacion,
            g.tipo,
            g.reglamentada,
            g.vigente,
            g.ctaaplic,
            g.ctaaplic_rez,
            COUNT(*) OVER() as total_count
        FROM comun.c_giros g
        WHERE 1=1
            AND (p_codigo IS NULL OR g.cod_giro::TEXT ILIKE '%' || p_codigo || '%')
            AND (p_descripcion IS NULL OR g.descripcion ILIKE '%' || p_descripcion || '%')
            AND (p_clasificacion IS NULL OR g.clasificacion = p_clasificacion)
            AND (p_tipo IS NULL OR g.tipo = p_tipo)
            AND (p_vigente IS NULL OR g.vigente = p_vigente)
        ORDER BY g.descripcion ASC
        LIMIT p_page_size
        OFFSET v_offset
    )
    SELECT
        fg.id_giro,
        fg.cod_giro,
        fg.cod_anun,
        fg.descripcion,
        fg.caracteristicas,
        fg.clasificacion,
        fg.tipo,
        fg.reglamentada,
        fg.vigente,
        fg.ctaaplic,
        fg.ctaaplic_rez,
        fg.total_count
    FROM filtered_giros fg;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION comun.sp_catalogogiros_list IS 'Lista giros con filtros múltiples y paginación';
