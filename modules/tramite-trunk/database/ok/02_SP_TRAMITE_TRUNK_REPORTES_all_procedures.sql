-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO TRAMITE TRUNK - REPORTES ADICIONALES
-- Archivo: 02_SP_TRAMITE_TRUNK_REPORTES_all_procedures.sql
-- ============================================

-- SP_TRAMITE_TRUNK_REPORTE_PRODUCTIVIDAD - Reporte de productividad por responsable
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_REPORTE_PRODUCTIVIDAD(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
) RETURNS TABLE(
    responsable VARCHAR(255),
    tramites_asignados INTEGER,
    tramites_finalizados INTEGER,
    tramites_pendientes INTEGER,
    tiempo_promedio_resolucion NUMERIC(5,2),
    efectividad NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.responsable,
        COUNT(*)::INTEGER as tramites_asignados,
        COUNT(CASE WHEN t.estado = 'FINALIZADO' THEN 1 END)::INTEGER as tramites_finalizados,
        COUNT(CASE WHEN t.estado = 'EN_PROCESO' THEN 1 END)::INTEGER as tramites_pendientes,
        AVG(CASE 
            WHEN t.estado = 'FINALIZADO' 
            THEN EXTRACT(DAY FROM (COALESCE(t.fecha_finalizacion, CURRENT_DATE) - t.fecha_solicitud))
            ELSE NULL 
        END)::NUMERIC(5,2) as tiempo_promedio_resolucion,
        (COUNT(CASE WHEN t.estado = 'FINALIZADO' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0))::NUMERIC(5,2) as efectividad
    FROM tramite_trunk.tramites t
    WHERE t.fecha_solicitud BETWEEN p_fecha_desde AND p_fecha_hasta
    GROUP BY t.responsable
    ORDER BY efectividad DESC;
END;
$$;