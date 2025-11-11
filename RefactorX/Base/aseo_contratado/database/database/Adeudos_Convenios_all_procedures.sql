-- SP ASEO_ADEUDOS_PENDIENTES
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_pendientes(p_control_contrato INTEGER DEFAULT NULL)
RETURNS TABLE(adeudo_id INTEGER, control_contrato INTEGER, folio_adeudo VARCHAR, periodo VARCHAR, ejercicio INTEGER,
fecha_vencimiento DATE, monto_original NUMERIC, monto_pagado NUMERIC, monto_pendiente NUMERIC,
status_pago VARCHAR, dias_mora INTEGER) AS $function$
BEGIN
RETURN QUERY SELECT a.adeudo_id, a.control_contrato, a.folio_adeudo, a.periodo, a.ejercicio,
a.fecha_vencimiento, a.monto_original, a.monto_pagado, a.monto_pendiente, a.status_pago,
CASE WHEN a.fecha_vencimiento < NOW()::DATE THEN EXTRACT(DAY FROM NOW() - a.fecha_vencimiento)::INTEGER ELSE 0 END as dias_mora
FROM ta_16_adeudos a WHERE a.status_pago IN ('PENDIENTE', 'PARCIAL') AND a.activo = true
AND (p_control_contrato IS NULL OR a.control_contrato = p_control_contrato) ORDER BY a.fecha_vencimiento;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_ADEUDOS_POR_CONTRATO
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_por_contrato(p_control_contrato INTEGER)
RETURNS TABLE(adeudo_id INTEGER, folio_adeudo VARCHAR, periodo VARCHAR, ejercicio INTEGER,
fecha_vencimiento DATE, monto_original NUMERIC, monto_pagado NUMERIC, monto_pendiente NUMERIC,
status_pago VARCHAR, observaciones TEXT) AS $function$
BEGIN
RETURN QUERY SELECT a.adeudo_id, a.folio_adeudo, a.periodo, a.ejercicio, a.fecha_vencimiento,
a.monto_original, a.monto_pagado, a.monto_pendiente, a.status_pago, a.observaciones
FROM ta_16_adeudos a WHERE a.control_contrato = p_control_contrato AND a.activo = true
ORDER BY a.ejercicio DESC, a.periodo DESC;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_ADEUDOS_CARGA_MASIVA (FIXED)
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_carga_masiva(p_ejercicio INTEGER, p_periodo VARCHAR, p_fecha_vencimiento DATE)
RETURNS TABLE(success BOOLEAN, message TEXT, total_creados INTEGER) AS $function$
DECLARE 
    v_creados INTEGER := 0; 
    v_adeudo_id INTEGER;
    v_contrato RECORD;
BEGIN
    FOR v_contrato IN SELECT control_contrato FROM ta_16_contratos WHERE status_vigencia = 'V' LOOP
        SELECT COALESCE(MAX(adeudo_id), 0) + 1 INTO v_adeudo_id FROM ta_16_adeudos;
        INSERT INTO ta_16_adeudos (adeudo_id, control_contrato, folio_adeudo, periodo, ejercicio,
        fecha_vencimiento, monto_original, monto_pagado, monto_pendiente, status_pago, activo, created_at)
        VALUES (v_adeudo_id, v_contrato.control_contrato, 'AD-' || v_adeudo_id, p_periodo, p_ejercicio, p_fecha_vencimiento,
        100.00, 0, 100.00, 'PENDIENTE', true, NOW());
        v_creados := v_creados + 1;
    END LOOP;
    RETURN QUERY SELECT TRUE, 'Adeudos creados', v_creados;
EXCEPTION WHEN OTHERS THEN 
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_ADEUDOS_GENERAR_RECARGOS
CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_generar_recargos(p_ejercicio INTEGER DEFAULT NULL)
RETURNS TABLE(success BOOLEAN, message TEXT, total_recargos INTEGER) AS $function$
DECLARE 
    v_recargos INTEGER := 0;
BEGIN
    UPDATE ta_16_adeudos SET monto_pendiente = monto_pendiente + (monto_original * 0.02), updated_at = NOW()
    WHERE status_pago = 'PENDIENTE' AND fecha_vencimiento < NOW() AND (p_ejercicio IS NULL OR ejercicio = p_ejercicio) AND activo = true;
    GET DIAGNOSTICS v_recargos = ROW_COUNT;
    RETURN QUERY SELECT TRUE, 'Recargos generados', v_recargos;
EXCEPTION WHEN OTHERS THEN 
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_APLICAR_EXENCION
CREATE OR REPLACE FUNCTION public.sp_aseo_aplicar_exencion(p_adeudo_id INTEGER, p_porcentaje NUMERIC, p_obs TEXT DEFAULT NULL)
RETURNS TABLE(success BOOLEAN, message TEXT, monto_exentado NUMERIC) AS $function$
DECLARE 
    v_monto NUMERIC; 
    v_exencion NUMERIC;
BEGIN
    SELECT monto_pendiente INTO v_monto FROM ta_16_adeudos WHERE adeudo_id = p_adeudo_id;
    IF v_monto IS NULL THEN 
        RETURN QUERY SELECT FALSE, 'Adeudo no encontrado', 0::NUMERIC; 
        RETURN; 
    END IF;
    v_exencion := v_monto * (p_porcentaje / 100);
    UPDATE ta_16_adeudos SET monto_pendiente = monto_pendiente - v_exencion, updated_at = NOW() WHERE adeudo_id = p_adeudo_id;
    RETURN QUERY SELECT TRUE, 'Exención aplicada', v_exencion;
EXCEPTION WHEN OTHERS THEN 
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0::NUMERIC;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_CONVENIO_CREAR
CREATE OR REPLACE FUNCTION public.sp_aseo_convenio_crear(p_contrato INTEGER, p_adeudos INTEGER[], p_parcialidades INTEGER, p_obs TEXT DEFAULT NULL)
RETURNS TABLE(success BOOLEAN, message TEXT, convenio_id INTEGER) AS $function$
DECLARE 
    v_convenio INTEGER; 
    v_total NUMERIC; 
    v_parcial NUMERIC;
BEGIN
    v_convenio := EXTRACT(EPOCH FROM NOW())::INTEGER;
    SELECT SUM(monto_pendiente) INTO v_total FROM ta_16_adeudos WHERE adeudo_id = ANY(p_adeudos) AND control_contrato = p_contrato;
    IF v_total IS NULL OR v_total = 0 THEN 
        RETURN QUERY SELECT FALSE, 'No se encontraron adeudos', NULL::INTEGER; 
        RETURN; 
    END IF;
    v_parcial := v_total / p_parcialidades;
    UPDATE ta_16_adeudos SET status_pago = 'EN_CONVENIO', updated_at = NOW() WHERE adeudo_id = ANY(p_adeudos);
    RETURN QUERY SELECT TRUE, 'Convenio creado', v_convenio;
EXCEPTION WHEN OTHERS THEN 
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, NULL::INTEGER;
END; $function$ LANGUAGE plpgsql;

-- SP ASEO_CONVENIOS_CONSULTAR
CREATE OR REPLACE FUNCTION public.sp_aseo_convenios_consultar(p_control_contrato INTEGER DEFAULT NULL)
RETURNS TABLE(adeudo_id INTEGER, control_contrato INTEGER, folio_adeudo VARCHAR, monto_pendiente NUMERIC, status_pago VARCHAR, observaciones TEXT) AS $function$
BEGIN
    RETURN QUERY SELECT a.adeudo_id, a.control_contrato, a.folio_adeudo, a.monto_pendiente, a.status_pago, a.observaciones
    FROM ta_16_adeudos a WHERE a.status_pago = 'EN_CONVENIO' AND a.activo = true
    AND (p_control_contrato IS NULL OR a.control_contrato = p_control_contrato) ORDER BY a.updated_at DESC;
END; $function$ LANGUAGE plpgsql;
