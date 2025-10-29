-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO ESTACIONAMIENTOS - REPORTES ADICIONALES
-- Archivo: 02_SP_ESTACIONAMIENTOS_REPORTES_all_procedures.sql
-- ============================================

-- SP_ESTACIONAMIENTOS_REPORTE_OCUPACION - Reporte de ocupación por zona
CREATE OR REPLACE FUNCTION SP_ESTACIONAMIENTOS_REPORTE_OCUPACION(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
) RETURNS TABLE(
    zona VARCHAR(50),
    permisos_activos INTEGER,
    total_movimientos INTEGER,
    ingresos_zona NUMERIC(15,2),
    ocupacion_promedio NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.zona,
        COUNT(DISTINCT p.id)::INTEGER as permisos_activos,
        COUNT(a.id)::INTEGER as total_movimientos,
        COALESCE(SUM(pg.monto_pago), 0) as ingresos_zona,
        (COUNT(a.id)::NUMERIC / NULLIF(COUNT(DISTINCT p.id), 0))::NUMERIC(5,2) as ocupacion_promedio
    FROM public.permisos p
    LEFT JOIN public.accesos a ON p.id = a.permiso_id 
        AND DATE(a.fecha_movimiento) BETWEEN p_fecha_desde AND p_fecha_hasta
    LEFT JOIN public.pagos pg ON p.id = pg.permiso_id 
        AND pg.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
    WHERE p.estado = 'VIGENTE'
    GROUP BY p.zona
    ORDER BY ingresos_zona DESC;
END;
$$;