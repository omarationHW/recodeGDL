-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO CONVENIOS - REPORTES ADICIONALES
-- Archivo: 02_SP_CONVENIOS_REPORTES_all_procedures.sql
-- ============================================

-- SP_CONVENIOS_REPORTE_EJECUTIVO - Reporte ejecutivo de convenios
CREATE OR REPLACE FUNCTION SP_CONVENIOS_REPORTE_EJECUTIVO(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
) RETURNS TABLE(
    periodo VARCHAR(10),
    convenios_nuevos INTEGER,
    monto_convenido NUMERIC(15,2),
    parcialidades_cobradas INTEGER,
    monto_cobrado NUMERIC(15,2),
    efectividad NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TO_CHAR(c.fecha_convenio, 'YYYY-MM') as periodo,
        COUNT(*)::INTEGER as convenios_nuevos,
        SUM(c.adeudo_original) as monto_convenido,
        SUM(c.parcialidades_pagadas)::INTEGER as parcialidades_cobradas,
        COALESCE(SUM(p.monto_pago), 0) as monto_cobrado,
        (COALESCE(SUM(p.monto_pago), 0) * 100.0 / NULLIF(SUM(c.adeudo_original), 0))::NUMERIC(5,2) as efectividad
    FROM public.convenios c
    LEFT JOIN public.pagos p ON c.id = p.convenio_id
    WHERE c.fecha_convenio BETWEEN p_fecha_desde AND p_fecha_hasta
    GROUP BY TO_CHAR(c.fecha_convenio, 'YYYY-MM')
    ORDER BY periodo DESC;
END;
$$;