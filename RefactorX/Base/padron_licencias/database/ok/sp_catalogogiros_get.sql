-- =====================================================
-- SP: sp_catalogogiros_get
-- Descripción: Obtiene detalle completo de un giro por ID
-- Esquema: comun
-- Tabla: comun.c_giros
-- Fecha: 2025-11-05
-- =====================================================

CREATE OR REPLACE FUNCTION comun.sp_catalogogiros_get(
    p_id_giro INTEGER
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
    ctaaplic_rez INTEGER
) AS $$
BEGIN
    RETURN QUERY
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
        g.ctaaplic_rez
    FROM comun.c_giros g
    WHERE g.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION comun.sp_catalogogiros_get IS 'Obtiene un giro por su ID';
