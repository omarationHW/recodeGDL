-- =============================================================================
-- STORED PROCEDURE: sp14_afolios
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: ConsGral / ConsGralPublicos.vue
-- Descripcion: Devuelve folios por placa desde ta14_datos_edo
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp14_afolios(varchar);

CREATE OR REPLACE FUNCTION public.sp14_afolios(
    parplaca VARCHAR
) RETURNS TABLE(
    tipoact varchar,
    axo integer,
    folio integer,
    fechaalta date,
    fechapago date,
    fechacancelado date,
    importe numeric,
    remesa varchar
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        TRIM(a.tipoact)::varchar,
        EXTRACT(YEAR FROM a.fechaalta)::integer AS axo,
        a.folio::integer,
        a.fechaalta,
        a.fechapago,
        a.fechacancelado,
        a.importe,
        TRIM(a.remesa)::varchar
    FROM public.ta14_datos_edo a
    WHERE TRIM(a.placa) = UPPER(TRIM(parplaca))
    ORDER BY a.fechaalta DESC;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
