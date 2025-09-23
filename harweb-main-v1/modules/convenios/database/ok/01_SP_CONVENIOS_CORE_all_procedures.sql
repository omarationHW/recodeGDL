-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO CONVENIOS - PROCEDIMIENTOS PRINCIPALES
-- Archivo: 01_SP_CONVENIOS_CORE_all_procedures.sql
-- ============================================

-- SP_CONVENIOS_LIST - Lista convenios de pago
CREATE OR REPLACE FUNCTION SP_CONVENIOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_search VARCHAR(255) DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    numero_convenio VARCHAR(50),
    contribuyente VARCHAR(255),
    rfc VARCHAR(15),
    adeudo_original NUMERIC(15,2),
    adeudo_actual NUMERIC(15,2),
    numero_parcialidades INTEGER,
    parcialidades_pagadas INTEGER,
    monto_parcialidad NUMERIC(15,2),
    fecha_convenio DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(30),
    tipo_convenio VARCHAR(50),
    observaciones TEXT,
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        c.id,
        c.numero_convenio,
        c.contribuyente,
        c.rfc,
        c.adeudo_original,
        c.adeudo_actual,
        c.numero_parcialidades,
        c.parcialidades_pagadas,
        c.monto_parcialidad,
        c.fecha_convenio,
        c.fecha_vencimiento,
        c.estado,
        c.tipo_convenio,
        c.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.convenios c
    WHERE (p_search IS NULL OR 
           c.contribuyente ILIKE '%' || p_search || '%' OR
           c.numero_convenio ILIKE '%' || p_search || '%' OR
           c.rfc ILIKE '%' || p_search || '%')
    AND (p_estado IS NULL OR c.estado = p_estado)
    AND (p_fecha_desde IS NULL OR c.fecha_convenio >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR c.fecha_convenio <= p_fecha_hasta)
    ORDER BY c.fecha_convenio DESC, c.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_CONVENIOS_CREATE - Crear nuevo convenio de pago
CREATE OR REPLACE FUNCTION SP_CONVENIOS_CREATE(
    p_numero_convenio VARCHAR(50),
    p_contribuyente VARCHAR(255),
    p_rfc VARCHAR(15),
    p_direccion TEXT,
    p_telefono VARCHAR(20),
    p_email VARCHAR(100),
    p_adeudo_original NUMERIC(15,2),
    p_numero_parcialidades INTEGER,
    p_monto_parcialidad NUMERIC(15,2),
    p_fecha_vencimiento DATE,
    p_tipo_convenio VARCHAR(50),
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    convenio_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    convenio_exists BOOLEAN;
    rfc_valido BOOLEAN;
BEGIN
    -- Validar número de convenio único
    SELECT EXISTS(
        SELECT 1 FROM public.convenios 
        WHERE numero_convenio = p_numero_convenio
    ) INTO convenio_exists;
    
    IF convenio_exists THEN
        RETURN QUERY SELECT FALSE, 'El número de convenio ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Validar RFC (longitud básica)
    IF LENGTH(p_rfc) NOT BETWEEN 12 AND 13 THEN
        RETURN QUERY SELECT FALSE, 'RFC inválido', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar convenio
    INSERT INTO public.convenios (
        numero_convenio,
        contribuyente,
        rfc,
        direccion,
        telefono,
        email,
        adeudo_original,
        adeudo_actual,
        numero_parcialidades,
        parcialidades_pagadas,
        monto_parcialidad,
        fecha_convenio,
        fecha_vencimiento,
        estado,
        tipo_convenio,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_numero_convenio,
        p_contribuyente,
        p_rfc,
        p_direccion,
        p_telefono,
        p_email,
        p_adeudo_original,
        p_adeudo_original, -- adeudo_actual inicia igual al original
        p_numero_parcialidades,
        0, -- parcialidades_pagadas inicia en 0
        p_monto_parcialidad,
        CURRENT_DATE,
        p_fecha_vencimiento,
        'ACTIVO',
        p_tipo_convenio,
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Convenio creado exitosamente', new_id;
END;
$$;

-- SP_CONVENIOS_PAGOS_LIST - Lista pagos de convenios
CREATE OR REPLACE FUNCTION SP_CONVENIOS_PAGOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_convenio_id INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    convenio_id INTEGER,
    numero_convenio VARCHAR(50),
    contribuyente VARCHAR(255),
    numero_parcialidad INTEGER,
    monto_pago NUMERIC(15,2),
    fecha_pago DATE,
    numero_recibo VARCHAR(50),
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
        p.convenio_id,
        c.numero_convenio,
        c.contribuyente,
        p.numero_parcialidad,
        p.monto_pago,
        p.fecha_pago,
        p.numero_recibo,
        p.forma_pago,
        p.estado_pago,
        p.cajero,
        p.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.pagos p
    JOIN public.convenios c ON p.convenio_id = c.id
    WHERE (p_convenio_id IS NULL OR p.convenio_id = p_convenio_id)
    AND (p_fecha_desde IS NULL OR p.fecha_pago >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR p.fecha_pago <= p_fecha_hasta)
    ORDER BY p.fecha_pago DESC, p.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_CONVENIOS_PAGO_CREATE - Registrar pago de parcialidad
CREATE OR REPLACE FUNCTION SP_CONVENIOS_PAGO_CREATE(
    p_convenio_id INTEGER,
    p_numero_parcialidad INTEGER,
    p_monto_pago NUMERIC(15,2),
    p_numero_recibo VARCHAR(50),
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
    convenio_info RECORD;
    recibo_exists BOOLEAN;
    parcialidad_exists BOOLEAN;
BEGIN
    -- Obtener información del convenio
    SELECT c.id, c.numero_convenio, c.estado, c.monto_parcialidad, c.adeudo_actual, c.parcialidades_pagadas
    INTO convenio_info
    FROM public.convenios c
    WHERE c.id = p_convenio_id;
    
    IF convenio_info.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El convenio no existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    IF convenio_info.estado != 'ACTIVO' THEN
        RETURN QUERY SELECT FALSE, 'El convenio no está activo', NULL::INTEGER;
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
    
    -- Validar que la parcialidad no esté pagada
    SELECT EXISTS(
        SELECT 1 FROM public.pagos 
        WHERE convenio_id = p_convenio_id AND numero_parcialidad = p_numero_parcialidad
    ) INTO parcialidad_exists;
    
    IF parcialidad_exists THEN
        RETURN QUERY SELECT FALSE, 'La parcialidad ya está pagada', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar pago
    INSERT INTO public.pagos (
        convenio_id,
        numero_parcialidad,
        monto_pago,
        fecha_pago,
        numero_recibo,
        forma_pago,
        estado_pago,
        cajero,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_convenio_id,
        p_numero_parcialidad,
        p_monto_pago,
        CURRENT_DATE,
        p_numero_recibo,
        p_forma_pago,
        'APLICADO',
        p_cajero,
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    -- Actualizar convenio
    UPDATE public.convenios 
    SET 
        parcialidades_pagadas = parcialidades_pagadas + 1,
        adeudo_actual = adeudo_actual - p_monto_pago,
        fecha_ultimo_pago = CURRENT_DATE,
        fecha_actualizacion = NOW()
    WHERE id = p_convenio_id;
    
    -- Verificar si el convenio está liquidado
    UPDATE public.convenios 
    SET estado = 'LIQUIDADO'
    WHERE id = p_convenio_id 
    AND parcialidades_pagadas >= numero_parcialidades;
    
    RETURN QUERY SELECT TRUE, 'Pago registrado exitosamente', new_id;
END;
$$;

-- SP_CONVENIOS_VENCIDOS - Lista convenios vencidos
CREATE OR REPLACE FUNCTION SP_CONVENIOS_VENCIDOS(
    p_dias_gracia INTEGER DEFAULT 0
) RETURNS TABLE(
    id INTEGER,
    numero_convenio VARCHAR(50),
    contribuyente VARCHAR(255),
    rfc VARCHAR(15),
    telefono VARCHAR(20),
    adeudo_actual NUMERIC(15,2),
    fecha_vencimiento DATE,
    dias_vencido INTEGER,
    parcialidades_pendientes INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.numero_convenio,
        c.contribuyente,
        c.rfc,
        c.telefono,
        c.adeudo_actual,
        c.fecha_vencimiento,
        (CURRENT_DATE - c.fecha_vencimiento)::INTEGER as dias_vencido,
        (c.numero_parcialidades - c.parcialidades_pagadas) as parcialidades_pendientes
    FROM public.convenios c
    WHERE c.estado = 'ACTIVO'
    AND c.fecha_vencimiento < (CURRENT_DATE - INTERVAL '1 day' * p_dias_gracia)
    ORDER BY c.fecha_vencimiento;
END;
$$;

-- SP_CONVENIOS_ESTADISTICAS - Estadísticas del módulo
CREATE OR REPLACE FUNCTION SP_CONVENIOS_ESTADISTICAS() RETURNS TABLE(
    convenios_activos INTEGER,
    convenios_liquidados INTEGER,
    convenios_vencidos INTEGER,
    monto_total_adeudo NUMERIC(15,2),
    monto_recuperado_mes NUMERIC(15,2),
    parcialidades_pendientes INTEGER,
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
        (SELECT COUNT(*)::INTEGER FROM public.convenios WHERE estado = 'ACTIVO') as convenios_activos,
        
        (SELECT COUNT(*)::INTEGER FROM public.convenios WHERE estado = 'LIQUIDADO') as convenios_liquidados,
        
        (SELECT COUNT(*)::INTEGER FROM public.convenios 
         WHERE estado = 'ACTIVO' AND fecha_vencimiento < CURRENT_DATE) as convenios_vencidos,
        
        (SELECT COALESCE(SUM(adeudo_actual), 0) FROM public.convenios 
         WHERE estado = 'ACTIVO') as monto_total_adeudo,
        
        (SELECT COALESCE(SUM(monto_pago), 0) FROM public.pagos 
         WHERE fecha_pago BETWEEN inicio_mes AND fin_mes) as monto_recuperado_mes,
        
        (SELECT COALESCE(SUM(numero_parcialidades - parcialidades_pagadas), 0)::INTEGER 
         FROM public.convenios WHERE estado = 'ACTIVO') as parcialidades_pendientes,
        
        (SELECT 
            CASE 
                WHEN COUNT(*) > 0 
                THEN (COUNT(CASE WHEN estado = 'LIQUIDADO' THEN 1 END) * 100.0 / COUNT(*))::NUMERIC(5,2)
                ELSE 0 
            END
         FROM public.convenios) as efectividad_cobranza;
END;
$$;