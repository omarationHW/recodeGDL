-- =============================================================================
-- STORED PROCEDURE: sp14_bfolios
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: ConsGral / ConsGralPublicos.vue
-- Descripcion: Devuelve folios por placa desde ta14_folios_histo
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp14_bfolios(varchar);

CREATE OR REPLACE FUNCTION public.sp14_bfolios(
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
        'PN'::varchar AS tipoact,
        c.axo::integer,
        c.folio::integer,
        c.fecha_folio AS fechaalta,
        c.fecha_movto AS fechapago,
        NULL::date AS fechacancelado,
        0::numeric AS importe,
        ('Banorte suc ' || COALESCE(d.sucursal::text, ''))::varchar AS remesa
    FROM public.ta14_folios_histo c
    LEFT JOIN public.ta14_fol_banorte d ON d.axo = c.axo AND d.folio = c.folio
    WHERE TRIM(c.placa) = UPPER(TRIM(parplaca))
    ORDER BY c.fecha_folio DESC;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
