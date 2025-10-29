-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO ESTACIONAMIENTOS - PROCEDIMIENTOS PRINCIPALES
-- Archivo: 01_SP_ESTACIONAMIENTOS_CORE_all_procedures.sql
-- ============================================

-- SP_ESTACIONAMIENTOS_PERMISOS_LIST - Lista permisos de estacionamiento
CREATE OR REPLACE FUNCTION SP_ESTACIONAMIENTOS_PERMISOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_search VARCHAR(255) DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL,
    p_zona VARCHAR(50) DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    numero_permiso VARCHAR(50),
    propietario VARCHAR(255),
    rfc VARCHAR(15),
    direccion_negocio TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    zona VARCHAR(50),
    tipo_estacionamiento VARCHAR(50),
    capacidad_vehiculos INTEGER,
    tarifa_por_hora NUMERIC(8,2),
    tarifa_mensualidad NUMERIC(8,2),
    fecha_expedicion DATE,
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
        e.id,
        e.numero_permiso,
        e.propietario,
        e.rfc,
        e.direccion_negocio,
        e.telefono,
        e.email,
        e.zona,
        e.tipo_estacionamiento,
        e.capacidad_vehiculos,
        e.tarifa_por_hora,
        e.tarifa_mensualidad,
        e.fecha_expedicion,
        e.fecha_vencimiento,
        e.estado,
        e.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.permisos e
    WHERE (p_search IS NULL OR 
           e.propietario ILIKE '%' || p_search || '%' OR
           e.numero_permiso ILIKE '%' || p_search || '%' OR
           e.rfc ILIKE '%' || p_search || '%')
    AND (p_estado IS NULL OR e.estado = p_estado)
    AND (p_zona IS NULL OR e.zona = p_zona)
    ORDER BY e.fecha_expedicion DESC, e.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_ESTACIONAMIENTOS_PERMISO_CREATE - Crear nuevo permiso
CREATE OR REPLACE FUNCTION SP_ESTACIONAMIENTOS_PERMISO_CREATE(
    p_numero_permiso VARCHAR(50),
    p_propietario VARCHAR(255),
    p_rfc VARCHAR(15),
    p_direccion_negocio TEXT,
    p_telefono VARCHAR(20),
    p_email VARCHAR(100),
    p_zona VARCHAR(50),
    p_tipo_estacionamiento VARCHAR(50),
    p_capacidad_vehiculos INTEGER,
    p_tarifa_por_hora NUMERIC(8,2),
    p_tarifa_mensualidad NUMERIC(8,2),
    p_vigencia_meses INTEGER DEFAULT 12,
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    permiso_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    permiso_exists BOOLEAN;
    rfc_exists BOOLEAN;
BEGIN
    -- Validar número de permiso único
    SELECT EXISTS(
        SELECT 1 FROM public.permisos 
        WHERE numero_permiso = p_numero_permiso
    ) INTO permiso_exists;
    
    IF permiso_exists THEN
        RETURN QUERY SELECT FALSE, 'El número de permiso ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Validar RFC único para la zona
    SELECT EXISTS(
        SELECT 1 FROM public.permisos 
        WHERE rfc = p_rfc AND zona = p_zona AND estado = 'VIGENTE'
    ) INTO rfc_exists;
    
    IF rfc_exists THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un permiso vigente para este RFC en la zona', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar permiso
    INSERT INTO public.permisos (
        numero_permiso,
        propietario,
        rfc,
        direccion_negocio,
        telefono,
        email,
        zona,
        tipo_estacionamiento,
        capacidad_vehiculos,
        tarifa_por_hora,
        tarifa_mensualidad,
        fecha_expedicion,
        fecha_vencimiento,
        estado,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_numero_permiso,
        p_propietario,
        p_rfc,
        p_direccion_negocio,
        p_telefono,
        p_email,
        p_zona,
        p_tipo_estacionamiento,
        p_capacidad_vehiculos,
        p_tarifa_por_hora,
        p_tarifa_mensualidad,
        CURRENT_DATE,
        CURRENT_DATE + INTERVAL '1 month' * p_vigencia_meses,
        'VIGENTE',
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Permiso de estacionamiento creado exitosamente', new_id;
END;
$$;

-- SP_ESTACIONAMIENTOS_ACCESOS_LIST - Lista control de accesos
CREATE OR REPLACE FUNCTION SP_ESTACIONAMIENTOS_ACCESOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_permiso_id INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_tipo_movimiento VARCHAR(20) DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    permiso_id INTEGER,
    numero_permiso VARCHAR(50),
    propietario VARCHAR(255),
    placa_vehiculo VARCHAR(20),
    tipo_vehiculo VARCHAR(30),
    tipo_movimiento VARCHAR(20),
    fecha_movimiento TIMESTAMP,
    operador VARCHAR(255),
    monto_cobrado NUMERIC(8,2),
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
        a.permiso_id,
        p.numero_permiso,
        p.propietario,
        a.placa_vehiculo,
        a.tipo_vehiculo,
        a.tipo_movimiento,
        a.fecha_movimiento,
        a.operador,
        a.monto_cobrado,
        a.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.accesos a
    JOIN public.permisos p ON a.permiso_id = p.id
    WHERE (p_permiso_id IS NULL OR a.permiso_id = p_permiso_id)
    AND (p_fecha_desde IS NULL OR DATE(a.fecha_movimiento) >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR DATE(a.fecha_movimiento) <= p_fecha_hasta)
    AND (p_tipo_movimiento IS NULL OR a.tipo_movimiento = p_tipo_movimiento)
    ORDER BY a.fecha_movimiento DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_ESTACIONAMIENTOS_PAGOS_LIST - Lista pagos de estacionamientos
CREATE OR REPLACE FUNCTION SP_ESTACIONAMIENTOS_PAGOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_permiso_id INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    permiso_id INTEGER,
    numero_permiso VARCHAR(50),
    propietario VARCHAR(255),
    numero_recibo VARCHAR(50),
    concepto_pago VARCHAR(255),
    monto_pago NUMERIC(10,2),
    fecha_pago DATE,
    periodo_desde DATE,
    periodo_hasta DATE,
    forma_pago VARCHAR(30),
    estado_pago VARCHAR(30),
    cajero VARCHAR(255),
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        pg.id,
        pg.permiso_id,
        p.numero_permiso,
        p.propietario,
        pg.numero_recibo,
        pg.concepto_pago,
        pg.monto_pago,
        pg.fecha_pago,
        pg.periodo_desde,
        pg.periodo_hasta,
        pg.forma_pago,
        pg.estado_pago,
        pg.cajero,
        COUNT(*) OVER() as total_count
    FROM public.pagos pg
    JOIN public.permisos p ON pg.permiso_id = p.id
    WHERE (p_permiso_id IS NULL OR pg.permiso_id = p_permiso_id)
    AND (p_fecha_desde IS NULL OR pg.fecha_pago >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR pg.fecha_pago <= p_fecha_hasta)
    ORDER BY pg.fecha_pago DESC, pg.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_ESTACIONAMIENTOS_CONSULTAS - Consultas rápidas
CREATE OR REPLACE FUNCTION SP_ESTACIONAMIENTOS_CONSULTAS(
    p_criterio VARCHAR(255),
    p_tipo_consulta VARCHAR(50) DEFAULT 'GENERAL'
) RETURNS TABLE(
    permiso_id INTEGER,
    numero_permiso VARCHAR(50),
    propietario VARCHAR(255),
    rfc VARCHAR(15),
    zona VARCHAR(50),
    estado VARCHAR(30),
    fecha_vencimiento DATE,
    dias_vencimiento INTEGER,
    telefono VARCHAR(20)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.numero_permiso,
        p.propietario,
        p.rfc,
        p.zona,
        p.estado,
        p.fecha_vencimiento,
        (p.fecha_vencimiento - CURRENT_DATE)::INTEGER as dias_vencimiento,
        p.telefono
    FROM public.permisos p
    WHERE 
        CASE p_tipo_consulta
            WHEN 'PERMISO' THEN p.numero_permiso ILIKE '%' || p_criterio || '%'
            WHEN 'RFC' THEN p.rfc ILIKE '%' || p_criterio || '%'
            WHEN 'PROPIETARIO' THEN p.propietario ILIKE '%' || p_criterio || '%'
            WHEN 'ZONA' THEN p.zona ILIKE '%' || p_criterio || '%'
            ELSE (
                p.numero_permiso ILIKE '%' || p_criterio || '%' OR
                p.propietario ILIKE '%' || p_criterio || '%' OR
                p.rfc ILIKE '%' || p_criterio || '%'
            )
        END
    ORDER BY p.fecha_expedicion DESC
    LIMIT 100;
END;
$$;

-- SP_ESTACIONAMIENTOS_BAJAS - Procesar baja de permiso
CREATE OR REPLACE FUNCTION SP_ESTACIONAMIENTOS_BAJAS(
    p_permiso_id INTEGER,
    p_motivo_baja TEXT,
    p_fecha_baja DATE DEFAULT NULL,
    p_autorizado_por VARCHAR(255) DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    permiso_info RECORD;
BEGIN
    -- Obtener información del permiso
    SELECT p.id, p.numero_permiso, p.estado
    INTO permiso_info
    FROM public.permisos p
    WHERE p.id = p_permiso_id;
    
    IF permiso_info.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El permiso no existe';
        RETURN;
    END IF;
    
    IF permiso_info.estado = 'CANCELADO' THEN
        RETURN QUERY SELECT FALSE, 'El permiso ya está cancelado';
        RETURN;
    END IF;
    
    -- Actualizar estado del permiso
    UPDATE public.permisos 
    SET 
        estado = 'CANCELADO',
        fecha_baja = COALESCE(p_fecha_baja, CURRENT_DATE),
        motivo_baja = p_motivo_baja,
        autorizado_por = p_autorizado_por,
        fecha_actualizacion = NOW()
    WHERE id = p_permiso_id;
    
    -- Registrar en historial
    INSERT INTO public.historial_bajas (
        permiso_id,
        fecha_baja,
        motivo,
        autorizado_por,
        fecha_registro
    ) VALUES (
        p_permiso_id,
        COALESCE(p_fecha_baja, CURRENT_DATE),
        p_motivo_baja,
        p_autorizado_por,
        NOW()
    );
    
    RETURN QUERY SELECT TRUE, 'Permiso dado de baja exitosamente';
END;
$$;

-- SP_ESTACIONAMIENTOS_GENERAR_REPORTE - Generar reportes de ingresos
CREATE OR REPLACE FUNCTION SP_ESTACIONAMIENTOS_GENERAR_REPORTE(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_zona VARCHAR(50) DEFAULT NULL
) RETURNS TABLE(
    zona VARCHAR(50),
    permisos_activos INTEGER,
    total_ingresos NUMERIC(15,2),
    movimientos_entrada INTEGER,
    movimientos_salida INTEGER,
    promedio_ingresos_permiso NUMERIC(10,2),
    capacidad_total INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.zona,
        COUNT(DISTINCT p.id)::INTEGER as permisos_activos,
        COALESCE(SUM(pg.monto_pago), 0) as total_ingresos,
        COUNT(CASE WHEN a.tipo_movimiento = 'ENTRADA' THEN 1 END)::INTEGER as movimientos_entrada,
        COUNT(CASE WHEN a.tipo_movimiento = 'SALIDA' THEN 1 END)::INTEGER as movimientos_salida,
        (COALESCE(SUM(pg.monto_pago), 0) / NULLIF(COUNT(DISTINCT p.id), 0))::NUMERIC(10,2) as promedio_ingresos_permiso,
        SUM(p.capacidad_vehiculos)::INTEGER as capacidad_total
    FROM public.permisos p
    LEFT JOIN public.pagos pg ON p.id = pg.permiso_id 
        AND pg.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
    LEFT JOIN public.accesos a ON p.id = a.permiso_id 
        AND DATE(a.fecha_movimiento) BETWEEN p_fecha_desde AND p_fecha_hasta
    WHERE p.estado = 'VIGENTE'
    AND (p_zona IS NULL OR p.zona = p_zona)
    GROUP BY p.zona
    ORDER BY total_ingresos DESC;
END;
$$;

-- SP_ESTACIONAMIENTOS_ESTADISTICAS - Estadísticas generales
CREATE OR REPLACE FUNCTION SP_ESTACIONAMIENTOS_ESTADISTICAS() RETURNS TABLE(
    permisos_vigentes INTEGER,
    permisos_vencidos INTEGER,
    permisos_cancelados INTEGER,
    ingresos_mes_actual NUMERIC(15,2),
    movimientos_mes_actual INTEGER,
    capacidad_total_sistema INTEGER,
    zonas_operativas INTEGER,
    promedio_tarifa_hora NUMERIC(8,2)
) LANGUAGE plpgsql AS $$
DECLARE
    inicio_mes DATE;
    fin_mes DATE;
BEGIN
    inicio_mes := DATE_TRUNC('month', CURRENT_DATE);
    fin_mes := inicio_mes + INTERVAL '1 month' - INTERVAL '1 day';
    
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM public.permisos 
         WHERE estado = 'VIGENTE' AND fecha_vencimiento >= CURRENT_DATE) as permisos_vigentes,
        
        (SELECT COUNT(*)::INTEGER FROM public.permisos 
         WHERE estado = 'VIGENTE' AND fecha_vencimiento < CURRENT_DATE) as permisos_vencidos,
        
        (SELECT COUNT(*)::INTEGER FROM public.permisos 
         WHERE estado = 'CANCELADO') as permisos_cancelados,
        
        (SELECT COALESCE(SUM(monto_pago), 0) FROM public.pagos 
         WHERE fecha_pago BETWEEN inicio_mes AND fin_mes) as ingresos_mes_actual,
        
        (SELECT COUNT(*)::INTEGER FROM public.accesos 
         WHERE DATE(fecha_movimiento) BETWEEN inicio_mes AND fin_mes) as movimientos_mes_actual,
        
        (SELECT COALESCE(SUM(capacidad_vehiculos), 0)::INTEGER FROM public.permisos 
         WHERE estado = 'VIGENTE') as capacidad_total_sistema,
        
        (SELECT COUNT(DISTINCT zona)::INTEGER FROM public.permisos 
         WHERE estado = 'VIGENTE') as zonas_operativas,
        
        (SELECT AVG(tarifa_por_hora)::NUMERIC(8,2) FROM public.permisos 
         WHERE estado = 'VIGENTE' AND tarifa_por_hora > 0) as promedio_tarifa_hora;
END;
$$;