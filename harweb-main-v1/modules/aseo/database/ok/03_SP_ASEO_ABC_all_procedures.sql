-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO ASEO - ABC Y CATALOGOS
-- Archivo: 03_SP_ASEO_ABC_all_procedures.sql
-- ============================================

-- SP_ASEO_TIPOS_EMPRESA_LIST - Lista tipos de empresa
CREATE OR REPLACE FUNCTION SP_ASEO_TIPOS_EMPRESA_LIST() RETURNS TABLE(
    id INTEGER,
    codigo_tipo VARCHAR(10),
    descripcion_tipo VARCHAR(100),
    activo BOOLEAN
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.codigo_tipo,
        t.descripcion_tipo,
        t.activo
    FROM public.tipos_empresa t
    WHERE t.activo = TRUE
    ORDER BY t.descripcion_tipo;
END;
$$;

-- SP_ASEO_CLAVES_OPERACION_LIST - Lista claves de operación
CREATE OR REPLACE FUNCTION SP_ASEO_CLAVES_OPERACION_LIST() RETURNS TABLE(
    id INTEGER,
    clave_operacion VARCHAR(20),
    descripcion_operacion VARCHAR(255),
    categoria VARCHAR(50),
    activo BOOLEAN
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.clave_operacion,
        c.descripcion_operacion,
        c.categoria,
        c.activo
    FROM public.claves_operacion c
    WHERE c.activo = TRUE
    ORDER BY c.categoria, c.descripcion_operacion;
END;
$$;

-- SP_ASEO_CLAVE_OPERACION_CREATE - Crear nueva clave de operación
CREATE OR REPLACE FUNCTION SP_ASEO_CLAVE_OPERACION_CREATE(
    p_clave_operacion VARCHAR(20),
    p_descripcion_operacion VARCHAR(255),
    p_categoria VARCHAR(50)
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    clave_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    clave_exists BOOLEAN;
BEGIN
    -- Validar clave única
    SELECT EXISTS(
        SELECT 1 FROM public.claves_operacion 
        WHERE clave_operacion = p_clave_operacion
    ) INTO clave_exists;
    
    IF clave_exists THEN
        RETURN QUERY SELECT FALSE, 'La clave de operación ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar clave
    INSERT INTO public.claves_operacion (
        clave_operacion,
        descripcion_operacion,
        categoria,
        activo,
        fecha_creacion
    ) VALUES (
        p_clave_operacion,
        p_descripcion_operacion,
        p_categoria,
        TRUE,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Clave de operación creada exitosamente', new_id;
END;
$$;

-- SP_ASEO_EMPRESA_SEARCH - Búsqueda avanzada de empresas
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESA_SEARCH(
    p_criterio VARCHAR(255),
    p_tipo_busqueda VARCHAR(50) DEFAULT 'GENERAL'
) RETURNS TABLE(
    id INTEGER,
    numero_registro VARCHAR(50),
    razon_social VARCHAR(255),
    rfc VARCHAR(15),
    telefono VARCHAR(20),
    email VARCHAR(100),
    estado VARCHAR(30),
    tipo_servicio VARCHAR(50)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.numero_registro,
        e.razon_social,
        e.rfc,
        e.telefono,
        e.email,
        e.estado,
        e.tipo_servicio
    FROM public.empresas e
    WHERE 
        CASE p_tipo_busqueda
            WHEN 'REGISTRO' THEN e.numero_registro ILIKE '%' || p_criterio || '%'
            WHEN 'RAZON_SOCIAL' THEN e.razon_social ILIKE '%' || p_criterio || '%'
            WHEN 'RFC' THEN e.rfc ILIKE '%' || p_criterio || '%'
            ELSE (
                e.numero_registro ILIKE '%' || p_criterio || '%' OR
                e.razon_social ILIKE '%' || p_criterio || '%' OR
                e.rfc ILIKE '%' || p_criterio || '%' OR
                e.nombre_comercial ILIKE '%' || p_criterio || '%'
            )
        END
    ORDER BY e.razon_social
    LIMIT 100;
END;
$$;

-- SP_ASEO_REPORTES_POR_ZONA - Reportes de operaciones por zona
CREATE OR REPLACE FUNCTION SP_ASEO_REPORTES_POR_ZONA(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
) RETURNS TABLE(
    zona VARCHAR(100),
    total_operaciones INTEGER,
    toneladas_recolectadas NUMERIC(10,2),
    empresas_operando INTEGER,
    costo_promedio NUMERIC(10,2),
    eficiencia_promedio NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.zona,
        COUNT(*)::INTEGER as total_operaciones,
        SUM(o.toneladas_recolectadas) as toneladas_recolectadas,
        COUNT(DISTINCT o.empresa_id)::INTEGER as empresas_operando,
        AVG(g.monto)::NUMERIC(10,2) as costo_promedio,
        AVG(o.toneladas_recolectadas / NULLIF(o.kilometros_recorridos, 0) * 100)::NUMERIC(5,2) as eficiencia_promedio
    FROM public.operaciones o
    LEFT JOIN public.gastos g ON o.empresa_id = g.empresa_id 
        AND g.fecha_gasto BETWEEN p_fecha_desde AND p_fecha_hasta
    WHERE o.fecha_operacion BETWEEN p_fecha_desde AND p_fecha_hasta
    GROUP BY o.zona
    ORDER BY toneladas_recolectadas DESC;
END;
$$;