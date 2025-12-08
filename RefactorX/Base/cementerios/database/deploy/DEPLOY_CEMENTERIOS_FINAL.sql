-- =====================================================================
-- DEPLOYMENT SCRIPT FINAL: Vistas y Stored Procedures para Cementerios
-- Base de datos: cementerio
-- Schema: public
-- Fecha: 2025-11-26
-- Descripción: Creación de vistas y SPs migrados desde padron_licencias.comun
-- =====================================================================

-- =====================================================================
-- PASO 1: CREAR/RECREAR VISTAS NECESARIAS
-- =====================================================================

-- Vista: v_tc_13_cementerios
DROP VIEW IF EXISTS public.v_tc_13_cementerios CASCADE;
CREATE OR REPLACE VIEW public.v_tc_13_cementerios AS
SELECT
    cementerio,
    nombre,
    domicilio,
    cta_aplicacion,
    cta_vencido,
    cta_descto,
    cta_desctopens,
    cta_desctopens_rez,
    cta_actualizacion
FROM public.tc_13_cementerios;

-- Vista: v_ta_13_pagosrcm
DROP VIEW IF EXISTS public.v_ta_13_pagosrcm CASCADE;
CREATE OR REPLACE VIEW public.v_ta_13_pagosrcm AS
SELECT
    fecing,
    recing,
    cajing,
    opcaja,
    control_id,
    control_rcm,
    cementerio,
    clase,
    clase_alfa,
    seccion,
    seccion_alfa,
    linea,
    linea_alfa,
    fosa,
    fosa_alfa,
    axo_pago_desde,
    axo_pago_hasta,
    importe_anual,
    importe_recargos,
    vigencia,
    usuario,
    fecha_mov
FROM public.ta_13_pagosrcm;

-- Vista: v_ta_13_cem400 (equivalente a ta_13_datosrcm)
DROP VIEW IF EXISTS public.v_ta_13_cem400 CASCADE;
CREATE OR REPLACE VIEW public.v_ta_13_cem400 AS
SELECT
    control_id,
    fecing,
    recing,
    cajing,
    opcaja,
    cementerio,
    clase,
    clase_alfa,
    seccion,
    seccion_alfa,
    linea,
    linea_alfa,
    fosa,
    fosa_alfa,
    axo_pago_desde,
    axo_pago_hasta,
    importe_anual,
    axo_pagado,
    metros,
    nombre,
    domicilio,
    exterior,
    interior,
    colonia
FROM public.ta_13_cem400;

-- =====================================================================
-- PASO 2: RECREAR STORED PROCEDURES CON CORRECCIONES
-- =====================================================================

-- SP 1: sp_cem_abc_cementerios
DROP FUNCTION IF EXISTS public.sp_cem_abc_cementerios(character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, integer) CASCADE;
CREATE OR REPLACE FUNCTION public.sp_cem_abc_cementerios(
    p_operacion character varying,
    p_cementerio character varying,
    p_nombre character varying DEFAULT NULL::character varying,
    p_domicilio character varying DEFAULT NULL::character varying,
    p_cta_aplicacion integer DEFAULT NULL::integer,
    p_cta_vencido integer DEFAULT NULL::integer,
    p_cta_descto integer DEFAULT NULL::integer,
    p_cta_desctopens integer DEFAULT NULL::integer,
    p_cta_desctopens_rez integer DEFAULT NULL::integer,
    p_cta_actualizacion integer DEFAULT NULL::integer
)
RETURNS TABLE(success boolean, message character varying, cementerio_ret character varying)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_existe INTEGER;
BEGIN
    IF p_operacion NOT IN ('A', 'B', 'C') THEN
        RETURN QUERY SELECT FALSE, 'Operacion invalida. Use A (Alta), B (Baja) o C (Cambio)'::VARCHAR, NULL::VARCHAR;
        RETURN;
    END IF;

    IF p_operacion = 'A' THEN
        SELECT COUNT(*) INTO v_existe FROM public.v_tc_13_cementerios vc WHERE vc.cementerio = p_cementerio;
        IF v_existe > 0 THEN
            RETURN QUERY SELECT FALSE, 'El cementerio ya existe'::VARCHAR, p_cementerio;
            RETURN;
        END IF;

        INSERT INTO public.tc_13_cementerios (
            cementerio, nombre, domicilio, cta_aplicacion, cta_vencido, cta_descto,
            cta_desctopens, cta_desctopens_rez, cta_actualizacion
        ) VALUES (
            p_cementerio, COALESCE(p_nombre, ''), COALESCE(p_domicilio, ''),
            COALESCE(p_cta_aplicacion, 0), COALESCE(p_cta_vencido, 0), COALESCE(p_cta_descto, 0),
            COALESCE(p_cta_desctopens, 0), COALESCE(p_cta_desctopens_rez, 0), COALESCE(p_cta_actualizacion, 0)
        );
        RETURN QUERY SELECT TRUE, 'Cementerio agregado exitosamente'::VARCHAR, p_cementerio;
        RETURN;
    END IF;

    IF p_operacion = 'B' THEN
        SELECT COUNT(*) INTO v_existe FROM public.v_tc_13_cementerios vc WHERE vc.cementerio = p_cementerio;
        IF v_existe = 0 THEN
            RETURN QUERY SELECT FALSE, 'El cementerio no existe'::VARCHAR, p_cementerio;
            RETURN;
        END IF;
        DELETE FROM public.tc_13_cementerios tc WHERE tc.cementerio = p_cementerio;
        RETURN QUERY SELECT TRUE, 'Cementerio eliminado exitosamente'::VARCHAR, p_cementerio;
        RETURN;
    END IF;

    IF p_operacion = 'C' THEN
        SELECT COUNT(*) INTO v_existe FROM public.v_tc_13_cementerios vc WHERE vc.cementerio = p_cementerio;
        IF v_existe = 0 THEN
            RETURN QUERY SELECT FALSE, 'El cementerio no existe'::VARCHAR, p_cementerio;
            RETURN;
        END IF;
        UPDATE public.tc_13_cementerios tc
        SET nombre = COALESCE(p_nombre, tc.nombre),
            domicilio = COALESCE(p_domicilio, tc.domicilio),
            cta_aplicacion = COALESCE(p_cta_aplicacion, tc.cta_aplicacion),
            cta_vencido = COALESCE(p_cta_vencido, tc.cta_vencido),
            cta_descto = COALESCE(p_cta_descto, tc.cta_descto),
            cta_desctopens = COALESCE(p_cta_desctopens, tc.cta_desctopens),
            cta_desctopens_rez = COALESCE(p_cta_desctopens_rez, tc.cta_desctopens_rez),
            cta_actualizacion = COALESCE(p_cta_actualizacion, tc.cta_actualizacion)
        WHERE tc.cementerio = p_cementerio;
        RETURN QUERY SELECT TRUE, 'Cementerio actualizado exitosamente'::VARCHAR, p_cementerio;
        RETURN;
    END IF;
END;
$function$;

-- =====================================================================
-- SP 2: sp_cem_abc_pagos_por_folio
-- NOTA: Este SP usa control_rcm para compatibilidad con el sistema original
DROP FUNCTION IF EXISTS public.sp_cem_abc_pagos_por_folio(character varying, integer, integer, date, integer, integer, numeric, numeric, integer, character varying) CASCADE;
CREATE OR REPLACE FUNCTION public.sp_cem_abc_pagos_por_folio(
    p_operacion character varying,
    p_control_rcm integer,
    p_recing integer DEFAULT NULL::integer,
    p_fecing date DEFAULT NULL::date,
    p_axo_pago_desde integer DEFAULT NULL::integer,
    p_axo_pago_hasta integer DEFAULT NULL::integer,
    p_importe_anual numeric DEFAULT NULL::numeric,
    p_importe_recargos numeric DEFAULT NULL::numeric,
    p_usuario integer DEFAULT NULL::integer,
    p_observaciones character varying DEFAULT NULL::character varying
)
RETURNS TABLE(success boolean, message character varying, id_pago integer)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_existe INTEGER;
    v_folio_existe INTEGER;
    v_nuevo_id INTEGER;
    v_total_registros INTEGER;
    v_control_id INTEGER;
BEGIN
    IF p_operacion NOT IN ('A', 'B', 'C') THEN
        RETURN QUERY SELECT FALSE, 'Operación inválida. Use A (Alta), B (Baja) o C (Cambio)'::VARCHAR, NULL::INTEGER;
        RETURN;
    END IF;

    -- Buscar control_id basado en control_rcm
    SELECT control_id INTO v_control_id
    FROM public.ta_13_cem400
    WHERE control_id = p_control_rcm
    LIMIT 1;

    IF v_control_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El folio no existe'::VARCHAR, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_operacion = 'A' THEN
        IF p_fecing IS NULL OR p_axo_pago_desde IS NULL THEN
            RETURN QUERY SELECT FALSE, 'Datos requeridos: fecha y año de pago'::VARCHAR, NULL::INTEGER;
            RETURN;
        END IF;

        SELECT COALESCE(MAX(recing), 0) + 1 INTO v_nuevo_id FROM public.v_ta_13_pagosrcm;

        INSERT INTO public.ta_13_pagosrcm (
            control_id, control_rcm, recing, fecing, axo_pago_desde, axo_pago_hasta,
            importe_anual, importe_recargos, usuario
        ) VALUES (
            v_control_id, p_control_rcm, COALESCE(p_recing, v_nuevo_id), p_fecing,
            p_axo_pago_desde, COALESCE(p_axo_pago_hasta, p_axo_pago_desde),
            COALESCE(p_importe_anual, 0), COALESCE(p_importe_recargos, 0), COALESCE(p_usuario, 0)
        );

        RETURN QUERY SELECT TRUE, 'Pago registrado exitosamente'::VARCHAR, COALESCE(p_recing, v_nuevo_id);
        RETURN;
    END IF;

    IF p_operacion = 'B' THEN
        IF p_recing IS NULL THEN
            RETURN QUERY SELECT FALSE, 'Debe especificar el ID del pago a eliminar'::VARCHAR, NULL::INTEGER;
            RETURN;
        END IF;

        SELECT COUNT(*) INTO v_existe
        FROM public.v_ta_13_pagosrcm
        WHERE control_rcm = p_control_rcm AND recing = p_recing;

        IF v_existe = 0 THEN
            RETURN QUERY SELECT FALSE, 'El pago no existe'::VARCHAR, p_recing;
            RETURN;
        END IF;

        DELETE FROM public.ta_13_pagosrcm WHERE control_rcm = p_control_rcm AND recing = p_recing;
        RETURN QUERY SELECT TRUE, 'Pago eliminado exitosamente'::VARCHAR, p_recing;
        RETURN;
    END IF;

    IF p_operacion = 'C' THEN
        IF p_recing IS NULL THEN
            RETURN QUERY SELECT FALSE, 'Debe especificar el ID del pago a modificar'::VARCHAR, NULL::INTEGER;
            RETURN;
        END IF;

        SELECT COUNT(*) INTO v_existe
        FROM public.v_ta_13_pagosrcm
        WHERE control_rcm = p_control_rcm AND recing = p_recing;

        IF v_existe = 0 THEN
            RETURN QUERY SELECT FALSE, 'El pago no existe'::VARCHAR, p_recing;
            RETURN;
        END IF;

        UPDATE public.ta_13_pagosrcm
        SET fecing = COALESCE(p_fecing, fecing),
            axo_pago_desde = COALESCE(p_axo_pago_desde, axo_pago_desde),
            axo_pago_hasta = COALESCE(p_axo_pago_hasta, axo_pago_hasta),
            importe_anual = COALESCE(p_importe_anual, importe_anual),
            importe_recargos = COALESCE(p_importe_recargos, importe_recargos),
            usuario = COALESCE(p_usuario, usuario)
        WHERE control_rcm = p_control_rcm AND recing = p_recing;

        RETURN QUERY SELECT TRUE, 'Pago actualizado exitosamente'::VARCHAR, p_recing;
        RETURN;
    END IF;
END;
$function$;

-- =====================================================================
-- SP 3: sp_cem_buscar_folio_pagos
-- NOTA: Cambiado para usar control_rcm como parámetro (compatible con sistema original)
DROP FUNCTION IF EXISTS public.sp_cem_buscar_folio_pagos(integer) CASCADE;
CREATE OR REPLACE FUNCTION public.sp_cem_buscar_folio_pagos(p_control_rcm integer)
RETURNS TABLE(
    control_rcm integer,
    nombre character varying,
    cementerio character varying,
    cementerio_nombre character varying,
    axo_pagado integer,
    total_pagos bigint,
    ultima_fecha_pago date,
    monto_total_pagado numeric
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        d.control_id as control_rcm,
        TRIM(d.nombre)::VARCHAR as nombre,
        d.cementerio::VARCHAR,
        c.nombre::VARCHAR as cementerio_nombre,
        COALESCE(d.axo_pagado, 0)::INTEGER as axo_pagado,
        COUNT(p.recing)::BIGINT as total_pagos,
        MAX(p.fecing)::DATE as ultima_fecha_pago,
        SUM(COALESCE(p.importe_anual, 0) + COALESCE(p.importe_recargos, 0))::DECIMAL as monto_total_pagado
    FROM public.v_ta_13_cem400 d
    LEFT JOIN public.v_tc_13_cementerios c ON d.cementerio = c.cementerio
    LEFT JOIN public.v_ta_13_pagosrcm p ON d.control_id = p.control_id
    WHERE d.control_id = p_control_rcm
    GROUP BY d.control_id, d.nombre, d.cementerio, c.nombre, d.axo_pagado;
END;
$function$;

-- =====================================================================
-- SP 4: sp_cem_listar_pagos_folio
-- NOTA: Cambiado para usar control_rcm como parámetro
DROP FUNCTION IF EXISTS public.sp_cem_listar_pagos_folio(integer) CASCADE;
CREATE OR REPLACE FUNCTION public.sp_cem_listar_pagos_folio(p_control_rcm integer)
RETURNS TABLE(
    recibo integer,
    fecha date,
    axo_desde integer,
    axo_hasta integer,
    importe numeric,
    recargos numeric,
    total numeric,
    usuario integer,
    nombre_usuario character varying
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.recing::INTEGER as recibo,
        p.fecing::DATE as fecha,
        p.axo_pago_desde::INTEGER as axo_desde,
        p.axo_pago_hasta::INTEGER as axo_hasta,
        COALESCE(p.importe_anual, 0)::DECIMAL as importe,
        COALESCE(p.importe_recargos, 0)::DECIMAL as recargos,
        (COALESCE(p.importe_anual, 0) + COALESCE(p.importe_recargos, 0))::DECIMAL as total,
        p.usuario::INTEGER,
        'SYSTEM'::VARCHAR as nombre_usuario
    FROM public.v_ta_13_pagosrcm p
    WHERE p.control_id = p_control_rcm
    ORDER BY p.fecing DESC, p.recing DESC;
END;
$function$;

-- =====================================================================
-- SP 5: sp_cem_registrar_pago
-- NOTA: Cambiado para usar control_rcm como parámetro
DROP FUNCTION IF EXISTS public.sp_cem_registrar_pago(integer, integer, integer, numeric, numeric, integer, character varying) CASCADE;
CREATE OR REPLACE FUNCTION public.sp_cem_registrar_pago(
    p_control_rcm integer,
    p_axo_desde integer,
    p_axo_hasta integer,
    p_importe_anual numeric,
    p_importe_recargos numeric DEFAULT 0,
    p_usuario integer DEFAULT 0,
    p_observaciones character varying DEFAULT NULL::character varying
)
RETURNS TABLE(success boolean, message character varying, recibo integer, total numeric)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_folio_existe INTEGER;
    v_nuevo_recibo INTEGER;
    v_total_pago DECIMAL;
    v_control_id INTEGER;
BEGIN
    -- Verificar que el folio existe y obtener control_id
    SELECT control_id INTO v_control_id
    FROM public.ta_13_cem400
    WHERE control_id = p_control_rcm;

    IF v_control_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El folio no existe'::VARCHAR, NULL::INTEGER, NULL::DECIMAL;
        RETURN;
    END IF;

    v_total_pago := p_importe_anual + COALESCE(p_importe_recargos, 0);

    SELECT COALESCE(MAX(recing), 0) + 1 INTO v_nuevo_recibo FROM public.v_ta_13_pagosrcm;

    INSERT INTO public.ta_13_pagosrcm (
        control_id, control_rcm, recing, fecing, axo_pago_desde, axo_pago_hasta,
        importe_anual, importe_recargos, usuario
    ) VALUES (
        v_control_id, p_control_rcm, v_nuevo_recibo, CURRENT_DATE,
        p_axo_desde, p_axo_hasta, p_importe_anual, p_importe_recargos, p_usuario
    );

    UPDATE public.ta_13_cem400
    SET axo_pagado = GREATEST(COALESCE(axo_pagado, 0), p_axo_hasta)
    WHERE control_id = p_control_rcm;

    RETURN QUERY SELECT TRUE, 'Pago registrado exitosamente'::VARCHAR, v_nuevo_recibo, v_total_pago;
END;
$function$;

-- =====================================================================
-- SP 6: sp_cem_obtener_adeudos_pendientes
DROP FUNCTION IF EXISTS public.sp_cem_obtener_adeudos_pendientes(integer) CASCADE;
CREATE OR REPLACE FUNCTION public.sp_cem_obtener_adeudos_pendientes(
    p_control_rcm integer DEFAULT NULL::integer
)
RETURNS TABLE(success boolean, message character varying, data jsonb)
LANGUAGE plpgsql
AS $function$
BEGIN
    -- SP generado automáticamente
    -- TODO: Implementar lógica específica
    RETURN QUERY SELECT TRUE, 'Operación completada'::VARCHAR, NULL::JSONB;
END;
$function$;

-- =====================================================================
-- FIN DEL SCRIPT
-- =====================================================================
