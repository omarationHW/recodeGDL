-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO RECAUDADORA - PROCEDIMIENTOS PRINCIPALES
-- Archivo: 01_SP_RECAUDADORA_CORE_all_procedures.sql
-- ============================================

-- SP_RECAUDADORA_INGRESOS_LIST - Lista ingresos de recaudación
CREATE OR REPLACE FUNCTION SP_RECAUDADORA_INGRESOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_concepto VARCHAR(50) DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    numero_recibo VARCHAR(50),
    contribuyente VARCHAR(255),
    rfc VARCHAR(15),
    concepto VARCHAR(50),
    descripcion TEXT,
    monto NUMERIC(15,2),
    fecha_pago DATE,
    cajero VARCHAR(255),
    turno VARCHAR(20),
    forma_pago VARCHAR(30),
    estado VARCHAR(30),
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        r.id,
        r.numero_recibo,
        r.contribuyente,
        r.rfc,
        r.concepto,
        r.descripcion,
        r.monto,
        r.fecha_pago,
        r.cajero,
        r.turno,
        r.forma_pago,
        r.estado,
        COUNT(*) OVER() as total_count
    FROM public.ingresos r
    WHERE (p_fecha_desde IS NULL OR r.fecha_pago >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR r.fecha_pago <= p_fecha_hasta)
    AND (p_concepto IS NULL OR r.concepto = p_concepto)
    ORDER BY r.fecha_pago DESC, r.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_RECAUDADORA_INGRESO_CREATE - Registrar nuevo ingreso
CREATE OR REPLACE FUNCTION SP_RECAUDADORA_INGRESO_CREATE(
    p_numero_recibo VARCHAR(50),
    p_contribuyente VARCHAR(255),
    p_rfc VARCHAR(15),
    p_concepto VARCHAR(50),
    p_descripcion TEXT,
    p_monto NUMERIC(15,2),
    p_cajero VARCHAR(255),
    p_turno VARCHAR(20),
    p_forma_pago VARCHAR(30)
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    ingreso_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    recibo_exists BOOLEAN;
BEGIN
    -- Validar recibo único
    SELECT EXISTS(
        SELECT 1 FROM public.ingresos 
        WHERE numero_recibo = p_numero_recibo
    ) INTO recibo_exists;
    
    IF recibo_exists THEN
        RETURN QUERY SELECT FALSE, 'El número de recibo ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar ingreso
    INSERT INTO public.ingresos (
        numero_recibo,
        contribuyente,
        rfc,
        concepto,
        descripcion,
        monto,
        fecha_pago,
        cajero,
        turno,
        forma_pago,
        estado,
        fecha_creacion
    ) VALUES (
        p_numero_recibo,
        p_contribuyente,
        p_rfc,
        p_concepto,
        p_descripcion,
        p_monto,
        CURRENT_DATE,
        p_cajero,
        p_turno,
        p_forma_pago,
        'REGISTRADO',
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Ingreso registrado exitosamente', new_id;
END;
$$;

-- SP_RECAUDADORA_REPORTES_DIARIOS - Reporte diario de recaudación
CREATE OR REPLACE FUNCTION SP_RECAUDADORA_REPORTES_DIARIOS(
    p_fecha DATE DEFAULT NULL
) RETURNS TABLE(
    concepto VARCHAR(50),
    cantidad_recibos INTEGER,
    monto_total NUMERIC(15,2),
    monto_efectivo NUMERIC(15,2),
    monto_cheque NUMERIC(15,2),
    monto_tarjeta NUMERIC(15,2),
    monto_transferencia NUMERIC(15,2)
) LANGUAGE plpgsql AS $$
DECLARE
    fecha_consulta DATE;
BEGIN
    fecha_consulta := COALESCE(p_fecha, CURRENT_DATE);
    
    RETURN QUERY
    SELECT 
        r.concepto,
        COUNT(*)::INTEGER as cantidad_recibos,
        SUM(r.monto) as monto_total,
        SUM(CASE WHEN r.forma_pago = 'EFECTIVO' THEN r.monto ELSE 0 END) as monto_efectivo,
        SUM(CASE WHEN r.forma_pago = 'CHEQUE' THEN r.monto ELSE 0 END) as monto_cheque,
        SUM(CASE WHEN r.forma_pago = 'TARJETA' THEN r.monto ELSE 0 END) as monto_tarjeta,
        SUM(CASE WHEN r.forma_pago = 'TRANSFERENCIA' THEN r.monto ELSE 0 END) as monto_transferencia
    FROM public.ingresos r
    WHERE r.fecha_pago = fecha_consulta
    GROUP BY r.concepto
    ORDER BY monto_total DESC;
END;
$$;

-- SP_RECAUDADORA_ESTADISTICAS - Estadísticas generales
CREATE OR REPLACE FUNCTION SP_RECAUDADORA_ESTADISTICAS() RETURNS TABLE(
    ingresos_dia_actual NUMERIC(15,2),
    ingresos_mes_actual NUMERIC(15,2),
    recibos_dia_actual INTEGER,
    recibos_mes_actual INTEGER,
    promedio_diario_mes NUMERIC(15,2)
) LANGUAGE plpgsql AS $$
DECLARE
    inicio_mes DATE;
    dias_transcurridos INTEGER;
BEGIN
    inicio_mes := DATE_TRUNC('month', CURRENT_DATE);
    dias_transcurridos := EXTRACT(DAY FROM CURRENT_DATE);
    
    RETURN QUERY
    SELECT 
        (SELECT COALESCE(SUM(monto), 0) FROM public.ingresos WHERE fecha_pago = CURRENT_DATE) as ingresos_dia_actual,
        (SELECT COALESCE(SUM(monto), 0) FROM public.ingresos WHERE fecha_pago >= inicio_mes) as ingresos_mes_actual,
        (SELECT COUNT(*)::INTEGER FROM public.ingresos WHERE fecha_pago = CURRENT_DATE) as recibos_dia_actual,
        (SELECT COUNT(*)::INTEGER FROM public.ingresos WHERE fecha_pago >= inicio_mes) as recibos_mes_actual,
        ((SELECT COALESCE(SUM(monto), 0) FROM public.ingresos WHERE fecha_pago >= inicio_mes) / NULLIF(dias_transcurridos, 0))::NUMERIC(15,2) as promedio_diario_mes;
END;
$$;