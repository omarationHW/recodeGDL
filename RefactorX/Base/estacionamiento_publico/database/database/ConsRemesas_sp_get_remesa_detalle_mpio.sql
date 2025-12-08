-- =============================================================================
-- STORED PROCEDURE: sp_get_remesa_detalle_mpio
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: ConsRemesas / ConsRemesasPublicos.vue
-- Descripcion: Obtiene detalle de remesa desde ta14_datos_edo por patron de num_remesa
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_get_remesa_detalle_mpio(varchar);

CREATE OR REPLACE FUNCTION public.sp_get_remesa_detalle_mpio(remesa_param VARCHAR)
RETURNS TABLE(
    placa varchar,
    axo integer,
    folio numeric,
    fechapago date,
    importe numeric
) AS $func$
DECLARE
    v_patron VARCHAR;
BEGIN
    -- Construir patrón de búsqueda: 'r' + número de remesa
    v_patron := '%r' || TRIM(remesa_param) || '%';

    RETURN QUERY
    SELECT
        TRIM(t.placa)::varchar,
        EXTRACT(YEAR FROM t.fechaalta)::integer AS axo,
        t.folio,
        t.fechapago,
        t.importe
    FROM public.ta14_datos_edo t
    WHERE t.remesa LIKE v_patron
    ORDER BY t.fechapago DESC NULLS LAST;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
