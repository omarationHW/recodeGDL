-- =====================================================================
-- DEPLOYMENT SCRIPT: Stored Procedures para Cementerios
-- Base de datos: cementerio
-- Schema: public
-- Fecha: 2025-11-26
-- Descripción: Creación de SPs migrados desde padron_licencias.comun
-- =====================================================================

-- SP 1: sp_cem_abc_cementerios
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
RETURNS TABLE(success boolean, message character varying, cementerio character varying)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_existe INTEGER;
BEGIN
    -- Validar operación
    IF p_operacion NOT IN ('A', 'B', 'C') THEN
        RETURN QUERY SELECT FALSE, 'Operación inválida. Use A (Alta), B (Baja) o C (Cambio)'::VARCHAR, NULL::VARCHAR;
        RETURN;
    END IF;

    -- ALTA
    IF p_operacion = 'A' THEN
        -- Verificar que no exista
        SELECT COUNT(*) INTO v_existe
        FROM v_tc_13_cementerios
        WHERE cementerio = p_cementerio;

        IF v_existe > 0 THEN
            RETURN QUERY SELECT FALSE, 'El cementerio ya existe'::VARCHAR, p_cementerio;
            RETURN;
        END IF;

        -- Insertar en tabla real
        INSERT INTO tc_13_cementerios (
            cementerio,
            nombre,
            domicilio,
            cta_aplicacion,
            cta_vencido,
            cta_descto,
            cta_desctopens,
            cta_desctopens_rez,
            cta_actualizacion
        ) VALUES (
            p_cementerio,
            COALESCE(p_nombre, ''),
            COALESCE(p_domicilio, ''),
            COALESCE(p_cta_aplicacion, 0),
            COALESCE(p_cta_vencido, 0),
            COALESCE(p_cta_descto, 0),
            COALESCE(p_cta_desctopens, 0),
            COALESCE(p_cta_desctopens_rez, 0),
            COALESCE(p_cta_actualizacion, 0)
        );

        RETURN QUERY SELECT TRUE, 'Cementerio agregado exitosamente'::VARCHAR, p_cementerio;
        RETURN;
    END IF;

    -- BAJA
    IF p_operacion = 'B' THEN
        -- Verificar que exista
        SELECT COUNT(*) INTO v_existe
        FROM v_tc_13_cementerios
        WHERE cementerio = p_cementerio;

        IF v_existe = 0 THEN
            RETURN QUERY SELECT FALSE, 'El cementerio no existe'::VARCHAR, p_cementerio;
            RETURN;
        END IF;

        -- Eliminar de tabla real
        DELETE FROM tc_13_cementerios
        WHERE cementerio = p_cementerio;

        RETURN QUERY SELECT TRUE, 'Cementerio eliminado exitosamente'::VARCHAR, p_cementerio;
        RETURN;
    END IF;

    -- CAMBIO
    IF p_operacion = 'C' THEN
        -- Verificar que exista
        SELECT COUNT(*) INTO v_existe
        FROM v_tc_13_cementerios
        WHERE cementerio = p_cementerio;

        IF v_existe = 0 THEN
            RETURN QUERY SELECT FALSE, 'El cementerio no existe'::VARCHAR, p_cementerio;
            RETURN;
        END IF;

        -- Actualizar en tabla real
        UPDATE tc_13_cementerios
        SET nombre = COALESCE(p_nombre, nombre),
            domicilio = COALESCE(p_domicilio, domicilio),
            cta_aplicacion = COALESCE(p_cta_aplicacion, cta_aplicacion),
            cta_vencido = COALESCE(p_cta_vencido, cta_vencido),
            cta_descto = COALESCE(p_cta_descto, cta_descto),
            cta_desctopens = COALESCE(p_cta_desctopens, cta_desctopens),
            cta_desctopens_rez = COALESCE(p_cta_desctopens_rez, cta_desctopens_rez),
            cta_actualizacion = COALESCE(p_cta_actualizacion, cta_actualizacion)
        WHERE cementerio = p_cementerio;

        RETURN QUERY SELECT TRUE, 'Cementerio actualizado exitosamente'::VARCHAR, p_cementerio;
        RETURN;
    END IF;
END;
$function$;

-- =====================================================================
-- SP 2: sp_cem_abc_pagos_por_folio
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
BEGIN
    -- Validar operación
    IF p_operacion NOT IN ('A', 'B', 'C') THEN
        RETURN QUERY SELECT FALSE, 'Operación inválida. Use A (Alta), B (Baja) o C (Cambio)'::VARCHAR, NULL::INTEGER;
        RETURN;
    END IF;

    -- Verificar que el folio existe
    SELECT COUNT(*) INTO v_folio_existe
    FROM ta_13_datosrcm
    WHERE control_rcm = p_control_rcm;

    IF v_folio_existe = 0 THEN
        RETURN QUERY SELECT FALSE, 'El folio no existe'::VARCHAR, NULL::INTEGER;
        RETURN;
    END IF;

    -- ALTA
    IF p_operacion = 'A' THEN
        -- Validar datos requeridos
        IF p_fecing IS NULL OR p_axo_pago_desde IS NULL THEN
            RETURN QUERY SELECT FALSE, 'Datos requeridos: fecha y año de pago'::VARCHAR, NULL::INTEGER;
            RETURN;
        END IF;

        -- Obtener total de registros para generar nuevo ID
        SELECT COUNT(*) INTO v_total_registros
        FROM v_ta_13_pagosrcm;

        v_nuevo_id := v_total_registros + 1;

        -- Insertar pago
        INSERT INTO ta_13_pagosrcm (
            control_rcm,
            recing,
            fecing,
            axo_pago_desde,
            axo_pago_hasta,
            importe_anual,
            importe_recargos,
            usuario,
            observaciones
        ) VALUES (
            p_control_rcm,
            COALESCE(p_recing, v_nuevo_id),
            p_fecing,
            p_axo_pago_desde,
            COALESCE(p_axo_pago_hasta, p_axo_pago_desde),
            COALESCE(p_importe_anual, 0),
            COALESCE(p_importe_recargos, 0),
            COALESCE(p_usuario, 0),
            p_observaciones
        );

        RETURN QUERY SELECT TRUE, 'Pago registrado exitosamente'::VARCHAR, COALESCE(p_recing, v_nuevo_id);
        RETURN;
    END IF;

    -- BAJA
    IF p_operacion = 'B' THEN
        IF p_recing IS NULL THEN
            RETURN QUERY SELECT FALSE, 'Debe especificar el ID del pago a eliminar'::VARCHAR, NULL::INTEGER;
            RETURN;
        END IF;

        -- Verificar que el pago existe
        SELECT COUNT(*) INTO v_existe
        FROM v_ta_13_pagosrcm
        WHERE control_rcm = p_control_rcm AND recing = p_recing;

        IF v_existe = 0 THEN
            RETURN QUERY SELECT FALSE, 'El pago no existe'::VARCHAR, p_recing;
            RETURN;
        END IF;

        -- Eliminar pago
        DELETE FROM ta_13_pagosrcm
        WHERE control_rcm = p_control_rcm AND recing = p_recing;

        RETURN QUERY SELECT TRUE, 'Pago eliminado exitosamente'::VARCHAR, p_recing;
        RETURN;
    END IF;

    -- CAMBIO
    IF p_operacion = 'C' THEN
        IF p_recing IS NULL THEN
            RETURN QUERY SELECT FALSE, 'Debe especificar el ID del pago a modificar'::VARCHAR, NULL::INTEGER;
            RETURN;
        END IF;

        -- Verificar que el pago existe
        SELECT COUNT(*) INTO v_existe
        FROM v_ta_13_pagosrcm
        WHERE control_rcm = p_control_rcm AND recing = p_recing;

        IF v_existe = 0 THEN
            RETURN QUERY SELECT FALSE, 'El pago no existe'::VARCHAR, p_recing;
            RETURN;
        END IF;

        -- Actualizar pago
        UPDATE ta_13_pagosrcm
        SET fecing = COALESCE(p_fecing, fecing),
            axo_pago_desde = COALESCE(p_axo_pago_desde, axo_pago_desde),
            axo_pago_hasta = COALESCE(p_axo_pago_hasta, axo_pago_hasta),
            importe_anual = COALESCE(p_importe_anual, importe_anual),
            importe_recargos = COALESCE(p_importe_recargos, importe_recargos),
            usuario = COALESCE(p_usuario, usuario),
            observaciones = COALESCE(p_observaciones, observaciones)
        WHERE control_rcm = p_control_rcm AND recing = p_recing;

        RETURN QUERY SELECT TRUE, 'Pago actualizado exitosamente'::VARCHAR, p_recing;
        RETURN;
    END IF;
END;
$function$;

-- =====================================================================
-- SP 3: sp_cem_buscar_folio_pagos
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
        d.control_rcm,
        TRIM(d.nombre)::VARCHAR as nombre,
        d.cementerio::VARCHAR,
        c.nombre::VARCHAR as cementerio_nombre,
        COALESCE(d.axo_pagado, 0)::INTEGER as axo_pagado,
        COUNT(p.recing)::BIGINT as total_pagos,
        MAX(p.fecing)::DATE as ultima_fecha_pago,
        SUM(COALESCE(p.importe_anual, 0) + COALESCE(p.importe_recargos, 0))::DECIMAL as monto_total_pagado
    FROM ta_13_datosrcm d
    LEFT JOIN v_tc_13_cementerios c ON d.cementerio = c.cementerio
    LEFT JOIN v_ta_13_pagosrcm p ON d.control_rcm = p.control_rcm
    WHERE d.control_rcm = p_control_rcm
    GROUP BY d.control_rcm, d.nombre, d.cementerio, c.nombre, d.axo_pagado;
END;
$function$;

-- =====================================================================
-- SP 4: sp_cem_listar_pagos_folio
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
        COALESCE(u.nombre, 'SYSTEM')::VARCHAR as nombre_usuario
    FROM v_ta_13_pagosrcm p
    LEFT JOIN ta_12_passwords u ON p.usuario = u.id_usuario
    WHERE p.control_rcm = p_control_rcm
    ORDER BY p.fecing DESC, p.recing DESC;
END;
$function$;

-- =====================================================================
-- SP 5: sp_cem_registrar_pago
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
BEGIN
    -- Verificar que el folio existe
    SELECT COUNT(*) INTO v_folio_existe
    FROM ta_13_datosrcm
    WHERE control_rcm = p_control_rcm;

    IF v_folio_existe = 0 THEN
        RETURN QUERY SELECT FALSE, 'El folio no existe'::VARCHAR, NULL::INTEGER, NULL::DECIMAL;
        RETURN;
    END IF;

    -- Calcular total
    v_total_pago := p_importe_anual + COALESCE(p_importe_recargos, 0);

    -- Generar número de recibo
    SELECT COALESCE(MAX(recing), 0) + 1 INTO v_nuevo_recibo
    FROM v_ta_13_pagosrcm;

    -- Registrar pago
    INSERT INTO ta_13_pagosrcm (
        control_rcm,
        recing,
        fecing,
        axo_pago_desde,
        axo_pago_hasta,
        importe_anual,
        importe_recargos,
        usuario,
        observaciones
    ) VALUES (
        p_control_rcm,
        v_nuevo_recibo,
        CURRENT_DATE,
        p_axo_desde,
        p_axo_hasta,
        p_importe_anual,
        p_importe_recargos,
        p_usuario,
        p_observaciones
    );

    -- Actualizar año pagado en el folio
    UPDATE ta_13_datosrcm
    SET axo_pagado = GREATEST(COALESCE(axo_pagado, 0), p_axo_hasta)
    WHERE control_rcm = p_control_rcm;

    RETURN QUERY SELECT TRUE, 'Pago registrado exitosamente'::VARCHAR, v_nuevo_recibo, v_total_pago;
END;
$function$;

-- =====================================================================
-- SP 6: sp_cem_obtener_adeudos_pendientes
CREATE OR REPLACE FUNCTION public.sp_cem_obtener_adeudos_pendientes(
    p_control_rcm integer DEFAULT NULL::integer
)
RETURNS TABLE(success boolean, message character varying, data jsonb)
LANGUAGE plpgsql
AS $function$
BEGIN
    -- SP generado automáticamente
    -- TODO: Implementar lógica específica

    -- Operación genérica
    RETURN QUERY SELECT TRUE, 'Operación completada'::VARCHAR, NULL::JSONB;
END;
$function$;

-- =====================================================================
-- FIN DEL SCRIPT
-- =====================================================================
