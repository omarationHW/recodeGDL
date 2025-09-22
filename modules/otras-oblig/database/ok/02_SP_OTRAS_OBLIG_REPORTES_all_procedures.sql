-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO OTRAS OBLIGACIONES - REPORTES ADICIONALES
-- Archivo: 02_SP_OTRAS_OBLIG_REPORTES_all_procedures.sql
-- ============================================

-- SP_OTRAS_OBLIG_REPORTE_TIPOS - Reporte por tipos de obligación
CREATE OR REPLACE FUNCTION SP_OTRAS_OBLIG_REPORTE_TIPOS(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
) RETURNS TABLE(
    tipo_obligacion VARCHAR(50),
    total_obligaciones INTEGER,
    monto_total NUMERIC(15,2),
    obligaciones_pagadas INTEGER,
    monto_pagado NUMERIC(15,2),
    porcentaje_cobrado NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.tipo_obligacion,
        COUNT(*)::INTEGER as total_obligaciones,
        SUM(o.monto_original) as monto_total,
        COUNT(CASE WHEN o.estado = 'PAGADO' THEN 1 END)::INTEGER as obligaciones_pagadas,
        COALESCE(SUM(p.monto_pago), 0) as monto_pagado,
        (COALESCE(SUM(p.monto_pago), 0) * 100.0 / NULLIF(SUM(o.monto_original), 0))::NUMERIC(5,2) as porcentaje_cobrado
    FROM otras_obligaciones.obligaciones o
    LEFT JOIN otras_obligaciones.pagos p ON o.id = p.obligacion_id
    WHERE o.fecha_generacion BETWEEN p_fecha_desde AND p_fecha_hasta
    GROUP BY o.tipo_obligacion
    ORDER BY monto_total DESC;
END;
$$;