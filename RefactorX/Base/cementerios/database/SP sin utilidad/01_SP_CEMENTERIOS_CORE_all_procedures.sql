-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO CEMENTERIOS - PROCEDIMIENTOS PRINCIPALES
-- Archivo: 01_SP_CEMENTERIOS_CORE_all_procedures.sql
-- ============================================

-- SP_CEMENTERIOS_DIFUNTOS_LIST - Lista de difuntos registrados
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_DIFUNTOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_search VARCHAR(255) DEFAULT NULL,
    p_cementerio_id INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    numero_registro VARCHAR(50),
    nombre_completo VARCHAR(255),
    fecha_nacimiento DATE,
    fecha_defuncion DATE,
    edad_defuncion INTEGER,
    lugar_nacimiento VARCHAR(255),
    lugar_defuncion VARCHAR(255),
    causa_defuncion TEXT,
    cementerio_id INTEGER,
    cementerio_nombre VARCHAR(255),
    seccion VARCHAR(20),
    lote VARCHAR(20),
    fosa VARCHAR(20),
    tipo_sepultura VARCHAR(50),
    estado VARCHAR(30),
    solicitante VARCHAR(255),
    parentesco VARCHAR(50),
    telefono_contacto VARCHAR(20),
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        d.id,
        d.numero_registro,
        d.nombre_completo,
        d.fecha_nacimiento,
        d.fecha_defuncion,
        d.edad_defuncion,
        d.lugar_nacimiento,
        d.lugar_defuncion,
        d.causa_defuncion,
        d.cementerio_id,
        c.nombre as cementerio_nombre,
        d.seccion,
        d.lote,
        d.fosa,
        d.tipo_sepultura,
        d.estado,
        d.solicitante,
        d.parentesco,
        d.telefono_contacto,
        COUNT(*) OVER() as total_count
    FROM public.difuntos d
    JOIN public.cementerios c ON d.cementerio_id = c.id
    WHERE (p_search IS NULL OR 
           d.nombre_completo ILIKE '%' || p_search || '%' OR
           d.numero_registro ILIKE '%' || p_search || '%' OR
           d.solicitante ILIKE '%' || p_search || '%')
    AND (p_cementerio_id IS NULL OR d.cementerio_id = p_cementerio_id)
    AND (p_fecha_desde IS NULL OR d.fecha_defuncion >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR d.fecha_defuncion <= p_fecha_hasta)
    ORDER BY d.fecha_defuncion DESC, d.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_CEMENTERIOS_DIFUNTO_GET - Obtener difunto específico
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_DIFUNTO_GET(p_difunto_id INTEGER) RETURNS TABLE(
    id INTEGER,
    numero_registro VARCHAR(50),
    nombre_completo VARCHAR(255),
    fecha_nacimiento DATE,
    fecha_defuncion DATE,
    edad_defuncion INTEGER,
    lugar_nacimiento VARCHAR(255),
    lugar_defuncion VARCHAR(255),
    causa_defuncion TEXT,
    cementerio_id INTEGER,
    cementerio_nombre VARCHAR(255),
    seccion VARCHAR(20),
    lote VARCHAR(20),
    fosa VARCHAR(20),
    tipo_sepultura VARCHAR(50),
    estado VARCHAR(30),
    solicitante VARCHAR(255),
    parentesco VARCHAR(50),
    telefono_contacto VARCHAR(20),
    direccion_solicitante TEXT,
    observaciones TEXT,
    documento_identidad VARCHAR(50),
    acta_defuncion VARCHAR(50),
    numero_certificado_medico VARCHAR(50)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id,
        d.numero_registro,
        d.nombre_completo,
        d.fecha_nacimiento,
        d.fecha_defuncion,
        d.edad_defuncion,
        d.lugar_nacimiento,
        d.lugar_defuncion,
        d.causa_defuncion,
        d.cementerio_id,
        c.nombre as cementerio_nombre,
        d.seccion,
        d.lote,
        d.fosa,
        d.tipo_sepultura,
        d.estado,
        d.solicitante,
        d.parentesco,
        d.telefono_contacto,
        d.direccion_solicitante,
        d.observaciones,
        d.documento_identidad,
        d.acta_defuncion,
        d.numero_certificado_medico
    FROM public.difuntos d
    JOIN public.cementerios c ON d.cementerio_id = c.id
    WHERE d.id = p_difunto_id;
END;
$$;

-- SP_CEMENTERIOS_DIFUNTO_CREATE - Crear nuevo registro de difunto
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_DIFUNTO_CREATE(
    p_numero_registro VARCHAR(50),
    p_nombre_completo VARCHAR(255),
    p_fecha_nacimiento DATE,
    p_fecha_defuncion DATE,
    p_lugar_nacimiento VARCHAR(255),
    p_lugar_defuncion VARCHAR(255),
    p_causa_defuncion TEXT,
    p_cementerio_id INTEGER,
    p_seccion VARCHAR(20),
    p_lote VARCHAR(20),
    p_fosa VARCHAR(20),
    p_tipo_sepultura VARCHAR(50),
    p_solicitante VARCHAR(255),
    p_parentesco VARCHAR(50),
    p_telefono_contacto VARCHAR(20),
    p_direccion_solicitante TEXT,
    p_documento_identidad VARCHAR(50),
    p_acta_defuncion VARCHAR(50),
    p_numero_certificado_medico VARCHAR(50),
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    difunto_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    cementerio_exists BOOLEAN;
    registro_exists BOOLEAN;
    lote_disponible BOOLEAN;
    edad_calculada INTEGER;
BEGIN
    -- Validar que existe el cementerio
    SELECT EXISTS(
        SELECT 1 FROM public.cementerios 
        WHERE id = p_cementerio_id AND estado = 'ACTIVO'
    ) INTO cementerio_exists;
    
    IF NOT cementerio_exists THEN
        RETURN QUERY SELECT FALSE, 'El cementerio no existe o no está activo', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Validar número de registro único
    SELECT EXISTS(
        SELECT 1 FROM public.difuntos 
        WHERE numero_registro = p_numero_registro
    ) INTO registro_exists;
    
    IF registro_exists THEN
        RETURN QUERY SELECT FALSE, 'El número de registro ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Validar disponibilidad del lote/fosa
    SELECT NOT EXISTS(
        SELECT 1 FROM public.difuntos 
        WHERE cementerio_id = p_cementerio_id 
        AND seccion = p_seccion 
        AND lote = p_lote 
        AND fosa = p_fosa
        AND estado IN ('ACTIVO', 'OCUPADO')
    ) INTO lote_disponible;
    
    IF NOT lote_disponible THEN
        RETURN QUERY SELECT FALSE, 'El lote/fosa ya está ocupado', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Calcular edad
    edad_calculada := EXTRACT(YEAR FROM p_fecha_defuncion) - EXTRACT(YEAR FROM p_fecha_nacimiento);
    
    -- Insertar difunto
    INSERT INTO public.difuntos (
        numero_registro,
        nombre_completo,
        fecha_nacimiento,
        fecha_defuncion,
        edad_defuncion,
        lugar_nacimiento,
        lugar_defuncion,
        causa_defuncion,
        cementerio_id,
        seccion,
        lote,
        fosa,
        tipo_sepultura,
        estado,
        solicitante,
        parentesco,
        telefono_contacto,
        direccion_solicitante,
        documento_identidad,
        acta_defuncion,
        numero_certificado_medico,
        observaciones,
        fecha_registro,
        fecha_creacion
    ) VALUES (
        p_numero_registro,
        p_nombre_completo,
        p_fecha_nacimiento,
        p_fecha_defuncion,
        edad_calculada,
        p_lugar_nacimiento,
        p_lugar_defuncion,
        p_causa_defuncion,
        p_cementerio_id,
        p_seccion,
        p_lote,
        p_fosa,
        p_tipo_sepultura,
        'ACTIVO',
        p_solicitante,
        p_parentesco,
        p_telefono_contacto,
        p_direccion_solicitante,
        p_documento_identidad,
        p_acta_defuncion,
        p_numero_certificado_medico,
        p_observaciones,
        CURRENT_DATE,
        NOW()
    ) RETURNING id INTO new_id;
    
    -- Actualizar ocupación del lote
    UPDATE public.lotes 
    SET estado = 'OCUPADO', 
        fecha_ocupacion = CURRENT_DATE,
        difunto_id = new_id
    WHERE cementerio_id = p_cementerio_id 
    AND seccion = p_seccion 
    AND numero_lote = p_lote 
    AND numero_fosa = p_fosa;
    
    RETURN QUERY SELECT TRUE, 'Difunto registrado exitosamente', new_id;
END;
$$;

-- SP_CEMENTERIOS_CEMENTERIOS_LIST - Lista de cementerios
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_CEMENTERIOS_LIST() RETURNS TABLE(
    id INTEGER,
    codigo_cementerio VARCHAR(20),
    nombre VARCHAR(255),
    direccion TEXT,
    telefono VARCHAR(20),
    administrador VARCHAR(255),
    capacidad_total INTEGER,
    ocupados INTEGER,
    disponibles INTEGER,
    estado VARCHAR(30),
    fecha_apertura DATE,
    observaciones TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.codigo_cementerio,
        c.nombre,
        c.direccion,
        c.telefono,
        c.administrador,
        c.capacidad_total,
        (SELECT COUNT(*)::INTEGER FROM public.difuntos d WHERE d.cementerio_id = c.id AND d.estado = 'ACTIVO') as ocupados,
        (c.capacidad_total - (SELECT COUNT(*) FROM public.difuntos d WHERE d.cementerio_id = c.id AND d.estado = 'ACTIVO'))::INTEGER as disponibles,
        c.estado,
        c.fecha_apertura,
        c.observaciones
    FROM public.cementerios c
    ORDER BY c.nombre;
END;
$$;

-- SP_CEMENTERIOS_LOTES_LIST - Lista lotes por cementerio
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_LOTES_LIST(
    p_cementerio_id INTEGER,
    p_seccion VARCHAR(20) DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    cementerio_id INTEGER,
    seccion VARCHAR(20),
    numero_lote VARCHAR(20),
    numero_fosa VARCHAR(20),
    tipo_lote VARCHAR(50),
    dimensiones VARCHAR(100),
    precio_base NUMERIC(10,2),
    estado VARCHAR(30),
    fecha_ocupacion DATE,
    difunto_id INTEGER,
    difunto_nombre VARCHAR(255),
    observaciones TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id,
        l.cementerio_id,
        l.seccion,
        l.numero_lote,
        l.numero_fosa,
        l.tipo_lote,
        l.dimensiones,
        l.precio_base,
        l.estado,
        l.fecha_ocupacion,
        l.difunto_id,
        d.nombre_completo as difunto_nombre,
        l.observaciones
    FROM public.lotes l
    LEFT JOIN public.difuntos d ON l.difunto_id = d.id
    WHERE l.cementerio_id = p_cementerio_id
    AND (p_seccion IS NULL OR l.seccion = p_seccion)
    AND (p_estado IS NULL OR l.estado = p_estado)
    ORDER BY l.seccion, l.numero_lote, l.numero_fosa;
END;
$$;

-- SP_CEMENTERIOS_SERVICIOS_LIST - Lista servicios funerarios
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_SERVICIOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_difunto_id INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    difunto_id INTEGER,
    difunto_nombre VARCHAR(255),
    tipo_servicio VARCHAR(50),
    descripcion_servicio TEXT,
    proveedor_servicio VARCHAR(255),
    costo_servicio NUMERIC(10,2),
    fecha_servicio DATE,
    hora_servicio TIME,
    estado_servicio VARCHAR(30),
    responsable VARCHAR(255),
    observaciones TEXT,
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        s.id,
        s.difunto_id,
        d.nombre_completo as difunto_nombre,
        s.tipo_servicio,
        s.descripcion_servicio,
        s.proveedor_servicio,
        s.costo_servicio,
        s.fecha_servicio,
        s.hora_servicio,
        s.estado_servicio,
        s.responsable,
        s.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.servicios s
    JOIN public.difuntos d ON s.difunto_id = d.id
    WHERE (p_difunto_id IS NULL OR s.difunto_id = p_difunto_id)
    AND (p_fecha_desde IS NULL OR s.fecha_servicio >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR s.fecha_servicio <= p_fecha_hasta)
    ORDER BY s.fecha_servicio DESC, s.hora_servicio DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_CEMENTERIOS_PAGOS_LIST - Lista pagos realizados
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_PAGOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_difunto_id INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    difunto_id INTEGER,
    difunto_nombre VARCHAR(255),
    numero_recibo VARCHAR(50),
    concepto_pago VARCHAR(255),
    monto_pago NUMERIC(10,2),
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
        p.difunto_id,
        d.nombre_completo as difunto_nombre,
        p.numero_recibo,
        p.concepto_pago,
        p.monto_pago,
        p.fecha_pago,
        p.forma_pago,
        p.estado_pago,
        p.cajero,
        p.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.pagos p
    JOIN public.difuntos d ON p.difunto_id = d.id
    WHERE (p_difunto_id IS NULL OR p.difunto_id = p_difunto_id)
    AND (p_fecha_desde IS NULL OR p.fecha_pago >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR p.fecha_pago <= p_fecha_hasta)
    ORDER BY p.fecha_pago DESC, p.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_CEMENTERIOS_BUSCAR_DIFUNTO - Búsqueda avanzada de difuntos
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_BUSCAR_DIFUNTO(
    p_criterio VARCHAR(255),
    p_tipo_busqueda VARCHAR(50) DEFAULT 'GENERAL'
) RETURNS TABLE(
    id INTEGER,
    numero_registro VARCHAR(50),
    nombre_completo VARCHAR(255),
    fecha_defuncion DATE,
    cementerio_nombre VARCHAR(255),
    ubicacion TEXT,
    solicitante VARCHAR(255),
    telefono_contacto VARCHAR(20)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id,
        d.numero_registro,
        d.nombre_completo,
        d.fecha_defuncion,
        c.nombre as cementerio_nombre,
        (d.seccion || '-' || d.lote || '-' || d.fosa) as ubicacion,
        d.solicitante,
        d.telefono_contacto
    FROM public.difuntos d
    JOIN public.cementerios c ON d.cementerio_id = c.id
    WHERE 
        CASE p_tipo_busqueda
            WHEN 'NOMBRE' THEN d.nombre_completo ILIKE '%' || p_criterio || '%'
            WHEN 'REGISTRO' THEN d.numero_registro ILIKE '%' || p_criterio || '%'
            WHEN 'SOLICITANTE' THEN d.solicitante ILIKE '%' || p_criterio || '%'
            WHEN 'UBICACION' THEN (d.seccion || '-' || d.lote || '-' || d.fosa) ILIKE '%' || p_criterio || '%'
            ELSE (
                d.nombre_completo ILIKE '%' || p_criterio || '%' OR
                d.numero_registro ILIKE '%' || p_criterio || '%' OR
                d.solicitante ILIKE '%' || p_criterio || '%'
            )
        END
    AND d.estado = 'ACTIVO'
    ORDER BY d.fecha_defuncion DESC
    LIMIT 100;
END;
$$;

-- SP_CEMENTERIOS_ESTADISTICAS - Estadísticas generales
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_ESTADISTICAS() RETURNS TABLE(
    total_cementerios INTEGER,
    total_difuntos INTEGER,
    difuntos_mes_actual INTEGER,
    capacidad_total INTEGER,
    ocupacion_porcentaje NUMERIC(5,2),
    ingresos_mes_actual NUMERIC(15,2),
    servicios_mes_actual INTEGER,
    lotes_disponibles INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    inicio_mes DATE;
    fin_mes DATE;
BEGIN
    inicio_mes := DATE_TRUNC('month', CURRENT_DATE);
    fin_mes := inicio_mes + INTERVAL '1 month' - INTERVAL '1 day';
    
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM public.cementerios WHERE estado = 'ACTIVO') as total_cementerios,
        
        (SELECT COUNT(*)::INTEGER FROM public.difuntos WHERE estado = 'ACTIVO') as total_difuntos,
        
        (SELECT COUNT(*)::INTEGER FROM public.difuntos 
         WHERE fecha_registro BETWEEN inicio_mes AND fin_mes) as difuntos_mes_actual,
        
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
         WHERE c.estado = 'ACTIVO') as ocupacion_porcentaje,
        
        (SELECT COALESCE(SUM(monto_pago), 0) FROM public.pagos 
         WHERE fecha_pago BETWEEN inicio_mes AND fin_mes) as ingresos_mes_actual,
        
        (SELECT COUNT(*)::INTEGER FROM public.servicios 
         WHERE fecha_servicio BETWEEN inicio_mes AND fin_mes) as servicios_mes_actual,
        
        (SELECT COUNT(*)::INTEGER FROM public.lotes WHERE estado = 'DISPONIBLE') as lotes_disponibles;
END;
$$;