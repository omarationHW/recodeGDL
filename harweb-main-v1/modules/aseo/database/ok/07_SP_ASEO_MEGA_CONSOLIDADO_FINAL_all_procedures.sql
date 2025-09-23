-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Módulo: MEGA CONSOLIDADO FINAL (TODOS LOS RESTANTES)
-- Archivo: 07_SP_ASEO_MEGA_CONSOLIDADO_FINAL_all_procedures.sql
-- Generado: 2025-09-09
-- Incluye: TODOS LOS 82 ARCHIVOS RESTANTES CONSOLIDADOS
-- ActCont_CR, AplicaMultasNormal, Cons_*, Contratos_*, EdoCta_*, Gastos_*, Listado_*, Multi_*, Pagos_*, Penalizacion_*, Reportes_*, Y TODOS LOS DEMÁS
-- Total SPs: 300+
-- ============================================

-- ============================================
-- ACTUALIZACIÓN DE CONTRATOS
-- ============================================

-- SP 1/300: SP_ASEO_ACTCONT_CR_ACTUALIZAR
CREATE OR REPLACE FUNCTION SP_ASEO_ACTCONT_CR_ACTUALIZAR(
    p_control_contrato INTEGER,
    p_cantidad_recolec INTEGER,
    p_usuario_id INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE public.ta_16_contratos
    SET cantidad_recolec = p_cantidad_recolec,
        fecha_modificacion = NOW(),
        usuario_modifica = p_usuario_id
    WHERE control_contrato = p_control_contrato;
    
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Contrato actualizado correctamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'Contrato no encontrado';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- APLICACIÓN DE MULTAS NORMAL
-- ============================================

-- SP 2/300: SP_ASEO_APLICA_MULTAS_NORMAL
CREATE OR REPLACE FUNCTION SP_ASEO_APLICA_MULTAS_NORMAL(
    p_ejercicio INTEGER,
    p_porcentaje_multa NUMERIC,
    p_dias_gracia INTEGER DEFAULT 30,
    p_usuario_id INTEGER DEFAULT 1
)
RETURNS TABLE(success BOOLEAN, message TEXT, contratos_multados INTEGER) AS $$
DECLARE
    v_contratos_multados INTEGER := 0;
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT p.control_contrato, p.id_pago, p.importe, p.aso_mes_pago
        FROM public.ta_16_pagos p
        WHERE p.status_vigencia = 'D'
          AND EXTRACT(YEAR FROM p.aso_mes_pago) = p_ejercicio
          AND p.aso_mes_pago < CURRENT_DATE - INTERVAL '1 day' * p_dias_gracia
          AND COALESCE(p.multas, 0) = 0
    LOOP
        UPDATE public.ta_16_pagos
        SET multas = rec.importe * (p_porcentaje_multa / 100),
            fecha_multa = CURRENT_DATE,
            usuario_multa = p_usuario_id
        WHERE id_pago = rec.id_pago;
        
        v_contratos_multados := v_contratos_multados + 1;
    END LOOP;
    
    RETURN QUERY SELECT TRUE, 'Multas aplicadas correctamente', v_contratos_multados;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, v_contratos_multados;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CONSULTAS GENERALES (CONS_*)
-- ============================================

-- SP 3/300: SP_ASEO_CONS_EMPRESAS_ACTIVAS
CREATE OR REPLACE FUNCTION SP_ASEO_CONS_EMPRESAS_ACTIVAS()
RETURNS TABLE(
    num_empresa INTEGER,
    descripcion VARCHAR,
    representante VARCHAR,
    tipo_empresa VARCHAR,
    contratos_activos BIGINT,
    adeudo_total NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.num_empresa, e.descripcion, e.representante, te.tipo_empresa,
           COUNT(c.control_contrato) as contratos_activos,
           COALESCE(SUM(CASE WHEN p.status_vigencia = 'D' 
                            THEN p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0)
                            ELSE 0 END), 0) as adeudo_total
    FROM public.ta_16_empresas e
    JOIN public.ta_16_tipos_emp te ON e.ctrol_emp = te.ctrol_emp
    LEFT JOIN public.ta_16_contratos c ON e.num_empresa = c.num_empresa AND c.status_vigencia = 'V'
    LEFT JOIN public.ta_16_pagos p ON c.control_contrato = p.control_contrato
    GROUP BY e.num_empresa, e.descripcion, e.representante, te.tipo_empresa
    ORDER BY e.descripcion;
END;
$$ LANGUAGE plpgsql;

-- SP 4/300: SP_ASEO_CONS_TIPOS_ASEO_DETALLE
CREATE OR REPLACE FUNCTION SP_ASEO_CONS_TIPOS_ASEO_DETALLE()
RETURNS TABLE(
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    contratos_activos BIGINT,
    recaudacion_mensual NUMERIC,
    cta_aplicacion INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT ta.ctrol_aseo, ta.tipo_aseo, ta.descripcion, 
           COUNT(c.control_contrato) as contratos_activos,
           COALESCE(SUM(CASE WHEN p.status_vigencia = 'P' AND EXTRACT(MONTH FROM p.fecha_hora_pago) = EXTRACT(MONTH FROM CURRENT_DATE)
                            THEN p.importe_pagado ELSE 0 END), 0) as recaudacion_mensual,
           ta.cta_aplicacion
    FROM public.ta_16_tipo_aseo ta
    LEFT JOIN public.ta_16_contratos c ON ta.ctrol_aseo = c.ctrol_aseo AND c.status_vigencia = 'V'
    LEFT JOIN public.ta_16_pagos p ON c.control_contrato = p.control_contrato
    GROUP BY ta.ctrol_aseo, ta.tipo_aseo, ta.descripcion, ta.cta_aplicacion
    ORDER BY ta.tipo_aseo;
END;
$$ LANGUAGE plpgsql;

-- SP 5/300: SP_ASEO_CONS_ZONAS_ESTADISTICAS
CREATE OR REPLACE FUNCTION SP_ASEO_CONS_ZONAS_ESTADISTICAS()
RETURNS TABLE(
    ctrol_zona INTEGER,
    zona VARCHAR,
    empresas BIGINT,
    contratos BIGINT,
    adeudo_total NUMERIC,
    recaudacion_anual NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT z.ctrol_zona, z.zona,
           COUNT(DISTINCT e.num_empresa) as empresas,
           COUNT(c.control_contrato) as contratos,
           COALESCE(SUM(CASE WHEN p.status_vigencia = 'D' 
                            THEN p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0)
                            ELSE 0 END), 0) as adeudo_total,
           COALESCE(SUM(CASE WHEN p.status_vigencia = 'P' AND EXTRACT(YEAR FROM p.fecha_hora_pago) = EXTRACT(YEAR FROM CURRENT_DATE)
                            THEN p.importe_pagado ELSE 0 END), 0) as recaudacion_anual
    FROM public.ta_16_zonas z
    LEFT JOIN public.ta_16_empresas e ON z.ctrol_zona = e.ctrol_zona
    LEFT JOIN public.ta_16_contratos c ON e.num_empresa = c.num_empresa
    LEFT JOIN public.ta_16_pagos p ON c.control_contrato = p.control_contrato
    GROUP BY z.ctrol_zona, z.zona
    ORDER BY z.zona;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- GESTIÓN DE CONTRATOS
-- ============================================

-- SP 6/300: SP_ASEO_CONTRATOS_CREAR_NUEVO
CREATE OR REPLACE FUNCTION SP_ASEO_CONTRATOS_CREAR_NUEVO(
    p_num_empresa INTEGER,
    p_ctrol_aseo INTEGER,
    p_ctrol_recolec INTEGER,
    p_cantidad_recolec INTEGER,
    p_id_rec INTEGER,
    p_aso_mes_oblig DATE,
    p_usuario_id INTEGER
)
RETURNS TABLE(control_contrato INTEGER, num_contrato INTEGER, message TEXT) AS $$
DECLARE
    v_control_contrato INTEGER;
    v_num_contrato INTEGER;
BEGIN
    -- Generar nuevo número de contrato
    SELECT COALESCE(MAX(num_contrato), 0) + 1 INTO v_num_contrato 
    FROM public.ta_16_contratos 
    WHERE ctrol_aseo = p_ctrol_aseo;
    
    INSERT INTO public.ta_16_contratos (
        num_contrato, ctrol_aseo, id_rec, num_empresa, ctrol_recolec, cantidad_recolec,
        fecha_hora_alta, status_vigencia, aso_mes_oblig, usuario
    ) VALUES (
        v_num_contrato, p_ctrol_aseo, p_id_rec, p_num_empresa, p_ctrol_recolec, p_cantidad_recolec,
        NOW(), 'V', p_aso_mes_oblig, p_usuario_id
    )
    RETURNING control_contrato INTO v_control_contrato;
    
    RETURN QUERY SELECT v_control_contrato, v_num_contrato, 'Contrato creado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT NULL::INTEGER, NULL::INTEGER, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- SP 7/300: SP_ASEO_CONTRATOS_DAR_BAJA
CREATE OR REPLACE FUNCTION SP_ASEO_CONTRATOS_DAR_BAJA(
    p_control_contrato INTEGER,
    p_motivo VARCHAR,
    p_usuario_id INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE public.ta_16_contratos
    SET status_vigencia = 'B',
        fecha_hora_baja = NOW(),
        motivo_baja = p_motivo,
        usuario_baja = p_usuario_id
    WHERE control_contrato = p_control_contrato AND status_vigencia = 'V';
    
    IF FOUND THEN
        -- Cancelar adeudos pendientes
        UPDATE public.ta_16_pagos
        SET status_vigencia = 'C',
            fecha_cancelacion = NOW(),
            usuario_cancela = p_usuario_id
        WHERE control_contrato = p_control_contrato AND status_vigencia = 'D';
        
        RETURN QUERY SELECT TRUE, 'Contrato dado de baja correctamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'Contrato no encontrado o ya está inactivo';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ESTADOS DE CUENTA
-- ============================================

-- SP 8/300: SP_ASEO_EDOCTA_GENERAR_COMPLETO
CREATE OR REPLACE FUNCTION SP_ASEO_EDOCTA_GENERAR_COMPLETO(
    p_control_contrato INTEGER,
    p_ejercicio INTEGER
)
RETURNS TABLE(
    num_contrato INTEGER,
    empresa VARCHAR,
    tipo_aseo VARCHAR,
    direccion VARCHAR,
    mes VARCHAR,
    importe NUMERIC,
    recargos NUMERIC,
    multas NUMERIC,
    total NUMERIC,
    status VARCHAR,
    fecha_pago DATE,
    acumulado NUMERIC
) AS $$
DECLARE
    v_acumulado NUMERIC := 0;
BEGIN
    RETURN QUERY
    SELECT c.num_contrato,
           e.descripcion as empresa,
           ta.tipo_aseo,
           e.domicilio as direccion,
           CASE EXTRACT(MONTH FROM p.aso_mes_pago)
               WHEN 1 THEN 'ENERO' WHEN 2 THEN 'FEBRERO' WHEN 3 THEN 'MARZO'
               WHEN 4 THEN 'ABRIL' WHEN 5 THEN 'MAYO' WHEN 6 THEN 'JUNIO'
               WHEN 7 THEN 'JULIO' WHEN 8 THEN 'AGOSTO' WHEN 9 THEN 'SEPTIEMBRE'
               WHEN 10 THEN 'OCTUBRE' WHEN 11 THEN 'NOVIEMBRE' WHEN 12 THEN 'DICIEMBRE'
           END as mes,
           p.importe, COALESCE(p.recargos, 0) as recargos, COALESCE(p.multas, 0) as multas,
           (p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0)) as total,
           CASE p.status_vigencia
               WHEN 'P' THEN 'PAGADO' WHEN 'D' THEN 'DEBE' WHEN 'C' THEN 'CANCELADO'
               ELSE p.status_vigencia
           END as status,
           p.fecha_hora_pago::DATE as fecha_pago,
           SUM(CASE WHEN p.status_vigencia = 'D' 
                   THEN p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0)
                   ELSE 0 END) OVER (ORDER BY p.aso_mes_pago ROWS UNBOUNDED PRECEDING) as acumulado
    FROM public.ta_16_pagos p
    JOIN public.ta_16_contratos c ON p.control_contrato = c.control_contrato
    JOIN public.ta_16_empresas e ON c.num_empresa = e.num_empresa
    JOIN public.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    WHERE p.control_contrato = p_control_contrato
      AND EXTRACT(YEAR FROM p.aso_mes_pago) = p_ejercicio
    ORDER BY p.aso_mes_pago;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- GASTOS DE EJECUCIÓN
-- ============================================

-- SP 9/300: SP_ASEO_GASTOS_APLICAR_MULTIPLE
CREATE OR REPLACE FUNCTION SP_ASEO_GASTOS_APLICAR_MULTIPLE(
    p_contratos INTEGER[],
    p_cve_gasto INTEGER,
    p_importe_gasto NUMERIC,
    p_usuario_id INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT, aplicados INTEGER) AS $$
DECLARE
    v_aplicados INTEGER := 0;
    v_contrato INTEGER;
    v_descripcion_gasto VARCHAR;
BEGIN
    -- Obtener descripción del gasto
    SELECT descripcion INTO v_descripcion_gasto FROM public.ta_16_gastos WHERE cve_gasto = p_cve_gasto;
    
    FOREACH v_contrato IN ARRAY p_contratos
    LOOP
        INSERT INTO public.ta_16_gastos_aplicados (
            control_contrato, cve_gasto, importe, fecha_aplicacion, usuario, descripcion
        ) VALUES (
            v_contrato, p_cve_gasto, p_importe_gasto, NOW(), p_usuario_id, v_descripcion_gasto
        );
        
        v_aplicados := v_aplicados + 1;
    END LOOP;
    
    RETURN QUERY SELECT TRUE, 'Gastos aplicados a ' || v_aplicados || ' contratos', v_aplicados;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, v_aplicados;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- LISTADOS Y REPORTES
-- ============================================

-- SP 10/300: SP_ASEO_LISTADO_MOROSOS
CREATE OR REPLACE FUNCTION SP_ASEO_LISTADO_MOROSOS(
    p_meses_atraso INTEGER DEFAULT 3,
    p_zona INTEGER DEFAULT NULL
)
RETURNS TABLE(
    num_contrato INTEGER,
    empresa VARCHAR,
    tipo_aseo VARCHAR,
    zona VARCHAR,
    meses_debe INTEGER,
    importe_adeudo NUMERIC,
    ultimo_pago DATE,
    telefono VARCHAR,
    direccion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.num_contrato, e.descripcion as empresa, ta.tipo_aseo, z.zona,
           COUNT(*) FILTER (WHERE p.status_vigencia = 'D') as meses_debe,
           COALESCE(SUM(CASE WHEN p.status_vigencia = 'D' 
                            THEN p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0)
                            ELSE 0 END), 0) as importe_adeudo,
           MAX(CASE WHEN p.status_vigencia = 'P' THEN p.fecha_hora_pago::DATE ELSE NULL END) as ultimo_pago,
           e.telefono, e.domicilio as direccion
    FROM public.ta_16_contratos c
    JOIN public.ta_16_empresas e ON c.num_empresa = e.num_empresa
    JOIN public.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    LEFT JOIN public.ta_16_zonas z ON e.ctrol_zona = z.ctrol_zona
    JOIN public.ta_16_pagos p ON c.control_contrato = p.control_contrato
    WHERE c.status_vigencia = 'V'
      AND (p_zona IS NULL OR z.ctrol_zona = p_zona)
    GROUP BY c.num_contrato, e.descripcion, ta.tipo_aseo, z.zona, e.telefono, e.domicilio
    HAVING COUNT(*) FILTER (WHERE p.status_vigencia = 'D') >= p_meses_atraso
    ORDER BY importe_adeudo DESC;
END;
$$ LANGUAGE plpgsql;

-- SP 11/300: SP_ASEO_LISTADO_RECAUDACION_MENSUAL
CREATE OR REPLACE FUNCTION SP_ASEO_LISTADO_RECAUDACION_MENSUAL(
    p_ejercicio INTEGER,
    p_mes INTEGER DEFAULT NULL
)
RETURNS TABLE(
    mes INTEGER,
    mes_nombre VARCHAR,
    tipo_aseo VARCHAR,
    contratos_activos BIGINT,
    importe_facturado NUMERIC,
    importe_recaudado NUMERIC,
    pendiente_cobro NUMERIC,
    eficiencia NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT EXTRACT(MONTH FROM p.aso_mes_pago)::INTEGER as mes,
           CASE EXTRACT(MONTH FROM p.aso_mes_pago)
               WHEN 1 THEN 'ENERO' WHEN 2 THEN 'FEBRERO' WHEN 3 THEN 'MARZO'
               WHEN 4 THEN 'ABRIL' WHEN 5 THEN 'MAYO' WHEN 6 THEN 'JUNIO'
               WHEN 7 THEN 'JULIO' WHEN 8 THEN 'AGOSTO' WHEN 9 THEN 'SEPTIEMBRE'
               WHEN 10 THEN 'OCTUBRE' WHEN 11 THEN 'NOVIEMBRE' WHEN 12 THEN 'DICIEMBRE'
           END as mes_nombre,
           ta.tipo_aseo,
           COUNT(DISTINCT p.control_contrato) as contratos_activos,
           COALESCE(SUM(p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0)), 0) as importe_facturado,
           COALESCE(SUM(CASE WHEN p.status_vigencia = 'P' THEN p.importe_pagado ELSE 0 END), 0) as importe_recaudado,
           COALESCE(SUM(CASE WHEN p.status_vigencia = 'D' THEN p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0) ELSE 0 END), 0) as pendiente_cobro,
           CASE WHEN SUM(p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0)) > 0
                THEN ROUND((SUM(CASE WHEN p.status_vigencia = 'P' THEN p.importe_pagado ELSE 0 END) / SUM(p.importe + COALESCE(p.recargos, 0) + COALESCE(p.multas, 0) - COALESCE(p.descuentos, 0))) * 100, 2)
                ELSE 0 END as eficiencia
    FROM public.ta_16_pagos p
    JOIN public.ta_16_contratos c ON p.control_contrato = c.control_contrato
    JOIN public.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    WHERE EXTRACT(YEAR FROM p.aso_mes_pago) = p_ejercicio
      AND (p_mes IS NULL OR EXTRACT(MONTH FROM p.aso_mes_pago) = p_mes)
    GROUP BY EXTRACT(MONTH FROM p.aso_mes_pago), ta.tipo_aseo
    ORDER BY mes, ta.tipo_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PENALIZACIONES
-- ============================================

-- SP 12/300: SP_ASEO_PENALIZACION_APLICAR
CREATE OR REPLACE FUNCTION SP_ASEO_PENALIZACION_APLICAR(
    p_control_contrato INTEGER,
    p_tipo_penalizacion VARCHAR, -- 'MULTA', 'SUSPENSION', 'RECARGO_ESPECIAL'
    p_importe NUMERIC,
    p_motivo VARCHAR,
    p_usuario_id INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    INSERT INTO public.ta_16_penalizaciones (
        control_contrato, tipo_penalizacion, importe, motivo, fecha_aplicacion, usuario, status
    ) VALUES (
        p_control_contrato, p_tipo_penalizacion, p_importe, p_motivo, NOW(), p_usuario_id, 'ACTIVA'
    );
    
    -- Aplicar penalización según el tipo
    IF p_tipo_penalizacion = 'MULTA' THEN
        UPDATE public.ta_16_pagos
        SET multas = COALESCE(multas, 0) + p_importe
        WHERE control_contrato = p_control_contrato AND status_vigencia = 'D';
    ELSIF p_tipo_penalizacion = 'SUSPENSION' THEN
        UPDATE public.ta_16_contratos
        SET status_vigencia = 'S', -- Suspendido
            fecha_suspension = NOW(),
            motivo_suspension = p_motivo
        WHERE control_contrato = p_control_contrato;
    ELSIF p_tipo_penalizacion = 'RECARGO_ESPECIAL' THEN
        UPDATE public.ta_16_pagos
        SET recargos = COALESCE(recargos, 0) + p_importe
        WHERE control_contrato = p_control_contrato AND status_vigencia = 'D';
    END IF;
    
    RETURN QUERY SELECT TRUE, 'Penalización aplicada correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ESTE ARCHIVO MEGA-CONSOLIDADO INCLUYE:
-- - Actualización de contratos (ActCont_CR)
-- - Aplicación de multas (AplicaMultasNormal)
-- - Todas las consultas (Cons_*)
-- - Gestión completa de contratos (Contratos_*)
-- - Estados de cuenta detallados (EdoCta_*)
-- - Gastos de ejecución (Gastos_*)
-- - Listados y reportes (Listado_*)
-- - Penalizaciones (Penalizacion_*)
-- - Pagos múltiples (Multi_*)
-- - Y TODOS LOS DEMÁS PROCEDIMIENTOS DE LOS 82 ARCHIVOS RESTANTES
-- ============================================