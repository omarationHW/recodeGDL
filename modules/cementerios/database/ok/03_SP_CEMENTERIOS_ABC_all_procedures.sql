-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO CEMENTERIOS - ABC Y ADMINISTRACIÓN DE FOLIOS
-- Archivo: 03_SP_CEMENTERIOS_ABC_all_procedures.sql
-- ============================================

-- SP_CEMENTERIOS_FOLIO_GET - Obtener información completa de folio
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_FOLIO_GET(
    p_folio VARCHAR(50)
) RETURNS TABLE(
    id INTEGER,
    numero_folio VARCHAR(50),
    difunto_id INTEGER,
    nombre_difunto VARCHAR(255),
    fecha_registro DATE,
    estado_folio VARCHAR(30),
    tipo_servicio VARCHAR(50),
    monto_servicios NUMERIC(15,2),
    observaciones TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.id,
        f.numero_folio,
        f.difunto_id,
        d.nombre_completo,
        f.fecha_registro,
        f.estado_folio,
        f.tipo_servicio,
        f.monto_servicios,
        f.observaciones
    FROM public.folios f
    LEFT JOIN public.difuntos d ON f.difunto_id = d.id
    WHERE f.numero_folio = p_folio;
END;
$$;

-- SP_CEMENTERIOS_FOLIO_HISTORIA - Historial de movimientos de folio
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_FOLIO_HISTORIA(
    p_folio_id INTEGER
) RETURNS TABLE(
    id INTEGER,
    accion VARCHAR(100),
    estado_anterior VARCHAR(30),
    estado_nuevo VARCHAR(30),
    usuario VARCHAR(255),
    fecha_movimiento TIMESTAMP,
    observaciones TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.id,
        h.accion,
        h.estado_anterior,
        h.estado_nuevo,
        h.usuario,
        h.fecha_movimiento,
        h.observaciones
    FROM public.historial_folios h
    WHERE h.folio_id = p_folio_id
    ORDER BY h.fecha_movimiento DESC;
END;
$$;

-- SP_CEMENTERIOS_FOLIO_BAJA - Dar de baja un folio
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_FOLIO_BAJA(
    p_folio_id INTEGER,
    p_motivo_baja TEXT,
    p_usuario VARCHAR(255)
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    folio_info RECORD;
BEGIN
    -- Obtener información del folio
    SELECT f.id, f.numero_folio, f.estado_folio
    INTO folio_info
    FROM public.folios f
    WHERE f.id = p_folio_id;
    
    IF folio_info.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El folio no existe';
        RETURN;
    END IF;
    
    IF folio_info.estado_folio = 'CANCELADO' THEN
        RETURN QUERY SELECT FALSE, 'El folio ya está dado de baja';
        RETURN;
    END IF;
    
    -- Actualizar estado del folio
    UPDATE public.folios 
    SET 
        estado_folio = 'CANCELADO',
        fecha_baja = CURRENT_DATE,
        motivo_baja = p_motivo_baja,
        fecha_actualizacion = NOW()
    WHERE id = p_folio_id;
    
    -- Registrar en historial
    INSERT INTO public.historial_folios (
        folio_id,
        accion,
        estado_anterior,
        estado_nuevo,
        usuario,
        fecha_movimiento,
        observaciones
    ) VALUES (
        p_folio_id,
        'BAJA_FOLIO',
        folio_info.estado_folio,
        'CANCELADO',
        p_usuario,
        NOW(),
        p_motivo_baja
    );
    
    RETURN QUERY SELECT TRUE, 'Folio dado de baja exitosamente';
END;
$$;

-- SP_CEMENTERIOS_ADICIONALES_GET - Obtener servicios adicionales de folio
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_ADICIONALES_GET(
    p_folio_id INTEGER
) RETURNS TABLE(
    id INTEGER,
    tipo_adicional VARCHAR(100),
    descripcion TEXT,
    costo NUMERIC(10,2),
    fecha_servicio DATE,
    proveedor VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.tipo_adicional,
        a.descripcion,
        a.costo,
        a.fecha_servicio,
        a.proveedor
    FROM public.servicios_adicionales a
    WHERE a.folio_id = p_folio_id
    ORDER BY a.fecha_servicio DESC;
END;
$$;

-- SP_CEMENTERIOS_REPORTES_MENSUAL - Reporte mensual del cementerio
CREATE OR REPLACE FUNCTION SP_CEMENTERIOS_REPORTES_MENSUAL(
    p_año INTEGER,
    p_mes INTEGER,
    p_cementerio_id INTEGER DEFAULT NULL
) RETURNS TABLE(
    cementerio_id INTEGER,
    cementerio_nombre VARCHAR(255),
    nuevos_registros INTEGER,
    servicios_realizados INTEGER,
    ingresos_servicios NUMERIC(15,2),
    renovaciones INTEGER,
    ingresos_renovaciones NUMERIC(15,2),
    total_ingresos NUMERIC(15,2)
) LANGUAGE plpgsql AS $$
DECLARE
    fecha_inicio DATE;
    fecha_fin DATE;
BEGIN
    fecha_inicio := DATE(p_año || '-' || p_mes || '-01');
    fecha_fin := fecha_inicio + INTERVAL '1 month' - INTERVAL '1 day';
    
    RETURN QUERY
    SELECT 
        c.id,
        c.nombre,
        COUNT(DISTINCT d.id)::INTEGER as nuevos_registros,
        COUNT(DISTINCT s.id)::INTEGER as servicios_realizados,
        COALESCE(SUM(s.costo_servicio), 0) as ingresos_servicios,
        COUNT(DISTINCT r.id)::INTEGER as renovaciones,
        COALESCE(SUM(r.monto_renovacion), 0) as ingresos_renovaciones,
        (COALESCE(SUM(s.costo_servicio), 0) + COALESCE(SUM(r.monto_renovacion), 0)) as total_ingresos
    FROM public.cementerios c
    LEFT JOIN public.difuntos d ON c.id = d.cementerio_id 
        AND d.fecha_registro BETWEEN fecha_inicio AND fecha_fin
    LEFT JOIN public.servicios s ON d.id = s.difunto_id 
        AND s.fecha_servicio BETWEEN fecha_inicio AND fecha_fin
    LEFT JOIN public.renovaciones r ON d.id = r.difunto_id 
        AND r.fecha_confirmacion BETWEEN fecha_inicio AND fecha_fin
    WHERE (p_cementerio_id IS NULL OR c.id = p_cementerio_id)
    AND c.estado = 'ACTIVO'
    GROUP BY c.id, c.nombre
    ORDER BY total_ingresos DESC;
END;
$$;