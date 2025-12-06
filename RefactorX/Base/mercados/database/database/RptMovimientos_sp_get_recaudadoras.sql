-- ============================================
-- SP: sp_get_recaudadoras
-- Descripción: Obtiene el catálogo de oficinas recaudadoras
-- Esquema: public (ta_12_recaudadoras)
-- Componente: RptMovimientos.vue
-- Corregido: 2025-12-04 - Cambio de comun a public
-- ============================================

DROP FUNCTION IF EXISTS public.sp_get_recaudadoras();

CREATE OR REPLACE FUNCTION public.sp_get_recaudadoras()
RETURNS TABLE (
    id_rec INTEGER,
    recaudadora VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_rec::INTEGER,
        r.recaudadora::VARCHAR
    FROM public.ta_12_recaudadoras r
    WHERE r.vigencia = 'A'
    ORDER BY r.id_rec;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_get_recaudadoras() IS
'Obtiene el catálogo de recaudadoras desde la tabla public.ta_12_recaudadoras';

-- ============================================
-- TEST
-- ============================================
-- SELECT * FROM sp_get_recaudadoras();
