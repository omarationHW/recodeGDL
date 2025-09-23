-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO ASEO - GESTIÓN DE EMPRESAS
-- Archivo: 01_SP_ASEO_EMPRESAS_all_procedures.sql
-- Basado en: ABC_Empresas_all_procedures.sql y archivos relacionados
-- ============================================

-- =============================================
-- SECCIÓN: CRUD DE EMPRESAS
-- =============================================

-- SP_ASEO_EMPRESAS_LISTAR - Lista todas las empresas con su tipo
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESAS_LISTAR() RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR(255),
    descripcion VARCHAR(255),
    representante VARCHAR(255),
    domicilio VARCHAR(255),
    telefono VARCHAR(50),
    email VARCHAR(100),
    fecha_registro DATE,
    vigencia VARCHAR(1)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.num_empresa,
        te.ctrol_emp,
        te.tipo_empresa,
        e.descripcion,
        e.representante,
        COALESCE(e.domicilio, '') as domicilio,
        COALESCE(e.telefono, '') as telefono,
        COALESCE(e.email, '') as email,
        COALESCE(e.fecha_registro, CURRENT_DATE) as fecha_registro,
        COALESCE(e.vigencia, 'A') as vigencia
    FROM public.ta_16_empresas e
    JOIN public.ta_16_tipos_emp te ON e.ctrol_emp = te.ctrol_emp
    ORDER BY e.descripcion, e.num_empresa;
END;
$$;

-- SP_ASEO_EMPRESA_OBTENER - Obtiene una empresa específica
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESA_OBTENER(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER
) RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR(255),
    descripcion VARCHAR(255),
    representante VARCHAR(255),
    domicilio VARCHAR(255),
    telefono VARCHAR(50),
    email VARCHAR(100),
    rfc VARCHAR(20),
    fecha_registro DATE,
    vigencia VARCHAR(1),
    sector VARCHAR(100),
    ctrol_zona INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.num_empresa,
        e.ctrol_emp,
        te.tipo_empresa,
        e.descripcion,
        e.representante,
        COALESCE(e.domicilio, '') as domicilio,
        COALESCE(e.telefono, '') as telefono,
        COALESCE(e.email, '') as email,
        COALESCE(e.rfc, '') as rfc,
        COALESCE(e.fecha_registro, CURRENT_DATE) as fecha_registro,
        COALESCE(e.vigencia, 'A') as vigencia,
        COALESCE(e.sector, '') as sector,
        COALESCE(e.ctrol_zona, 0) as ctrol_zona
    FROM public.ta_16_empresas e
    JOIN public.ta_16_tipos_emp te ON e.ctrol_emp = te.ctrol_emp
    WHERE e.num_empresa = p_num_empresa AND e.ctrol_emp = p_ctrol_emp;
END;
$$;

-- SP_ASEO_EMPRESA_CREAR - Crear nueva empresa
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESA_CREAR(
    p_ctrol_emp INTEGER,
    p_descripcion VARCHAR(255),
    p_representante VARCHAR(255),
    p_domicilio VARCHAR(255) DEFAULT NULL,
    p_telefono VARCHAR(50) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_sector VARCHAR(100) DEFAULT NULL,
    p_ctrol_zona INTEGER DEFAULT NULL
) RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    resultado TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    v_num_empresa INTEGER;
    v_existe INTEGER;
BEGIN
    -- Verificar que no exista empresa con la misma descripción y tipo
    SELECT COUNT(*) INTO v_existe 
    FROM public.ta_16_empresas 
    WHERE ctrol_emp = p_ctrol_emp AND UPPER(descripcion) = UPPER(p_descripcion);
    
    IF v_existe > 0 THEN
        RETURN QUERY SELECT NULL::INTEGER, p_ctrol_emp, 'ERROR: Ya existe una empresa con ese nombre y tipo'::TEXT;
        RETURN;
    END IF;
    
    -- Obtener siguiente número de empresa
    SELECT COALESCE(MAX(num_empresa), 0) + 1 INTO v_num_empresa 
    FROM public.ta_16_empresas 
    WHERE ctrol_emp = p_ctrol_emp;
    
    -- Insertar nueva empresa
    INSERT INTO public.ta_16_empresas (
        num_empresa, ctrol_emp, descripcion, representante, domicilio, 
        telefono, email, rfc, sector, ctrol_zona, fecha_registro, vigencia
    ) VALUES (
        v_num_empresa, p_ctrol_emp, p_descripcion, p_representante, p_domicilio,
        p_telefono, p_email, p_rfc, p_sector, p_ctrol_zona, CURRENT_DATE, 'A'
    );
    
    RETURN QUERY SELECT v_num_empresa, p_ctrol_emp, 'OK: Empresa creada exitosamente'::TEXT;
END;
$$;

-- SP_ASEO_EMPRESA_ACTUALIZAR - Actualizar empresa existente
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESA_ACTUALIZAR(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER,
    p_descripcion VARCHAR(255),
    p_representante VARCHAR(255),
    p_domicilio VARCHAR(255) DEFAULT NULL,
    p_telefono VARCHAR(50) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_sector VARCHAR(100) DEFAULT NULL,
    p_ctrol_zona INTEGER DEFAULT NULL
) RETURNS TABLE(
    actualizado INTEGER,
    mensaje TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    -- Actualizar empresa
    UPDATE public.ta_16_empresas 
    SET descripcion = p_descripcion,
        representante = p_representante,
        domicilio = p_domicilio,
        telefono = p_telefono,
        email = p_email,
        rfc = p_rfc,
        sector = p_sector,
        ctrol_zona = p_ctrol_zona,
        fecha_modificacion = CURRENT_DATE
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
    
    IF FOUND THEN
        RETURN QUERY SELECT 1, 'Empresa actualizada exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT 0, 'No se encontró la empresa especificada'::TEXT;
    END IF;
END;
$$;

-- SP_ASEO_EMPRESA_ELIMINAR - Eliminar empresa (solo si no tiene contratos)
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESA_ELIMINAR(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER
) RETURNS TABLE(
    eliminado INTEGER,
    mensaje TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    v_contratos INTEGER;
BEGIN
    -- Verificar si tiene contratos asociados
    SELECT COUNT(*) INTO v_contratos 
    FROM public.ta_16_contratos 
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
    
    IF v_contratos > 0 THEN
        RETURN QUERY SELECT 0, 'No se puede eliminar: la empresa tiene contratos asociados'::TEXT;
        RETURN;
    END IF;
    
    -- Eliminar empresa
    DELETE FROM public.ta_16_empresas 
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
    
    IF FOUND THEN
        RETURN QUERY SELECT 1, 'Empresa eliminada exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT 0, 'No se encontró la empresa especificada'::TEXT;
    END IF;
END;
$$;

-- SP_ASEO_EMPRESAS_BUSCAR - Buscar empresas por criterios
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESAS_BUSCAR(
    p_descripcion VARCHAR(255) DEFAULT NULL,
    p_ctrol_emp INTEGER DEFAULT NULL,
    p_representante VARCHAR(255) DEFAULT NULL,
    p_num_empresa INTEGER DEFAULT NULL
) RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR(255),
    descripcion VARCHAR(255),
    representante VARCHAR(255),
    domicilio VARCHAR(255),
    telefono VARCHAR(50),
    total_contratos INTEGER,
    vigencia VARCHAR(1)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.num_empresa,
        e.ctrol_emp,
        te.tipo_empresa,
        e.descripcion,
        e.representante,
        COALESCE(e.domicilio, '') as domicilio,
        COALESCE(e.telefono, '') as telefono,
        (SELECT COUNT(*)::INTEGER FROM public.ta_16_contratos c 
         WHERE c.num_empresa = e.num_empresa AND c.ctrol_emp = e.ctrol_emp) as total_contratos,
        COALESCE(e.vigencia, 'A') as vigencia
    FROM public.ta_16_empresas e
    JOIN public.ta_16_tipos_emp te ON e.ctrol_emp = te.ctrol_emp
    WHERE (p_descripcion IS NULL OR e.descripcion ILIKE '%' || p_descripcion || '%')
    AND (p_ctrol_emp IS NULL OR e.ctrol_emp = p_ctrol_emp)
    AND (p_representante IS NULL OR e.representante ILIKE '%' || p_representante || '%')
    AND (p_num_empresa IS NULL OR e.num_empresa = p_num_empresa)
    ORDER BY e.descripcion, e.num_empresa;
END;
$$;

-- =============================================
-- SECCIÓN: CATÁLOGOS DE APOYO
-- =============================================

-- SP_ASEO_TIPOS_EMPRESA_LISTAR - Lista todos los tipos de empresa
CREATE OR REPLACE FUNCTION SP_ASEO_TIPOS_EMPRESA_LISTAR() RETURNS TABLE(
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR(255),
    descripcion VARCHAR(255),
    vigencia VARCHAR(1),
    fecha_creacion DATE
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        te.ctrol_emp,
        te.tipo_empresa,
        COALESCE(te.descripcion, te.tipo_empresa) as descripcion,
        COALESCE(te.vigencia, 'A') as vigencia,
        COALESCE(te.fecha_creacion, CURRENT_DATE) as fecha_creacion
    FROM public.ta_16_tipos_emp te
    ORDER BY te.ctrol_emp;
END;
$$;

-- SP_ASEO_EMPRESAS_POR_NUMERO - Buscar empresa por número
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESAS_POR_NUMERO(
    p_num_empresa INTEGER
) RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR(255),
    descripcion VARCHAR(255),
    representante VARCHAR(255),
    domicilio VARCHAR(255),
    telefono VARCHAR(50),
    email VARCHAR(100)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.num_empresa,
        e.ctrol_emp,
        te.tipo_empresa,
        e.descripcion,
        e.representante,
        COALESCE(e.domicilio, '') as domicilio,
        COALESCE(e.telefono, '') as telefono,
        COALESCE(e.email, '') as email
    FROM public.ta_16_empresas e
    JOIN public.ta_16_tipos_emp te ON e.ctrol_emp = te.ctrol_emp
    WHERE e.num_empresa = p_num_empresa
    ORDER BY e.ctrol_emp;
END;
$$;

-- SP_ASEO_EMPRESAS_POR_NOMBRE - Buscar empresas por nombre
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESAS_POR_NOMBRE(
    p_nombre VARCHAR(255)
) RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR(255),
    descripcion VARCHAR(255),
    representante VARCHAR(255),
    coincidencia NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.num_empresa,
        e.ctrol_emp,
        te.tipo_empresa,
        e.descripcion,
        e.representante,
        -- Cálculo simple de coincidencia basado en similitud de texto
        CASE 
            WHEN UPPER(e.descripcion) = UPPER(p_nombre) THEN 100.0
            WHEN UPPER(e.descripcion) LIKE UPPER('%' || p_nombre || '%') THEN 80.0
            WHEN similarity(UPPER(e.descripcion), UPPER(p_nombre)) > 0.3 THEN 60.0
            ELSE 40.0
        END as coincidencia
    FROM public.ta_16_empresas e
    JOIN public.ta_16_tipos_emp te ON e.ctrol_emp = te.ctrol_emp
    WHERE e.descripcion ILIKE '%' || p_nombre || '%'
    OR e.representante ILIKE '%' || p_nombre || '%'
    ORDER BY coincidencia DESC, e.descripcion;
END;
$$;

-- SP_ASEO_EMPRESA_CONTRATOS - Obtener contratos de una empresa
CREATE OR REPLACE FUNCTION SP_ASEO_EMPRESA_CONTRATOS(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER
) RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR(255),
    id_rec SMALLINT,
    ctrol_recolec INTEGER,
    cantidad_recolec SMALLINT,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR(1),
    aso_mes_oblig DATE
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.control_contrato,
        c.num_contrato,
        c.ctrol_aseo,
        ta.tipo_aseo,
        c.id_rec,
        c.ctrol_recolec,
        c.cantidad_recolec,
        c.fecha_hora_alta,
        c.status_vigencia,
        c.aso_mes_oblig
    FROM public.ta_16_contratos c
    LEFT JOIN public.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    WHERE c.num_empresa = p_num_empresa AND c.ctrol_emp = p_ctrol_emp
    ORDER BY c.num_contrato;
END;
$$;