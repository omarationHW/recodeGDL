-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO ASEO - PROCEDIMIENTOS PRINCIPALES
-- Archivo: 01_SP_ASEO_CORE_all_procedures.sql
-- ============================================

-- SP_ASEO_EMPRESAS_LIST - Lista empresas del servicio de aseo
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESAS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_search VARCHAR(255) DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    numero_registro VARCHAR(50),
    razon_social VARCHAR(255),
    nombre_comercial VARCHAR(255),
    rfc VARCHAR(15),
    direccion_fiscal TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    representante_legal VARCHAR(255),
    estado VARCHAR(30),
    fecha_alta DATE,
    fecha_vencimiento_licencia DATE,
    tipo_servicio VARCHAR(50),
    zona_cobertura TEXT,
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        e.id,
        e.numero_registro,
        e.razon_social,
        e.nombre_comercial,
        e.rfc,
        e.direccion_fiscal,
        e.telefono,
        e.email,
        e.representante_legal,
        e.estado,
        e.fecha_alta,
        e.fecha_vencimiento_licencia,
        e.tipo_servicio,
        e.zona_cobertura,
        COUNT(*) OVER() as total_count
    FROM public.empresas e
    WHERE (p_search IS NULL OR 
           e.razon_social ILIKE '%' || p_search || '%' OR
           e.nombre_comercial ILIKE '%' || p_search || '%' OR
           e.rfc ILIKE '%' || p_search || '%' OR
           e.numero_registro ILIKE '%' || p_search || '%')
    AND (p_estado IS NULL OR e.estado = p_estado)
    ORDER BY e.razon_social
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_ASEO_EMPRESA_GET - Obtener empresa específica
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESA_GET(p_empresa_id INTEGER) RETURNS TABLE(
    id INTEGER,
    numero_registro VARCHAR(50),
    razon_social VARCHAR(255),
    nombre_comercial VARCHAR(255),
    rfc VARCHAR(15),
    direccion_fiscal TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    representante_legal VARCHAR(255),
    estado VARCHAR(30),
    fecha_alta DATE,
    fecha_vencimiento_licencia DATE,
    tipo_servicio VARCHAR(50),
    zona_cobertura TEXT,
    observaciones TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.numero_registro,
        e.razon_social,
        e.nombre_comercial,
        e.rfc,
        e.direccion_fiscal,
        e.telefono,
        e.email,
        e.representante_legal,
        e.estado,
        e.fecha_alta,
        e.fecha_vencimiento_licencia,
        e.tipo_servicio,
        e.zona_cobertura,
        e.observaciones
    FROM public.empresas e
    WHERE e.id = p_empresa_id;
END;
$$;

-- SP_ASEO_EMPRESA_CREATE - Crear nueva empresa
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESA_CREATE(
    p_numero_registro VARCHAR(50),
    p_razon_social VARCHAR(255),
    p_nombre_comercial VARCHAR(255),
    p_rfc VARCHAR(15),
    p_direccion_fiscal TEXT,
    p_telefono VARCHAR(20),
    p_email VARCHAR(100),
    p_representante_legal VARCHAR(255),
    p_tipo_servicio VARCHAR(50),
    p_zona_cobertura TEXT,
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    empresa_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    registro_exists BOOLEAN;
    rfc_exists BOOLEAN;
BEGIN
    -- Validar número de registro único
    SELECT EXISTS(
        SELECT 1 FROM public.empresas 
        WHERE numero_registro = p_numero_registro
    ) INTO registro_exists;
    
    IF registro_exists THEN
        RETURN QUERY SELECT FALSE, 'El número de registro ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Validar RFC único
    SELECT EXISTS(
        SELECT 1 FROM public.empresas 
        WHERE rfc = p_rfc
    ) INTO rfc_exists;
    
    IF rfc_exists THEN
        RETURN QUERY SELECT FALSE, 'El RFC ya está registrado', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar empresa
    INSERT INTO public.empresas (
        numero_registro,
        razon_social,
        nombre_comercial,
        rfc,
        direccion_fiscal,
        telefono,
        email,
        representante_legal,
        estado,
        fecha_alta,
        fecha_vencimiento_licencia,
        tipo_servicio,
        zona_cobertura,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_numero_registro,
        p_razon_social,
        p_nombre_comercial,
        p_rfc,
        p_direccion_fiscal,
        p_telefono,
        p_email,
        p_representante_legal,
        'ACTIVA',
        CURRENT_DATE,
        CURRENT_DATE + INTERVAL '1 year',
        p_tipo_servicio,
        p_zona_cobertura,
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Empresa creada exitosamente', new_id;
END;
$$;

-- SP_ASEO_GASTOS_LIST - Lista gastos del servicio de aseo
CREATE OR REPLACE FUNCTION SP_ASEO_GASTOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_empresa_id INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_tipo_gasto VARCHAR(50) DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    empresa_id INTEGER,
    empresa_nombre VARCHAR(255),
    numero_comprobante VARCHAR(50),
    tipo_gasto VARCHAR(50),
    concepto TEXT,
    monto NUMERIC(15,2),
    fecha_gasto DATE,
    proveedor VARCHAR(255),
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
        g.id,
        g.empresa_id,
        e.razon_social,
        g.numero_comprobante,
        g.tipo_gasto,
        g.concepto,
        g.monto,
        g.fecha_gasto,
        g.proveedor,
        g.estado,
        g.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.gastos g
    JOIN public.empresas e ON g.empresa_id = e.id
    WHERE (p_empresa_id IS NULL OR g.empresa_id = p_empresa_id)
    AND (p_fecha_desde IS NULL OR g.fecha_gasto >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR g.fecha_gasto <= p_fecha_hasta)
    AND (p_tipo_gasto IS NULL OR g.tipo_gasto = p_tipo_gasto)
    ORDER BY g.fecha_gasto DESC, g.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_ASEO_OPERACIONES_LIST - Lista operaciones realizadas
CREATE OR REPLACE FUNCTION SP_ASEO_OPERACIONES_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_empresa_id INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_zona VARCHAR(100) DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    empresa_id INTEGER,
    empresa_nombre VARCHAR(255),
    tipo_operacion VARCHAR(50),
    zona VARCHAR(100),
    descripcion_operacion TEXT,
    fecha_operacion DATE,
    turno VARCHAR(20),
    responsable VARCHAR(255),
    vehiculo VARCHAR(50),
    toneladas_recolectadas NUMERIC(8,2),
    kilometros_recorridos NUMERIC(8,2),
    combustible_consumido NUMERIC(8,2),
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
        o.empresa_id,
        e.razon_social,
        o.tipo_operacion,
        o.zona,
        o.descripcion_operacion,
        o.fecha_operacion,
        o.turno,
        o.responsable,
        o.vehiculo,
        o.toneladas_recolectadas,
        o.kilometros_recorridos,
        o.combustible_consumido,
        o.estado,
        o.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.operaciones o
    JOIN public.empresas e ON o.empresa_id = e.id
    WHERE (p_empresa_id IS NULL OR o.empresa_id = p_empresa_id)
    AND (p_fecha_desde IS NULL OR o.fecha_operacion >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR o.fecha_operacion <= p_fecha_hasta)
    AND (p_zona IS NULL OR o.zona ILIKE '%' || p_zona || '%')
    ORDER BY o.fecha_operacion DESC, o.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_ASEO_RECARGOS_LIST - Lista recargos aplicados
CREATE OR REPLACE FUNCTION SP_ASEO_RECARGOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_empresa_id INTEGER DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    empresa_id INTEGER,
    empresa_nombre VARCHAR(255),
    numero_recargo VARCHAR(50),
    tipo_recargo VARCHAR(50),
    concepto_recargo TEXT,
    monto_base NUMERIC(15,2),
    porcentaje_recargo NUMERIC(5,2),
    monto_recargo NUMERIC(15,2),
    monto_total NUMERIC(15,2),
    fecha_aplicacion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(30),
    motivo TEXT,
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        r.id,
        r.empresa_id,
        e.razon_social,
        r.numero_recargo,
        r.tipo_recargo,
        r.concepto_recargo,
        r.monto_base,
        r.porcentaje_recargo,
        r.monto_recargo,
        r.monto_total,
        r.fecha_aplicacion,
        r.fecha_vencimiento,
        r.estado,
        r.motivo,
        COUNT(*) OVER() as total_count
    FROM public.recargos r
    JOIN public.empresas e ON r.empresa_id = e.id
    WHERE (p_empresa_id IS NULL OR r.empresa_id = p_empresa_id)
    AND (p_estado IS NULL OR r.estado = p_estado)
    ORDER BY r.fecha_aplicacion DESC, r.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_ASEO_ESTADISTICAS_EMPRESA - Estadísticas por empresa
CREATE OR REPLACE FUNCTION SP_ASEO_ESTADISTICAS_EMPRESA(
    p_empresa_id INTEGER,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    total_operaciones INTEGER,
    toneladas_totales NUMERIC(10,2),
    kilometros_totales NUMERIC(10,2),
    combustible_total NUMERIC(10,2),
    gastos_totales NUMERIC(15,2),
    recargos_aplicados INTEGER,
    monto_recargos NUMERIC(15,2),
    eficiencia_promedio NUMERIC(5,2),
    costo_por_tonelada NUMERIC(10,2)
) LANGUAGE plpgsql AS $$
DECLARE
    fecha_inicio DATE;
    fecha_fin DATE;
    total_ops INTEGER;
    tons_total NUMERIC(10,2);
    kms_total NUMERIC(10,2);
    combustible NUMERIC(10,2);
    gastos NUMERIC(15,2);
    cant_recargos INTEGER;
    monto_rec NUMERIC(15,2);
    eficiencia NUMERIC(5,2);
    costo_ton NUMERIC(10,2);
BEGIN
    -- Definir período
    fecha_inicio := COALESCE(p_fecha_desde, CURRENT_DATE - INTERVAL '1 month');
    fecha_fin := COALESCE(p_fecha_hasta, CURRENT_DATE);
    
    -- Operaciones
    SELECT 
        COUNT(*),
        COALESCE(SUM(toneladas_recolectadas), 0),
        COALESCE(SUM(kilometros_recorridos), 0),
        COALESCE(SUM(combustible_consumido), 0)
    INTO total_ops, tons_total, kms_total, combustible
    FROM public.operaciones 
    WHERE empresa_id = p_empresa_id 
    AND fecha_operacion BETWEEN fecha_inicio AND fecha_fin;
    
    -- Gastos
    SELECT COALESCE(SUM(monto), 0) INTO gastos
    FROM public.gastos 
    WHERE empresa_id = p_empresa_id 
    AND fecha_gasto BETWEEN fecha_inicio AND fecha_fin;
    
    -- Recargos
    SELECT 
        COUNT(*),
        COALESCE(SUM(monto_total), 0)
    INTO cant_recargos, monto_rec
    FROM public.recargos 
    WHERE empresa_id = p_empresa_id 
    AND fecha_aplicacion BETWEEN fecha_inicio AND fecha_fin;
    
    -- Cálculos
    eficiencia := CASE 
        WHEN kms_total > 0 THEN (tons_total / kms_total * 100)
        ELSE 0 
    END;
    
    costo_ton := CASE 
        WHEN tons_total > 0 THEN (gastos / tons_total)
        ELSE 0 
    END;
    
    RETURN QUERY SELECT 
        total_ops,
        tons_total,
        kms_total,
        combustible,
        gastos,
        cant_recargos,
        monto_rec,
        eficiencia,
        costo_ton;
END;
$$;

-- SP_ASEO_EMPRESAS_VENCIMIENTO - Empresas próximas a vencer
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESAS_VENCIMIENTO(
    p_dias_anticipacion INTEGER DEFAULT 30
) RETURNS TABLE(
    id INTEGER,
    numero_registro VARCHAR(50),
    razon_social VARCHAR(255),
    fecha_vencimiento_licencia DATE,
    dias_restantes INTEGER,
    telefono VARCHAR(20),
    email VARCHAR(100),
    representante_legal VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.numero_registro,
        e.razon_social,
        e.fecha_vencimiento_licencia,
        (e.fecha_vencimiento_licencia - CURRENT_DATE)::INTEGER as dias_restantes,
        e.telefono,
        e.email,
        e.representante_legal
    FROM public.empresas e
    WHERE e.estado = 'ACTIVA'
    AND e.fecha_vencimiento_licencia BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '1 day' * p_dias_anticipacion
    ORDER BY e.fecha_vencimiento_licencia;
END;
$$;