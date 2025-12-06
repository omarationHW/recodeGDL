-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptPadronEnergia
-- SP: sp_get_recaudadoras
-- Base: mercados
-- Esquema: public
-- Fecha: 2025-12-04
-- Corrección: Cambio de comun.ta_12_recaudadoras a public.ta_12_recaudadoras
--             (Datos sincronizados desde padron_licencias.comun)
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
