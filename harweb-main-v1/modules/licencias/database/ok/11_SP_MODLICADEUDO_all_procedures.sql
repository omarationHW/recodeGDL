-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA MODIFICACIÓN LICENCIAS CON ADEUDO
-- Convención: SP_MODLICADEUDO_XXX
-- Generado: 2025-09-09
-- Módulo: 11 - MODLICADEUDOFRM (Prioridad Media)
-- ============================================

-- SP 1/6: SP_MODLICADEUDO_LIST
CREATE OR REPLACE FUNCTION SP_MODLICADEUDO_LIST(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_monto_desde NUMERIC(12,2) DEFAULT NULL,
    p_monto_hasta NUMERIC(12,2) DEFAULT NULL,
    p_estado_adeudo VARCHAR(30) DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    concepto_adeudo VARCHAR(255),
    monto_adeudo NUMERIC(12,2),
    fecha_vencimiento_pago DATE,
    estado_adeudo VARCHAR(30),
    dias_vencido INTEGER,
    recargos_acumulados NUMERIC(10,2),
    total_adeudo BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE v_total_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total_count FROM public.adeudos_licencias al
    WHERE (p_numero_licencia IS NULL OR al.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR al.propietario ILIKE '%' || p_propietario || '%')
      AND (p_monto_desde IS NULL OR al.monto_adeudo >= p_monto_desde)
      AND (p_monto_hasta IS NULL OR al.monto_adeudo <= p_monto_hasta)
      AND (p_estado_adeudo IS NULL OR al.estado_adeudo = upper(p_estado_adeudo));

    RETURN QUERY
    SELECT al.id, al.numero_licencia, al.propietario, al.concepto_adeudo, al.monto_adeudo,
           al.fecha_vencimiento_pago, al.estado_adeudo,
           (CURRENT_DATE - al.fecha_vencimiento_pago)::INTEGER as dias_vencido,
           al.recargos_acumulados, v_total_count as total_adeudo
    FROM public.adeudos_licencias al
    WHERE (p_numero_licencia IS NULL OR al.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR al.propietario ILIKE '%' || p_propietario || '%')
      AND (p_monto_desde IS NULL OR al.monto_adeudo >= p_monto_desde)
      AND (p_monto_hasta IS NULL OR al.monto_adeudo <= p_monto_hasta)
      AND (p_estado_adeudo IS NULL OR al.estado_adeudo = upper(p_estado_adeudo))
    ORDER BY al.fecha_vencimiento_pago ASC LIMIT p_limite OFFSET p_offset;
END;
$$;

-- SP 2/6: SP_MODLICADEUDO_GET
CREATE OR REPLACE FUNCTION SP_MODLICADEUDO_GET(p_numero_licencia VARCHAR(100))
RETURNS TABLE(
    numero_licencia VARCHAR(100), propietario VARCHAR(255), monto_total NUMERIC(12,2),
    conceptos_adeudo TEXT, fecha_ultimo_pago DATE, plan_pagos_activo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT al.numero_licencia, al.propietario, 
           SUM(al.monto_adeudo + al.recargos_acumulados) as monto_total,
           STRING_AGG(al.concepto_adeudo, ', ') as conceptos_adeudo,
           MAX(al.fecha_ultimo_pago) as fecha_ultimo_pago,
           bool_or(al.plan_pagos_activo) as plan_pagos_activo
    FROM public.adeudos_licencias al
    WHERE al.numero_licencia = p_numero_licencia AND al.estado_adeudo = 'PENDIENTE'
    GROUP BY al.numero_licencia, al.propietario;
END;
$$;

-- SP 3/6: SP_MODLICADEUDO_CREATE
CREATE OR REPLACE FUNCTION SP_MODLICADEUDO_CREATE(
    p_numero_licencia VARCHAR(100), p_concepto_adeudo VARCHAR(255),
    p_monto_adeudo NUMERIC(12,2), p_fecha_vencimiento_pago DATE,
    p_usuario_registro VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT, id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE v_new_id INTEGER;
BEGIN
    INSERT INTO public.adeudos_licencias (numero_licencia, concepto_adeudo, monto_adeudo, fecha_vencimiento_pago, usuario_registro)
    VALUES (upper(trim(p_numero_licencia)), p_concepto_adeudo, p_monto_adeudo, p_fecha_vencimiento_pago, upper(trim(p_usuario_registro)))
    RETURNING public.adeudos_public.id INTO v_new_id;
    
    RETURN QUERY SELECT TRUE, 'Adeudo registrado correctamente.', v_new_id;
END;
$$;

-- SP 4/6: SP_MODLICADEUDO_UPDATE
CREATE OR REPLACE FUNCTION SP_MODLICADEUDO_UPDATE(
    p_id INTEGER, p_monto_adeudo NUMERIC(12,2) DEFAULT NULL,
    p_recargos_acumulados NUMERIC(10,2) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.adeudos_licencias
    SET monto_adeudo = COALESCE(p_monto_adeudo, monto_adeudo),
        recargos_acumulados = COALESCE(p_recargos_acumulados, recargos_acumulados)
    WHERE id = p_id;
    
    RETURN QUERY SELECT TRUE, 'Adeudo actualizado correctamente.';
END;
$$;

-- SP 5/6: SP_MODLICADEUDO_PAGAR
CREATE OR REPLACE FUNCTION SP_MODLICADEUDO_PAGAR(
    p_numero_licencia VARCHAR(100), p_monto_pago NUMERIC(12,2),
    p_funcionario_cajero VARCHAR(100)
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.adeudos_licencias
    SET estado_adeudo = 'PAGADO', fecha_ultimo_pago = CURRENT_DATE,
        funcionario_cajero = upper(trim(p_funcionario_cajero))
    WHERE numero_licencia = p_numero_licencia AND monto_adeudo <= p_monto_pago;
    
    RETURN QUERY SELECT TRUE, 'Pagos aplicados correctamente.';
END;
$$;

-- SP 6/6: SP_MODLICADEUDO_ESTADISTICAS
CREATE OR REPLACE FUNCTION SP_MODLICADEUDO_ESTADISTICAS()
RETURNS TABLE(
    total_adeudos INTEGER, monto_total_pendiente NUMERIC(15,2),
    promedio_adeudo NUMERIC(10,2), recargos_totales NUMERIC(12,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(*)::INTEGER, SUM(monto_adeudo), AVG(monto_adeudo), SUM(recargos_acumulados)
    FROM public.adeudos_licencias WHERE estado_adeudo = 'PENDIENTE';
END;
$$;