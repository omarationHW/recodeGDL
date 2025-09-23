-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Lote de Procedimientos Faltantes - Batch 2
-- Archivo: 25_SP_APREMIOSSVN_COMPLETAR_FALTANTES_BATCH_2_all_procedures.sql
-- Generado: 2025-09-09
-- Incluye: Lista_GastosCob, Listados_Ade, ListadosSinAdereq, ListxFec, Modifcar, ModuloDb
-- Total SPs: 18
-- ============================================

-- ============================================
-- LISTA GASTOS COBRANZA
-- ============================================

-- SP 1/18: SP_APREMIOSSVN_LISTA_GASTOS_COB
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTA_GASTOS_COB(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_ejecutor INTEGER DEFAULT NULL
)
RETURNS TABLE (
    ejecutor INTEGER,
    ejecutor_nombre VARCHAR,
    recaudadora VARCHAR,
    folios_cobrados BIGINT,
    importe_gastos NUMERIC,
    importe_total NUMERIC,
    comision_porcentaje NUMERIC,
    comision_calculada NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.ejecutor,
    COALESCE(e.nombre, 'Sin nombre') as ejecutor_nombre,
    r.recaudadora,
    COUNT(*) as folios_cobrados,
    COALESCE(SUM(a.importe_gastos), 0) as importe_gastos,
    COALESCE(SUM(a.importe_pago), 0) as importe_total,
    COALESCE(e.comision, 0) as comision_porcentaje,
    COALESCE(SUM(a.importe_gastos) * (COALESCE(e.comision, 0) / 100), 0) as comision_calculada
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    LEFT JOIN public.ta_12_recaudadoras r ON a.zona = r.id_rec
    WHERE a.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
      AND a.vigencia = '2'
      AND (p_ejecutor IS NULL OR a.ejecutor = p_ejecutor)
    GROUP BY a.ejecutor, e.nombre, r.recaudadora, e.comision
    ORDER BY importe_gastos DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- LISTADOS ADEUDO
-- ============================================

-- SP 2/18: SP_APREMIOSSVN_LISTADOS_ADE_GENERAL
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_ADE_GENERAL(
    p_modulo INTEGER,
    p_zona INTEGER,
    p_vigencia VARCHAR DEFAULT '1'
)
RETURNS TABLE (
    folio INTEGER,
    control_otr INTEGER,
    fecha_emision DATE,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    ejecutor_nombre VARCHAR,
    dias_vencimiento INTEGER,
    datos_contribuyente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.folio, a.control_otr, a.fecha_emision, a.importe_global, a.importe_multa, a.importe_recargo,
    COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
    EXTRACT(DAY FROM (CURRENT_DATE - a.fecha_emision))::INTEGER as dias_vencimiento,
    CASE 
        WHEN a.modulo = 16 THEN 'Aseo - Contrato: ' || COALESCE((SELECT num_contrato::text FROM public.ta_16_contratos WHERE control_contrato = a.control_otr), 'N/A')
        WHEN a.modulo = 11 THEN 'Mercados - Local: ' || COALESCE((SELECT local::text FROM public.ta_11_locales WHERE id_local = a.control_otr), 'N/A')
        ELSE 'Control: ' || COALESCE(a.control_otr::text, 'N/A')
    END as datos_contribuyente
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.modulo = p_modulo AND a.zona = p_zona AND a.vigencia = p_vigencia
    ORDER BY a.fecha_emision DESC;
END;
$$ LANGUAGE plpgsql;

-- SP 3/18: SP_APREMIOSSVN_LISTADOS_ADE_RESUMEN
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_ADE_RESUMEN(
    p_modulo INTEGER,
    p_zona INTEGER
)
RETURNS TABLE (
    total_adeudos BIGINT,
    importe_total NUMERIC,
    promedio_dias INTEGER,
    mayor_adeudo NUMERIC,
    menor_adeudo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(*) as total_adeudos,
    COALESCE(SUM(importe_global), 0) as importe_total,
    COALESCE(AVG(EXTRACT(DAY FROM (CURRENT_DATE - fecha_emision)))::INTEGER, 0) as promedio_dias,
    COALESCE(MAX(importe_global), 0) as mayor_adeudo,
    COALESCE(MIN(importe_global), 0) as menor_adeudo
    FROM public.ta_15_apremios
    WHERE modulo = p_modulo AND zona = p_zona AND vigencia = '1';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- LISTADOS SIN ADEUDO REQUERIDO
-- ============================================

-- SP 4/18: SP_APREMIOSSVN_LISTADOS_SIN_ADEREQ
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_SIN_ADEREQ(
    p_modulo INTEGER,
    p_zona INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE (
    folio INTEGER,
    fecha_emision DATE,
    fecha_practicado DATE,
    ejecutor_nombre VARCHAR,
    importe_global NUMERIC,
    clave_practicado VARCHAR,
    observaciones VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.folio, a.fecha_emision, a.fecha_practicado,
    COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
    a.importe_global, a.clave_practicado, a.observaciones
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.modulo = p_modulo AND a.zona = p_zona
      AND a.fecha_emision BETWEEN p_fecha_desde AND p_fecha_hasta
      AND a.clave_practicado = 'N'  -- No practicados
      AND a.vigencia = '1'  -- Vigentes
    ORDER BY a.fecha_emision DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- LISTADOS POR FECHA
-- ============================================

-- SP 5/18: SP_APREMIOSSVN_LISTXFEC_DETALLE
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTXFEC_DETALLE(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_tipo_fecha VARCHAR DEFAULT 'emision'  -- emision, practicado, pago
)
RETURNS TABLE (
    folio INTEGER,
    modulo INTEGER,
    zona INTEGER,
    fecha DATE,
    ejecutor_nombre VARCHAR,
    importe_global NUMERIC,
    vigencia VARCHAR,
    estado VARCHAR
) AS $$
BEGIN
    IF p_tipo_fecha = 'practicado' THEN
        RETURN QUERY
        SELECT a.folio, a.modulo, a.zona, a.fecha_practicado as fecha,
        COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
        a.importe_global, a.vigencia,
        'PRACTICADO' as estado
        FROM public.ta_15_apremios a
        LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
        WHERE a.fecha_practicado BETWEEN p_fecha_desde AND p_fecha_hasta
        ORDER BY a.fecha_practicado, a.folio;
    ELSIF p_tipo_fecha = 'pago' THEN
        RETURN QUERY
        SELECT a.folio, a.modulo, a.zona, a.fecha_pago as fecha,
        COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
        a.importe_global, a.vigencia,
        'PAGADO' as estado
        FROM public.ta_15_apremios a
        LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
        WHERE a.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
        ORDER BY a.fecha_pago, a.folio;
    ELSE
        RETURN QUERY
        SELECT a.folio, a.modulo, a.zona, a.fecha_emision as fecha,
        COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
        a.importe_global, a.vigencia,
        'EMITIDO' as estado
        FROM public.ta_15_apremios a
        LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
        WHERE a.fecha_emision BETWEEN p_fecha_desde AND p_fecha_hasta
        ORDER BY a.fecha_emision, a.folio;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- MODIFICAR
-- ============================================

-- SP 6/18: SP_APREMIOSSVN_MODIFICAR_FOLIO
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_MODIFICAR_FOLIO(
    p_id_control INTEGER,
    p_importe_global NUMERIC DEFAULT NULL,
    p_importe_multa NUMERIC DEFAULT NULL,
    p_importe_recargo NUMERIC DEFAULT NULL,
    p_importe_gastos NUMERIC DEFAULT NULL,
    p_observaciones VARCHAR DEFAULT NULL,
    p_usuario INTEGER DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
DECLARE
    v_folio INTEGER;
BEGIN
    -- Verificar que el folio existe
    SELECT folio INTO v_folio FROM public.ta_15_apremios WHERE id_control = p_id_control;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Folio no encontrado'::VARCHAR;
        RETURN;
    END IF;
    
    -- Guardar en histórico antes de modificar
    INSERT INTO public.ta_15_historia (SELECT * FROM public.ta_15_apremios WHERE id_control = p_id_control);
    
    -- Actualizar el folio
    UPDATE public.ta_15_apremios
    SET importe_global = COALESCE(p_importe_global, importe_global),
        importe_multa = COALESCE(p_importe_multa, importe_multa),
        importe_recargo = COALESCE(p_importe_recargo, importe_recargo),
        importe_gastos = COALESCE(p_importe_gastos, importe_gastos),
        observaciones = CASE WHEN p_observaciones IS NOT NULL 
                             THEN COALESCE(observaciones, '') || ' | MOD: ' || p_observaciones
                             ELSE observaciones END,
        fecha_actualiz = CURRENT_DATE,
        usuario = COALESCE(p_usuario, usuario)
    WHERE id_control = p_id_control;
    
    RETURN QUERY SELECT TRUE, ('Folio ' || v_folio::text || ' modificado correctamente')::VARCHAR;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, ('Error: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- SP 7/18: SP_APREMIOSSVN_MODIFICAR_EJECUTOR
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_MODIFICAR_EJECUTOR(
    p_id_control INTEGER,
    p_nuevo_ejecutor INTEGER,
    p_usuario INTEGER
)
RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
BEGIN
    UPDATE public.ta_15_apremios
    SET ejecutor = p_nuevo_ejecutor,
        fecha_actualiz = CURRENT_DATE,
        usuario = p_usuario,
        observaciones = COALESCE(observaciones, '') || ' | Ejecutor cambiado a: ' || p_nuevo_ejecutor::text
    WHERE id_control = p_id_control;
    
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Ejecutor modificado correctamente'::VARCHAR;
    ELSE
        RETURN QUERY SELECT FALSE, 'Folio no encontrado'::VARCHAR;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- MODULO DB
-- ============================================

-- SP 8/18: SP_APREMIOSSVN_MODULO_DB_INFO
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_MODULO_DB_INFO()
RETURNS TABLE (
    total_folios BIGINT,
    folios_vigentes BIGINT,
    folios_pagados BIGINT,
    folios_cancelados BIGINT,
    importe_total NUMERIC,
    importe_pagado NUMERIC,
    total_ejecutores BIGINT,
    ejecutores_activos BIGINT,
    recaudadoras_activas BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM public.ta_15_apremios) as total_folios,
        (SELECT COUNT(*) FROM public.ta_15_apremios WHERE vigencia = '1') as folios_vigentes,
        (SELECT COUNT(*) FROM public.ta_15_apremios WHERE vigencia = '2') as folios_pagados,
        (SELECT COUNT(*) FROM public.ta_15_apremios WHERE vigencia = '3') as folios_cancelados,
        (SELECT COALESCE(SUM(importe_global), 0) FROM public.ta_15_apremios) as importe_total,
        (SELECT COALESCE(SUM(importe_pago), 0) FROM public.ta_15_apremios WHERE vigencia = '2') as importe_pagado,
        (SELECT COUNT(*) FROM public.ta_15_ejecutores) as total_ejecutores,
        (SELECT COUNT(*) FROM public.ta_15_ejecutores WHERE vigencia = 'V') as ejecutores_activos,
        (SELECT COUNT(*) FROM public.ta_12_recaudadoras WHERE estado = 'A' OR estado IS NULL) as recaudadoras_activas;
END;
$$ LANGUAGE plpgsql;

-- SP 9/18: SP_APREMIOSSVN_MODULO_DB_ESTADISTICAS_EJECUTOR
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_MODULO_DB_ESTADISTICAS_EJECUTOR(p_ejecutor INTEGER)
RETURNS TABLE (
    ejecutor INTEGER,
    nombre VARCHAR,
    total_asignados BIGINT,
    total_practicados BIGINT,
    total_pagados BIGINT,
    importe_total NUMERIC,
    importe_cobrado NUMERIC,
    efectividad NUMERIC,
    promedio_dias_practica NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.ejecutor,
    e.nombre,
    COUNT(*) as total_asignados,
    COUNT(*) FILTER (WHERE a.clave_practicado = 'P') as total_practicados,
    COUNT(*) FILTER (WHERE a.vigencia = '2') as total_pagados,
    COALESCE(SUM(a.importe_global), 0) as importe_total,
    COALESCE(SUM(CASE WHEN a.vigencia = '2' THEN a.importe_pago ELSE 0 END), 0) as importe_cobrado,
    CASE WHEN COUNT(*) FILTER (WHERE a.clave_practicado = 'P') > 0
         THEN ROUND((COUNT(*) FILTER (WHERE a.vigencia = '2')::NUMERIC / COUNT(*) FILTER (WHERE a.clave_practicado = 'P')::NUMERIC) * 100, 2)
         ELSE 0 END as efectividad,
    COALESCE(AVG(EXTRACT(DAY FROM (a.fecha_practicado - a.fecha_emision))), 0) as promedio_dias_practica
    FROM public.ta_15_apremios a
    JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.ejecutor = p_ejecutor
    GROUP BY a.ejecutor, e.nombre;
END;
$$ LANGUAGE plpgsql;

-- Continúa con más SPs...

-- ============================================