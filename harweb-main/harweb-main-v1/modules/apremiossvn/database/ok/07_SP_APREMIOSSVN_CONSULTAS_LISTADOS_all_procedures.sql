-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO APREMIOSSVN - CONSULTAS HISTÓRICAS Y LISTADOS
-- Archivo: 07_SP_APREMIOSSVN_CONSULTAS_LISTADOS_all_procedures.sql
-- Basado en: Cons_his, Listados y otros archivos de consultas
-- ============================================

-- =============================================
-- SECCIÓN: CONSULTAS HISTÓRICAS
-- =============================================

-- SP_APREMIOSSVN_CONSULTA_HISTORIA - Consulta histórica completa de apremio
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CONSULTA_HISTORIA(
    p_id_control INTEGER
) RETURNS TABLE(
    id_control INTEGER,
    control INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR(255),
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado VARCHAR(10),
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate VARCHAR(50),
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones VARCHAR(500),
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja VARCHAR(50),
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia VARCHAR(1),
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov VARCHAR(10),
    hora_practicado TIMESTAMP,
    descripcion_diligencia VARCHAR(255),
    descripcion_practicado VARCHAR(255),
    descripcion_secuestro VARCHAR(255),
    descripcion_remate VARCHAR(255),
    descripcion_vigencia VARCHAR(255),
    nombre_usuario VARCHAR(255),
    nombre_ejecutor VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.id_control,
        h.control,
        h.zona,
        h.modulo,
        h.control_otr,
        h.folio,
        h.diligencia,
        h.importe_global,
        h.importe_multa,
        h.importe_recargo,
        h.importe_gastos,
        h.zona_apremio,
        h.fecha_emision,
        h.clave_practicado,
        h.fecha_practicado,
        h.fecha_entrega1,
        h.fecha_entrega2,
        h.fecha_citatorio,
        h.hora,
        h.ejecutor,
        h.clave_secuestro,
        h.clave_remate,
        h.fecha_remate,
        h.porcentaje_multa,
        h.observaciones,
        h.fecha_pago,
        h.recaudadora,
        h.caja,
        h.operacion,
        h.importe_pago,
        h.vigencia,
        h.fecha_actualiz,
        h.usuario,
        h.clave_mov,
        h.hora_practicado,
        (SELECT c.descrip FROM public.ta_15_claves c WHERE c.clave = h.diligencia AND c.tipo_clave = 4 LIMIT 1) as descripcion_diligencia,
        (SELECT c.descrip FROM public.ta_15_claves c WHERE c.clave = h.clave_practicado AND c.tipo_clave = 1 LIMIT 1) as descripcion_practicado,
        (SELECT c.descrip FROM public.ta_15_claves c WHERE c.clave = h.clave_secuestro::VARCHAR AND c.tipo_clave = 2 LIMIT 1) as descripcion_secuestro,
        (SELECT c.descrip FROM public.ta_15_claves c WHERE c.clave = h.clave_remate AND c.tipo_clave = 3 LIMIT 1) as descripcion_remate,
        (SELECT c.descrip FROM public.ta_15_claves c WHERE c.clave = h.clave_mov AND c.tipo_clave = 5 LIMIT 1) as descripcion_vigencia,
        (SELECT u.nombre FROM public.ta_12_passwords u WHERE u.id_usuario = h.usuario LIMIT 1) as nombre_usuario,
        (SELECT e.nombre FROM public.ta_15_ejecutores e WHERE e.cve_eje = h.ejecutor AND e.id_rec = h.zona LIMIT 1) as nombre_ejecutor
    FROM public.ta_15_historia h
    WHERE h.id_control = p_id_control
    ORDER BY h.control DESC
    LIMIT 1;
END;
$$;

-- SP_APREMIOSSVN_CONSULTA_DETALLES_PERIODOS - Detalles de períodos de un apremio
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CONSULTA_DETALLES_PERIODOS(
    p_control_otr INTEGER
) RETURNS TABLE(
    id_control INTEGER,
    control_otr INTEGER,
    anio SMALLINT,
    periodo SMALLINT,
    importe NUMERIC,
    recargos NUMERIC,
    cantidad NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_control,
        p.control_otr,
        p.ayo as anio,
        p.periodo,
        p.importe,
        p.recargos,
        p.cantidad
    FROM public.ta_15_periodos p
    WHERE p.control_otr = p_control_otr
    ORDER BY p.ayo, p.periodo;
END;
$$;

-- SP_APREMIOSSVN_REFERENCIA_ASEO - Referencia completa de contrato de aseo
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REFERENCIA_ASEO(
    p_control_contrato INTEGER
) RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    id_rec SMALLINT,
    num_empresa INTEGER,
    ctrol_recolec INTEGER,
    cantidad_recolec SMALLINT,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR(1),
    aso_mes_oblig TIMESTAMP,
    cve VARCHAR(50),
    usuario INTEGER,
    fecha_hora_baja TIMESTAMP,
    tipo_aseo VARCHAR(255),
    descripcion_tipo VARCHAR(255),
    cta_aplicacion INTEGER,
    empresa_descripcion VARCHAR(255),
    representante VARCHAR(255),
    domicilio VARCHAR(255),
    sector VARCHAR(255),
    ctrol_zona INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.control_contrato,
        c.num_contrato,
        c.ctrol_aseo,
        c.id_rec,
        c.num_empresa,
        c.ctrol_recolec,
        c.cantidad_recolec,
        c.fecha_hora_alta,
        c.status_vigencia,
        c.aso_mes_oblig,
        c.cve,
        c.usuario,
        c.fecha_hora_baja,
        ta.tipo_aseo,
        ta.descripcion as descripcion_tipo,
        ta.cta_aplicacion,
        e.descripcion as empresa_descripcion,
        e.representante,
        e.domicilio,
        e.sector,
        e.ctrol_zona
    FROM public.ta_16_contratos c
    JOIN public.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    JOIN public.ta_16_empresas e ON c.num_empresa = e.num_empresa
    WHERE c.control_contrato = p_control_contrato;
END;
$$;

-- SP_APREMIOSSVN_REFERENCIA_MERCADO - Referencia completa de local de mercado
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REFERENCIA_MERCADO(
    p_id_local INTEGER
) RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(10),
    local SMALLINT,
    letra_local VARCHAR(2),
    bloque VARCHAR(10),
    id_contribuy_prop INTEGER,
    id_contribuy_renta INTEGER,
    nombre VARCHAR(255),
    arrendatario VARCHAR(255),
    domicilio VARCHAR(255),
    sector VARCHAR(255),
    zona SMALLINT,
    descripcion_local VARCHAR(255),
    superficie FLOAT,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    vigencia VARCHAR(1),
    id_usuario INTEGER,
    clave_cuota SMALLINT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.id_contribuy_prop,
        l.id_contribuy_renta,
        l.nombre,
        l.arrendatario,
        l.domicilio,
        l.sector,
        l.zona,
        l.descripcion_local,
        l.superficie,
        l.giro,
        l.fecha_alta,
        l.fecha_baja,
        l.fecha_modificacion,
        l.vigencia,
        l.id_usuario,
        l.clave_cuota
    FROM public.ta_11_locales l
    WHERE l.id_local = p_id_local;
END;
$$;

-- =============================================
-- SECCIÓN: LISTADOS Y CATÁLOGOS
-- =============================================

-- SP_APREMIOSSVN_CATALOGO_CLAVES - Catálogo de claves por tipo
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CATALOGO_CLAVES(
    p_tipo_clave SMALLINT DEFAULT NULL
) RETURNS TABLE(
    id_clave INTEGER,
    tipo_clave SMALLINT,
    concepto_tipo VARCHAR(255),
    clave VARCHAR(10),
    descripcion VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id_clave,
        c.tipo_clave,
        c.concepto_tipo,
        c.clave,
        c.descrip as descripcion
    FROM public.ta_15_claves c
    WHERE (p_tipo_clave IS NULL OR c.tipo_clave = p_tipo_clave)
    AND c.tipo_clave <> 4
    ORDER BY c.tipo_clave, c.clave;
END;
$$;

-- SP_APREMIOSSVN_CATALOGO_VIGENCIAS - Catálogo específico de vigencias
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CATALOGO_VIGENCIAS() RETURNS TABLE(
    id_clave INTEGER,
    tipo_clave SMALLINT,
    concepto_tipo VARCHAR(255),
    clave VARCHAR(10),
    descripcion VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id_clave,
        c.tipo_clave,
        c.concepto_tipo,
        c.clave,
        c.descrip as descripcion
    FROM public.ta_15_claves c
    WHERE c.tipo_clave = 5
    ORDER BY c.clave;
END;
$$;

-- SP_APREMIOSSVN_CATALOGO_RECAUDADORAS_COMPLETO - Catálogo completo de recaudadoras
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CATALOGO_RECAUDADORAS_COMPLETO() RETURNS TABLE(
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR(255),
    domicilio VARCHAR(255),
    telefono VARCHAR(50),
    recaudador VARCHAR(255),
    sector VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id_rec,
        r.id_zona,
        r.recaudadora,
        r.domicilio,
        r.tel as telefono,
        r.recaudador,
        r.sector
    FROM public.ta_12_recaudadoras r
    ORDER BY r.id_rec;
END;
$$;

-- SP_APREMIOSSVN_LISTADO_FOLIOS_FILTRADO - Listado principal con filtros avanzados
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADO_FOLIOS_FILTRADO(
    p_id_rec INTEGER,
    p_modulo INTEGER,
    p_folio_desde INTEGER,
    p_folio_hasta INTEGER,
    p_clave VARCHAR(10) DEFAULT NULL,
    p_vigencia VARCHAR(1) DEFAULT NULL,
    p_fecha_prac_desde DATE DEFAULT NULL,
    p_fecha_prac_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    id_control INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR(255),
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado VARCHAR(10),
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate VARCHAR(50),
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones VARCHAR(500),
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja VARCHAR(50),
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia VARCHAR(1),
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov VARCHAR(10),
    hora_practicado TIMESTAMP,
    nombre_ejecutor VARCHAR(255),
    datos_referencia TEXT,
    nombre_recaudadora VARCHAR(255),
    zona_descripcion VARCHAR(255),
    modulo_descripcion VARCHAR(255),
    estado_descripcion VARCHAR(20),
    anio_inicial SMALLINT,
    mes_inicial INTEGER,
    anio_final SMALLINT,
    mes_final INTEGER,
    importe_pagado NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_control,
        a.zona,
        a.modulo,
        a.control_otr,
        a.folio,
        a.diligencia,
        a.importe_global,
        a.importe_multa,
        a.importe_recargo,
        a.importe_gastos,
        a.zona_apremio,
        a.fecha_emision,
        a.clave_practicado,
        a.fecha_practicado,
        a.fecha_entrega1,
        a.fecha_entrega2,
        a.fecha_citatorio,
        a.hora,
        a.ejecutor,
        a.clave_secuestro,
        a.clave_remate,
        a.fecha_remate,
        a.porcentaje_multa,
        a.observaciones,
        a.fecha_pago,
        a.recaudadora,
        a.caja,
        a.operacion,
        a.importe_pago,
        a.vigencia,
        a.fecha_actualiz,
        a.usuario,
        a.clave_mov,
        a.hora_practicado,
        e.nombre as nombre_ejecutor,
        -- Datos de referencia según módulo
        CASE 
            WHEN a.modulo = 16 THEN 'Contrato Aseo: ' || COALESCE(ta.tipo_aseo, '') || '-' || COALESCE(tc.num_contrato::TEXT, '')
            WHEN a.modulo = 11 THEN 'Mercado: ' || COALESCE(tl.num_mercado::TEXT, '') || ' Cat:' || COALESCE(tl.categoria::TEXT, '') || ' Sec:' || COALESCE(tl.seccion, '') || ' Local:' || COALESCE(tl.local::TEXT, '')
            ELSE 'Módulo ' || a.modulo::TEXT
        END as datos_referencia,
        r.recaudadora as nombre_recaudadora,
        z.zona as zona_descripcion,
        m.descripcion as modulo_descripcion,
        CASE a.vigencia 
            WHEN '1' THEN 'VIGENTE'
            WHEN '2' THEN 'PAGADO'
            WHEN '3' THEN 'CANCELADO'
            ELSE 'SUSPENDIDO'
        END as estado_descripcion,
        (SELECT MIN(p.ayo) FROM public.ta_15_periodos p WHERE p.control_otr = a.id_control) as anio_inicial,
        (SELECT MIN(p.periodo) FROM public.ta_15_periodos p WHERE p.control_otr = a.id_control) as mes_inicial,
        (SELECT MAX(p.ayo) FROM public.ta_15_periodos p WHERE p.control_otr = a.id_control) as anio_final,
        (SELECT MAX(p.periodo) FROM public.ta_15_periodos p WHERE p.control_otr = a.id_control) as mes_final,
        COALESCE(a.importe_pago, 0) as importe_pagado
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    LEFT JOIN public.ta_12_recaudadoras r ON a.zona = r.id_rec
    LEFT JOIN public.ta_12_zonas z ON r.id_zona = z.id_zona
    LEFT JOIN public.ta_12_modulos m ON a.modulo = m.id_modulo
    -- JOINs condicionales según módulo
    LEFT JOIN public.ta_16_contratos tc ON a.modulo = 16 AND a.control_otr = tc.control_contrato
    LEFT JOIN public.ta_16_tipo_aseo ta ON tc.ctrol_aseo = ta.ctrol_aseo
    LEFT JOIN public.ta_11_locales tl ON a.modulo = 11 AND a.control_otr = tl.id_local
    WHERE a.zona = p_id_rec 
    AND a.modulo = p_modulo 
    AND a.folio BETWEEN p_folio_desde AND p_folio_hasta
    AND (p_clave IS NULL OR p_clave = 'todas' OR a.clave_practicado = p_clave)
    AND (p_fecha_prac_desde IS NULL OR p_fecha_prac_hasta IS NULL OR 
         (p_clave = 'P' AND a.fecha_practicado BETWEEN p_fecha_prac_desde AND p_fecha_prac_hasta))
    AND (p_vigencia IS NULL OR p_vigencia = 'todas' OR 
         (p_vigencia = '2' AND a.vigencia IN ('2', 'P')) OR 
         a.vigencia = p_vigencia)
    ORDER BY a.folio;
END;
$$;