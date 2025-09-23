-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO OTRAS OBLIGACIONES - PROCEDIMIENTOS PRINCIPALES
-- Archivo: 01_SP_OTRAS_OBLIGACIONES_CORE_all_procedures.sql
-- ============================================

-- SP_OTRAS_OBLIGACIONES_LIST - Lista otras obligaciones
CREATE OR REPLACE FUNCTION SP_OTRAS_OBLIGACIONES_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_search VARCHAR(255) DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL,
    p_tipo_obligacion VARCHAR(50) DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    numero_obligacion VARCHAR(50),
    contribuyente VARCHAR(255),
    rfc VARCHAR(15),
    tipo_obligacion VARCHAR(50),
    descripcion TEXT,
    monto_original NUMERIC(15,2),
    monto_actual NUMERIC(15,2),
    fecha_generacion DATE,
    fecha_vencimiento DATE,
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
        o.id,
        o.numero_obligacion,
        o.contribuyente,
        o.rfc,
        o.tipo_obligacion,
        o.descripcion,
        o.monto_original,
        o.monto_actual,
        o.fecha_generacion,
        o.fecha_vencimiento,
        o.estado,
        o.observaciones,
        COUNT(*) OVER() as total_count
    FROM otras_obligaciones.obligaciones o
    WHERE (p_search IS NULL OR 
           o.contribuyente ILIKE '%' || p_search || '%' OR
           o.numero_obligacion ILIKE '%' || p_search || '%' OR
           o.rfc ILIKE '%' || p_search || '%')
    AND (p_estado IS NULL OR o.estado = p_estado)
    AND (p_tipo_obligacion IS NULL OR o.tipo_obligacion = p_tipo_obligacion)
    ORDER BY o.fecha_generacion DESC, o.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_OTRAS_OBLIGACIONES_CREATE - Crear nueva obligación
CREATE OR REPLACE FUNCTION SP_OTRAS_OBLIGACIONES_CREATE(
    p_numero_obligacion VARCHAR(50),
    p_contribuyente VARCHAR(255),
    p_rfc VARCHAR(15),
    p_tipo_obligacion VARCHAR(50),
    p_descripcion TEXT,
    p_monto_original NUMERIC(15,2),
    p_fecha_vencimiento DATE,
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    obligacion_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    obligacion_exists BOOLEAN;
BEGIN
    -- Validar número único
    SELECT EXISTS(
        SELECT 1 FROM otras_obligaciones.obligaciones 
        WHERE numero_obligacion = p_numero_obligacion
    ) INTO obligacion_exists;
    
    IF obligacion_exists THEN
        RETURN QUERY SELECT FALSE, 'El número de obligación ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar obligación
    INSERT INTO otras_obligaciones.obligaciones (
        numero_obligacion,
        contribuyente,
        rfc,
        tipo_obligacion,
        descripcion,
        monto_original,
        monto_actual,
        fecha_generacion,
        fecha_vencimiento,
        estado,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_numero_obligacion,
        p_contribuyente,
        p_rfc,
        p_tipo_obligacion,
        p_descripcion,
        p_monto_original,
        p_monto_original,
        CURRENT_DATE,
        p_fecha_vencimiento,
        'PENDIENTE',
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Obligación creada exitosamente', new_id;
END;
$$;

-- SP_OTRAS_OBLIGACIONES_PAGOS_LIST - Lista pagos
CREATE OR REPLACE FUNCTION SP_OTRAS_OBLIGACIONES_PAGOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_obligacion_id INTEGER DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    obligacion_id INTEGER,
    numero_obligacion VARCHAR(50),
    contribuyente VARCHAR(255),
    numero_recibo VARCHAR(50),
    monto_pago NUMERIC(15,2),
    fecha_pago DATE,
    forma_pago VARCHAR(30),
    cajero VARCHAR(255),
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        p.id,
        p.obligacion_id,
        o.numero_obligacion,
        o.contribuyente,
        p.numero_recibo,
        p.monto_pago,
        p.fecha_pago,
        p.forma_pago,
        p.cajero,
        COUNT(*) OVER() as total_count
    FROM otras_obligaciones.pagos p
    JOIN otras_obligaciones.obligaciones o ON p.obligacion_id = o.id
    WHERE (p_obligacion_id IS NULL OR p.obligacion_id = p_obligacion_id)
    ORDER BY p.fecha_pago DESC, p.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_OTRAS_OBLIGACIONES_ESTADISTICAS - Estadísticas
CREATE OR REPLACE FUNCTION SP_OTRAS_OBLIGACIONES_ESTADISTICAS() RETURNS TABLE(
    obligaciones_pendientes INTEGER,
    obligaciones_pagadas INTEGER,
    monto_total_pendiente NUMERIC(15,2),
    ingresos_mes_actual NUMERIC(15,2)
) LANGUAGE plpgsql AS $$
DECLARE
    inicio_mes DATE;
BEGIN
    inicio_mes := DATE_TRUNC('month', CURRENT_DATE);
    
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM otras_obligaciones.obligaciones WHERE estado = 'PENDIENTE') as obligaciones_pendientes,
        (SELECT COUNT(*)::INTEGER FROM otras_obligaciones.obligaciones WHERE estado = 'PAGADO') as obligaciones_pagadas,
        (SELECT COALESCE(SUM(monto_actual), 0) FROM otras_obligaciones.obligaciones WHERE estado = 'PENDIENTE') as monto_total_pendiente,
        (SELECT COALESCE(SUM(monto_pago), 0) FROM otras_obligaciones.pagos WHERE fecha_pago >= inicio_mes) as ingresos_mes_actual;
END;
$$;