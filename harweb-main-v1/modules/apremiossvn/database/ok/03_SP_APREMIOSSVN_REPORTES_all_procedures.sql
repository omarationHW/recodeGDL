-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO APREMIOSSVN - REPORTES Y CONSULTAS
-- Archivo: 03_SP_APREMIOSSVN_REPORTES_all_procedures.sql
-- ============================================

-- SP_APREMIOSSVN_REPORTES_LISTADOS - Reportes de listados por ejecutor
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTES_LISTADOS(
    p_ejecutor_id INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_tipo_reporte VARCHAR(50) DEFAULT 'GENERAL'
) RETURNS TABLE(
    ejecutor_id INTEGER,
    nombre_ejecutor VARCHAR(255),
    total_expedientes INTEGER,
    expedientes_activos INTEGER,
    expedientes_liquidados INTEGER,
    monto_total NUMERIC(15,2),
    monto_recuperado NUMERIC(15,2),
    efectividad NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ej.id,
        ej.nombre_ejecutor,
        COUNT(DISTINCT e.id)::INTEGER as total_expedientes,
        COUNT(CASE WHEN e.estado = 'ACTIVO' THEN 1 END)::INTEGER as expedientes_activos,
        COUNT(CASE WHEN e.estado = 'LIQUIDADO' THEN 1 END)::INTEGER as expedientes_liquidados,
        COALESCE(SUM(e.adeudo_original), 0) as monto_total,
        COALESCE(SUM(p.monto_pago), 0) as monto_recuperado,
        CASE 
            WHEN COUNT(DISTINCT e.id) > 0 
            THEN (COUNT(CASE WHEN e.estado = 'LIQUIDADO' THEN 1 END) * 100.0 / COUNT(DISTINCT e.id))::NUMERIC(5,2)
            ELSE 0 
        END as efectividad
    FROM public.ejecutores ej
    LEFT JOIN public.expedientes e ON ej.nombre_ejecutor = e.notificador
        AND (p_fecha_desde IS NULL OR e.fecha_inicio >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR e.fecha_inicio <= p_fecha_hasta)
    LEFT JOIN public.pagos p ON e.id = p.expediente_id
    WHERE (p_ejecutor_id IS NULL OR ej.id = p_ejecutor_id)
    AND ej.vigencia = TRUE
    GROUP BY ej.id, ej.nombre_ejecutor
    ORDER BY monto_recuperado DESC;
END;
$$;

-- SP_APREMIOSSVN_REPORTES_ESTADXFOLIO - Estadísticas por folio
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTES_ESTADXFOLIO(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
) RETURNS TABLE(
    fase VARCHAR(30),
    total_expedientes INTEGER,
    monto_total NUMERIC(15,2),
    porcentaje NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
DECLARE
    total_general INTEGER;
BEGIN
    -- Obtener total general
    SELECT COUNT(*) INTO total_general
    FROM public.expedientes e
    WHERE e.fecha_inicio BETWEEN p_fecha_desde AND p_fecha_hasta;
    
    RETURN QUERY
    SELECT 
        e.fase_actual,
        COUNT(*)::INTEGER as total_expedientes,
        SUM(e.adeudo_actual) as monto_total,
        (COUNT(*) * 100.0 / NULLIF(total_general, 0))::NUMERIC(5,2) as porcentaje
    FROM public.expedientes e
    WHERE e.fecha_inicio BETWEEN p_fecha_desde AND p_fecha_hasta
    GROUP BY e.fase_actual
    ORDER BY total_expedientes DESC;
END;
$$;

-- SP_APREMIOSSVN_REPORTES_PRENOMINA - Reporte de prenómina
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTES_PRENOMINA(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
) RETURNS TABLE(
    ejecutor VARCHAR(255),
    notificaciones_realizadas INTEGER,
    notificaciones_exitosas INTEGER,
    monto_gestionado NUMERIC(15,2),
    comision_base NUMERIC(10,2),
    comision_efectividad NUMERIC(10,2),
    comision_total NUMERIC(10,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        n.notificador,
        COUNT(*)::INTEGER as notificaciones_realizadas,
        COUNT(CASE WHEN n.resultado = 'EXITOSA' THEN 1 END)::INTEGER as notificaciones_exitosas,
        COALESCE(SUM(e.adeudo_original), 0) as monto_gestionado,
        (COUNT(*) * 50.0)::NUMERIC(10,2) as comision_base, -- 50 pesos por notificación
        (COUNT(CASE WHEN n.resultado = 'EXITOSA' THEN 1 END) * 25.0)::NUMERIC(10,2) as comision_efectividad,
        ((COUNT(*) * 50.0) + (COUNT(CASE WHEN n.resultado = 'EXITOSA' THEN 1 END) * 25.0))::NUMERIC(10,2) as comision_total
    FROM public.notificaciones n
    JOIN public.expedientes e ON n.expediente_id = e.id
    WHERE n.fecha_realizada BETWEEN p_fecha_desde AND p_fecha_hasta
    GROUP BY n.notificador
    ORDER BY comision_total DESC;
END;
$$;

-- SP_APREMIOSSVN_REPORTES_RECUPERACION - Reporte de recuperación de cartera
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTES_RECUPERACION(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_tipo_adeudo VARCHAR(50) DEFAULT NULL
) RETURNS TABLE(
    periodo VARCHAR(10),
    expedientes_ingresados INTEGER,
    monto_ingresado NUMERIC(15,2),
    expedientes_liquidados INTEGER,
    monto_recuperado NUMERIC(15,2),
    porcentaje_recuperacion NUMERIC(5,2),
    expedientes_pendientes INTEGER,
    monto_pendiente NUMERIC(15,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        TO_CHAR(e.fecha_inicio, 'YYYY-MM') as periodo,
        COUNT(*)::INTEGER as expedientes_ingresados,
        SUM(e.adeudo_original) as monto_ingresado,
        COUNT(CASE WHEN e.estado = 'LIQUIDADO' THEN 1 END)::INTEGER as expedientes_liquidados,
        COALESCE(SUM(CASE WHEN e.estado = 'LIQUIDADO' THEN e.adeudo_original ELSE 0 END), 0) as monto_recuperado,
        (COALESCE(SUM(CASE WHEN e.estado = 'LIQUIDADO' THEN e.adeudo_original ELSE 0 END), 0) * 100.0 / 
         NULLIF(SUM(e.adeudo_original), 0))::NUMERIC(5,2) as porcentaje_recuperacion,
        COUNT(CASE WHEN e.estado = 'ACTIVO' THEN 1 END)::INTEGER as expedientes_pendientes,
        COALESCE(SUM(CASE WHEN e.estado = 'ACTIVO' THEN e.adeudo_actual ELSE 0 END), 0) as monto_pendiente
    FROM public.expedientes e
    WHERE e.fecha_inicio BETWEEN p_fecha_desde AND p_fecha_hasta
    AND (p_tipo_adeudo IS NULL OR e.concepto_adeudo ILIKE '%' || p_tipo_adeudo || '%')
    GROUP BY TO_CHAR(e.fecha_inicio, 'YYYY-MM')
    ORDER BY periodo DESC;
END;
$$;

-- SP_APREMIOSSVN_REPORTES_NOTIFICACIONES_MES - Reporte mensual de notificaciones
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTES_NOTIFICACIONES_MES(
    p_año INTEGER,
    p_mes INTEGER
) RETURNS TABLE(
    dia INTEGER,
    notificaciones_programadas INTEGER,
    notificaciones_realizadas INTEGER,
    notificaciones_exitosas INTEGER,
    porcentaje_efectividad NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
DECLARE
    fecha_inicio DATE;
    fecha_fin DATE;
BEGIN
    fecha_inicio := DATE(p_año || '-' || p_mes || '-01');
    fecha_fin := fecha_inicio + INTERVAL '1 month' - INTERVAL '1 day';
    
    RETURN QUERY
    SELECT 
        EXTRACT(DAY FROM n.fecha_programada)::INTEGER as dia,
        COUNT(*)::INTEGER as notificaciones_programadas,
        COUNT(CASE WHEN n.fecha_realizada IS NOT NULL THEN 1 END)::INTEGER as notificaciones_realizadas,
        COUNT(CASE WHEN n.resultado = 'EXITOSA' THEN 1 END)::INTEGER as notificaciones_exitosas,
        (COUNT(CASE WHEN n.resultado = 'EXITOSA' THEN 1 END) * 100.0 / 
         NULLIF(COUNT(CASE WHEN n.fecha_realizada IS NOT NULL THEN 1 END), 0))::NUMERIC(5,2) as porcentaje_efectividad
    FROM public.notificaciones n
    WHERE n.fecha_programada BETWEEN fecha_inicio AND fecha_fin
    GROUP BY EXTRACT(DAY FROM n.fecha_programada)
    ORDER BY dia;
END;
$$;

-- SP_APREMIOSSVN_CONSULTA_HISTORICA - Consulta histórica de expedientes
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CONSULTA_HISTORICA(
    p_criterio VARCHAR(255),
    p_tipo_busqueda VARCHAR(50) DEFAULT 'GENERAL'
) RETURNS TABLE(
    numero_expediente VARCHAR(50),
    contribuyente VARCHAR(255),
    cuenta_predial VARCHAR(50),
    adeudo_original NUMERIC(15,2),
    adeudo_actual NUMERIC(15,2),
    fase_actual VARCHAR(30),
    estado VARCHAR(30),
    fecha_inicio DATE,
    ultimo_movimiento DATE,
    notificador VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.numero_expediente,
        e.contribuyente,
        e.cuenta_predial,
        e.adeudo_original,
        e.adeudo_actual,
        e.fase_actual,
        e.estado,
        e.fecha_inicio,
        e.fecha_actualizacion::DATE as ultimo_movimiento,
        e.notificador
    FROM public.expedientes e
    WHERE 
        CASE p_tipo_busqueda
            WHEN 'EXPEDIENTE' THEN e.numero_expediente ILIKE '%' || p_criterio || '%'
            WHEN 'CONTRIBUYENTE' THEN e.contribuyente ILIKE '%' || p_criterio || '%'
            WHEN 'CUENTA' THEN e.cuenta_predial ILIKE '%' || p_criterio || '%'
            WHEN 'RFC' THEN e.rfc ILIKE '%' || p_criterio || '%'
            ELSE (
                e.numero_expediente ILIKE '%' || p_criterio || '%' OR
                e.contribuyente ILIKE '%' || p_criterio || '%' OR
                e.cuenta_predial ILIKE '%' || p_criterio || '%' OR
                e.rfc ILIKE '%' || p_criterio || '%'
            )
        END
    ORDER BY e.fecha_inicio DESC
    LIMIT 500;
END;
$$;

-- SP_APREMIOSSVN_REPORTES_GASTOS_COBRANZA - Reporte de gastos de cobranza
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTES_GASTOS_COBRANZA(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
) RETURNS TABLE(
    tipo_actuacion VARCHAR(50),
    cantidad_actuaciones INTEGER,
    costo_total NUMERIC(15,2),
    costo_promedio NUMERIC(10,2),
    expedientes_afectados INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.tipo_actuacion,
        COUNT(*)::INTEGER as cantidad_actuaciones,
        SUM(a.costo_actuacion) as costo_total,
        AVG(a.costo_actuacion)::NUMERIC(10,2) as costo_promedio,
        COUNT(DISTINCT a.expediente_id)::INTEGER as expedientes_afectados
    FROM public.actuaciones a
    WHERE a.fecha_actuacion BETWEEN p_fecha_desde AND p_fecha_hasta
    AND a.costo_actuacion > 0
    GROUP BY a.tipo_actuacion
    ORDER BY costo_total DESC;
END;
$$;