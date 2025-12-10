-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO CEMENTERIOS - GESTIÓN Y SERVICIOS
-- Archivo: 02_SP_CEMENTERIOS_GESTION_all_procedures.sql
-- ============================================

-- SP_CEMENTERIOS_SERVICIO_CREATE - Crear nuevo servicio funerario
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_SERVICIO_CREATE(
    p_difunto_id INTEGER,
    p_tipo_servicio VARCHAR(50),
    p_descripcion_servicio TEXT,
    p_proveedor_servicio VARCHAR(255),
    p_costo_servicio NUMERIC(10,2),
    p_fecha_servicio DATE,
    p_hora_servicio TIME,
    p_responsable VARCHAR(255),
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    servicio_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    difunto_exists BOOLEAN;
BEGIN
    -- Validar que existe el difunto
    SELECT EXISTS(
        SELECT 1 FROM public.difuntos 
        WHERE id = p_difunto_id AND estado = 'ACTIVO'
    ) INTO difunto_exists;
    
    IF NOT difunto_exists THEN
        RETURN QUERY SELECT FALSE, 'El difunto no existe o no está activo', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar servicio
    INSERT INTO public.servicios (
        difunto_id,
        tipo_servicio,
        descripcion_servicio,
        proveedor_servicio,
        costo_servicio,
        fecha_servicio,
        hora_servicio,
        estado_servicio,
        responsable,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_difunto_id,
        p_tipo_servicio,
        p_descripcion_servicio,
        p_proveedor_servicio,
        p_costo_servicio,
        p_fecha_servicio,
        p_hora_servicio,
        'PROGRAMADO',
        p_responsable,
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Servicio funerario creado exitosamente', new_id;
END;
$$;

-- SP_CEMENTERIOS_PAGO_CREATE - Registrar nuevo pago
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_PAGO_CREATE(
    p_difunto_id INTEGER,
    p_numero_recibo VARCHAR(50),
    p_concepto_pago VARCHAR(255),
    p_monto_pago NUMERIC(10,2),
    p_forma_pago VARCHAR(30),
    p_cajero VARCHAR(255),
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    pago_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    difunto_exists BOOLEAN;
    recibo_exists BOOLEAN;
BEGIN
    -- Validar que existe el difunto
    SELECT EXISTS(
        SELECT 1 FROM public.difuntos 
        WHERE id = p_difunto_id
    ) INTO difunto_exists;
    
    IF NOT difunto_exists THEN
        RETURN QUERY SELECT FALSE, 'El difunto no existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Validar número de recibo único
    SELECT EXISTS(
        SELECT 1 FROM public.pagos 
        WHERE numero_recibo = p_numero_recibo
    ) INTO recibo_exists;
    
    IF recibo_exists THEN
        RETURN QUERY SELECT FALSE, 'El número de recibo ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar pago
    INSERT INTO public.pagos (
        difunto_id,
        numero_recibo,
        concepto_pago,
        monto_pago,
        fecha_pago,
        forma_pago,
        estado_pago,
        cajero,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_difunto_id,
        p_numero_recibo,
        p_concepto_pago,
        p_monto_pago,
        CURRENT_DATE,
        p_forma_pago,
        'PAGADO',
        p_cajero,
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Pago registrado exitosamente', new_id;
END;
$$;

-- SP_CEMENTERIOS_LOTE_LIBERAR - Liberar lote por exhumación
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_LOTE_LIBERAR(
    p_difunto_id INTEGER,
    p_motivo_liberacion TEXT,
    p_autorizado_por VARCHAR(255),
    p_fecha_exhumacion DATE DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    difunto_info RECORD;
BEGIN
    -- Obtener información del difunto
    SELECT d.id, d.cementerio_id, d.seccion, d.lote, d.fosa
    INTO difunto_info
    FROM public.difuntos d
    WHERE d.id = p_difunto_id AND d.estado = 'ACTIVO';
    
    IF difunto_info.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El difunto no existe o no está activo';
        RETURN;
    END IF;
    
    -- Actualizar estado del difunto
    UPDATE public.difuntos 
    SET 
        estado = 'EXHUMADO',
        fecha_exhumacion = COALESCE(p_fecha_exhumacion, CURRENT_DATE),
        motivo_liberacion = p_motivo_liberacion,
        autorizado_por = p_autorizado_por,
        fecha_actualizacion = NOW()
    WHERE id = p_difunto_id;
    
    -- Liberar lote
    UPDATE public.lotes 
    SET 
        estado = 'DISPONIBLE',
        fecha_liberacion = CURRENT_DATE,
        difunto_id = NULL
    WHERE cementerio_id = difunto_info.cementerio_id 
    AND seccion = difunto_info.seccion 
    AND numero_lote = difunto_info.lote 
    AND numero_fosa = difunto_info.fosa;
    
    -- Registrar en historial
    INSERT INTO public.historial_exhumaciones (
        difunto_id,
        fecha_exhumacion,
        motivo,
        autorizado_por,
        ubicacion_anterior,
        fecha_registro
    ) VALUES (
        p_difunto_id,
        COALESCE(p_fecha_exhumacion, CURRENT_DATE),
        p_motivo_liberacion,
        p_autorizado_por,
        difunto_info.seccion || '-' || difunto_info.lote || '-' || difunto_info.fosa,
        NOW()
    );
    
    RETURN QUERY SELECT TRUE, 'Lote liberado exitosamente';
END;
$$;

-- SP_CEMENTERIOS_RENOVACION_CREATE - Crear renovación de concesión
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_RENOVACION_CREATE(
    p_difunto_id INTEGER,
    p_años_renovacion INTEGER,
    p_monto_renovacion NUMERIC(10,2),
    p_solicitante VARCHAR(255),
    p_telefono_contacto VARCHAR(20),
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    renovacion_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    difunto_exists BOOLEAN;
    fecha_vencimiento_actual DATE;
    nueva_fecha_vencimiento DATE;
BEGIN
    -- Validar que existe el difunto
    SELECT EXISTS(
        SELECT 1 FROM public.difuntos 
        WHERE id = p_difunto_id AND estado = 'ACTIVO'
    ), fecha_vencimiento_concesion
    INTO difunto_exists, fecha_vencimiento_actual
    FROM public.difuntos 
    WHERE id = p_difunto_id;
    
    IF NOT difunto_exists THEN
        RETURN QUERY SELECT FALSE, 'El difunto no existe o no está activo', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Calcular nueva fecha de vencimiento
    nueva_fecha_vencimiento := COALESCE(fecha_vencimiento_actual, CURRENT_DATE) + INTERVAL '1 year' * p_años_renovacion;
    
    -- Insertar renovación
    INSERT INTO public.renovaciones (
        difunto_id,
        años_renovacion,
        monto_renovacion,
        fecha_solicitud,
        fecha_vencimiento_anterior,
        fecha_vencimiento_nueva,
        estado_renovacion,
        solicitante,
        telefono_contacto,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_difunto_id,
        p_años_renovacion,
        p_monto_renovacion,
        CURRENT_DATE,
        fecha_vencimiento_actual,
        nueva_fecha_vencimiento,
        'PENDIENTE_PAGO',
        p_solicitante,
        p_telefono_contacto,
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Renovación de concesión creada exitosamente', new_id;
END;
$$;

-- SP_CEMENTERIOS_RENOVACION_CONFIRMAR - Confirmar renovación tras pago
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_RENOVACION_CONFIRMAR(
    p_renovacion_id INTEGER,
    p_numero_recibo VARCHAR(50)
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    renovacion_info RECORD;
BEGIN
    -- Obtener información de la renovación
    SELECT r.id, r.difunto_id, r.fecha_vencimiento_nueva, r.estado_renovacion
    INTO renovacion_info
    FROM public.renovaciones r
    WHERE r.id = p_renovacion_id;
    
    IF renovacion_info.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'La renovación no existe';
        RETURN;
    END IF;
    
    IF renovacion_info.estado_renovacion != 'PENDIENTE_PAGO' THEN
        RETURN QUERY SELECT FALSE, 'La renovación no está pendiente de pago';
        RETURN;
    END IF;
    
    -- Actualizar renovación
    UPDATE public.renovaciones 
    SET 
        estado_renovacion = 'CONFIRMADA',
        numero_recibo = p_numero_recibo,
        fecha_confirmacion = CURRENT_DATE,
        fecha_actualizacion = NOW()
    WHERE id = p_renovacion_id;
    
    -- Actualizar fecha de vencimiento del difunto
    UPDATE public.difuntos 
    SET 
        fecha_vencimiento_concesion = renovacion_info.fecha_vencimiento_nueva,
        fecha_actualizacion = NOW()
    WHERE id = renovacion_info.difunto_id;
    
    RETURN QUERY SELECT TRUE, 'Renovación confirmada exitosamente';
END;
$$;

-- SP_CEMENTERIOS_REPORTES_OCUPACION - Reporte de ocupación por cementerio
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_REPORTES_OCUPACION() RETURNS TABLE(
    cementerio_id INTEGER,
    cementerio_nombre VARCHAR(255),
    capacidad_total INTEGER,
    lotes_ocupados INTEGER,
    lotes_disponibles INTEGER,
    porcentaje_ocupacion NUMERIC(5,2),
    ingresos_mes_actual NUMERIC(15,2),
    nuevos_registros_mes INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    inicio_mes DATE;
    fin_mes DATE;
BEGIN
    inicio_mes := DATE_TRUNC('month', CURRENT_DATE);
    fin_mes := inicio_mes + INTERVAL '1 month' - INTERVAL '1 day';
    
    RETURN QUERY
    SELECT 
        c.id,
        c.nombre,
        c.capacidad_total,
        COUNT(CASE WHEN d.estado = 'ACTIVO' THEN 1 END)::INTEGER as lotes_ocupados,
        (c.capacidad_total - COUNT(CASE WHEN d.estado = 'ACTIVO' THEN 1 END))::INTEGER as lotes_disponibles,
        (COUNT(CASE WHEN d.estado = 'ACTIVO' THEN 1 END) * 100.0 / NULLIF(c.capacidad_total, 0))::NUMERIC(5,2) as porcentaje_ocupacion,
        COALESCE(
            (SELECT SUM(p.monto_pago) 
             FROM public.pagos p 
             JOIN public.difuntos d2 ON p.difunto_id = d2.id 
             WHERE d2.cementerio_id = c.id 
             AND p.fecha_pago BETWEEN inicio_mes AND fin_mes), 
            0
        ) as ingresos_mes_actual,
        COUNT(CASE WHEN d.fecha_registro BETWEEN inicio_mes AND fin_mes THEN 1 END)::INTEGER as nuevos_registros_mes
    FROM public.cementerios c
    LEFT JOIN public.difuntos d ON c.id = d.cementerio_id
    WHERE c.estado = 'ACTIVO'
    GROUP BY c.id, c.nombre, c.capacidad_total
    ORDER BY porcentaje_ocupacion DESC;
END;
$$;

-- SP_CEMENTERIOS_VENCIMIENTOS_PROXIMOS - Concesiones próximas a vencer
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_VENCIMIENTOS_PROXIMOS(
    p_dias_anticipacion INTEGER DEFAULT 90
) RETURNS TABLE(
    difunto_id INTEGER,
    numero_registro VARCHAR(50),
    nombre_difunto VARCHAR(255),
    cementerio_nombre VARCHAR(255),
    ubicacion TEXT,
    fecha_vencimiento DATE,
    dias_restantes INTEGER,
    solicitante VARCHAR(255),
    telefono_contacto VARCHAR(20),
    monto_renovacion NUMERIC(10,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id,
        d.numero_registro,
        d.nombre_completo,
        c.nombre as cementerio_nombre,
        (d.seccion || '-' || d.lote || '-' || d.fosa) as ubicacion,
        d.fecha_vencimiento_concesion,
        (d.fecha_vencimiento_concesion - CURRENT_DATE)::INTEGER as dias_restantes,
        d.solicitante,
        d.telefono_contacto,
        l.precio_base * 0.5 as monto_renovacion -- 50% del precio base como renovación
    FROM public.difuntos d
    JOIN public.cementerios c ON d.cementerio_id = c.id
    LEFT JOIN public.lotes l ON d.cementerio_id = l.cementerio_id 
        AND d.seccion = l.seccion 
        AND d.lote = l.numero_lote 
        AND d.fosa = l.numero_fosa
    WHERE d.estado = 'ACTIVO'
    AND d.fecha_vencimiento_concesion IS NOT NULL
    AND d.fecha_vencimiento_concesion BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '1 day' * p_dias_anticipacion
    ORDER BY d.fecha_vencimiento_concesion;
END;
$$;

-- SP_CEMENTERIOS_DASHBOARD_RESUMEN - Resumen para dashboard
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_DASHBOARD_RESUMEN() RETURNS TABLE(
    cementerios_activos INTEGER,
    total_difuntos INTEGER,
    registros_mes_actual INTEGER,
    capacidad_total INTEGER,
    porcentaje_ocupacion NUMERIC(5,2),
    ingresos_mes_actual NUMERIC(15,2),
    servicios_mes_actual INTEGER,
    vencimientos_proximos INTEGER,
    renovaciones_pendientes INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    inicio_mes DATE;
    fin_mes DATE;
BEGIN
    inicio_mes := DATE_TRUNC('month', CURRENT_DATE);
    fin_mes := inicio_mes + INTERVAL '1 month' - INTERVAL '1 day';
    
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM public.cementerios WHERE estado = 'ACTIVO') as cementerios_activos,
        
        (SELECT COUNT(*)::INTEGER FROM public.difuntos WHERE estado = 'ACTIVO') as total_difuntos,
        
        (SELECT COUNT(*)::INTEGER FROM public.difuntos 
         WHERE fecha_registro BETWEEN inicio_mes AND fin_mes) as registros_mes_actual,
        
        (SELECT COALESCE(SUM(capacidad_total), 0)::INTEGER FROM public.cementerios 
         WHERE estado = 'ACTIVO') as capacidad_total,
        
        (SELECT 
            CASE 
                WHEN SUM(c.capacidad_total) > 0 
                THEN (COUNT(d.id) * 100.0 / SUM(c.capacidad_total))::NUMERIC(5,2)
                ELSE 0 
            END
         FROM public.cementerios c
         LEFT JOIN public.difuntos d ON c.id = d.cementerio_id AND d.estado = 'ACTIVO'
         WHERE c.estado = 'ACTIVO') as porcentaje_ocupacion,
        
        (SELECT COALESCE(SUM(monto_pago), 0) FROM public.pagos 
         WHERE fecha_pago BETWEEN inicio_mes AND fin_mes) as ingresos_mes_actual,
        
        (SELECT COUNT(*)::INTEGER FROM public.servicios 
         WHERE fecha_servicio BETWEEN inicio_mes AND fin_mes) as servicios_mes_actual,
        
        (SELECT COUNT(*)::INTEGER FROM public.difuntos 
         WHERE estado = 'ACTIVO' 
         AND fecha_vencimiento_concesion BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '90 days') as vencimientos_proximos,
        
        (SELECT COUNT(*)::INTEGER FROM public.renovaciones 
         WHERE estado_renovacion = 'PENDIENTE_PAGO') as renovaciones_pendientes;
END;
$$;