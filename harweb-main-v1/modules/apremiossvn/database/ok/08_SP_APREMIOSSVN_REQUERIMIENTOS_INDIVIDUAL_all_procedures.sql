-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO APREMIOSSVN - REQUERIMIENTOS Y CONSULTAS INDIVIDUALES
-- Archivo: 08_SP_APREMIOSSVN_REQUERIMIENTOS_INDIVIDUAL_all_procedures.sql
-- Basado en: Requerimientos, Individual y archivos relacionados
-- ============================================

-- =============================================
-- SECCIÓN: CONSULTAS INDIVIDUALES
-- =============================================

-- SP_APREMIOSSVN_CONSULTA_FOLIO_INDIVIDUAL - Consulta completa de folio individual
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CONSULTA_FOLIO_INDIVIDUAL(
    p_folio INTEGER
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
    descripcion_diligencia VARCHAR(255),
    descripcion_practicado VARCHAR(255),
    descripcion_secuestro VARCHAR(255),
    descripcion_remate VARCHAR(255),
    descripcion_vigencia VARCHAR(255),
    nombre_usuario VARCHAR(255),
    nombre_ejecutor VARCHAR(255),
    hora_practicado TIMESTAMP,
    modulo_descripcion VARCHAR(50),
    datos_referencia TEXT,
    importe_actualizado NUMERIC
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
        (SELECT c.descrip FROM public.ta_15_claves c WHERE c.clave = a.diligencia AND c.tipo_clave = 4 LIMIT 1) as descripcion_diligencia,
        (SELECT c.descrip FROM public.ta_15_claves c WHERE c.clave = a.clave_practicado AND c.tipo_clave = 1 LIMIT 1) as descripcion_practicado,
        (SELECT c.descrip FROM public.ta_15_claves c WHERE c.clave = a.clave_secuestro::VARCHAR AND c.tipo_clave = 2 LIMIT 1) as descripcion_secuestro,
        (SELECT c.descrip FROM public.ta_15_claves c WHERE c.clave = a.clave_remate AND c.tipo_clave = 3 LIMIT 1) as descripcion_remate,
        (SELECT c.descrip FROM public.ta_15_claves c WHERE c.clave = a.vigencia AND c.tipo_clave = 5 LIMIT 1) as descripcion_vigencia,
        (SELECT u.nombre FROM public.ta_12_passwords u WHERE u.id_usuario = a.usuario LIMIT 1) as nombre_usuario,
        (SELECT e.nombre FROM public.ta_15_ejecutores e WHERE e.cve_eje = a.ejecutor AND e.id_rec = a.zona LIMIT 1) as nombre_ejecutor,
        a.hora_practicado,
        CASE a.modulo
            WHEN 16 THEN 'Aseo'
            WHEN 11 THEN 'Mercados'
            WHEN 24 THEN 'Estacionamientos Públicos'
            WHEN 28 THEN 'Estacionamientos Exclusivos'
            WHEN 14 THEN 'Estacionómetros'
            WHEN 13 THEN 'Cementerios'
            ELSE 'Otro Módulo'
        END as modulo_descripcion,
        -- Datos de referencia según módulo
        CASE 
            WHEN a.modulo = 16 THEN 
                (SELECT 'Contrato Aseo: ' || COALESCE(ta.tipo_aseo, '') || '-' || COALESCE(tc.num_contrato::TEXT, '')
                 FROM public.ta_16_contratos tc
                 LEFT JOIN public.ta_16_tipo_aseo ta ON tc.ctrol_aseo = ta.ctrol_aseo
                 WHERE tc.control_contrato = a.control_otr LIMIT 1)
            WHEN a.modulo = 11 THEN 
                (SELECT 'Mercado: ' || COALESCE(tl.num_mercado::TEXT, '') || ' Cat:' || COALESCE(tl.categoria::TEXT, '') || ' Sec:' || COALESCE(tl.seccion, '') || ' Local:' || COALESCE(tl.local::TEXT, '')
                 FROM public.ta_11_locales tl
                 WHERE tl.id_local = a.control_otr LIMIT 1)
            WHEN a.modulo = 13 THEN
                (SELECT 'Cementerio: ' || COALESCE(tc.cementerio, '') || ' Clase:' || COALESCE(tc.clase::TEXT, '') || ' Sección:' || COALESCE(tc.seccion::TEXT, '')
                 FROM public.ta_13_datosrcm tc
                 WHERE tc.control_rcm = a.control_otr LIMIT 1)
            ELSE 'Referencia Módulo ' || a.modulo::TEXT
        END as datos_referencia,
        COALESCE(a.importe_global, 0) as importe_actualizado
    FROM public.ta_15_apremios a
    WHERE a.folio = p_folio;
END;
$$;

-- SP_APREMIOSSVN_HISTORIAL_FOLIO_INDIVIDUAL - Historial completo de un folio
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_HISTORIAL_FOLIO_INDIVIDUAL(
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
    hora_practicado TIMESTAMP
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
        h.hora_practicado
    FROM public.ta_15_historia h
    WHERE h.id_control = p_id_control
    ORDER BY h.fecha_actualiz DESC;
END;
$$;

-- SP_APREMIOSSVN_PERIODOS_FOLIO_INDIVIDUAL - Períodos asociados a un folio
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_PERIODOS_FOLIO_INDIVIDUAL(
    p_id_control INTEGER
) RETURNS TABLE(
    id_control INTEGER,
    control_otr INTEGER,
    anio SMALLINT,
    periodo INTEGER,
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
    WHERE p.control_otr = p_id_control
    ORDER BY p.ayo, p.periodo;
END;
$$;

-- SP_APREMIOSSVN_DETALLE_MODULO_REFERENCIA - Detalle JSON del módulo de referencia
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_DETALLE_MODULO_REFERENCIA(
    p_modulo INTEGER,
    p_control_otr INTEGER
) RETURNS JSONB LANGUAGE plpgsql AS $$
DECLARE
    resultado JSONB;
BEGIN
    CASE p_modulo
        WHEN 16 THEN -- Aseo
            SELECT row_to_json(datos)::JSONB INTO resultado
            FROM (
                SELECT c.*, ta.tipo_aseo, ta.descripcion as descripcion_tipo,
                       e.descripcion as empresa_descripcion, e.representante
                FROM public.ta_16_contratos c
                LEFT JOIN public.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
                LEFT JOIN public.ta_16_empresas e ON c.num_empresa = e.num_empresa
                WHERE c.control_contrato = p_control_otr
            ) datos;
            
        WHEN 11 THEN -- Mercados
            SELECT row_to_json(datos)::JSONB INTO resultado
            FROM (
                SELECT * FROM public.ta_11_locales
                WHERE id_local = p_control_otr
            ) datos;
            
        WHEN 24 THEN -- Estacionamientos Públicos
            SELECT row_to_json(datos)::JSONB INTO resultado
            FROM (
                SELECT * FROM public.pubmain
                WHERE id = p_control_otr
            ) datos;
            
        WHEN 28 THEN -- Estacionamientos Exclusivos
            SELECT row_to_json(datos)::JSONB INTO resultado
            FROM (
                SELECT * FROM public.ex_contrato
                WHERE id = p_control_otr
            ) datos;
            
        WHEN 14 THEN -- Estacionómetros
            SELECT row_to_json(datos)::JSONB INTO resultado
            FROM (
                SELECT * FROM public.ta_padron
                WHERE id = p_control_otr
            ) datos;
            
        WHEN 13 THEN -- Cementerios
            SELECT row_to_json(datos)::JSONB INTO resultado
            FROM (
                SELECT * FROM public.ta_13_datosrcm
                WHERE control_rcm = p_control_otr
            ) datos;
            
        ELSE
            resultado := NULL;
    END CASE;
    
    RETURN COALESCE(resultado, '{}'::JSONB);
END;
$$;

-- =============================================
-- SECCIÓN: REQUERIMIENTOS DE PAGO
-- =============================================

-- SP_APREMIOSSVN_CATALOGO_MERCADOS - Catálogo de mercados para requerimientos
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CATALOGO_MERCADOS(
    p_usuario_id INTEGER DEFAULT NULL
) RETURNS TABLE(
    id_mercado INTEGER,
    descripcion TEXT,
    num_mercado INTEGER,
    ubicacion VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id_mercado,
        m.descripcion::TEXT,
        m.num_mercado,
        COALESCE(m.domicilio, '') as ubicacion
    FROM public.mercados m
    WHERE (p_usuario_id IS NULL OR p_usuario_id = 1 OR m.user_id = p_usuario_id)
    ORDER BY m.num_mercado;
END;
$$;

-- SP_APREMIOSSVN_CATALOGO_SECCIONES_MERCADO - Catálogo de secciones
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CATALOGO_SECCIONES_MERCADO() RETURNS TABLE(
    seccion VARCHAR(10),
    descripcion TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.seccion,
        s.descripcion::TEXT
    FROM public.secciones s
    ORDER BY s.seccion;
END;
$$;

-- SP_APREMIOSSVN_CATALOGO_TIPOS_ASEO - Catálogo de tipos de aseo
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CATALOGO_TIPOS_ASEO() RETURNS TABLE(
    ctrol_aseo INTEGER,
    tipo_aseo TEXT,
    descripcion TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ta.ctrol_aseo,
        ta.tipo_aseo::TEXT,
        ta.descripcion::TEXT
    FROM public.ta_16_tipo_aseo ta
    ORDER BY ta.ctrol_aseo DESC;
END;
$$;

-- SP_APREMIOSSVN_BUSCAR_ADEUDOS_MERCADOS - Búsqueda de adeudos de mercados
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_BUSCAR_ADEUDOS_MERCADOS(
    p_oficina INTEGER,
    p_mercado_desde INTEGER,
    p_mercado_hasta INTEGER,
    p_local_desde INTEGER,
    p_local_hasta INTEGER,
    p_seccion VARCHAR(10) DEFAULT NULL,
    p_filtro_tipo VARCHAR(50) DEFAULT NULL,
    p_filtro_valor TEXT DEFAULT NULL,
    p_adeudo_minimo NUMERIC DEFAULT 0,
    p_adeudo_maximo NUMERIC DEFAULT 999999999,
    p_usuario_id INTEGER DEFAULT NULL
) RETURNS TABLE(
    id_referencia INTEGER,
    descripcion_mercado TEXT,
    num_mercado INTEGER,
    local_info TEXT,
    adeudo_total NUMERIC,
    periodo_texto TEXT,
    importe_base NUMERIC,
    recargos_total NUMERIC,
    estado VARCHAR(20)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id_mercado as id_referencia,
        m.descripcion::TEXT as descripcion_mercado,
        m.num_mercado,
        ('Local: ' || COALESCE(m.local::TEXT, '') || ' Sec: ' || COALESCE(m.seccion, ''))::TEXT as local_info,
        SUM(COALESCE(a.importe, 0)) as adeudo_total,
        '2024-1'::TEXT as periodo_texto,
        SUM(COALESCE(a.importe, 0)) as importe_base,
        SUM(COALESCE(a.recargos, 0)) as recargos_total,
        'ADEUDO'::VARCHAR(20) as estado
    FROM public.mercados m
    LEFT JOIN public.adeudos a ON a.id_mercado = m.id_mercado
    WHERE m.oficina = p_oficina
    AND m.num_mercado BETWEEN p_mercado_desde AND p_mercado_hasta
    AND (p_local_desde IS NULL OR a.local BETWEEN p_local_desde AND p_local_hasta)
    AND (p_seccion IS NULL OR m.seccion = p_seccion)
    AND (p_usuario_id IS NULL OR p_usuario_id = 1 OR m.user_id = p_usuario_id)
    GROUP BY m.id_mercado, m.descripcion, m.num_mercado, m.local, m.seccion
    HAVING SUM(COALESCE(a.importe, 0)) BETWEEN p_adeudo_minimo AND p_adeudo_maximo
    ORDER BY m.num_mercado, m.local;
END;
$$;

-- SP_APREMIOSSVN_BUSCAR_ADEUDOS_ASEO - Búsqueda de adeudos de aseo
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_BUSCAR_ADEUDOS_ASEO(
    p_tipo_aseo TEXT,
    p_contrato_desde INTEGER,
    p_contrato_hasta INTEGER,
    p_filtro_tipo VARCHAR(50) DEFAULT NULL,
    p_filtro_valor TEXT DEFAULT NULL,
    p_adeudo_minimo NUMERIC DEFAULT 0,
    p_adeudo_maximo NUMERIC DEFAULT 999999999,
    p_usuario_id INTEGER DEFAULT NULL
) RETURNS TABLE(
    id_referencia INTEGER,
    tipo_aseo TEXT,
    num_contrato INTEGER,
    empresa_info TEXT,
    adeudo_total NUMERIC,
    periodo_texto TEXT,
    importe_base NUMERIC,
    recargos_total NUMERIC,
    estado VARCHAR(20)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id_contrato as id_referencia,
        c.tipo_aseo::TEXT,
        c.num_contrato,
        ('Empresa: ' || COALESCE(e.descripcion, ''))::TEXT as empresa_info,
        SUM(COALESCE(a.importe, 0)) as adeudo_total,
        '2024-1'::TEXT as periodo_texto,
        SUM(COALESCE(a.importe, 0)) as importe_base,
        SUM(COALESCE(a.recargos, 0)) as recargos_total,
        'ADEUDO'::VARCHAR(20) as estado
    FROM public.contratos_aseo c
    LEFT JOIN public.adeudos_aseo a ON a.id_contrato = c.id_contrato
    LEFT JOIN public.ta_16_empresas e ON c.num_empresa = e.num_empresa
    WHERE c.tipo_aseo = p_tipo_aseo
    AND c.num_contrato BETWEEN p_contrato_desde AND p_contrato_hasta
    GROUP BY c.id_contrato, c.tipo_aseo, c.num_contrato, e.descripcion
    HAVING SUM(COALESCE(a.importe, 0)) BETWEEN p_adeudo_minimo AND p_adeudo_maximo
    ORDER BY c.num_contrato;
END;
$$;

-- SP_APREMIOSSVN_GENERAR_REQUERIMIENTOS_MERCADO - Generar requerimientos masivos mercados
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GENERAR_REQUERIMIENTOS_MERCADO(
    p_oficina INTEGER,
    p_mercado_desde INTEGER,
    p_mercado_hasta INTEGER,
    p_local_desde INTEGER,
    p_local_hasta INTEGER,
    p_seccion VARCHAR(10) DEFAULT NULL,
    p_usuario_id INTEGER
) RETURNS TABLE(
    folio INTEGER,
    id_mercado INTEGER,
    resultado TEXT,
    detalles TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    rec RECORD;
    v_folio INTEGER;
BEGIN
    FOR rec IN 
        SELECT m.id_mercado, m.descripcion, m.num_mercado
        FROM public.mercados m
        WHERE m.oficina = p_oficina
        AND m.num_mercado BETWEEN p_mercado_desde AND p_mercado_hasta
        AND (p_seccion IS NULL OR m.seccion = p_seccion)
    LOOP
        -- Generar folio secuencial
        SELECT COALESCE(MAX(folio), 0) + 1 INTO v_folio 
        FROM public.requerimientos 
        WHERE EXTRACT(YEAR FROM fecha_emision) = EXTRACT(YEAR FROM CURRENT_DATE);
        
        -- Insertar requerimiento
        INSERT INTO public.requerimientos (
            folio, id_mercado, user_id, fecha_emision, estado, tipo_requerimiento
        ) VALUES (
            v_folio, rec.id_mercado, p_usuario_id, NOW(), 'EMITIDO', 'MERCADO'
        );
        
        RETURN QUERY SELECT v_folio, rec.id_mercado, 'OK'::TEXT, 
                           ('Requerimiento generado para mercado: ' || rec.descripcion)::TEXT;
    END LOOP;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 0, 0, 'ERROR'::TEXT, 'No se encontraron mercados que cumplan los criterios'::TEXT;
    END IF;
END;
$$;

-- SP_APREMIOSSVN_GENERAR_REQUERIMIENTOS_ASEO - Generar requerimientos masivos aseo
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GENERAR_REQUERIMIENTOS_ASEO(
    p_tipo_aseo TEXT,
    p_contrato_desde INTEGER,
    p_contrato_hasta INTEGER,
    p_usuario_id INTEGER
) RETURNS TABLE(
    folio INTEGER,
    id_contrato INTEGER,
    resultado TEXT,
    detalles TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    rec RECORD;
    v_folio INTEGER;
BEGIN
    FOR rec IN 
        SELECT c.id_contrato, c.tipo_aseo, c.num_contrato
        FROM public.contratos_aseo c
        WHERE c.tipo_aseo = p_tipo_aseo
        AND c.num_contrato BETWEEN p_contrato_desde AND p_contrato_hasta
    LOOP
        -- Generar folio secuencial
        SELECT COALESCE(MAX(folio), 0) + 1 INTO v_folio 
        FROM public.requerimientos_aseo 
        WHERE EXTRACT(YEAR FROM fecha_emision) = EXTRACT(YEAR FROM CURRENT_DATE);
        
        -- Insertar requerimiento
        INSERT INTO public.requerimientos_aseo (
            folio, id_contrato, user_id, fecha_emision, estado, tipo_requerimiento
        ) VALUES (
            v_folio, rec.id_contrato, p_usuario_id, NOW(), 'EMITIDO', 'ASEO'
        );
        
        RETURN QUERY SELECT v_folio, rec.id_contrato, 'OK'::TEXT, 
                           ('Requerimiento generado para contrato: ' || rec.num_contrato::TEXT)::TEXT;
    END LOOP;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 0, 0, 'ERROR'::TEXT, 'No se encontraron contratos que cumplan los criterios'::TEXT;
    END IF;
END;
$$;