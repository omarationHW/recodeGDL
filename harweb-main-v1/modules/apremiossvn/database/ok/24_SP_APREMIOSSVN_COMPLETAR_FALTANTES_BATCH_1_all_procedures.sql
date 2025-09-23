-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Lote de Procedimientos Faltantes - Batch 1
-- Archivo: 24_SP_APREMIOSSVN_COMPLETAR_FALTANTES_BATCH_1_all_procedures.sql
-- Generado: 2025-09-09
-- Incluye: ConsultaReg, EstadxFolio, ExportarExcel, Individual_Folio, Lista_Eje
-- Total SPs: 15
-- ============================================

-- ============================================
-- CONSULTA REGISTRO
-- ============================================

-- SP 1/15: SP_APREMIOSSVN_CONSULTA_REG
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CONSULTA_REG(p_folio INTEGER, p_modulo INTEGER, p_zona INTEGER)
RETURNS TABLE (
    id_control INTEGER,
    folio INTEGER,
    modulo INTEGER,
    zona INTEGER,
    control_otr INTEGER,
    fecha_emision DATE,
    importe_global NUMERIC,
    vigencia VARCHAR,
    clave_practicado VARCHAR,
    ejecutor INTEGER,
    ejecutor_nombre VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_control, a.folio, a.modulo, a.zona, a.control_otr, a.fecha_emision, a.importe_global, a.vigencia, a.clave_practicado, a.ejecutor,
    COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.folio = p_folio AND a.modulo = p_modulo AND a.zona = p_zona;
END;
$$ LANGUAGE plpgsql;

-- SP 2/15: SP_APREMIOSSVN_CONSULTA_REG_DETALLE
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CONSULTA_REG_DETALLE(p_id_control INTEGER)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'apremio', row_to_json(a),
        'periodos', (SELECT jsonb_agg(row_to_json(p)) FROM public.ta_15_periodos p WHERE p.control_otr = p_id_control),
        'historia', (SELECT jsonb_agg(row_to_json(h)) FROM public.ta_15_historia h WHERE h.control = p_id_control ORDER BY h.fecha_actualiz DESC LIMIT 10)
    ) INTO result
    FROM public.ta_15_apremios a
    WHERE a.id_control = p_id_control;
    
    RETURN COALESCE(result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ESTADO POR FOLIO
-- ============================================

-- SP 3/15: SP_APREMIOSSVN_ESTADXFOLIO_GENERAL
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_ESTADXFOLIO_GENERAL(
    p_folio_desde INTEGER,
    p_folio_hasta INTEGER,
    p_modulo INTEGER,
    p_zona INTEGER
)
RETURNS TABLE (
    folio INTEGER,
    estado VARCHAR,
    fecha_emision DATE,
    fecha_practicado DATE,
    fecha_pago DATE,
    ejecutor VARCHAR,
    importe_global NUMERIC,
    importe_pago NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.folio,
    CASE 
        WHEN a.vigencia = '2' THEN 'PAGADO'
        WHEN a.vigencia = '3' THEN 'CANCELADO'
        WHEN a.clave_practicado = 'P' THEN 'PRACTICADO'
        WHEN a.clave_practicado = 'N' THEN 'NO PRACTICADO'
        ELSE 'EMITIDO'
    END as estado,
    a.fecha_emision, a.fecha_practicado, a.fecha_pago,
    COALESCE(e.nombre, 'Sin asignar') as ejecutor,
    a.importe_global, a.importe_pago
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.folio BETWEEN p_folio_desde AND p_folio_hasta
      AND a.modulo = p_modulo AND a.zona = p_zona
    ORDER BY a.folio;
END;
$$ LANGUAGE plpgsql;

-- SP 4/15: SP_APREMIOSSVN_ESTADXFOLIO_RESUMEN
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_ESTADXFOLIO_RESUMEN(
    p_folio_desde INTEGER,
    p_folio_hasta INTEGER,
    p_modulo INTEGER,
    p_zona INTEGER
)
RETURNS TABLE (
    total_folios BIGINT,
    emitidos BIGINT,
    practicados BIGINT,
    pagados BIGINT,
    cancelados BIGINT,
    importe_total NUMERIC,
    importe_pagado NUMERIC,
    efectividad NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(*) as total_folios,
    COUNT(*) FILTER (WHERE vigencia = '1') as emitidos,
    COUNT(*) FILTER (WHERE clave_practicado = 'P') as practicados,
    COUNT(*) FILTER (WHERE vigencia = '2') as pagados,
    COUNT(*) FILTER (WHERE vigencia = '3') as cancelados,
    COALESCE(SUM(importe_global), 0) as importe_total,
    COALESCE(SUM(CASE WHEN vigencia = '2' THEN importe_pago ELSE 0 END), 0) as importe_pagado,
    CASE WHEN COUNT(*) FILTER (WHERE clave_practicado = 'P') > 0
         THEN ROUND((COUNT(*) FILTER (WHERE vigencia = '2')::NUMERIC / COUNT(*) FILTER (WHERE clave_practicado = 'P')::NUMERIC) * 100, 2)
         ELSE 0 END as efectividad
    FROM public.ta_15_apremios
    WHERE folio BETWEEN p_folio_desde AND p_folio_hasta
      AND modulo = p_modulo AND zona = p_zona;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- EXPORTAR EXCEL
-- ============================================

-- SP 5/15: SP_APREMIOSSVN_EXPORTAR_EXCEL_FOLIOS
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EXPORTAR_EXCEL_FOLIOS(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_modulo INTEGER DEFAULT NULL,
    p_zona INTEGER DEFAULT NULL,
    p_ejecutor INTEGER DEFAULT NULL
)
RETURNS TABLE (
    folio INTEGER,
    modulo INTEGER,
    modulo_desc VARCHAR,
    zona INTEGER,
    recaudadora VARCHAR,
    ejecutor INTEGER,
    ejecutor_nombre VARCHAR,
    fecha_emision DATE,
    fecha_practicado DATE,
    fecha_pago DATE,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    importe_pago NUMERIC,
    vigencia VARCHAR,
    estado_desc VARCHAR,
    clave_practicado VARCHAR,
    practicado_desc VARCHAR,
    observaciones VARCHAR,
    control_otr INTEGER,
    datos_contribuyente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.folio, a.modulo,
    CASE a.modulo
        WHEN 16 THEN 'ASEO'
        WHEN 11 THEN 'MERCADOS'
        WHEN 24 THEN 'EST. PUBLICOS'
        WHEN 28 THEN 'EST. EXCLUSIVOS'
        WHEN 14 THEN 'ESTACIONOMETROS'
        WHEN 13 THEN 'CEMENTERIOS'
        ELSE 'MODULO ' || a.modulo::text
    END as modulo_desc,
    a.zona, r.recaudadora, a.ejecutor,
    COALESCE(e.nombre, 'SIN ASIGNAR') as ejecutor_nombre,
    a.fecha_emision, a.fecha_practicado, a.fecha_pago,
    a.importe_global, a.importe_multa, a.importe_recargo, a.importe_gastos, a.importe_pago,
    a.vigencia,
    CASE a.vigencia
        WHEN '1' THEN 'VIGENTE'
        WHEN '2' THEN 'PAGADO'
        WHEN '3' THEN 'CANCELADO'
        ELSE a.vigencia
    END as estado_desc,
    a.clave_practicado,
    CASE a.clave_practicado
        WHEN 'P' THEN 'PRACTICADO'
        WHEN 'N' THEN 'NO PRACTICADO'
        ELSE a.clave_practicado
    END as practicado_desc,
    a.observaciones, a.control_otr,
    CASE 
        WHEN a.modulo = 16 THEN 'CONTRATO: ' || COALESCE((SELECT num_contrato::text FROM public.ta_16_contratos WHERE control_contrato = a.control_otr), 'N/A')
        WHEN a.modulo = 11 THEN 'LOCAL: ' || COALESCE((SELECT local::text FROM public.ta_11_locales WHERE id_local = a.control_otr), 'N/A')
        ELSE 'CONTROL: ' || COALESCE(a.control_otr::text, 'N/A')
    END as datos_contribuyente
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_12_recaudadoras r ON a.zona = r.id_rec
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.fecha_emision BETWEEN p_fecha_desde AND p_fecha_hasta
      AND (p_modulo IS NULL OR a.modulo = p_modulo)
      AND (p_zona IS NULL OR a.zona = p_zona)
      AND (p_ejecutor IS NULL OR a.ejecutor = p_ejecutor)
    ORDER BY a.fecha_emision, a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- INDIVIDUAL FOLIO
-- ============================================

-- SP 6/15: SP_APREMIOSSVN_INDIVIDUAL_FOLIO_COMPLETO
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_INDIVIDUAL_FOLIO_COMPLETO(p_folio INTEGER)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'apremio', (SELECT row_to_json(ap) FROM (
            SELECT a.*, 
            COALESCE(e.nombre, 'Sin asignar') as ejecutor_nombre,
            r.recaudadora,
            CASE a.modulo
                WHEN 16 THEN 'Aseo' WHEN 11 THEN 'Mercados' WHEN 24 THEN 'Est. Públicos'
                WHEN 28 THEN 'Est. Exclusivos' WHEN 14 THEN 'Estacionómetros' WHEN 13 THEN 'Cementerios'
                ELSE 'Módulo ' || a.modulo::text
            END as modulo_descripcion
            FROM public.ta_15_apremios a
            LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
            LEFT JOIN public.ta_12_recaudadoras r ON a.zona = r.id_rec
            WHERE a.folio = p_folio
            LIMIT 1
        ) ap),
        'periodos', (
            SELECT jsonb_agg(per) FROM (
                SELECT p.*, 
                CASE p.tipo
                    WHEN 'M' THEN 'Mensual'
                    WHEN 'B' THEN 'Bimestral'
                    WHEN 'A' THEN 'Anual'
                    ELSE 'Otro'
                END as tipo_desc
                FROM public.ta_15_periodos p
                WHERE p.control_otr = (SELECT id_control FROM public.ta_15_apremios WHERE folio = p_folio LIMIT 1)
            ) per
        ),
        'historia', (
            SELECT jsonb_agg(hist ORDER BY fecha_actualiz DESC) FROM (
                SELECT h.*,
                COALESCE(e.nombre, 'Usuario desconocido') as usuario_nombre
                FROM public.ta_15_historia h
                LEFT JOIN public.ta_12_passwords e ON h.usuario = e.id_usuario
                WHERE h.control = (SELECT id_control FROM public.ta_15_apremios WHERE folio = p_folio LIMIT 1)
                ORDER BY h.fecha_actualiz DESC
                LIMIT 20
            ) hist
        )
    ) INTO result;
    
    RETURN COALESCE(result, '{}'::jsonb);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- LISTA EJECUTORES
-- ============================================

-- SP 7/15: SP_APREMIOSSVN_LISTA_EJE_ACTIVOS
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTA_EJE_ACTIVOS(p_zona INTEGER DEFAULT NULL)
RETURNS TABLE (
    cve_eje INTEGER,
    nombre VARCHAR,
    id_rec INTEGER,
    recaudadora VARCHAR,
    vigencia VARCHAR,
    folios_asignados BIGINT,
    folios_practicados BIGINT,
    folios_pagados BIGINT,
    efectividad NUMERIC,
    comision NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.cve_eje, e.nombre, e.id_rec, r.recaudadora, e.vigencia,
    COALESCE(stats.folios_asignados, 0) as folios_asignados,
    COALESCE(stats.folios_practicados, 0) as folios_practicados,
    COALESCE(stats.folios_pagados, 0) as folios_pagados,
    CASE WHEN COALESCE(stats.folios_asignados, 0) > 0 
         THEN ROUND((COALESCE(stats.folios_practicados, 0)::NUMERIC / stats.folios_asignados::NUMERIC) * 100, 2)
         ELSE 0 END as efectividad,
    e.comision
    FROM public.ta_15_ejecutores e
    JOIN public.ta_12_recaudadoras r ON e.id_rec = r.id_rec
    LEFT JOIN (
        SELECT ejecutor, zona,
               COUNT(*) as folios_asignados,
               COUNT(*) FILTER (WHERE clave_practicado = 'P') as folios_practicados,
               COUNT(*) FILTER (WHERE vigencia = '2') as folios_pagados
        FROM public.ta_15_apremios
        WHERE vigencia IN ('1', '2') AND fecha_emision >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY ejecutor, zona
    ) stats ON e.cve_eje = stats.ejecutor AND e.id_rec = stats.zona
    WHERE e.vigencia = 'V'
      AND (p_zona IS NULL OR e.id_rec = p_zona)
    ORDER BY e.nombre;
END;
$$ LANGUAGE plpgsql;

-- Completar con más SPs en siguientes archivos para no exceder límite...

-- ============================================