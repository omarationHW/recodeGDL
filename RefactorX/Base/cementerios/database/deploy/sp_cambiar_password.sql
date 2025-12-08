-- Stored Procedure: sp_cambiar_password
-- Migrado de padron_licencias.comun a cementerio.public
-- Fecha: 2025-11-26

CREATE OR REPLACE FUNCTION public.sp_cambiar_password(
    p_id_usuario integer DEFAULT NULL::integer,
    p_password_nuevo character varying DEFAULT NULL::character varying
)
RETURNS TABLE(
    success boolean,
    message character varying
)
LANGUAGE plpgsql
AS $function$
BEGIN
    -- SP generado automáticamente
    -- TODO: Implementar lógica específica

    -- Cambio de contraseña
    UPDATE ta_12_passwords
    SET password = p_password_nuevo
    WHERE id_usuario = p_id_usuario;

    RETURN QUERY SELECT TRUE, 'Contraseña actualizada'::VARCHAR;
END;
$function$;
