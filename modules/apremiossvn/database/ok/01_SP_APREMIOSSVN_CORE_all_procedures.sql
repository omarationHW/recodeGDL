-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO APREMIOSSVN - PROCEDIMIENTOS PRINCIPALES
-- Archivo: 01_SP_APREMIOSSVN_CORE_all_procedures.sql
-- ============================================

-- SP_APREMIOSSVN_EXPEDIENTES_LIST - Lista expedientes de apremios SVN
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EXPEDIENTES_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_search VARCHAR(255) DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    numero_expediente VARCHAR(50),
    contribuyente VARCHAR(255),
    rfc VARCHAR(15),
    cuenta_predial VARCHAR(50),
    adeudo_original NUMERIC(15,2),
    adeudo_actual NUMERIC(15,2),
    recargos NUMERIC(15,2),
    gastos_ejecucion NUMERIC(15,2),
    fecha_inicio DATE,
    fecha_vencimiento DATE,
    fase_actual VARCHAR(30),
    estado VARCHAR(30),
    notificador VARCHAR(255),
    observaciones TEXT,
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        e.id,
        e.numero_expediente,
        e.contribuyente,
        e.rfc,
        e.cuenta_predial,
        e.adeudo_original,
        e.adeudo_actual,
        e.recargos,
        e.gastos_ejecucion,
        e.fecha_inicio,
        e.fecha_vencimiento,
        e.fase_actual,
        e.estado,
        e.notificador,
        e.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.expedientes e
    WHERE (p_search IS NULL OR 
           e.contribuyente ILIKE '%' || p_search || '%' OR
           e.numero_expediente ILIKE '%' || p_search || '%' OR
           e.rfc ILIKE '%' || p_search || '%' OR
           e.cuenta_predial ILIKE '%' || p_search || '%')
    AND (p_estado IS NULL OR e.estado = p_estado)
    AND (p_fecha_desde IS NULL OR e.fecha_inicio >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR e.fecha_inicio <= p_fecha_hasta)
    ORDER BY e.fecha_inicio DESC, e.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_APREMIOSSVN_EXPEDIENTE_CREATE - Crear nuevo expediente
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EXPEDIENTE_CREATE(
    p_numero_expediente VARCHAR(50),
    p_contribuyente VARCHAR(255),
    p_rfc VARCHAR(15),
    p_cuenta_predial VARCHAR(50),
    p_direccion TEXT,
    p_telefono VARCHAR(20),
    p_email VARCHAR(100),
    p_adeudo_original NUMERIC(15,2),
    p_concepto_adeudo TEXT,
    p_fecha_vencimiento DATE,
    p_notificador VARCHAR(255),
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    expediente_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    expediente_exists BOOLEAN;
    cuenta_exists BOOLEAN;
BEGIN
    -- Validar número de expediente único
    SELECT EXISTS(
        SELECT 1 FROM public.expedientes 
        WHERE numero_expediente = p_numero_expediente
    ) INTO expediente_exists;
    
    IF expediente_exists THEN
        RETURN QUERY SELECT FALSE, 'El número de expediente ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Validar que no exista expediente activo para la misma cuenta predial
    SELECT EXISTS(
        SELECT 1 FROM public.expedientes 
        WHERE cuenta_predial = p_cuenta_predial AND estado = 'ACTIVO'
    ) INTO cuenta_exists;
    
    IF cuenta_exists THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un expediente activo para esta cuenta predial', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar expediente
    INSERT INTO public.expedientes (
        numero_expediente,
        contribuyente,
        rfc,
        cuenta_predial,
        direccion,
        telefono,
        email,
        adeudo_original,
        adeudo_actual,
        recargos,
        gastos_ejecucion,
        concepto_adeudo,
        fecha_inicio,
        fecha_vencimiento,
        fase_actual,
        estado,
        notificador,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_numero_expediente,
        p_contribuyente,
        p_rfc,
        p_cuenta_predial,
        p_direccion,
        p_telefono,
        p_email,
        p_adeudo_original,
        p_adeudo_original, -- adeudo_actual inicia igual al original
        0, -- recargos inician en 0
        0, -- gastos_ejecucion inician en 0
        p_concepto_adeudo,
        CURRENT_DATE,
        p_fecha_vencimiento,
        'REQUERIMIENTO',
        'ACTIVO',
        p_notificador,
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Expediente de apremio creado exitosamente', new_id;
END;
$$;

-- SP_APREMIOSSVN_NOTIFICACIONES_LIST - Lista notificaciones del sistema SVN
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_NOTIFICACIONES_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_expediente_id INTEGER DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL,
    p_tipo_notificacion VARCHAR(50) DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    expediente_id INTEGER,
    numero_expediente VARCHAR(50),
    contribuyente VARCHAR(255),
    tipo_notificacion VARCHAR(50),
    descripcion TEXT,
    fecha_programada DATE,
    fecha_realizada DATE,
    resultado VARCHAR(50),
    estado VARCHAR(30),
    notificador VARCHAR(255),
    direccion_notificacion TEXT,
    observaciones TEXT,
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        n.id,
        n.expediente_id,
        e.numero_expediente,
        e.contribuyente,
        n.tipo_notificacion,
        n.descripcion,
        n.fecha_programada,
        n.fecha_realizada,
        n.resultado,
        n.estado,
        n.notificador,
        n.direccion_notificacion,
        n.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.notificaciones n
    JOIN public.expedientes e ON n.expediente_id = e.id
    WHERE (p_expediente_id IS NULL OR n.expediente_id = p_expediente_id)
    AND (p_estado IS NULL OR n.estado = p_estado)
    AND (p_tipo_notificacion IS NULL OR n.tipo_notificacion = p_tipo_notificacion)
    ORDER BY n.fecha_programada DESC, n.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_APREMIOSSVN_ACTUACIONES_LIST - Lista actuaciones procesales
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_ACTUACIONES_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_expediente_id INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    expediente_id INTEGER,
    numero_expediente VARCHAR(50),
    tipo_actuacion VARCHAR(50),
    descripcion_actuacion TEXT,
    fecha_actuacion DATE,
    responsable VARCHAR(255),
    resultado VARCHAR(100),
    costo_actuacion NUMERIC(10,2),
    estado VARCHAR(30),
    observaciones TEXT,
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        a.id,
        a.expediente_id,
        e.numero_expediente,
        a.tipo_actuacion,
        a.descripcion_actuacion,
        a.fecha_actuacion,
        a.responsable,
        a.resultado,
        a.costo_actuacion,
        a.estado,
        a.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.actuaciones a
    JOIN public.expedientes e ON a.expediente_id = e.id
    WHERE (p_expediente_id IS NULL OR a.expediente_id = p_expediente_id)
    AND (p_fecha_desde IS NULL OR a.fecha_actuacion >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR a.fecha_actuacion <= p_fecha_hasta)
    ORDER BY a.fecha_actuacion DESC, a.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_APREMIOSSVN_CAMBIAR_FASE - Cambiar fase del expediente
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CAMBIAR_FASE(
    p_expediente_id INTEGER,
    p_nueva_fase VARCHAR(30),
    p_motivo TEXT,
    p_responsable VARCHAR(255)
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    expediente_info RECORD;
    fase_valida BOOLEAN;
BEGIN
    -- Obtener información del expediente
    SELECT e.id, e.numero_expediente, e.fase_actual, e.estado
    INTO expediente_info
    FROM public.expedientes e
    WHERE e.id = p_expediente_id;
    
    IF expediente_info.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El expediente no existe';
        RETURN;
    END IF;
    
    IF expediente_info.estado != 'ACTIVO' THEN
        RETURN QUERY SELECT FALSE, 'El expediente no está activo';
        RETURN;
    END IF;
    
    -- Validar secuencia de fases
    fase_valida := CASE 
        WHEN expediente_info.fase_actual = 'REQUERIMIENTO' AND p_nueva_fase IN ('EMBARGO', 'CANCELADO') THEN TRUE
        WHEN expediente_info.fase_actual = 'EMBARGO' AND p_nueva_fase IN ('REMATE', 'CANCELADO') THEN TRUE
        WHEN expediente_info.fase_actual = 'REMATE' AND p_nueva_fase IN ('ADJUDICACION', 'CANCELADO') THEN TRUE
        ELSE FALSE
    END;
    
    IF NOT fase_valida THEN
        RETURN QUERY SELECT FALSE, 'Cambio de fase no válido';
        RETURN;
    END IF;
    
    -- Actualizar fase
    UPDATE public.expedientes 
    SET 
        fase_actual = p_nueva_fase,
        fecha_cambio_fase = CURRENT_DATE,
        fecha_actualizacion = NOW()
    WHERE id = p_expediente_id;
    
    -- Registrar en historial
    INSERT INTO public.historial_fases (
        expediente_id,
        fase_anterior,
        fase_nueva,
        motivo,
        responsable,
        fecha_cambio
    ) VALUES (
        p_expediente_id,
        expediente_info.fase_actual,
        p_nueva_fase,
        p_motivo,
        p_responsable,
        NOW()
    );
    
    RETURN QUERY SELECT TRUE, 'Fase del expediente actualizada exitosamente';
END;
$$;

-- SP_APREMIOSSVN_PAGOS_LIST - Lista pagos del sistema SVN
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_PAGOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_expediente_id INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    expediente_id INTEGER,
    numero_expediente VARCHAR(50),
    contribuyente VARCHAR(255),
    numero_recibo VARCHAR(50),
    monto_pago NUMERIC(15,2),
    monto_capital NUMERIC(15,2),
    monto_recargos NUMERIC(15,2),
    monto_gastos NUMERIC(15,2),
    fecha_pago DATE,
    forma_pago VARCHAR(30),
    estado_pago VARCHAR(30),
    cajero VARCHAR(255),
    observaciones TEXT,
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        p.id,
        p.expediente_id,
        e.numero_expediente,
        e.contribuyente,
        p.numero_recibo,
        p.monto_pago,
        p.monto_capital,
        p.monto_recargos,
        p.monto_gastos,
        p.fecha_pago,
        p.forma_pago,
        p.estado_pago,
        p.cajero,
        p.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.pagos p
    JOIN public.expedientes e ON p.expediente_id = e.id
    WHERE (p_expediente_id IS NULL OR p.expediente_id = p_expediente_id)
    AND (p_fecha_desde IS NULL OR p.fecha_pago >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR p.fecha_pago <= p_fecha_hasta)
    ORDER BY p.fecha_pago DESC, p.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_APREMIOSSVN_ESTADISTICAS_GENERALES - Estadísticas del módulo SVN
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_ESTADISTICAS_GENERALES() RETURNS TABLE(
    expedientes_activos INTEGER,
    expedientes_en_requerimiento INTEGER,
    expedientes_en_embargo INTEGER,
    expedientes_en_remate INTEGER,
    monto_total_adeudo NUMERIC(15,2),
    monto_recuperado_mes NUMERIC(15,2),
    notificaciones_pendientes INTEGER,
    actuaciones_mes_actual INTEGER,
    efectividad_cobranza NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
DECLARE
    inicio_mes DATE;
    fin_mes DATE;
BEGIN
    inicio_mes := DATE_TRUNC('month', CURRENT_DATE);
    fin_mes := inicio_mes + INTERVAL '1 month' - INTERVAL '1 day';
    
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM public.expedientes WHERE estado = 'ACTIVO') as expedientes_activos,
        
        (SELECT COUNT(*)::INTEGER FROM public.expedientes 
         WHERE estado = 'ACTIVO' AND fase_actual = 'REQUERIMIENTO') as expedientes_en_requerimiento,
        
        (SELECT COUNT(*)::INTEGER FROM public.expedientes 
         WHERE estado = 'ACTIVO' AND fase_actual = 'EMBARGO') as expedientes_en_embargo,
        
        (SELECT COUNT(*)::INTEGER FROM public.expedientes 
         WHERE estado = 'ACTIVO' AND fase_actual = 'REMATE') as expedientes_en_remate,
        
        (SELECT COALESCE(SUM(adeudo_actual), 0) FROM public.expedientes 
         WHERE estado = 'ACTIVO') as monto_total_adeudo,
        
        (SELECT COALESCE(SUM(monto_pago), 0) FROM public.pagos 
         WHERE fecha_pago BETWEEN inicio_mes AND fin_mes) as monto_recuperado_mes,
        
        (SELECT COUNT(*)::INTEGER FROM public.notificaciones 
         WHERE estado = 'PENDIENTE') as notificaciones_pendientes,
        
        (SELECT COUNT(*)::INTEGER FROM public.actuaciones 
         WHERE fecha_actuacion BETWEEN inicio_mes AND fin_mes) as actuaciones_mes_actual,
        
        (SELECT 
            CASE 
                WHEN COUNT(*) > 0 
                THEN (COUNT(CASE WHEN estado = 'LIQUIDADO' THEN 1 END) * 100.0 / COUNT(*))::NUMERIC(5,2)
                ELSE 0 
            END
         FROM public.expedientes) as efectividad_cobranza;
END;
$$;

-- SP_APREMIOSSVN_PROXIMOS_VENCIMIENTO - Expedientes próximos a vencer
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_PROXIMOS_VENCIMIENTO(
    p_dias_anticipacion INTEGER DEFAULT 15
) RETURNS TABLE(
    id INTEGER,
    numero_expediente VARCHAR(50),
    contribuyente VARCHAR(255),
    cuenta_predial VARCHAR(50),
    adeudo_actual NUMERIC(15,2),
    fecha_vencimiento DATE,
    dias_restantes INTEGER,
    fase_actual VARCHAR(30),
    telefono VARCHAR(20),
    notificador VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.numero_expediente,
        e.contribuyente,
        e.cuenta_predial,
        e.adeudo_actual,
        e.fecha_vencimiento,
        (e.fecha_vencimiento - CURRENT_DATE)::INTEGER as dias_restantes,
        e.fase_actual,
        e.telefono,
        e.notificador
    FROM public.expedientes e
    WHERE e.estado = 'ACTIVO'
    AND e.fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '1 day' * p_dias_anticipacion
    ORDER BY e.fecha_vencimiento;
END;
$$;