-- =============================================================================
-- STORED PROCEDURE: sp_get_public_parking_fines
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: sfrm_consultapublicos / ConsultaPublicos.vue
-- Descripcion: Obtiene las multas asociadas a un numero de licencia
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_get_public_parking_fines(integer);

CREATE OR REPLACE FUNCTION public.sp_get_public_parking_fines(
    p_numlicencia INTEGER
) RETURNS TABLE (
    id_multa integer,
    num_acta integer,
    fecha_acta date,
    giro varchar,
    total numeric
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        m.id_multa,
        m.num_acta,
        m.fecha_acta,
        TRIM(m.giro)::varchar,
        m.total
    FROM public.multas m
    WHERE m.num_licencia = p_numlicencia
    ORDER BY m.fecha_acta DESC;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
