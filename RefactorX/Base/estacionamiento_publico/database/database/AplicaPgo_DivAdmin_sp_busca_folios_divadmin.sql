-- =============================================================================
-- STORED PROCEDURE: sp_busca_folios_divadmin
-- Base: estacionamiento_publico
-- Esquema: public
-- Descripcion: Busca folios de adeudo segun opcion de busqueda
--   opcion=0: Por placa
--   opcion=1: Por placa + folio
--   opcion=2: Por axo + folio
-- Formulario: AplicaPgo_DivAdmin
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_busca_folios_divadmin(integer, varchar, integer, integer);

CREATE OR REPLACE FUNCTION public.sp_busca_folios_divadmin(
    p_opcion INTEGER,
    p_placa VARCHAR,
    p_folio INTEGER,
    p_axo INTEGER
) RETURNS TABLE (
    axo smallint,
    folio integer,
    placa varchar,
    fecha_folio date,
    infraccion smallint,
    estado smallint,
    tarifa numeric,
    zona smallint,
    espacio smallint
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        a.axo,
        a.folio,
        TRIM(a.placa)::varchar as placa,
        a.fecha_folio,
        a.infraccion,
        a.estado,
        COALESCE(t.tarifa, 0) as tarifa,
        a.zona,
        a.espacio
    FROM public.ta14_folios_adeudo a
    LEFT JOIN public.ta14_tarifas t ON a.infraccion = t.num_clave
        AND a.fecha_folio BETWEEN t.fecha_inicial AND t.fecha_fin
    WHERE
        CASE
            WHEN p_opcion = 0 THEN TRIM(a.placa) = UPPER(TRIM(p_placa))
            WHEN p_opcion = 1 THEN TRIM(a.placa) = UPPER(TRIM(p_placa)) AND a.folio = p_folio
            WHEN p_opcion = 2 THEN a.axo = p_axo AND a.folio = p_folio
            ELSE false
        END
        AND a.estado NOT IN (2, 14)  -- Excluir pagados
    ORDER BY a.axo DESC, a.folio DESC;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
