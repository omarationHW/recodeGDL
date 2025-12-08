-- =============================================================================
-- STORED PROCEDURE: sp_get_incidencias_baja_multiple
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: Bja_Multiple / BajaMultiplePublicos.vue
-- Descripcion: Consulta incidencias de baja multiple por nombre de archivo
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_get_incidencias_baja_multiple(varchar);

CREATE OR REPLACE FUNCTION public.sp_get_incidencias_baja_multiple(
    p_archivo VARCHAR
) RETURNS TABLE (
    placa varchar,
    folio_archivo integer,
    fecha_archivo varchar,
    anomalia varchar,
    referencia integer
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        TRIM(b.placa)::varchar as placa,
        b.folio_archivo,
        TRIM(b.fecha_archivo)::varchar as fecha_archivo,
        TRIM(b.anomalia)::varchar as anomalia,
        b.referencia
    FROM public.ta14_folios_baja_esta b
    WHERE b.archivo = p_archivo
      AND b.estatus = '9'
    ORDER BY b.referencia;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
