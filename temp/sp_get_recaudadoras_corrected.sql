-- ============================================
-- STORED PROCEDURE CORREGIDO
-- SP: sp_get_recaudadoras
-- Base: mercados
-- Descripción: Obtiene el catálogo de recaudadoras desde la tabla
-- Fecha: 2025-12-04
-- Corrección: Eliminados datos hardcoded, ahora consulta public.ta_12_recaudadoras
-- ============================================

DROP FUNCTION IF EXISTS public.sp_get_recaudadoras();

CREATE OR REPLACE FUNCTION public.sp_get_recaudadoras()
RETURNS TABLE(
    id_rec INTEGER,
    recaudadora VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_rec::INTEGER,
        r.recaudadora::VARCHAR
    FROM public.ta_12_recaudadoras r
    ORDER BY r.id_rec;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_get_recaudadoras() IS
'Obtiene el catálogo de recaudadoras desde la tabla public.ta_12_recaudadoras';

-- ============================================
-- TEST
-- ============================================
-- SELECT * FROM sp_get_recaudadoras();
