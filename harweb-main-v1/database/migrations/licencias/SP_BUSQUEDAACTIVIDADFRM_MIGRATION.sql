-- ============================================
-- MIGRACIÓN DE STORED PROCEDURES - BUSQUEDAACTIVIDADFRM
-- Base de datos: padron_licencias
-- Esquema: informix
-- Generado: 2025-09-22
-- ============================================

\c padron_licencias;
SET search_path TO informix;

-- ============================================
-- SP 1/1: buscar_actividades
-- Descripción: Busca actividades en c_giros filtrando por cod_giro (SCIAN) y descripción
-- ============================================

CREATE OR REPLACE FUNCTION informix.buscar_actividades(
    p_scian INTEGER,
    p_descripcion TEXT DEFAULT ''
)
RETURNS TABLE (
    id_giro INTEGER,
    cod_giro INTEGER,
    descripcion TEXT,
    vigente CHAR(1),
    axo INTEGER,
    costo NUMERIC,
    refrendo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT cg.id_giro, cg.cod_giro, cg.descripcion, cg.vigente,
           cvl.axo, cvl.costo, cvl.refrendo
    FROM informix.c_giros cg
    LEFT JOIN informix.c_valoreslic cvl ON cvl.id_giro = cg.id_giro AND cvl.axo = EXTRACT(YEAR FROM CURRENT_DATE)
    WHERE cg.id_giro >= 5000
      AND cg.vigente = 'V'
      AND cg.id_giro <> cg.cod_giro
      AND cg.cod_giro = p_scian
      AND (
        p_descripcion IS NULL OR p_descripcion = '' OR
        cg.descripcion ILIKE '%' || p_descripcion || '%'
      )
    ORDER BY cg.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMENTARIOS DE USO
-- ============================================
-- 1. Buscar por código SCIAN: SELECT * FROM informix.buscar_actividades(462112, '');
-- 2. Buscar con descripción: SELECT * FROM informix.buscar_actividades(462112, 'comercio');