-- =====================================================
-- SP OPTIMIZADO PARA ESTADÍSTICAS DE LICENCIAS
-- =====================================================
-- Una sola consulta que retorna todas las stats
-- =====================================================

DROP FUNCTION IF EXISTS public.licenciasvigentesfrm_sp_stats();

CREATE OR REPLACE FUNCTION public.licenciasvigentesfrm_sp_stats()
RETURNS TABLE(
    total_licencias bigint,
    total_vigentes bigint,
    total_suspendidas bigint,
    total_temporales bigint,
    total_canceladas bigint,
    total_bajas bigint
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*) as total_licencias,
        COUNT(*) FILTER (WHERE l.vigente = 'V') as total_vigentes,
        COUNT(*) FILTER (WHERE l.vigente = 'S') as total_suspendidas,
        COUNT(*) FILTER (WHERE l.vigente = 'T') as total_temporales,
        COUNT(*) FILTER (WHERE l.vigente = 'C') as total_canceladas,
        COUNT(*) FILTER (WHERE l.vigente = 'B') as total_bajas
    FROM comun.licencias l
    WHERE l.licencia > 0;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.licenciasvigentesfrm_sp_stats IS
'SP optimizado para obtener estadísticas de licencias en una sola consulta usando COUNT FILTER';
