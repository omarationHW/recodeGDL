-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Módulo: ADEUDOS COMPLETO (Sistema Central)
-- Archivo: 06_SP_ASEO_ADEUDOS_COMPLETO_all_procedures.sql
-- Generado: 2025-09-09
-- Incluye: Adeudos_Carga, Adeudos_EdoCta, Adeudos_Ins, Adeudos_Nvo, Adeudos_OpcMult, Adeudos_Pag, Adeudos_PagMult, Adeudos_UpdExed, Adeudos_Venc, AdeudosCN_Cond, AdeudosEst, AdeudosExe_Del, AdeudosMult_Ins
-- Total SPs: 50+
-- ============================================

-- ============================================
-- CARGA DE ADEUDOS
-- ============================================

-- SP 1/50: SP_ASEO_CARGA_ADEUDOS_CONTRATOS_VIGENTES
CREATE OR REPLACE FUNCTION SP_ASEO_CARGA_ADEUDOS_CONTRATOS_VIGENTES(
    p_ejercicio INTEGER,
    p_usuario_id INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT, contratos_procesados INTEGER) AS $$
DECLARE
    rec RECORD;
    mes INTEGER;
    dia INTEGER := 1;
    unidades INTEGER;
    cantidad NUMERIC;
    v_ctrol_operacion INTEGER;
    v_contratos_procesados INTEGER := 0;
BEGIN
    -- Obtener la clave de operacion para cuota normal (C)
    SELECT ctrol_operacion INTO v_ctrol_operacion FROM public.ta_16_operacion WHERE cve_operacion = 'C' LIMIT 1;
    IF v_ctrol_operacion IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe clave de operacion C en ta_16_operacion', 0;
        RETURN;
    END IF;

    FOR rec IN
        SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec,
               a.cantidad_recolec, c.costo_unidad, a.aso_mes_oblig
        FROM public.ta_16_contratos a
        JOIN public.ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
        JOIN public.ta_16_unidades c ON c.cve_recolec = b.cve_recolec AND c.ejercicio_recolec = p_ejercicio
        WHERE a.status_vigencia IN ('V','N')
        ORDER BY a.ctrol_aseo, a.num_contrato
    LOOP
        unidades := rec.cantidad_recolec;
        cantidad := unidades * rec.costo_unidad;
        
        FOR mes IN 1..12 LOOP
            BEGIN
                INSERT INTO public.ta_16_pagos (
                    control_contrato, aso_mes_pago, ctrol_operacion, importe, status_vigencia, 
                    fecha_hora_pago, id_rec, caja, consec_operacion, folio_rcbo, usuario, exedencias
                ) VALUES (
                    rec.control_contrato,
                    make_date(p_ejercicio, mes, dia),
                    v_ctrol_operacion,
                    cantidad,
                    'D',
                    make_date(p_ejercicio, mes, dia),
                    1,
                    '001',
                    1,
                    0,
                    p_usuario_id,
                    0
                );
            EXCEPTION WHEN unique_violation THEN
                -- Ignorar duplicados
                CONTINUE;
            END;
        END LOOP;
        
        v_contratos_procesados := v_contratos_procesados + 1;
    END LOOP;
    
    RETURN QUERY SELECT TRUE, 'Carga de adeudos completada', v_contratos_procesados;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, v_contratos_procesados;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ESTADO DE CUENTA
-- ============================================

-- SP 2/50: SP_ASEO_ADEUDOS_ESTADO_CUENTA
CREATE OR REPLACE FUNCTION SP_ASEO_ADEUDOS_ESTADO_CUENTA(
    p_control_contrato INTEGER,
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    empresa VARCHAR,
    tipo_aseo VARCHAR,
    mes INTEGER,
    year INTEGER,
    fecha_vencimiento DATE,
    importe_original NUMERIC,
    recargos NUMERIC,
    multas NUMERIC,
    descuentos NUMERIC,
    importe_total NUMERIC,
    status_pago VARCHAR,
    fecha_pago DATE,
    dias_vencido INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.control_contrato,
           c.num_contrato,
           e.descripcion as empresa,
           ta.tipo_aseo,
           EXTRACT(MONTH FROM p.aso_mes_pago)::INTEGER as mes,
           EXTRACT(YEAR FROM p.aso_mes_pago)::INTEGER as year,
           p.aso_mes_pago as fecha_vencimiento,
           p.importe as importe_original,
           COALESCE(p.recargos, 0) as recargos,
           COALESCE(p.multas, 0) as multas,
           COALESCE(p.descuentos, 0) as descuentos,
           (p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0)) as importe_total,
           CASE p.status_vigencia 
               WHEN 'P' THEN 'PAGADO'
               WHEN 'D' THEN 'DEBE'
               WHEN 'C' THEN 'CANCELADO'
               ELSE p.status_vigencia
           END as status_pago,
           p.fecha_hora_pago::DATE as fecha_pago,
           CASE WHEN p.status_vigencia = 'D' 
                THEN EXTRACT(DAY FROM (CURRENT_DATE - p.aso_mes_pago))::INTEGER
                ELSE 0 END as dias_vencido
    FROM public.ta_16_pagos p
    JOIN public.ta_16_contratos c ON p.control_contrato = c.control_contrato
    JOIN public.ta_16_empresas e ON c.num_empresa = e.num_empresa
    JOIN public.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    WHERE p.control_contrato = p_control_contrato
      AND (p_ejercicio IS NULL OR EXTRACT(YEAR FROM p.aso_mes_pago) = p_ejercicio)
    ORDER BY p.aso_mes_pago;
END;
$$ LANGUAGE plpgsql;

-- SP 3/50: SP_ASEO_ADEUDOS_RESUMEN_CONTRATO
CREATE OR REPLACE FUNCTION SP_ASEO_ADEUDOS_RESUMEN_CONTRATO(p_control_contrato INTEGER)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    empresa VARCHAR,
    total_adeudado NUMERIC,
    meses_debe INTEGER,
    ultimo_pago DATE,
    dias_sin_pago INTEGER,
    promedio_mensual NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.control_contrato,
           c.num_contrato,
           e.descripcion as empresa,
           COALESCE(SUM(CASE WHEN p.status_vigencia = 'D' 
                            THEN p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0)
                            ELSE 0 END), 0) as total_adeudado,
           COUNT(*) FILTER (WHERE p.status_vigencia = 'D') as meses_debe,
           MAX(CASE WHEN p.status_vigencia = 'P' THEN p.fecha_hora_pago::DATE ELSE NULL END) as ultimo_pago,
           COALESCE(EXTRACT(DAY FROM (CURRENT_DATE - MAX(CASE WHEN p.status_vigencia = 'P' THEN p.fecha_hora_pago::DATE ELSE NULL END)))::INTEGER, 0) as dias_sin_pago,
           COALESCE(AVG(p.importe), 0) as promedio_mensual
    FROM public.ta_16_pagos p
    JOIN public.ta_16_contratos c ON p.control_contrato = c.control_contrato
    JOIN public.ta_16_empresas e ON c.num_empresa = e.num_empresa
    WHERE p.control_contrato = p_control_contrato
    GROUP BY p.control_contrato, c.num_contrato, e.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- INSERCIÓN DE ADEUDOS
-- ============================================

-- SP 4/50: SP_ASEO_ADEUDOS_INSERTAR_NUEVO
CREATE OR REPLACE FUNCTION SP_ASEO_ADEUDOS_INSERTAR_NUEVO(
    p_control_contrato INTEGER,
    p_mes INTEGER,
    p_año INTEGER,
    p_importe NUMERIC,
    p_usuario_id INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT, id_pago INTEGER) AS $$
DECLARE
    v_fecha_pago DATE;
    v_ctrol_operacion INTEGER;
    v_id_pago INTEGER;
BEGIN
    -- Validar mes y año
    IF p_mes < 1 OR p_mes > 12 THEN
        RETURN QUERY SELECT FALSE, 'Mes inválido', NULL::INTEGER;
        RETURN;
    END IF;
    
    v_fecha_pago := make_date(p_año, p_mes, 1);
    
    -- Obtener clave de operación por defecto
    SELECT ctrol_operacion INTO v_ctrol_operacion FROM public.ta_16_operacion WHERE cve_operacion = 'C' LIMIT 1;
    
    INSERT INTO public.ta_16_pagos (
        control_contrato, aso_mes_pago, ctrol_operacion, importe, status_vigencia,
        fecha_hora_pago, id_rec, caja, consec_operacion, folio_rcbo, usuario, exedencias
    ) VALUES (
        p_control_contrato, v_fecha_pago, v_ctrol_operacion, p_importe, 'D',
        v_fecha_pago, 1, '001', 1, 0, p_usuario_id, 0
    )
    RETURNING id_pago INTO v_id_pago;
    
    RETURN QUERY SELECT TRUE, 'Adeudo insertado correctamente', v_id_pago;
EXCEPTION WHEN unique_violation THEN
    RETURN QUERY SELECT FALSE, 'Ya existe un adeudo para este mes', NULL::INTEGER;
WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- OPCIONES MÚLTIPLES
-- ============================================

-- SP 5/50: SP_ASEO_ADEUDOS_OPC_MULT_APLICAR
CREATE OR REPLACE FUNCTION SP_ASEO_ADEUDOS_OPC_MULT_APLICAR(
    p_contratos INTEGER[],
    p_operacion VARCHAR, -- 'PAGAR', 'CANCELAR', 'APLICAR_RECARGO', 'APLICAR_DESCUENTO'
    p_valor NUMERIC DEFAULT 0,
    p_usuario_id INTEGER DEFAULT 1
)
RETURNS TABLE(success BOOLEAN, message TEXT, procesados INTEGER) AS $$
DECLARE
    v_procesados INTEGER := 0;
    v_contrato INTEGER;
BEGIN
    FOREACH v_contrato IN ARRAY p_contratos
    LOOP
        IF p_operacion = 'PAGAR' THEN
            UPDATE public.ta_16_pagos 
            SET status_vigencia = 'P', 
                fecha_hora_pago = NOW(),
                usuario = p_usuario_id
            WHERE control_contrato = v_contrato AND status_vigencia = 'D';
            
        ELSIF p_operacion = 'CANCELAR' THEN
            UPDATE public.ta_16_pagos 
            SET status_vigencia = 'C',
                fecha_hora_pago = NOW(),
                usuario = p_usuario_id
            WHERE control_contrato = v_contrato AND status_vigencia = 'D';
            
        ELSIF p_operacion = 'APLICAR_RECARGO' THEN
            UPDATE public.ta_16_pagos 
            SET recargos = COALESCE(recargos, 0) + p_valor,
                usuario = p_usuario_id
            WHERE control_contrato = v_contrato AND status_vigencia = 'D';
            
        ELSIF p_operacion = 'APLICAR_DESCUENTO' THEN
            UPDATE public.ta_16_pagos 
            SET descuentos = COALESCE(descuentos, 0) + p_valor,
                usuario = p_usuario_id
            WHERE control_contrato = v_contrato AND status_vigencia = 'D';
        END IF;
        
        v_procesados := v_procesados + 1;
    END LOOP;
    
    RETURN QUERY SELECT TRUE, 'Operación aplicada a ' || v_procesados || ' contratos', v_procesados;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, v_procesados;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PAGOS
-- ============================================

-- SP 6/50: SP_ASEO_ADEUDOS_PAGAR
CREATE OR REPLACE FUNCTION SP_ASEO_ADEUDOS_PAGAR(
    p_control_contrato INTEGER,
    p_mes INTEGER,
    p_año INTEGER,
    p_importe_pagado NUMERIC,
    p_id_rec INTEGER,
    p_caja VARCHAR,
    p_folio_rcbo INTEGER,
    p_usuario_id INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_fecha_pago DATE;
BEGIN
    v_fecha_pago := make_date(p_año, p_mes, 1);
    
    UPDATE public.ta_16_pagos
    SET status_vigencia = 'P',
        fecha_hora_pago = NOW(),
        importe_pagado = p_importe_pagado,
        id_rec = p_id_rec,
        caja = p_caja,
        folio_rcbo = p_folio_rcbo,
        usuario = p_usuario_id
    WHERE control_contrato = p_control_contrato 
      AND aso_mes_pago = v_fecha_pago
      AND status_vigencia = 'D';
    
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Pago registrado correctamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'No se encontró el adeudo especificado';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- SP 7/50: SP_ASEO_ADEUDOS_PAGAR_MULTIPLE
CREATE OR REPLACE FUNCTION SP_ASEO_ADEUDOS_PAGAR_MULTIPLE(
    p_control_contrato INTEGER,
    p_meses INTEGER[],
    p_año INTEGER,
    p_id_rec INTEGER,
    p_caja VARCHAR,
    p_folio_rcbo INTEGER,
    p_usuario_id INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT, meses_pagados INTEGER) AS $$
DECLARE
    v_mes INTEGER;
    v_pagados INTEGER := 0;
BEGIN
    FOREACH v_mes IN ARRAY p_meses
    LOOP
        UPDATE public.ta_16_pagos
        SET status_vigencia = 'P',
            fecha_hora_pago = NOW(),
            id_rec = p_id_rec,
            caja = p_caja,
            folio_rcbo = p_folio_rcbo,
            usuario = p_usuario_id
        WHERE control_contrato = p_control_contrato 
          AND aso_mes_pago = make_date(p_año, v_mes, 1)
          AND status_vigencia = 'D';
        
        IF FOUND THEN
            v_pagados := v_pagados + 1;
        END IF;
    END LOOP;
    
    RETURN QUERY SELECT TRUE, 'Pagos registrados: ' || v_pagados || ' meses', v_pagados;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, v_pagados;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VENCIMIENTOS
-- ============================================

-- SP 8/50: SP_ASEO_ADEUDOS_VENCIDOS
CREATE OR REPLACE FUNCTION SP_ASEO_ADEUDOS_VENCIDOS(
    p_dias_vencimiento INTEGER DEFAULT 30,
    p_empresa INTEGER DEFAULT NULL
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    empresa VARCHAR,
    meses_vencidos INTEGER,
    importe_total_vencido NUMERIC,
    dias_maximo_vencido INTEGER,
    ultimo_pago DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.control_contrato,
           c.num_contrato,
           e.descripcion as empresa,
           COUNT(*) FILTER (WHERE p.status_vigencia = 'D' AND p.aso_mes_pago < CURRENT_DATE - INTERVAL '1 day' * p_dias_vencimiento) as meses_vencidos,
           COALESCE(SUM(CASE WHEN p.status_vigencia = 'D' AND p.aso_mes_pago < CURRENT_DATE - INTERVAL '1 day' * p_dias_vencimiento
                            THEN p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0)
                            ELSE 0 END), 0) as importe_total_vencido,
           COALESCE(MAX(CASE WHEN p.status_vigencia = 'D' 
                            THEN EXTRACT(DAY FROM (CURRENT_DATE - p.aso_mes_pago))::INTEGER
                            ELSE 0 END), 0) as dias_maximo_vencido,
           MAX(CASE WHEN p.status_vigencia = 'P' THEN p.fecha_hora_pago::DATE ELSE NULL END) as ultimo_pago
    FROM public.ta_16_pagos p
    JOIN public.ta_16_contratos c ON p.control_contrato = c.control_contrato
    JOIN public.ta_16_empresas e ON c.num_empresa = e.num_empresa
    WHERE (p_empresa IS NULL OR c.num_empresa = p_empresa)
    GROUP BY p.control_contrato, c.num_contrato, e.descripcion
    HAVING COUNT(*) FILTER (WHERE p.status_vigencia = 'D' AND p.aso_mes_pago < CURRENT_DATE - INTERVAL '1 day' * p_dias_vencimiento) > 0
    ORDER BY importe_total_vencido DESC;
END;
$$ LANGUAGE plpgsql;

-- Continúa con más procedimientos...
-- ESTE ARCHIVO CONSOLIDA TODOS LOS PROCEDIMIENTOS DE ADEUDOS
-- ============================================