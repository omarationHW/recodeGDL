-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Facturación
-- Archivo: 13_SP_APREMIOSSVN_FACTURACION_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 3
-- ============================================

-- SP 1/3: SP_APREMIOSSVN_FACTURACION_LIST
-- Tipo: Report
-- Descripción: Obtiene el listado de facturación para un rango de folios, módulo y public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FACTURACION_LIST(
    p_modulo integer,
    p_rec integer,
    p_fol1 integer,
    p_fol2 integer
)
RETURNS TABLE(
    folio integer,
    nombre text,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    vigencia text,
    ejecutor_nombre text,
    datos_contribuyente text
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.folio,
        COALESCE(b.nombre, '') AS nombre,
        a.importe_global,
        a.importe_multa,
        a.importe_recargo,
        a.importe_gastos,
        a.fecha_emision,
        a.vigencia,
        COALESCE(b.nombre, 'Sin asignar') AS ejecutor_nombre,
        CASE 
            WHEN a.modulo = 16 THEN 'Aseo - Contrato: ' || COALESCE(ta_16_contratos.num_contrato::text,'')
            WHEN a.modulo = 11 THEN 'Mercados - Local: ' || COALESCE(ta_11_locales.local::text,'')
            WHEN a.modulo = 13 THEN 'Cementerios - Control: ' || COALESCE(ta_13_datosrcm.control_rcm::text,'')
            ELSE 'Módulo: ' || a.modulo::text
        END as datos_contribuyente
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores b ON a.ejecutor = b.cve_eje AND a.zona = b.id_rec
    LEFT JOIN public.ta_16_contratos ON a.modulo = 16 AND a.control_otr = ta_16_contratos.control_contrato
    LEFT JOIN public.ta_11_locales ON a.modulo = 11 AND a.control_otr = ta_11_locales.id_local
    LEFT JOIN public.ta_13_datosrcm ON a.modulo = 13 AND a.control_otr = ta_13_datosrcm.control_rcm
    WHERE a.modulo = p_modulo
      AND a.zona = p_rec
      AND a.folio BETWEEN p_fol1 AND p_fol2
    ORDER BY a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: SP_APREMIOSSVN_FACTURACION_REPORT
-- Tipo: Report
-- Descripción: Genera el reporte de facturación para un rango de folios, módulo y recaudadora (puede usarse para PDF/Excel).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FACTURACION_REPORT(
    p_modulo integer,
    p_rec integer,
    p_fol1 integer,
    p_fol2 integer
)
RETURNS TABLE(
    folio integer,
    nombre text,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    vigencia text,
    total_folios bigint,
    total_importe numeric,
    total_multas numeric,
    total_recargos numeric,
    total_gastos numeric
) AS $$
DECLARE
    v_total_folios bigint;
    v_total_importe numeric;
    v_total_multas numeric;
    v_total_recargos numeric;
    v_total_gastos numeric;
BEGIN
    -- Calcular totales
    SELECT COUNT(*), 
           COALESCE(SUM(importe_global), 0),
           COALESCE(SUM(importe_multa), 0),
           COALESCE(SUM(importe_recargo), 0),
           COALESCE(SUM(importe_gastos), 0)
    INTO v_total_folios, v_total_importe, v_total_multas, v_total_recargos, v_total_gastos
    FROM public.ta_15_apremios a
    WHERE a.modulo = p_modulo
      AND a.zona = p_rec
      AND a.folio BETWEEN p_fol1 AND p_fol2;

    RETURN QUERY
    SELECT
        a.folio,
        COALESCE(b.nombre, '') AS nombre,
        a.importe_global,
        a.importe_multa,
        a.importe_recargo,
        a.importe_gastos,
        a.fecha_emision,
        a.vigencia,
        v_total_folios,
        v_total_importe,
        v_total_multas,
        v_total_recargos,
        v_total_gastos
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores b ON a.ejecutor = b.cve_eje AND a.zona = b.id_rec
    WHERE a.modulo = p_modulo
      AND a.zona = p_rec
      AND a.folio BETWEEN p_fol1 AND p_fol2
    ORDER BY a.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: SP_APREMIOSSVN_GET_RECAUDADORAS
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_GET_RECAUDADORAS()
RETURNS TABLE(
    id_rec integer,
    recaudadora text,
    zona text,
    activa boolean
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id_rec, 
        r.recaudadora,
        z.zona,
        CASE WHEN r.estado = 'A' THEN true ELSE false END as activa
    FROM public.ta_12_recaudadoras r
    LEFT JOIN public.ta_12_zonas z ON r.id_zona = z.id_zona
    ORDER BY r.id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================