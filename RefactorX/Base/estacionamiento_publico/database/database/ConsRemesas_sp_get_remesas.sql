-- =============================================================================
-- STORED PROCEDURE: sp_get_remesas
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: ConsRemesas / ConsRemesasPublicos.vue
-- Descripcion: Obtiene lista de remesas filtradas por tipo (A, B, C, D)
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_get_remesas(varchar);

CREATE OR REPLACE FUNCTION public.sp_get_remesas(tipo_param VARCHAR)
RETURNS TABLE(
    control integer,
    tipo varchar,
    fecha_inicio date,
    fecha_fin date,
    fecha_hoy date,
    num_remesa integer,
    cant_reg integer
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        b.control,
        TRIM(b.tipo)::varchar,
        b.fecha_inicio,
        b.fecha_fin,
        b.fecha_hoy,
        b.num_remesa,
        b.cant_reg
    FROM public.ta14_bitacora b
    WHERE TRIM(b.tipo) = UPPER(TRIM(tipo_param))
    ORDER BY b.num_remesa DESC;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
