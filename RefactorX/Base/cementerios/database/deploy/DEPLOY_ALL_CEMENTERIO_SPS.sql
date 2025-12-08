-- ==================================================================================
-- DEPLOY ALL CEMENTERIO STORED PROCEDURES
-- Migración completa de padron_licencias.comun a cementerio.public
-- Fecha: 2025-11-26
-- ==================================================================================
--
-- Este archivo contiene todos los stored procedures necesarios para el módulo
-- de cementerios, migrados desde padron_licencias.comun hacia cementerio.public.
--
-- Stored Procedures incluidos:
-- 1. sp_cem_reporte_titulos
-- 2. sp_cem_reporte_bonificaciones
-- 3. sp_cem_reporte_cuentas_cobrar
-- 4. sp_validar_usuario
-- 5. sp_registrar_acceso
-- 6. sp_validar_password_actual
-- 7. sp_cambiar_password
--
-- Modificaciones aplicadas:
-- - Cambio de esquema: comun.* a public.*
-- - Eliminación de referencias a esquema comun
-- - Todas las tablas ahora se referencian sin prefijo de esquema
--
-- ==================================================================================

-- ==================================================================================
-- 1. sp_cem_reporte_titulos
-- ==================================================================================
CREATE OR REPLACE FUNCTION public.sp_cem_reporte_titulos(
    p_fecha_desde date,
    p_fecha_hasta date,
    p_cementerio character varying DEFAULT NULL::character varying
)
RETURNS TABLE(
    titulo character varying,
    fecha date,
    control_rcm character varying,
    nombre character varying,
    cementerio character varying,
    clase integer,
    seccion integer,
    linea integer,
    fosa integer,
    importe numeric,
    recaudacion character varying
)
LANGUAGE plpgsql
AS $function$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'titulos' AND table_schema = 'public') THEN
        RETURN QUERY
        SELECT
            t.titulo::VARCHAR,
            t.fecha::DATE,
            t.control_rcm::VARCHAR,
            t.nombre::VARCHAR,
            t.cementerio::VARCHAR,
            t.clase::INTEGER,
            t.seccion::INTEGER,
            t.linea::INTEGER,
            t.fosa::INTEGER,
            COALESCE(t.importe, 0)::DECIMAL,
            COALESCE(t.recaudacion, '')::VARCHAR
        FROM titulos t
        WHERE t.fecha BETWEEN p_fecha_desde AND p_fecha_hasta
          AND (p_cementerio IS NULL OR t.cementerio = p_cementerio)
        ORDER BY t.fecha DESC, t.titulo;
    END IF;
END;
$function$;

-- ==================================================================================
-- 2. sp_cem_reporte_bonificaciones
-- ==================================================================================
CREATE OR REPLACE FUNCTION public.sp_cem_reporte_bonificaciones(
    p_fecha_inicio date,
    p_fecha_fin date,
    p_cementerio character varying DEFAULT NULL::character varying
)
RETURNS TABLE(
    id_bonificacion integer,
    fecha_aplicacion date,
    control_rcm character varying,
    nombre character varying,
    cementerio character varying,
    porcentaje numeric,
    importe_bonificado numeric,
    usuario character varying,
    nombre_usuario character varying,
    motivo text
)
LANGUAGE plpgsql
AS $function$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bonificaciones' AND table_schema = 'public') THEN
        RETURN QUERY
        SELECT
            b.id_bonificacion::INTEGER,
            b.fecha_aplicacion::DATE,
            b.control_rcm::VARCHAR,
            d.nombre::VARCHAR,
            d.cementerio::VARCHAR,
            COALESCE(b.porcentaje, 0)::DECIMAL,
            COALESCE(b.importe_bonificado, 0)::DECIMAL,
            b.usuario::VARCHAR,
            COALESCE(u.nombre, b.usuario)::VARCHAR as nombre_usuario,
            COALESCE(b.motivo, '')::TEXT
        FROM bonificaciones b
        LEFT JOIN datosrcm d ON b.control_rcm::INTEGER = d.control_rcm
        LEFT JOIN public.usuarios u ON b.usuario = u.usuario
        WHERE b.fecha_aplicacion BETWEEN p_fecha_inicio AND p_fecha_fin
          AND (p_cementerio IS NULL OR d.cementerio = p_cementerio)
        ORDER BY b.fecha_aplicacion DESC;
    END IF;
END;
$function$;

-- ==================================================================================
-- 3. sp_cem_reporte_cuentas_cobrar
-- ==================================================================================
CREATE OR REPLACE FUNCTION public.sp_cem_reporte_cuentas_cobrar(
    p_cementerio character varying DEFAULT NULL::character varying,
    p_anio integer DEFAULT NULL::integer
)
RETURNS TABLE(
    control_rcm character varying,
    cementerio character varying,
    nombre character varying,
    domicilio character varying,
    axo_pagado integer,
    anios_adeudo integer
)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_anio_ref INTEGER;
BEGIN
    v_anio_ref := COALESCE(p_anio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'datosrcm' AND table_schema = 'public') THEN
        RETURN QUERY
        SELECT
            d.control_rcm::VARCHAR,
            d.cementerio::VARCHAR,
            d.nombre::VARCHAR,
            COALESCE(d.domicilio, '')::VARCHAR,
            COALESCE(d.axo_pagado, v_anio_ref)::INTEGER,
            (v_anio_ref - COALESCE(d.axo_pagado, v_anio_ref))::INTEGER as anios_adeudo
        FROM datosrcm d
        WHERE COALESCE(d.axo_pagado, v_anio_ref) < v_anio_ref
          AND (p_cementerio IS NULL OR d.cementerio = p_cementerio)
        ORDER BY anios_adeudo DESC, d.cementerio, d.control_rcm;
    END IF;
END;
$function$;

-- ==================================================================================
-- 4. sp_validar_usuario
-- ==================================================================================
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

-- ==================================================================================
-- 5. sp_registrar_acceso
-- ==================================================================================
CREATE OR REPLACE FUNCTION public.sp_registrar_acceso(
    p_id_usuario integer DEFAULT NULL::integer,
    p_modulo character varying DEFAULT NULL::character varying
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

    -- Registro de acceso (placeholder)
    RETURN QUERY SELECT TRUE, 'Acceso registrado'::VARCHAR;
END;
$function$;

-- ==================================================================================
-- 6. sp_validar_password_actual
-- ==================================================================================
CREATE OR REPLACE FUNCTION public.sp_validar_password_actual(
    p_id_usuario integer DEFAULT NULL::integer,
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

    -- Operación genérica
    RETURN QUERY SELECT TRUE, 'Operación completada'::VARCHAR;
END;
$function$;

-- ==================================================================================
-- 7. sp_cambiar_password
-- ==================================================================================
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

-- ==================================================================================
-- FIN DEL DEPLOY
-- ==================================================================================
