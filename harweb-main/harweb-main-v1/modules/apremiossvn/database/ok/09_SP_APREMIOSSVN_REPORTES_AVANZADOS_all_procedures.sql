-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO APREMIOSSVN - REPORTES AVANZADOS Y EXPORTACIONES
-- Archivo: 09_SP_APREMIOSSVN_REPORTES_AVANZADOS_all_procedures.sql
-- Basado en: RptFact_Merc, ExportarExcel, RptLista_mercados y otros reportes
-- ============================================

-- =============================================
-- SECCIÓN: REPORTES DE FACTURACIÓN
-- =============================================

-- SP_APREMIOSSVN_REPORTE_FACTURACION_MERCADOS - Reporte de facturación de mercados
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTE_FACTURACION_MERCADOS(
    p_recaudadora INTEGER,
    p_folio_desde INTEGER,
    p_folio_hasta INTEGER
) RETURNS TABLE(
    -- Datos del local
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(10),
    local SMALLINT,
    letra_local VARCHAR(2),
    bloque VARCHAR(10),
    id_contribuyente_propietario INTEGER,
    id_contribuyente_renta INTEGER,
    nombre VARCHAR(255),
    arrendatario VARCHAR(255),
    domicilio VARCHAR(255),
    sector VARCHAR(50),
    zona SMALLINT,
    descripcion_local VARCHAR(255),
    superficie FLOAT,
    giro SMALLINT,
    fecha_alta DATE,
    fecha_baja DATE,
    fecha_modificacion TIMESTAMP,
    vigencia VARCHAR(1),
    id_usuario INTEGER,
    clave_cuota SMALLINT,
    -- Datos del apremio
    id_control INTEGER,
    zona_apremio SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR(255),
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio_detalle SMALLINT,
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
    vigencia_apremio VARCHAR(1),
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov VARCHAR(10),
    hora_practicado TIMESTAMP
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        -- Datos del local
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.id_contribuy_prop as id_contribuyente_propietario,
        l.id_contribuy_renta as id_contribuyente_renta,
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
        l.clave_cuota,
        -- Datos del apremio
        a.id_control,
        a.zona as zona_apremio,
        a.modulo,
        a.control_otr,
        a.folio,
        a.diligencia,
        a.importe_global,
        a.importe_multa,
        a.importe_recargo,
        a.importe_gastos,
        a.zona_apremio as zona_apremio_detalle,
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
        a.vigencia as vigencia_apremio,
        a.fecha_actualiz,
        a.usuario,
        a.clave_mov,
        a.hora_practicado
    FROM public.ta_11_locales l
    JOIN public.ta_15_apremios a ON l.id_local = a.control_otr
    WHERE a.zona = p_recaudadora
    AND a.folio BETWEEN p_folio_desde AND p_folio_hasta
    AND a.modulo = 11 -- Mercados
    ORDER BY a.folio;
END;
$$;

-- =============================================
-- SECCIÓN: EXPORTACIÓN A EXCEL
-- =============================================

-- SP_APREMIOSSVN_EXPORTAR_FOLIOS_PAGADOS - Exportación de folios pagados para Excel
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EXPORTAR_FOLIOS_PAGADOS(
    p_recaudadora INTEGER,
    p_modulo INTEGER,
    p_folio_desde INTEGER,
    p_folio_hasta INTEGER,
    p_fecha_emision DATE,
    p_fecha_pago_desde DATE,
    p_fecha_pago_hasta DATE
) RETURNS TABLE(
    id_control INTEGER,
    modulo INTEGER,
    id_modulo_referencia INTEGER,
    folio INTEGER,
    fecha_emision DATE,
    importe_pago NUMERIC,
    fecha_pago DATE,
    periodo_inicial TEXT,
    periodo_final TEXT,
    registro_referencia TEXT,
    datos_contribuyente TEXT,
    estado VARCHAR(20)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_control,
        a.modulo,
        a.control_otr as id_modulo_referencia,
        a.folio,
        a.fecha_emision,
        COALESCE(a.importe_pago, 0) as importe_pago,
        a.fecha_pago,
        -- Periodo inicial desde ta_15_periodos
        (SELECT CONCAT(MIN(p.ayo), '-', LPAD(MIN(p.periodo)::TEXT, 2, '0'))
         FROM public.ta_15_periodos p WHERE p.control_otr = a.id_control) as periodo_inicial,
        -- Periodo final desde ta_15_periodos
        (SELECT CONCAT(MAX(p.ayo), '-', LPAD(MAX(p.periodo)::TEXT, 2, '0'))
         FROM public.ta_15_periodos p WHERE p.control_otr = a.id_control) as periodo_final,
        -- Registro según módulo
        CASE a.modulo
            WHEN 11 THEN -- Mercados
                (SELECT CONCAT(l.oficina, '-', l.num_mercado, '-', l.categoria, '-', 
                              COALESCE(l.seccion, ''), '-', l.local, '-', 
                              COALESCE(l.letra_local, ''), '-', COALESCE(l.bloque, ''))
                 FROM public.ta_11_locales l WHERE l.id_local = a.control_otr)
            WHEN 16 THEN -- Aseo
                (SELECT CONCAT('ASEO-', c.num_contrato, '-', ta.tipo_aseo)
                 FROM public.ta_16_contratos c
                 LEFT JOIN public.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
                 WHERE c.control_contrato = a.control_otr)
            WHEN 13 THEN -- Cementerios
                (SELECT CONCAT('CEM-', tc.cementerio, '-C', tc.clase, '-S', tc.seccion, '-L', tc.linea, '-F', tc.fosa)
                 FROM public.ta_13_datosrcm tc WHERE tc.control_rcm = a.control_otr)
            ELSE CONCAT('MOD', a.modulo, '-', a.control_otr)
        END as registro_referencia,
        -- Datos del contribuyente según módulo
        CASE a.modulo
            WHEN 11 THEN -- Mercados
                (SELECT CONCAT(COALESCE(l.nombre, ''), ' / ', COALESCE(l.arrendatario, ''))
                 FROM public.ta_11_locales l WHERE l.id_local = a.control_otr)
            WHEN 16 THEN -- Aseo
                (SELECT CONCAT(COALESCE(e.descripcion, ''), ' / ', COALESCE(e.representante, ''))
                 FROM public.ta_16_contratos c
                 LEFT JOIN public.ta_16_empresas e ON c.num_empresa = e.num_empresa
                 WHERE c.control_contrato = a.control_otr)
            ELSE 'Sin datos'
        END as datos_contribuyente,
        CASE a.vigencia
            WHEN '1' THEN 'VIGENTE'
            WHEN '2' THEN 'PAGADO'
            WHEN '3' THEN 'CANCELADO'
            ELSE 'SUSPENDIDO'
        END as estado
    FROM public.ta_15_apremios a
    WHERE a.zona = p_recaudadora
    AND a.modulo = p_modulo
    AND a.folio BETWEEN p_folio_desde AND p_folio_hasta
    AND (p_fecha_emision IS NULL OR a.fecha_emision = p_fecha_emision)
    AND (p_fecha_pago_desde IS NULL OR p_fecha_pago_hasta IS NULL OR 
         a.fecha_pago BETWEEN p_fecha_pago_desde AND p_fecha_pago_hasta)
    AND a.fecha_pago IS NOT NULL -- Solo folios pagados
    ORDER BY a.folio;
END;
$$;

-- =============================================
-- SECCIÓN: REPORTES DE LISTADOS MERCADOS
-- =============================================

-- SP_APREMIOSSVN_REPORTE_LISTADO_MERCADOS - Listado completo de mercados
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTE_LISTADO_MERCADOS(
    p_recaudadora INTEGER,
    p_mercado INTEGER DEFAULT NULL,
    p_categoria INTEGER DEFAULT NULL,
    p_seccion VARCHAR(10) DEFAULT NULL
) RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(10),
    local SMALLINT,
    letra_local VARCHAR(2),
    bloque VARCHAR(10),
    nombre VARCHAR(255),
    arrendatario VARCHAR(255),
    domicilio VARCHAR(255),
    sector VARCHAR(50),
    descripcion_local VARCHAR(255),
    superficie FLOAT,
    giro SMALLINT,
    fecha_alta DATE,
    vigencia VARCHAR(1),
    total_adeudos NUMERIC,
    total_gastos NUMERIC,
    total_recargos NUMERIC,
    ultimo_pago DATE,
    estado_actual VARCHAR(20)
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
        l.nombre,
        l.arrendatario,
        l.domicilio,
        l.sector,
        l.descripcion_local,
        l.superficie,
        l.giro,
        l.fecha_alta,
        l.vigencia,
        -- Cálculos de adeudos
        COALESCE(SUM(a.importe_global), 0) as total_adeudos,
        COALESCE(SUM(a.importe_gastos), 0) as total_gastos,
        COALESCE(SUM(a.importe_recargo), 0) as total_recargos,
        MAX(a.fecha_pago) as ultimo_pago,
        CASE 
            WHEN COUNT(CASE WHEN a.vigencia = '1' THEN 1 END) > 0 THEN 'CON ADEUDO'
            WHEN COUNT(CASE WHEN a.vigencia = '2' THEN 1 END) > 0 THEN 'AL CORRIENTE'
            ELSE 'SIN MOVIMIENTOS'
        END as estado_actual
    FROM public.ta_11_locales l
    LEFT JOIN public.ta_15_apremios a ON l.id_local = a.control_otr AND a.modulo = 11
    WHERE l.oficina = p_recaudadora
    AND (p_mercado IS NULL OR l.num_mercado = p_mercado)
    AND (p_categoria IS NULL OR l.categoria = p_categoria)
    AND (p_seccion IS NULL OR l.seccion = p_seccion)
    GROUP BY l.id_local, l.oficina, l.num_mercado, l.categoria, l.seccion, 
             l.local, l.letra_local, l.bloque, l.nombre, l.arrendatario, 
             l.domicilio, l.sector, l.descripcion_local, l.superficie, 
             l.giro, l.fecha_alta, l.vigencia
    ORDER BY l.num_mercado, l.categoria, l.seccion, l.local;
END;
$$;

-- SP_APREMIOSSVN_REPORTE_LISTADO_MERCADOS_GASTOS - Listado con detalle de gastos
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTE_LISTADO_MERCADOS_GASTOS(
    p_recaudadora INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE
) RETURNS TABLE(
    mercado INTEGER,
    categoria INTEGER,
    local INTEGER,
    nombre VARCHAR(255),
    total_gastos_cobranza NUMERIC,
    total_gastos_ejecucion NUMERIC,
    total_gastos_notificacion NUMERIC,
    total_general NUMERIC,
    cantidad_folios INTEGER,
    promedio_gastos NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.num_mercado as mercado,
        l.categoria,
        l.local,
        l.nombre,
        SUM(CASE WHEN a.clave_practicado = 'C' THEN a.importe_gastos ELSE 0 END) as total_gastos_cobranza,
        SUM(CASE WHEN a.clave_practicado = 'E' THEN a.importe_gastos ELSE 0 END) as total_gastos_ejecucion,
        SUM(CASE WHEN a.clave_practicado = 'N' THEN a.importe_gastos ELSE 0 END) as total_gastos_notificacion,
        SUM(a.importe_gastos) as total_general,
        COUNT(a.folio)::INTEGER as cantidad_folios,
        AVG(a.importe_gastos) as promedio_gastos
    FROM public.ta_11_locales l
    JOIN public.ta_15_apremios a ON l.id_local = a.control_otr AND a.modulo = 11
    WHERE l.oficina = p_recaudadora
    AND a.fecha_emision BETWEEN p_fecha_desde AND p_fecha_hasta
    AND a.importe_gastos > 0
    GROUP BY l.num_mercado, l.categoria, l.local, l.nombre
    ORDER BY total_general DESC;
END;
$$;

-- SP_APREMIOSSVN_REPORTE_LISTADO_MERCADOS_RECARGOS - Listado con detalle de recargos
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTE_LISTADO_MERCADOS_RECARGOS(
    p_recaudadora INTEGER,
    p_anio INTEGER
) RETURNS TABLE(
    mercado INTEGER,
    categoria INTEGER,
    local INTEGER,
    nombre VARCHAR(255),
    recargos_enero NUMERIC,
    recargos_febrero NUMERIC,
    recargos_marzo NUMERIC,
    recargos_abril NUMERIC,
    recargos_mayo NUMERIC,
    recargos_junio NUMERIC,
    recargos_julio NUMERIC,
    recargos_agosto NUMERIC,
    recargos_septiembre NUMERIC,
    recargos_octubre NUMERIC,
    recargos_noviembre NUMERIC,
    recargos_diciembre NUMERIC,
    total_anual NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.num_mercado as mercado,
        l.categoria,
        l.local,
        l.nombre,
        SUM(CASE WHEN p.periodo = 1 THEN p.recargos ELSE 0 END) as recargos_enero,
        SUM(CASE WHEN p.periodo = 2 THEN p.recargos ELSE 0 END) as recargos_febrero,
        SUM(CASE WHEN p.periodo = 3 THEN p.recargos ELSE 0 END) as recargos_marzo,
        SUM(CASE WHEN p.periodo = 4 THEN p.recargos ELSE 0 END) as recargos_abril,
        SUM(CASE WHEN p.periodo = 5 THEN p.recargos ELSE 0 END) as recargos_mayo,
        SUM(CASE WHEN p.periodo = 6 THEN p.recargos ELSE 0 END) as recargos_junio,
        SUM(CASE WHEN p.periodo = 7 THEN p.recargos ELSE 0 END) as recargos_julio,
        SUM(CASE WHEN p.periodo = 8 THEN p.recargos ELSE 0 END) as recargos_agosto,
        SUM(CASE WHEN p.periodo = 9 THEN p.recargos ELSE 0 END) as recargos_septiembre,
        SUM(CASE WHEN p.periodo = 10 THEN p.recargos ELSE 0 END) as recargos_octubre,
        SUM(CASE WHEN p.periodo = 11 THEN p.recargos ELSE 0 END) as recargos_noviembre,
        SUM(CASE WHEN p.periodo = 12 THEN p.recargos ELSE 0 END) as recargos_diciembre,
        SUM(p.recargos) as total_anual
    FROM public.ta_11_locales l
    JOIN public.ta_15_apremios a ON l.id_local = a.control_otr AND a.modulo = 11
    JOIN public.ta_15_periodos p ON a.id_control = p.control_otr
    WHERE l.oficina = p_recaudadora
    AND p.ayo = p_anio
    GROUP BY l.num_mercado, l.categoria, l.local, l.nombre
    ORDER BY l.num_mercado, l.categoria, l.local;
END;
$$;

-- SP_APREMIOSSVN_REPORTE_RESUMEN_MERCADOS - Resumen ejecutivo de mercados
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTE_RESUMEN_MERCADOS(
    p_recaudadora INTEGER
) RETURNS TABLE(
    total_locales INTEGER,
    locales_vigentes INTEGER,
    locales_con_adeudo INTEGER,
    locales_al_corriente INTEGER,
    total_adeudo_global NUMERIC,
    total_gastos_global NUMERIC,
    total_recargos_global NUMERIC,
    promedio_adeudo NUMERIC,
    mercado_mayor_adeudo INTEGER,
    mercado_menor_adeudo INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(l.id_local)::INTEGER as total_locales,
        COUNT(CASE WHEN l.vigencia = 'A' THEN 1 END)::INTEGER as locales_vigentes,
        COUNT(CASE WHEN EXISTS(
            SELECT 1 FROM public.ta_15_apremios a 
            WHERE a.control_otr = l.id_local AND a.vigencia = '1'
        ) THEN 1 END)::INTEGER as locales_con_adeudo,
        COUNT(CASE WHEN NOT EXISTS(
            SELECT 1 FROM public.ta_15_apremios a 
            WHERE a.control_otr = l.id_local AND a.vigencia = '1'
        ) THEN 1 END)::INTEGER as locales_al_corriente,
        COALESCE(SUM(a.importe_global), 0) as total_adeudo_global,
        COALESCE(SUM(a.importe_gastos), 0) as total_gastos_global,
        COALESCE(SUM(a.importe_recargo), 0) as total_recargos_global,
        COALESCE(AVG(a.importe_global), 0) as promedio_adeudo,
        (SELECT l2.num_mercado FROM public.ta_11_locales l2
         JOIN public.ta_15_apremios a2 ON l2.id_local = a2.control_otr
         WHERE l2.oficina = p_recaudadora
         GROUP BY l2.num_mercado
         ORDER BY SUM(a2.importe_global) DESC LIMIT 1) as mercado_mayor_adeudo,
        (SELECT l3.num_mercado FROM public.ta_11_locales l3
         JOIN public.ta_15_apremios a3 ON l3.id_local = a3.control_otr
         WHERE l3.oficina = p_recaudadora
         GROUP BY l3.num_mercado
         ORDER BY SUM(a3.importe_global) ASC LIMIT 1) as mercado_menor_adeudo
    FROM public.ta_11_locales l
    LEFT JOIN public.ta_15_apremios a ON l.id_local = a.control_otr AND a.modulo = 11
    WHERE l.oficina = p_recaudadora;
END;
$$;