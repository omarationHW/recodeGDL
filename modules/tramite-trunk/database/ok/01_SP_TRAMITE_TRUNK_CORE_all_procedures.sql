-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO TRAMITE TRUNK - PROCEDIMIENTOS PRINCIPALES
-- Archivo: 01_SP_TRAMITE_TRUNK_CORE_all_procedures.sql
-- ============================================

-- SP_TRAMITE_TRUNK_TRAMITES_LIST - Lista trámites generales
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_TRAMITES_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_search VARCHAR(255) DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL,
    p_tipo_tramite VARCHAR(50) DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    numero_tramite VARCHAR(50),
    solicitante VARCHAR(255),
    rfc VARCHAR(15),
    tipo_tramite VARCHAR(50),
    descripcion TEXT,
    fecha_solicitud DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(30),
    responsable VARCHAR(255),
    observaciones TEXT,
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        t.id,
        t.numero_tramite,
        t.solicitante,
        t.rfc,
        t.tipo_tramite,
        t.descripcion,
        t.fecha_solicitud,
        t.fecha_vencimiento,
        t.estado,
        t.responsable,
        t.observaciones,
        COUNT(*) OVER() as total_count
    FROM tramite_trunk.tramites t
    WHERE (p_search IS NULL OR 
           t.solicitante ILIKE '%' || p_search || '%' OR
           t.numero_tramite ILIKE '%' || p_search || '%' OR
           t.rfc ILIKE '%' || p_search || '%')
    AND (p_estado IS NULL OR t.estado = p_estado)
    AND (p_tipo_tramite IS NULL OR t.tipo_tramite = p_tipo_tramite)
    ORDER BY t.fecha_solicitud DESC, t.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_TRAMITE_TRUNK_TRAMITE_CREATE - Crear nuevo trámite
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_TRAMITE_CREATE(
    p_numero_tramite VARCHAR(50),
    p_solicitante VARCHAR(255),
    p_rfc VARCHAR(15),
    p_tipo_tramite VARCHAR(50),
    p_descripcion TEXT,
    p_fecha_vencimiento DATE,
    p_responsable VARCHAR(255),
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    tramite_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    tramite_exists BOOLEAN;
BEGIN
    -- Validar número único
    SELECT EXISTS(
        SELECT 1 FROM tramite_trunk.tramites 
        WHERE numero_tramite = p_numero_tramite
    ) INTO tramite_exists;
    
    IF tramite_exists THEN
        RETURN QUERY SELECT FALSE, 'El número de trámite ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar trámite
    INSERT INTO tramite_trunk.tramites (
        numero_tramite,
        solicitante,
        rfc,
        tipo_tramite,
        descripcion,
        fecha_solicitud,
        fecha_vencimiento,
        estado,
        responsable,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_numero_tramite,
        p_solicitante,
        p_rfc,
        p_tipo_tramite,
        p_descripcion,
        CURRENT_DATE,
        p_fecha_vencimiento,
        'EN_PROCESO',
        p_responsable,
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Trámite creado exitosamente', new_id;
END;
$$;

-- SP_TRAMITE_TRUNK_SEGUIMIENTO_LIST - Lista seguimiento de trámites
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_SEGUIMIENTO_LIST(
    p_tramite_id INTEGER
) RETURNS TABLE(
    id INTEGER,
    tramite_id INTEGER,
    estado_anterior VARCHAR(30),
    estado_nuevo VARCHAR(30),
    comentario TEXT,
    responsable VARCHAR(255),
    fecha_cambio TIMESTAMP
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.tramite_id,
        s.estado_anterior,
        s.estado_nuevo,
        s.comentario,
        s.responsable,
        s.fecha_cambio
    FROM tramite_trunk.seguimiento s
    WHERE s.tramite_id = p_tramite_id
    ORDER BY s.fecha_cambio DESC;
END;
$$;

-- SP_TRAMITE_TRUNK_ESTADISTICAS - Estadísticas
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_ESTADISTICAS() RETURNS TABLE(
    tramites_en_proceso INTEGER,
    tramites_finalizados INTEGER,
    tramites_vencidos INTEGER,
    tramites_mes_actual INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    inicio_mes DATE;
BEGIN
    inicio_mes := DATE_TRUNC('month', CURRENT_DATE);
    
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM tramite_trunk.tramites WHERE estado = 'EN_PROCESO') as tramites_en_proceso,
        (SELECT COUNT(*)::INTEGER FROM tramite_trunk.tramites WHERE estado = 'FINALIZADO') as tramites_finalizados,
        (SELECT COUNT(*)::INTEGER FROM tramite_trunk.tramites WHERE estado = 'EN_PROCESO' AND fecha_vencimiento < CURRENT_DATE) as tramites_vencidos,
        (SELECT COUNT(*)::INTEGER FROM tramite_trunk.tramites WHERE fecha_solicitud >= inicio_mes) as tramites_mes_actual;
END;
$$;