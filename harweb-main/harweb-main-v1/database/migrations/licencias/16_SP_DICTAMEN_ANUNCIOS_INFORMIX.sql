-- =====================================================
-- STORED PROCEDURES: DICTÁMENES DE ANUNCIOS
-- Módulo: Licencias - HARWEB Guadalajara
-- Descripción: Gestión de dictámenes para anuncios publicitarios
-- Fecha: 2025-09-29
-- Versión: 1.0
-- =====================================================

-- SP 1: LISTAR DICTÁMENES CON PAGINACIÓN Y FILTROS
CREATE OR REPLACE FUNCTION sp_dictamen_list(
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0,
    p_anuncio VARCHAR(20) DEFAULT '',
    p_propietario VARCHAR(200) DEFAULT '',
    p_clasificacion VARCHAR(100) DEFAULT '',
    p_ubicacion VARCHAR(500) DEFAULT ''
)
RETURNS TABLE (
    id_dictamen INTEGER,
    numero_anuncio VARCHAR(20),
    folio_dictamen VARCHAR(50),
    propietario VARCHAR(200),
    clasificacion VARCHAR(100),
    ubicacion VARCHAR(500),
    medidas VARCHAR(100),
    fecha_solicitud DATE,
    fecha_dictamen DATE,
    fecha_vencimiento DATE,
    estatus VARCHAR(30),
    observaciones TEXT,
    importe DECIMAL(15,2),
    usuario_responsable VARCHAR(50),
    fecha_creacion TIMESTAMP,
    fecha_modificacion TIMESTAMP,
    total_registros INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_where TEXT := '';
    v_total INTEGER;
BEGIN
    -- Construir WHERE dinámico
    IF p_anuncio != '' THEN
        v_where := v_where || ' AND d.numero_anuncio = ''' || p_anuncio || '''';
    END IF;

    IF p_propietario != '' THEN
        v_where := v_where || ' AND UPPER(d.propietario) LIKE UPPER(''%' || p_propietario || '%'')';
    END IF;

    IF p_clasificacion != '' THEN
        v_where := v_where || ' AND UPPER(d.clasificacion) LIKE UPPER(''%' || p_clasificacion || '%'')';
    END IF;

    IF p_ubicacion != '' THEN
        v_where := v_where || ' AND UPPER(d.ubicacion) LIKE UPPER(''%' || p_ubicacion || '%'')';
    END IF;

    -- Obtener total de registros
    v_sql := 'SELECT COUNT(*) FROM dictamenes_anuncios d WHERE 1=1 ' || v_where;
    EXECUTE v_sql INTO v_total;

    -- Query principal con paginación
    v_sql := '
    SELECT
        d.id_dictamen,
        d.numero_anuncio,
        d.folio_dictamen,
        d.propietario,
        d.clasificacion,
        d.ubicacion,
        d.medidas,
        d.fecha_solicitud,
        d.fecha_dictamen,
        d.fecha_vencimiento,
        d.estatus,
        d.observaciones,
        d.importe,
        d.usuario_responsable,
        d.fecha_creacion,
        d.fecha_modificacion,
        ' || v_total || ' as total_registros
    FROM dictamenes_anuncios d
    WHERE 1=1 ' || v_where || '
    ORDER BY d.fecha_creacion DESC
    LIMIT ' || p_limite || ' OFFSET ' || p_offset;

    RETURN QUERY EXECUTE v_sql;
END;
$$;

-- SP 2: OBTENER DETALLE DE DICTAMEN
CREATE OR REPLACE FUNCTION sp_dictamen_detalle(
    p_id_dictamen INTEGER
)
RETURNS TABLE (
    id_dictamen INTEGER,
    numero_anuncio VARCHAR(20),
    folio_dictamen VARCHAR(50),
    propietario VARCHAR(200),
    rfc VARCHAR(15),
    domicilio_propietario VARCHAR(500),
    telefono VARCHAR(20),
    email VARCHAR(100),
    clasificacion VARCHAR(100),
    ubicacion VARCHAR(500),
    colonia VARCHAR(100),
    cp VARCHAR(10),
    medidas VARCHAR(100),
    superficie DECIMAL(10,2),
    material VARCHAR(100),
    iluminacion VARCHAR(50),
    fecha_solicitud DATE,
    fecha_dictamen DATE,
    fecha_vencimiento DATE,
    vigencia_meses INTEGER,
    estatus VARCHAR(30),
    observaciones TEXT,
    importe DECIMAL(15,2),
    pagado CHAR(1),
    fecha_pago DATE,
    usuario_responsable VARCHAR(50),
    fecha_creacion TIMESTAMP,
    fecha_modificacion TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_dictamen,
        d.numero_anuncio,
        d.folio_dictamen,
        d.propietario,
        d.rfc,
        d.domicilio_propietario,
        d.telefono,
        d.email,
        d.clasificacion,
        d.ubicacion,
        d.colonia,
        d.cp,
        d.medidas,
        d.superficie,
        d.material,
        d.iluminacion,
        d.fecha_solicitud,
        d.fecha_dictamen,
        d.fecha_vencimiento,
        d.vigencia_meses,
        d.estatus,
        d.observaciones,
        d.importe,
        d.pagado,
        d.fecha_pago,
        d.usuario_responsable,
        d.fecha_creacion,
        d.fecha_modificacion
    FROM dictamenes_anuncios d
    WHERE d.id_dictamen = p_id_dictamen;
END;
$$;

-- SP 3: CREAR NUEVO DICTAMEN
CREATE OR REPLACE FUNCTION SP_DICTAMEN_CREATE(
    p_numero_anuncio VARCHAR(20),
    p_propietario VARCHAR(200),
    p_rfc VARCHAR(15) DEFAULT NULL,
    p_domicilio_propietario VARCHAR(500) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_clasificacion VARCHAR(100),
    p_ubicacion VARCHAR(500),
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_cp VARCHAR(10) DEFAULT NULL,
    p_medidas VARCHAR(100),
    p_superficie DECIMAL(10,2) DEFAULT NULL,
    p_material VARCHAR(100) DEFAULT NULL,
    p_iluminacion VARCHAR(50) DEFAULT NULL,
    p_vigencia_meses INTEGER DEFAULT 12,
    p_observaciones TEXT DEFAULT NULL,
    p_importe DECIMAL(15,2) DEFAULT 0,
    p_usuario_responsable VARCHAR(50)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_dictamen INTEGER,
    folio_dictamen VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_dictamen INTEGER;
    v_folio_dictamen VARCHAR(50);
    v_fecha_vencimiento DATE;
BEGIN
    -- Verificar que el número de anuncio no exista con dictamen activo
    IF EXISTS (
        SELECT 1 FROM dictamenes_anuncios
        WHERE numero_anuncio = p_numero_anuncio
        AND estatus IN ('VIGENTE', 'PENDIENTE')
    ) THEN
        RETURN QUERY SELECT false, 'Ya existe un dictamen activo para este número de anuncio', NULL::INTEGER, NULL::VARCHAR;
        RETURN;
    END IF;

    -- Generar folio de dictamen
    SELECT 'DICT-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' ||
           LPAD((COALESCE(MAX(CAST(SUBSTRING(folio_dictamen FROM 11) AS INTEGER)), 0) + 1)::TEXT, 6, '0')
    INTO v_folio_dictamen
    FROM dictamenes_anuncios
    WHERE folio_dictamen LIKE 'DICT-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-%';

    -- Calcular fecha de vencimiento
    v_fecha_vencimiento := CURRENT_DATE + (p_vigencia_meses || ' months')::INTERVAL;

    -- Insertar dictamen
    INSERT INTO dictamenes_anuncios (
        numero_anuncio, folio_dictamen, propietario, rfc, domicilio_propietario,
        telefono, email, clasificacion, ubicacion, colonia, cp, medidas,
        superficie, material, iluminacion, fecha_solicitud, fecha_dictamen,
        fecha_vencimiento, vigencia_meses, estatus, observaciones, importe,
        pagado, usuario_responsable, fecha_creacion, fecha_modificacion
    ) VALUES (
        p_numero_anuncio, v_folio_dictamen, p_propietario, p_rfc, p_domicilio_propietario,
        p_telefono, p_email, p_clasificacion, p_ubicacion, p_colonia, p_cp, p_medidas,
        p_superficie, p_material, p_iluminacion, CURRENT_DATE, CURRENT_DATE,
        v_fecha_vencimiento, p_vigencia_meses, 'VIGENTE', p_observaciones, p_importe,
        'N', p_usuario_responsable, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    ) RETURNING id_dictamen INTO v_id_dictamen;

    RETURN QUERY SELECT true, 'Dictamen creado exitosamente', v_id_dictamen, v_folio_dictamen;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Error al crear dictamen: ' || SQLERRM, NULL::INTEGER, NULL::VARCHAR;
END;
$$;

-- SP 4: ACTUALIZAR DICTAMEN
CREATE OR REPLACE FUNCTION SP_DICTAMEN_UPDATE(
    p_id_dictamen INTEGER,
    p_propietario VARCHAR(200) DEFAULT NULL,
    p_rfc VARCHAR(15) DEFAULT NULL,
    p_domicilio_propietario VARCHAR(500) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_clasificacion VARCHAR(100) DEFAULT NULL,
    p_ubicacion VARCHAR(500) DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_cp VARCHAR(10) DEFAULT NULL,
    p_medidas VARCHAR(100) DEFAULT NULL,
    p_superficie DECIMAL(10,2) DEFAULT NULL,
    p_material VARCHAR(100) DEFAULT NULL,
    p_iluminacion VARCHAR(50) DEFAULT NULL,
    p_estatus VARCHAR(30) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_importe DECIMAL(15,2) DEFAULT NULL,
    p_usuario_responsable VARCHAR(50)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE dictamenes_anuncios SET
        propietario = COALESCE(p_propietario, propietario),
        rfc = COALESCE(p_rfc, rfc),
        domicilio_propietario = COALESCE(p_domicilio_propietario, domicilio_propietario),
        telefono = COALESCE(p_telefono, telefono),
        email = COALESCE(p_email, email),
        clasificacion = COALESCE(p_clasificacion, clasificacion),
        ubicacion = COALESCE(p_ubicacion, ubicacion),
        colonia = COALESCE(p_colonia, colonia),
        cp = COALESCE(p_cp, cp),
        medidas = COALESCE(p_medidas, medidas),
        superficie = COALESCE(p_superficie, superficie),
        material = COALESCE(p_material, material),
        iluminacion = COALESCE(p_iluminacion, iluminacion),
        estatus = COALESCE(p_estatus, estatus),
        observaciones = COALESCE(p_observaciones, observaciones),
        importe = COALESCE(p_importe, importe),
        fecha_modificacion = CURRENT_TIMESTAMP
    WHERE id_dictamen = p_id_dictamen;

    IF FOUND THEN
        -- Registrar modificación en historial
        INSERT INTO historial_dictamenes (
            id_dictamen, accion, descripcion, usuario, fecha_accion
        ) VALUES (
            p_id_dictamen, 'MODIFICACION',
            'Dictamen modificado por usuario: ' || p_usuario_responsable,
            p_usuario_responsable, CURRENT_TIMESTAMP
        );

        RETURN QUERY SELECT true, 'Dictamen actualizado exitosamente';
    ELSE
        RETURN QUERY SELECT false, 'Dictamen no encontrado';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Error al actualizar dictamen: ' || SQLERRM;
END;
$$;

-- SP 5: CAMBIAR ESTATUS DE DICTAMEN
CREATE OR REPLACE FUNCTION sp_dictamen_cambiar_estatus(
    p_id_dictamen INTEGER,
    p_nuevo_estatus VARCHAR(30),
    p_observaciones TEXT DEFAULT NULL,
    p_usuario_responsable VARCHAR(50)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar estatus permitidos
    IF p_nuevo_estatus NOT IN ('VIGENTE', 'VENCIDO', 'CANCELADO', 'RENOVADO') THEN
        RETURN QUERY SELECT false, 'Estatus no válido. Debe ser: VIGENTE, VENCIDO, CANCELADO, RENOVADO';
        RETURN;
    END IF;

    UPDATE dictamenes_anuncios SET
        estatus = p_nuevo_estatus,
        observaciones = COALESCE(p_observaciones, observaciones),
        fecha_modificacion = CURRENT_TIMESTAMP
    WHERE id_dictamen = p_id_dictamen;

    IF FOUND THEN
        -- Registrar cambio de estatus en historial
        INSERT INTO historial_dictamenes (
            id_dictamen, accion, descripcion, usuario, fecha_accion
        ) VALUES (
            p_id_dictamen, 'CAMBIO_ESTATUS',
            'Estatus cambiado a: ' || p_nuevo_estatus ||
            CASE WHEN p_observaciones IS NOT NULL THEN '. Observaciones: ' || p_observaciones ELSE '' END,
            p_usuario_responsable, CURRENT_TIMESTAMP
        );

        RETURN QUERY SELECT true, 'Estatus actualizado exitosamente a: ' || p_nuevo_estatus;
    ELSE
        RETURN QUERY SELECT false, 'Dictamen no encontrado';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Error al cambiar estatus: ' || SQLERRM;
END;
$$;

-- SP 6: ESTADÍSTICAS DE DICTÁMENES
CREATE OR REPLACE FUNCTION sp_dictamen_estadisticas(
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL
)
RETURNS TABLE (
    total_dictamenes INTEGER,
    dictamenes_vigentes INTEGER,
    dictamenes_vencidos INTEGER,
    dictamenes_cancelados INTEGER,
    dictamenes_renovados INTEGER,
    importe_total DECIMAL(15,2),
    importe_pagado DECIMAL(15,2),
    importe_pendiente DECIMAL(15,2),
    promedio_vigencia DECIMAL(10,2),
    dictamenes_mes_actual INTEGER,
    vencimientos_proximos INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_where_clause TEXT := '';
BEGIN
    -- Construir filtros de fecha
    IF p_fecha_inicio IS NOT NULL THEN
        v_where_clause := v_where_clause || ' AND d.fecha_creacion >= ''' || p_fecha_inicio || '''';
    END IF;

    IF p_fecha_fin IS NOT NULL THEN
        v_where_clause := v_where_clause || ' AND d.fecha_creacion <= ''' || p_fecha_fin || '''';
    END IF;

    RETURN QUERY EXECUTE '
    SELECT
        COUNT(*)::INTEGER as total_dictamenes,
        COUNT(CASE WHEN d.estatus = ''VIGENTE'' THEN 1 END)::INTEGER as dictamenes_vigentes,
        COUNT(CASE WHEN d.estatus = ''VENCIDO'' THEN 1 END)::INTEGER as dictamenes_vencidos,
        COUNT(CASE WHEN d.estatus = ''CANCELADO'' THEN 1 END)::INTEGER as dictamenes_cancelados,
        COUNT(CASE WHEN d.estatus = ''RENOVADO'' THEN 1 END)::INTEGER as dictamenes_renovados,

        COALESCE(SUM(d.importe), 0) as importe_total,
        COALESCE(SUM(CASE WHEN d.pagado = ''S'' THEN d.importe ELSE 0 END), 0) as importe_pagado,
        COALESCE(SUM(CASE WHEN d.pagado = ''N'' THEN d.importe ELSE 0 END), 0) as importe_pendiente,

        CASE
            WHEN COUNT(*) > 0 THEN ROUND(AVG(d.vigencia_meses), 2)
            ELSE 0
        END as promedio_vigencia,

        COUNT(CASE WHEN DATE_TRUNC(''month'', d.fecha_creacion) = DATE_TRUNC(''month'', CURRENT_DATE) THEN 1 END)::INTEGER as dictamenes_mes_actual,

        COUNT(CASE WHEN d.fecha_vencimiento BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL ''30 days'' AND d.estatus = ''VIGENTE'' THEN 1 END)::INTEGER as vencimientos_proximos

    FROM dictamenes_anuncios d
    WHERE 1=1 ' || v_where_clause;
END;
$$;

-- =====================================================
-- COMENTARIOS Y DOCUMENTACIÓN
-- =====================================================

COMMENT ON FUNCTION sp_dictamen_list IS 'Lista dictámenes de anuncios con paginación y filtros múltiples';
COMMENT ON FUNCTION sp_dictamen_detalle IS 'Obtiene detalle completo de un dictamen específico';
COMMENT ON FUNCTION SP_DICTAMEN_CREATE IS 'Crea nuevo dictamen con generación automática de folio';
COMMENT ON FUNCTION SP_DICTAMEN_UPDATE IS 'Actualiza datos de dictamen existente con historial';
COMMENT ON FUNCTION sp_dictamen_cambiar_estatus IS 'Cambia estatus de dictamen con validaciones';
COMMENT ON FUNCTION sp_dictamen_estadisticas IS 'Genera estadísticas del módulo de dictámenes';

-- =====================================================
-- ÍNDICES RECOMENDADOS PARA OPTIMIZACIÓN
-- =====================================================

-- CREATE INDEX IF NOT EXISTS idx_dictamenes_numero_anuncio ON dictamenes_anuncios(numero_anuncio);
-- CREATE INDEX IF NOT EXISTS idx_dictamenes_propietario ON dictamenes_anuncios(propietario);
-- CREATE INDEX IF NOT EXISTS idx_dictamenes_estatus ON dictamenes_anuncios(estatus);
-- CREATE INDEX IF NOT EXISTS idx_dictamenes_fecha_vencimiento ON dictamenes_anuncios(fecha_vencimiento, estatus);
-- CREATE INDEX IF NOT EXISTS idx_dictamenes_fecha_creacion ON dictamenes_anuncios(fecha_creacion);