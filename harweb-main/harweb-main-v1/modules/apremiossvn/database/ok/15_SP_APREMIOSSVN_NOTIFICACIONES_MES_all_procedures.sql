-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - APREMIOSSVN
-- Módulo: Notificaciones por Mes
-- Archivo: 15_SP_APREMIOSSVN_NOTIFICACIONES_MES_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 1
-- ============================================

-- SP 1/1: SP_APREMIOSSVN_NOTIF_MES
-- Tipo: Report
-- Descripción: Reporte de notificaciones por mes, agrupando por módulo, mes, año, ejecutor, y mostrando asignados, practicados, cancelados, pagados y recaudado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_NOTIF_MES(
    p_axo_pract INTEGER,
    p_axo_emi INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE (
    modulo TEXT,
    mes INTEGER,
    axo INTEGER,
    ejecutor INTEGER,
    ejecutor_nombre TEXT,
    asignados INTEGER,
    practicados INTEGER,
    cancelados INTEGER,
    pagados INTEGER,
    recaudado NUMERIC,
    porcentaje_practicado NUMERIC,
    porcentaje_pagado NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.modulo::TEXT,
        EXTRACT(MONTH FROM a.fecha_emision)::INTEGER AS mes,
        EXTRACT(YEAR FROM a.fecha_emision)::INTEGER AS axo,
        a.ejecutor,
        COALESCE(e.nombre, 'Sin asignar') AS ejecutor_nombre,
        COUNT(*) FILTER (WHERE a.vigencia = '1')::INTEGER AS asignados,
        COUNT(*) FILTER (WHERE a.clave_practicado = 'P')::INTEGER AS practicados,
        COUNT(*) FILTER (WHERE a.vigencia = '3')::INTEGER AS cancelados,
        COUNT(*) FILTER (WHERE a.vigencia = '2')::INTEGER AS pagados,
        COALESCE(SUM(CASE WHEN a.vigencia = '2' THEN a.importe_pago ELSE 0 END),0) AS recaudado,
        CASE WHEN COUNT(*) FILTER (WHERE a.vigencia = '1') > 0 
             THEN ROUND((COUNT(*) FILTER (WHERE a.clave_practicado = 'P')::NUMERIC / COUNT(*) FILTER (WHERE a.vigencia = '1')::NUMERIC) * 100, 2)
             ELSE 0 END AS porcentaje_practicado,
        CASE WHEN COUNT(*) FILTER (WHERE a.clave_practicado = 'P') > 0 
             THEN ROUND((COUNT(*) FILTER (WHERE a.vigencia = '2')::NUMERIC / COUNT(*) FILTER (WHERE a.clave_practicado = 'P')::NUMERIC) * 100, 2)
             ELSE 0 END AS porcentaje_pagado
    FROM public.ta_15_apremios a
    LEFT JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE
        EXTRACT(YEAR FROM a.fecha_practicado) = p_axo_pract
        AND EXTRACT(YEAR FROM a.fecha_emision) = p_axo_emi
        AND a.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
    GROUP BY a.modulo, mes, axo, a.ejecutor, e.nombre
    ORDER BY a.modulo, axo, mes, a.ejecutor;
END;
$$ LANGUAGE plpgsql;

-- ============================================