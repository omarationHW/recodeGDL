-- Stored Procedure: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras.
-- Generado para formulario: PadronEnergia
-- Fecha: 2025-08-27 00:17:27
-- Corregido: 2025-12-04 - Agregado schema public

DROP FUNCTION IF EXISTS public.sp_get_recaudadoras();

CREATE OR REPLACE FUNCTION public.sp_get_recaudadoras()
RETURNS TABLE(id_rec INTEGER, recaudadora VARCHAR) AS $$
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