-- Stored Procedure: sp_validar_usuario
-- Migrado de padron_licencias.comun a cementerio.public
-- Fecha: 2025-11-26

CREATE OR REPLACE FUNCTION public.sp_validar_usuario(
    p_usuario character varying DEFAULT NULL::character varying,
    p_password character varying DEFAULT NULL::character varying
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

    -- Validación de usuario
    RETURN QUERY
    SELECT
        EXISTS(SELECT 1 FROM ta_12_passwords WHERE usuario = p_usuario AND password = p_password)::BOOLEAN as success,
        CASE
            WHEN EXISTS(SELECT 1 FROM ta_12_passwords WHERE usuario = p_usuario AND password = p_password)
            THEN 'Usuario válido'::VARCHAR
            ELSE 'Usuario o contraseña incorrectos'::VARCHAR
        END as message,
        NULL::JSONB as data;
END;
$function$;
