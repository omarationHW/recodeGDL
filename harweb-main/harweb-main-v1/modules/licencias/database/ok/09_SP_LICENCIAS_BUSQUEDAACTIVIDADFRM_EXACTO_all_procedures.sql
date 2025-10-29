-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: BUSQUEDAACTIVIDADFRM (EXACTO del archivo original)
-- Archivo: 09_SP_LICENCIAS_BUSQUEDAACTIVIDADFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: buscar_actividades
-- Tipo: Catalog
-- Descripción: Busca actividades en c_giros filtrando por cod_giro (SCIAN) y descripción, mostrando solo vigentes y excluyendo id_giro = cod_giro. Incluye costo y refrendo del año actual.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_actividades(
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
    FROM c_giros cg
    LEFT JOIN c_valoreslic cvl ON cvl.id_giro = cg.id_giro AND cvl.axo = EXTRACT(YEAR FROM CURRENT_DATE)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: BUSQUEDAACTIVIDADFRM (EXACTO del archivo original)
-- Archivo: 09_SP_LICENCIAS_BUSQUEDAACTIVIDADFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

