-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO ASEO - GESTIÓN Y OPERACIONES
-- Archivo: 02_SP_ASEO_GESTION_all_procedures.sql
-- ============================================

-- SP_ASEO_GASTO_CREATE - Crear nuevo gasto
CREATE OR REPLACE FUNCTION SP_ASEO_GASTO_CREATE(
    p_empresa_id INTEGER,
    p_numero_comprobante VARCHAR(50),
    p_tipo_gasto VARCHAR(50),
    p_concepto TEXT,
    p_monto NUMERIC(15,2),
    p_proveedor VARCHAR(255),
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    gasto_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    empresa_exists BOOLEAN;
    comprobante_exists BOOLEAN;
BEGIN
    -- Validar que existe la empresa
    SELECT EXISTS(
        SELECT 1 FROM public.empresas 
        WHERE id = p_empresa_id AND estado = 'ACTIVA'
    ) INTO empresa_exists;
    
    IF NOT empresa_exists THEN
        RETURN QUERY SELECT FALSE, 'La empresa no existe o no está activa', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Validar comprobante único
    SELECT EXISTS(
        SELECT 1 FROM public.gastos 
        WHERE numero_comprobante = p_numero_comprobante
    ) INTO comprobante_exists;
    
    IF comprobante_exists THEN
        RETURN QUERY SELECT FALSE, 'El número de comprobante ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar gasto
    INSERT INTO public.gastos (
        empresa_id,
        numero_comprobante,
        tipo_gasto,
        concepto,
        monto,
        fecha_gasto,
        proveedor,
        estado,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_empresa_id,
        p_numero_comprobante,
        p_tipo_gasto,
        p_concepto,
        p_monto,
        CURRENT_DATE,
        p_proveedor,
        'REGISTRADO',
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Gasto registrado exitosamente', new_id;
END;
$$;

-- SP_ASEO_OPERACION_CREATE - Crear nueva operación
CREATE OR REPLACE FUNCTION SP_ASEO_OPERACION_CREATE(
    p_empresa_id INTEGER,
    p_tipo_operacion VARCHAR(50),
    p_zona VARCHAR(100),
    p_descripcion_operacion TEXT,
    p_turno VARCHAR(20),
    p_responsable VARCHAR(255),
    p_vehiculo VARCHAR(50),
    p_toneladas_recolectadas NUMERIC(8,2),
    p_kilometros_recorridos NUMERIC(8,2),
    p_combustible_consumido NUMERIC(8,2),
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    operacion_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    empresa_exists BOOLEAN;
BEGIN
    -- Validar que existe la empresa
    SELECT EXISTS(
        SELECT 1 FROM public.empresas 
        WHERE id = p_empresa_id AND estado = 'ACTIVA'
    ) INTO empresa_exists;
    
    IF NOT empresa_exists THEN
        RETURN QUERY SELECT FALSE, 'La empresa no existe o no está activa', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar operación
    INSERT INTO public.operaciones (
        empresa_id,
        tipo_operacion,
        zona,
        descripcion_operacion,
        fecha_operacion,
        turno,
        responsable,
        vehiculo,
        toneladas_recolectadas,
        kilometros_recorridos,
        combustible_consumido,
        estado,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_empresa_id,
        p_tipo_operacion,
        p_zona,
        p_descripcion_operacion,
        CURRENT_DATE,
        p_turno,
        p_responsable,
        p_vehiculo,
        p_toneladas_recolectadas,
        p_kilometros_recorridos,
        p_combustible_consumido,
        'COMPLETADA',
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Operación registrada exitosamente', new_id;
END;
$$;

-- SP_ASEO_RECARGO_CREATE - Crear nuevo recargo
CREATE OR REPLACE FUNCTION SP_ASEO_RECARGO_CREATE(
    p_empresa_id INTEGER,
    p_numero_recargo VARCHAR(50),
    p_tipo_recargo VARCHAR(50),
    p_concepto_recargo TEXT,
    p_monto_base NUMERIC(15,2),
    p_porcentaje_recargo NUMERIC(5,2),
    p_motivo TEXT,
    p_dias_vencimiento INTEGER DEFAULT 30
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    recargo_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    empresa_exists BOOLEAN;
    recargo_exists BOOLEAN;
    monto_recargo NUMERIC(15,2);
    monto_total NUMERIC(15,2);
BEGIN
    -- Validar que existe la empresa
    SELECT EXISTS(
        SELECT 1 FROM public.empresas 
        WHERE id = p_empresa_id AND estado = 'ACTIVA'
    ) INTO empresa_exists;
    
    IF NOT empresa_exists THEN
        RETURN QUERY SELECT FALSE, 'La empresa no existe o no está activa', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Validar número de recargo único
    SELECT EXISTS(
        SELECT 1 FROM public.recargos 
        WHERE numero_recargo = p_numero_recargo
    ) INTO recargo_exists;
    
    IF recargo_exists THEN
        RETURN QUERY SELECT FALSE, 'El número de recargo ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Calcular montos
    monto_recargo := p_monto_base * (p_porcentaje_recargo / 100);
    monto_total := p_monto_base + monto_recargo;
    
    -- Insertar recargo
    INSERT INTO public.recargos (
        empresa_id,
        numero_recargo,
        tipo_recargo,
        concepto_recargo,
        monto_base,
        porcentaje_recargo,
        monto_recargo,
        monto_total,
        fecha_aplicacion,
        fecha_vencimiento,
        estado,
        motivo,
        fecha_creacion
    ) VALUES (
        p_empresa_id,
        p_numero_recargo,
        p_tipo_recargo,
        p_concepto_recargo,
        p_monto_base,
        p_porcentaje_recargo,
        monto_recargo,
        monto_total,
        CURRENT_DATE,
        CURRENT_DATE + INTERVAL '1 day' * p_dias_vencimiento,
        'PENDIENTE',
        p_motivo,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Recargo aplicado exitosamente', new_id;
END;
$$;

-- SP_ASEO_EMPRESA_UPDATE - Actualizar empresa
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESA_UPDATE(
    p_empresa_id INTEGER,
    p_razon_social VARCHAR(255),
    p_nombre_comercial VARCHAR(255),
    p_direccion_fiscal TEXT,
    p_telefono VARCHAR(20),
    p_email VARCHAR(100),
    p_representante_legal VARCHAR(255),
    p_tipo_servicio VARCHAR(50),
    p_zona_cobertura TEXT,
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    empresa_exists BOOLEAN;
BEGIN
    -- Validar que existe la empresa
    SELECT EXISTS(
        SELECT 1 FROM public.empresas 
        WHERE id = p_empresa_id
    ) INTO empresa_exists;
    
    IF NOT empresa_exists THEN
        RETURN QUERY SELECT FALSE, 'La empresa no existe';
        RETURN;
    END IF;
    
    -- Actualizar empresa
    UPDATE public.empresas 
    SET 
        razon_social = p_razon_social,
        nombre_comercial = p_nombre_comercial,
        direccion_fiscal = p_direccion_fiscal,
        telefono = p_telefono,
        email = p_email,
        representante_legal = p_representante_legal,
        tipo_servicio = p_tipo_servicio,
        zona_cobertura = p_zona_cobertura,
        observaciones = p_observaciones,
        fecha_actualizacion = NOW()
    WHERE id = p_empresa_id;
    
    RETURN QUERY SELECT TRUE, 'Empresa actualizada exitosamente';
END;
$$;

-- SP_ASEO_EMPRESA_CAMBIAR_ESTADO - Cambiar estado de empresa
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESA_CAMBIAR_ESTADO(
    p_empresa_id INTEGER,
    p_nuevo_estado VARCHAR(30),
    p_motivo TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    empresa_exists BOOLEAN;
    estado_actual VARCHAR(30);
BEGIN
    -- Validar que existe la empresa
    SELECT EXISTS(
        SELECT 1 FROM public.empresas 
        WHERE id = p_empresa_id
    ), estado INTO empresa_exists, estado_actual
    FROM public.empresas 
    WHERE id = p_empresa_id;
    
    IF NOT empresa_exists THEN
        RETURN QUERY SELECT FALSE, 'La empresa no existe';
        RETURN;
    END IF;
    
    -- Validar cambio de estado válido
    IF estado_actual = p_nuevo_estado THEN
        RETURN QUERY SELECT FALSE, 'La empresa ya se encuentra en ese estado';
        RETURN;
    END IF;
    
    -- Actualizar estado
    UPDATE public.empresas 
    SET 
        estado = p_nuevo_estado,
        motivo_cambio_estado = p_motivo,
        fecha_cambio_estado = CURRENT_DATE,
        fecha_actualizacion = NOW()
    WHERE id = p_empresa_id;
    
    -- Registrar en historial
    INSERT INTO public.historial_cambios_estado (
        empresa_id,
        estado_anterior,
        estado_nuevo,
        motivo,
        fecha_cambio,
        usuario_cambio
    ) VALUES (
        p_empresa_id,
        estado_actual,
        p_nuevo_estado,
        p_motivo,
        NOW(),
        SESSION_USER
    );
    
    RETURN QUERY SELECT TRUE, 'Estado de empresa actualizado exitosamente';
END;
$$;

-- SP_ASEO_REPORTES_MENSUAL - Reporte mensual de aseo
CREATE OR REPLACE FUNCTION SP_ASEO_REPORTES_MENSUAL(
    p_mes INTEGER,
    p_año INTEGER
) RETURNS TABLE(
    empresa_id INTEGER,
    empresa_nombre VARCHAR(255),
    total_operaciones INTEGER,
    toneladas_recolectadas NUMERIC(10,2),
    kilometros_recorridos NUMERIC(10,2),
    combustible_consumido NUMERIC(10,2),
    gastos_totales NUMERIC(15,2),
    recargos_aplicados INTEGER,
    monto_recargos NUMERIC(15,2),
    eficiencia NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.razon_social,
        COUNT(DISTINCT o.id)::INTEGER as total_operaciones,
        COALESCE(SUM(o.toneladas_recolectadas), 0) as toneladas_recolectadas,
        COALESCE(SUM(o.kilometros_recorridos), 0) as kilometros_recorridos,
        COALESCE(SUM(o.combustible_consumido), 0) as combustible_consumido,
        COALESCE(SUM(g.monto), 0) as gastos_totales,
        COUNT(DISTINCT r.id)::INTEGER as recargos_aplicados,
        COALESCE(SUM(r.monto_total), 0) as monto_recargos,
        CASE 
            WHEN SUM(o.kilometros_recorridos) > 0 
            THEN (SUM(o.toneladas_recolectadas) / SUM(o.kilometros_recorridos) * 100)::NUMERIC(5,2)
            ELSE 0 
        END as eficiencia
    FROM public.empresas e
    LEFT JOIN public.operaciones o ON e.id = o.empresa_id 
        AND EXTRACT(MONTH FROM o.fecha_operacion) = p_mes 
        AND EXTRACT(YEAR FROM o.fecha_operacion) = p_año
    LEFT JOIN public.gastos g ON e.id = g.empresa_id 
        AND EXTRACT(MONTH FROM g.fecha_gasto) = p_mes 
        AND EXTRACT(YEAR FROM g.fecha_gasto) = p_año
    LEFT JOIN public.recargos r ON e.id = r.empresa_id 
        AND EXTRACT(MONTH FROM r.fecha_aplicacion) = p_mes 
        AND EXTRACT(YEAR FROM r.fecha_aplicacion) = p_año
    WHERE e.estado = 'ACTIVA'
    GROUP BY e.id, e.razon_social
    ORDER BY toneladas_recolectadas DESC;
END;
$$;

-- SP_ASEO_DASHBOARD_RESUMEN - Resumen para dashboard
CREATE OR REPLACE FUNCTION SP_ASEO_DASHBOARD_RESUMEN() RETURNS TABLE(
    empresas_activas INTEGER,
    operaciones_mes_actual INTEGER,
    toneladas_mes_actual NUMERIC(10,2),
    gastos_mes_actual NUMERIC(15,2),
    recargos_pendientes INTEGER,
    empresas_proximas_vencer INTEGER,
    eficiencia_promedio NUMERIC(5,2),
    costo_promedio_tonelada NUMERIC(10,2)
) LANGUAGE plpgsql AS $$
DECLARE
    inicio_mes DATE;
    fin_mes DATE;
BEGIN
    inicio_mes := DATE_TRUNC('month', CURRENT_DATE);
    fin_mes := inicio_mes + INTERVAL '1 month' - INTERVAL '1 day';
    
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM public.empresas WHERE estado = 'ACTIVA') as empresas_activas,
        
        (SELECT COUNT(*)::INTEGER FROM public.operaciones 
         WHERE fecha_operacion BETWEEN inicio_mes AND fin_mes) as operaciones_mes_actual,
        
        (SELECT COALESCE(SUM(toneladas_recolectadas), 0) FROM public.operaciones 
         WHERE fecha_operacion BETWEEN inicio_mes AND fin_mes) as toneladas_mes_actual,
        
        (SELECT COALESCE(SUM(monto), 0) FROM public.gastos 
         WHERE fecha_gasto BETWEEN inicio_mes AND fin_mes) as gastos_mes_actual,
        
        (SELECT COUNT(*)::INTEGER FROM public.recargos WHERE estado = 'PENDIENTE') as recargos_pendientes,
        
        (SELECT COUNT(*)::INTEGER FROM public.empresas 
         WHERE estado = 'ACTIVA' 
         AND fecha_vencimiento_licencia BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days') as empresas_proximas_vencer,
        
        (SELECT 
            CASE 
                WHEN SUM(kilometros_recorridos) > 0 
                THEN (SUM(toneladas_recolectadas) / SUM(kilometros_recorridos) * 100)::NUMERIC(5,2)
                ELSE 0 
            END
         FROM public.operaciones 
         WHERE fecha_operacion BETWEEN inicio_mes AND fin_mes) as eficiencia_promedio,
        
        (SELECT 
            CASE 
                WHEN SUM(o.toneladas_recolectadas) > 0 
                THEN (SUM(g.monto) / SUM(o.toneladas_recolectadas))::NUMERIC(10,2)
                ELSE 0 
            END
         FROM public.operaciones o
         JOIN public.gastos g ON o.empresa_id = g.empresa_id
         WHERE o.fecha_operacion BETWEEN inicio_mes AND fin_mes
         AND g.fecha_gasto BETWEEN inicio_mes AND fin_mes) as costo_promedio_tonelada;
END;
$$;