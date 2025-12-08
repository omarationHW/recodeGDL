-- =============================================================================
-- STORED PROCEDURE: sp_conciliados_by_folio
-- Base: estacionamiento_publico
-- Esquema: public
-- Formulario: srfrm_conci_banorte / ConciBanortePublicos.vue
-- Descripcion: Consulta conciliacion Banorte por año y folio
-- =============================================================================

DROP FUNCTION IF EXISTS public.sp_conciliados_by_folio(integer, integer);

CREATE OR REPLACE FUNCTION public.sp_conciliados_by_folio(
    p_axo INTEGER,
    p_folio INTEGER
) RETURNS TABLE(
    axo smallint,
    folio integer,
    fecha_folio date,
    placa varchar,
    infraccion smallint,
    fec_pago date,
    folio_pago varchar,
    medio_pago varchar,
    forma_pago varchar,
    importe_bruto numeric,
    importe_neto numeric,
    fecha_venci date,
    sucursal integer,
    hora_banco varchar,
    estatus_banco varchar,
    usu_carga integer,
    fecha_afectacion date,
    status_mpio smallint,
    placa_cambio varchar,
    fec_placa_cambio date,
    fec_carga_ascii date,
    fec_caja date,
    operacion integer,
    caja_ingre varchar,
    reca smallint,
    stat varchar
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        a.axo,
        a.folio,
        a.fecha_folio,
        TRIM(a.placa)::varchar,
        a.infraccion,
        a.fec_pago,
        TRIM(a.folio_pago)::varchar,
        TRIM(a.medio_pago)::varchar,
        TRIM(a.forma_pago)::varchar,
        a.importe_bruto,
        a.importe_neto,
        a.fecha_venci,
        a.sucursal,
        TRIM(a.hora_banco)::varchar,
        TRIM(a.estatus_banco)::varchar,
        a.usu_carga,
        a.fecha_afectacion,
        a.status_mpio,
        TRIM(a.placa_cambio)::varchar,
        a.fec_placa_cambio,
        a.fec_carga_ascii,
        a.fec_caja,
        a.operacion,
        TRIM(a.caja_ingre)::varchar,
        a.reca,
        CASE
            WHEN a.status_mpio = 0 THEN 'OK'
            WHEN a.status_mpio = 1 THEN 'Doble'
            WHEN a.status_mpio = 9 THEN 'Alta'
            WHEN a.status_mpio = 4 THEN 'Er. placa'
            WHEN a.status_mpio = 5 THEN 'Histo Er. placa'
            WHEN a.status_mpio = 6 THEN 'Banorte Er. placa'
            WHEN a.status_mpio = 10 THEN 'Banorte anterioridad'
            ELSE 'Sin Afect'
        END::varchar AS stat
    FROM public.ta14_fol_banorte a
    WHERE a.status_mpio <> 0
      AND a.axo = p_axo
      AND a.folio = p_folio
    ORDER BY a.status_mpio;
END;
$func$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN STORED PROCEDURE
-- =============================================================================
