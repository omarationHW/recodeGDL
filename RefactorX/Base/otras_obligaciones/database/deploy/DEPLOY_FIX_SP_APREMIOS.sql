-- =====================================================
-- FIX: SP sp_otras_oblig_get_apremios
-- Corrige referencia a tabla ta_12_passwords
-- La tabla está en comun.ta_12_passwords, no public
-- =====================================================

DROP FUNCTION IF EXISTS public.sp_otras_oblig_get_apremios(integer, integer);

CREATE OR REPLACE FUNCTION public.sp_otras_oblig_get_apremios(
    p_modulo integer,
    p_control integer
)
RETURNS TABLE(
    id_control integer,
    zona smallint,
    folio integer,
    diligencia character,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    zona_apremio smallint,
    fecha_emision date,
    clave_practicado character,
    fecha_practicado date,
    hora_practicado time without time zone,
    fecha_entrega1 date,
    fecha_entrega2 date,
    fecha_citatorio date,
    hora time without time zone,
    ejecutor character varying,
    clave_secuestro smallint,
    clave_remate character,
    fecha_remate date,
    porcentaje_multa smallint,
    observaciones character varying
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        a.id_control,
        a.zona,
        a.folio,
        a.diligencia,
        a.importe_global,
        a.importe_multa,
        a.importe_recargo,
        a.importe_gastos,
        a.zona_apremio,
        a.fecha_emision,
        a.clave_practicado,
        a.fecha_practicado,
        a.hora_practicado::TIME,
        a.fecha_entrega1,
        a.fecha_entrega2,
        a.fecha_citatorio,
        a.hora::TIME,
        COALESCE(u.usuario, 'Sin asignar')::VARCHAR as ejecutor,
        a.clave_secuestro,
        a.clave_remate,
        a.fecha_remate,
        a.porcentaje_multa,
        a.observaciones::VARCHAR
    FROM comun.ta_15_apremios a
    LEFT JOIN comun.ta_12_passwords u ON u.id_usuario = a.ejecutor
    WHERE a.modulo = p_modulo
      AND a.control_otr = p_control
      AND a.vigencia = '1'
      AND a.clave_practicado = 'P';
END;
$function$;

-- Verificar que funcione
DO $$
BEGIN
    RAISE NOTICE 'SP sp_otras_oblig_get_apremios actualizado correctamente';
END $$;
