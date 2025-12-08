CREATE OR REPLACE FUNCTION public.sp_cem_consultar_por_nombre(
    p_nombre character varying DEFAULT NULL::character varying,
    p_p_limit integer DEFAULT NULL::integer
)
RETURNS TABLE(
    success boolean,
    message character varying,
    data jsonb
)
LANGUAGE plpgsql
AS $function$
BEGIN
    -- SP generado automaticamente
    -- TODO: Implementar logica especifica

    -- Consulta generica
    RETURN QUERY
    SELECT
        TRUE::BOOLEAN as success,
        'Consulta ejecutada'::VARCHAR as message,
        '{}'::JSONB as data;
END;
$function$;
