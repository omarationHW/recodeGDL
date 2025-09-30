-- =====================================================
-- STORED PROCEDURES: DICTÁMENES DE USO DE SUELO
-- Módulo: Licencias - HARWEB Guadalajara
-- Descripción: Gestión de constancias de uso de suelo
-- Fecha: 2025-09-29
-- Versión: 1.0
-- =====================================================

-- SP 1: LISTAR DICTÁMENES DE USO DE SUELO CON PAGINACIÓN
CREATE OR REPLACE FUNCTION sp_dictamenuso_list(
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0,
    p_axo INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_solicitante VARCHAR(200) DEFAULT '',
    p_ubicacion VARCHAR(500) DEFAULT '',
    p_estatus VARCHAR(30) DEFAULT ''
)
RETURNS TABLE (
    id_dictamen_uso INTEGER,
    axo INTEGER,
    folio INTEGER,
    folio_completo VARCHAR(20),
    fecha_solicitud DATE,
    fecha_dictamen DATE,
    fecha_vencimiento DATE,
    solicitante VARCHAR(200),
    rfc VARCHAR(15),
    ubicacion_predio VARCHAR(500),
    colonia VARCHAR(100),
    cp VARCHAR(10),
    superficie_terreno DECIMAL(10,2),
    superficie_construida DECIMAL(10,2),
    uso_actual VARCHAR(200),
    uso_solicitado VARCHAR(200),
    zonificacion VARCHAR(100),
    dictamen_resultado VARCHAR(100),
    estatus VARCHAR(30),
    observaciones TEXT,
    importe DECIMAL(15,2),
    pagado CHAR(1),
    fecha_pago DATE,
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
    IF p_axo IS NOT NULL THEN
        v_where := v_where || ' AND d.axo = ' || p_axo;
    END IF;

    IF p_folio IS NOT NULL THEN
        v_where := v_where || ' AND d.folio = ' || p_folio;
    END IF;

    IF p_solicitante != '' THEN
        v_where := v_where || ' AND UPPER(d.solicitante) LIKE UPPER(''%' || p_solicitante || '%'')';
    END IF;

    IF p_ubicacion != '' THEN
        v_where := v_where || ' AND UPPER(d.ubicacion_predio) LIKE UPPER(''%' || p_ubicacion || '%'')';
    END IF;

    IF p_estatus != '' THEN
        v_where := v_where || ' AND d.estatus = ''' || p_estatus || '''';
    END IF;

    -- Obtener total de registros
    v_sql := 'SELECT COUNT(*) FROM dictamenes_uso_suelo d WHERE 1=1 ' || v_where;
    EXECUTE v_sql INTO v_total;

    -- Query principal con paginación
    v_sql := '
    SELECT
        d.id_dictamen_uso,
        d.axo,
        d.folio,
        d.axo || ''-'' || LPAD(d.folio::TEXT, 4, ''0'') as folio_completo,
        d.fecha_solicitud,
        d.fecha_dictamen,
        d.fecha_vencimiento,
        d.solicitante,
        d.rfc,
        d.ubicacion_predio,
        d.colonia,
        d.cp,
        d.superficie_terreno,
        d.superficie_construida,
        d.uso_actual,
        d.uso_solicitado,
        d.zonificacion,
        d.dictamen_resultado,
        d.estatus,
        d.observaciones,
        d.importe,
        d.pagado,
        d.fecha_pago,
        d.usuario_responsable,
        d.fecha_creacion,
        d.fecha_modificacion,
        ' || v_total || ' as total_registros
    FROM dictamenes_uso_suelo d
    WHERE 1=1 ' || v_where || '
    ORDER BY d.fecha_creacion DESC, d.axo DESC, d.folio DESC
    LIMIT ' || p_limite || ' OFFSET ' || p_offset;

    RETURN QUERY EXECUTE v_sql;
END;
$$;

-- SP 2: OBTENER DETALLE DE DICTAMEN USO DE SUELO
CREATE OR REPLACE FUNCTION sp_dictamenuso_detalle(
    p_id_dictamen_uso INTEGER
)
RETURNS TABLE (
    id_dictamen_uso INTEGER,
    axo INTEGER,
    folio INTEGER,
    folio_completo VARCHAR(20),
    fecha_solicitud DATE,
    fecha_dictamen DATE,
    fecha_vencimiento DATE,
    vigencia_meses INTEGER,
    solicitante VARCHAR(200),
    rfc VARCHAR(15),
    curp VARCHAR(20),
    domicilio_solicitante VARCHAR(500),
    telefono VARCHAR(20),
    email VARCHAR(100),
    ubicacion_predio VARCHAR(500),
    colonia VARCHAR(100),
    municipio VARCHAR(100),
    cp VARCHAR(10),
    superficie_terreno DECIMAL(10,2),
    superficie_construida DECIMAL(10,2),
    uso_actual VARCHAR(200),
    uso_solicitado VARCHAR(200),
    zonificacion VARCHAR(100),
    densidad_permitida VARCHAR(50),
    coeficiente_ocupacion DECIMAL(5,2),
    coeficiente_utilizacion DECIMAL(5,2),
    dictamen_resultado VARCHAR(100),
    restricciones TEXT,
    condicionantes TEXT,
    estatus VARCHAR(30),
    observaciones TEXT,
    importe DECIMAL(15,2),
    pagado CHAR(1),
    fecha_pago DATE,
    recibo_pago VARCHAR(50),
    usuario_responsable VARCHAR(50),
    fecha_creacion TIMESTAMP,
    fecha_modificacion TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_dictamen_uso,
        d.axo,
        d.folio,
        d.axo || '-' || LPAD(d.folio::TEXT, 4, '0') as folio_completo,
        d.fecha_solicitud,
        d.fecha_dictamen,
        d.fecha_vencimiento,
        d.vigencia_meses,
        d.solicitante,
        d.rfc,
        d.curp,
        d.domicilio_solicitante,
        d.telefono,
        d.email,
        d.ubicacion_predio,
        d.colonia,
        d.municipio,
        d.cp,
        d.superficie_terreno,
        d.superficie_construida,
        d.uso_actual,
        d.uso_solicitado,
        d.zonificacion,
        d.densidad_permitida,
        d.coeficiente_ocupacion,
        d.coeficiente_utilizacion,
        d.dictamen_resultado,
        d.restricciones,
        d.condicionantes,
        d.estatus,
        d.observaciones,
        d.importe,
        d.pagado,
        d.fecha_pago,
        d.recibo_pago,
        d.usuario_responsable,
        d.fecha_creacion,
        d.fecha_modificacion
    FROM dictamenes_uso_suelo d
    WHERE d.id_dictamen_uso = p_id_dictamen_uso;
END;
$$;

-- SP 3: CREAR NUEVO DICTAMEN USO DE SUELO
CREATE OR REPLACE FUNCTION sp_dictamenuso_create(
    p_solicitante VARCHAR(200),
    p_rfc VARCHAR(15) DEFAULT NULL,
    p_curp VARCHAR(20) DEFAULT NULL,
    p_domicilio_solicitante VARCHAR(500) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_ubicacion_predio VARCHAR(500),
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_cp VARCHAR(10) DEFAULT NULL,
    p_superficie_terreno DECIMAL(10,2) DEFAULT NULL,
    p_superficie_construida DECIMAL(10,2) DEFAULT NULL,
    p_uso_actual VARCHAR(200) DEFAULT NULL,
    p_uso_solicitado VARCHAR(200),
    p_vigencia_meses INTEGER DEFAULT 24,
    p_observaciones TEXT DEFAULT NULL,
    p_importe DECIMAL(15,2) DEFAULT 0,
    p_usuario_responsable VARCHAR(50)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_dictamen_uso INTEGER,
    folio_completo VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_dictamen_uso INTEGER;
    v_axo INTEGER;
    v_folio INTEGER;
    v_folio_completo VARCHAR(20);
    v_fecha_vencimiento DATE;
BEGIN
    -- Obtener año actual
    v_axo := EXTRACT(YEAR FROM CURRENT_DATE);

    -- Obtener siguiente folio para el año
    SELECT COALESCE(MAX(folio), 0) + 1
    INTO v_folio
    FROM dictamenes_uso_suelo
    WHERE axo = v_axo;

    -- Crear folio completo
    v_folio_completo := v_axo || '-' || LPAD(v_folio::TEXT, 4, '0');

    -- Calcular fecha de vencimiento
    v_fecha_vencimiento := CURRENT_DATE + (p_vigencia_meses || ' months')::INTERVAL;

    -- Insertar dictamen
    INSERT INTO dictamenes_uso_suelo (
        axo, folio, fecha_solicitud, fecha_dictamen, fecha_vencimiento,
        vigencia_meses, solicitante, rfc, curp, domicilio_solicitante,
        telefono, email, ubicacion_predio, colonia, municipio, cp,
        superficie_terreno, superficie_construida, uso_actual, uso_solicitado,
        zonificacion, dictamen_resultado, estatus, observaciones, importe,
        pagado, usuario_responsable, fecha_creacion, fecha_modificacion
    ) VALUES (
        v_axo, v_folio, CURRENT_DATE, CURRENT_DATE, v_fecha_vencimiento,
        p_vigencia_meses, p_solicitante, p_rfc, p_curp, p_domicilio_solicitante,
        p_telefono, p_email, p_ubicacion_predio, p_colonia, 'Guadalajara', p_cp,
        p_superficie_terreno, p_superficie_construida, p_uso_actual, p_uso_solicitado,
        'POR_DETERMINAR', 'FAVORABLE', 'VIGENTE', p_observaciones, p_importe,
        'N', p_usuario_responsable, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    ) RETURNING id_dictamen_uso INTO v_id_dictamen_uso;

    RETURN QUERY SELECT true, 'Constancia de uso de suelo creada exitosamente', v_id_dictamen_uso, v_folio_completo;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Error al crear constancia: ' || SQLERRM, NULL::INTEGER, NULL::VARCHAR;
END;
$$;

-- SP 4: ACTUALIZAR DICTAMEN USO DE SUELO
CREATE OR REPLACE FUNCTION sp_dictamenuso_update(
    p_id_dictamen_uso INTEGER,
    p_solicitante VARCHAR(200) DEFAULT NULL,
    p_rfc VARCHAR(15) DEFAULT NULL,
    p_domicilio_solicitante VARCHAR(500) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_ubicacion_predio VARCHAR(500) DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_cp VARCHAR(10) DEFAULT NULL,
    p_superficie_terreno DECIMAL(10,2) DEFAULT NULL,
    p_superficie_construida DECIMAL(10,2) DEFAULT NULL,
    p_uso_actual VARCHAR(200) DEFAULT NULL,
    p_uso_solicitado VARCHAR(200) DEFAULT NULL,
    p_zonificacion VARCHAR(100) DEFAULT NULL,
    p_dictamen_resultado VARCHAR(100) DEFAULT NULL,
    p_restricciones TEXT DEFAULT NULL,
    p_condicionantes TEXT DEFAULT NULL,
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
    UPDATE dictamenes_uso_suelo SET
        solicitante = COALESCE(p_solicitante, solicitante),
        rfc = COALESCE(p_rfc, rfc),
        domicilio_solicitante = COALESCE(p_domicilio_solicitante, domicilio_solicitante),
        telefono = COALESCE(p_telefono, telefono),
        email = COALESCE(p_email, email),
        ubicacion_predio = COALESCE(p_ubicacion_predio, ubicacion_predio),
        colonia = COALESCE(p_colonia, colonia),
        cp = COALESCE(p_cp, cp),
        superficie_terreno = COALESCE(p_superficie_terreno, superficie_terreno),
        superficie_construida = COALESCE(p_superficie_construida, superficie_construida),
        uso_actual = COALESCE(p_uso_actual, uso_actual),
        uso_solicitado = COALESCE(p_uso_solicitado, uso_solicitado),
        zonificacion = COALESCE(p_zonificacion, zonificacion),
        dictamen_resultado = COALESCE(p_dictamen_resultado, dictamen_resultado),
        restricciones = COALESCE(p_restricciones, restricciones),
        condicionantes = COALESCE(p_condicionantes, condicionantes),
        estatus = COALESCE(p_estatus, estatus),
        observaciones = COALESCE(p_observaciones, observaciones),
        importe = COALESCE(p_importe, importe),
        fecha_modificacion = CURRENT_TIMESTAMP
    WHERE id_dictamen_uso = p_id_dictamen_uso;

    IF FOUND THEN
        -- Registrar modificación en historial
        INSERT INTO historial_dictamenes_uso (
            id_dictamen_uso, accion, descripcion, usuario, fecha_accion
        ) VALUES (
            p_id_dictamen_uso, 'MODIFICACION',
            'Constancia modificada por usuario: ' || p_usuario_responsable,
            p_usuario_responsable, CURRENT_TIMESTAMP
        );

        RETURN QUERY SELECT true, 'Constancia actualizada exitosamente';
    ELSE
        RETURN QUERY SELECT false, 'Constancia no encontrada';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Error al actualizar constancia: ' || SQLERRM;
END;
$$;

-- SP 5: REGISTRAR PAGO DE DICTAMEN
CREATE OR REPLACE FUNCTION sp_dictamenuso_registrar_pago(
    p_id_dictamen_uso INTEGER,
    p_fecha_pago DATE DEFAULT CURRENT_DATE,
    p_recibo_pago VARCHAR(50),
    p_usuario_responsable VARCHAR(50)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE dictamenes_uso_suelo SET
        pagado = 'S',
        fecha_pago = p_fecha_pago,
        recibo_pago = p_recibo_pago,
        fecha_modificacion = CURRENT_TIMESTAMP
    WHERE id_dictamen_uso = p_id_dictamen_uso;

    IF FOUND THEN
        -- Registrar pago en historial
        INSERT INTO historial_dictamenes_uso (
            id_dictamen_uso, accion, descripcion, usuario, fecha_accion
        ) VALUES (
            p_id_dictamen_uso, 'PAGO_REGISTRADO',
            'Pago registrado. Recibo: ' || p_recibo_pago,
            p_usuario_responsable, CURRENT_TIMESTAMP
        );

        RETURN QUERY SELECT true, 'Pago registrado exitosamente';
    ELSE
        RETURN QUERY SELECT false, 'Constancia no encontrada';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Error al registrar pago: ' || SQLERRM;
END;
$$;

-- SP 6: ESTADÍSTICAS DE DICTÁMENES USO DE SUELO
CREATE OR REPLACE FUNCTION sp_dictamenuso_estadisticas(
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL
)
RETURNS TABLE (
    total_dictamenes INTEGER,
    dictamenes_vigentes INTEGER,
    dictamenes_vencidos INTEGER,
    dictamenes_favorables INTEGER,
    dictamenes_desfavorables INTEGER,
    importe_total DECIMAL(15,2),
    importe_pagado DECIMAL(15,2),
    importe_pendiente DECIMAL(15,2),
    promedio_superficie_terreno DECIMAL(10,2),
    promedio_superficie_construida DECIMAL(10,2),
    dictamenes_mes_actual INTEGER,
    usos_mas_solicitados TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_where_clause TEXT := '';
    v_usos_populares TEXT;
BEGIN
    -- Construir filtros de fecha
    IF p_fecha_inicio IS NOT NULL THEN
        v_where_clause := v_where_clause || ' AND d.fecha_creacion >= ''' || p_fecha_inicio || '''';
    END IF;

    IF p_fecha_fin IS NOT NULL THEN
        v_where_clause := v_where_clause || ' AND d.fecha_creacion <= ''' || p_fecha_fin || '''';
    END IF;

    -- Obtener usos más solicitados
    SELECT STRING_AGG(uso_count.uso_solicitado || ' (' || uso_count.cantidad || ')', ', ')
    INTO v_usos_populares
    FROM (
        SELECT uso_solicitado, COUNT(*) as cantidad
        FROM dictamenes_uso_suelo
        WHERE uso_solicitado IS NOT NULL
        GROUP BY uso_solicitado
        ORDER BY COUNT(*) DESC
        LIMIT 5
    ) uso_count;

    RETURN QUERY EXECUTE '
    SELECT
        COUNT(*)::INTEGER as total_dictamenes,
        COUNT(CASE WHEN d.estatus = ''VIGENTE'' THEN 1 END)::INTEGER as dictamenes_vigentes,
        COUNT(CASE WHEN d.estatus = ''VENCIDO'' THEN 1 END)::INTEGER as dictamenes_vencidos,
        COUNT(CASE WHEN d.dictamen_resultado = ''FAVORABLE'' THEN 1 END)::INTEGER as dictamenes_favorables,
        COUNT(CASE WHEN d.dictamen_resultado = ''DESFAVORABLE'' THEN 1 END)::INTEGER as dictamenes_desfavorables,

        COALESCE(SUM(d.importe), 0) as importe_total,
        COALESCE(SUM(CASE WHEN d.pagado = ''S'' THEN d.importe ELSE 0 END), 0) as importe_pagado,
        COALESCE(SUM(CASE WHEN d.pagado = ''N'' THEN d.importe ELSE 0 END), 0) as importe_pendiente,

        CASE
            WHEN COUNT(*) > 0 THEN ROUND(AVG(d.superficie_terreno), 2)
            ELSE 0
        END as promedio_superficie_terreno,

        CASE
            WHEN COUNT(*) > 0 THEN ROUND(AVG(d.superficie_construida), 2)
            ELSE 0
        END as promedio_superficie_construida,

        COUNT(CASE WHEN DATE_TRUNC(''month'', d.fecha_creacion) = DATE_TRUNC(''month'', CURRENT_DATE) THEN 1 END)::INTEGER as dictamenes_mes_actual,

        ''' || COALESCE(v_usos_populares, 'Sin datos') || ''' as usos_mas_solicitados

    FROM dictamenes_uso_suelo d
    WHERE 1=1 ' || v_where_clause;
END;
$$;

-- =====================================================
-- COMENTARIOS Y DOCUMENTACIÓN
-- =====================================================

COMMENT ON FUNCTION sp_dictamenuso_list IS 'Lista constancias de uso de suelo con paginación y filtros';
COMMENT ON FUNCTION sp_dictamenuso_detalle IS 'Obtiene detalle completo de constancia de uso de suelo';
COMMENT ON FUNCTION sp_dictamenuso_create IS 'Crea nueva constancia con folio automático';
COMMENT ON FUNCTION sp_dictamenuso_update IS 'Actualiza constancia existente con historial';
COMMENT ON FUNCTION sp_dictamenuso_registrar_pago IS 'Registra pago de constancia';
COMMENT ON FUNCTION sp_dictamenuso_estadisticas IS 'Genera estadísticas del módulo de uso de suelo';

-- =====================================================
-- ÍNDICES RECOMENDADOS PARA OPTIMIZACIÓN
-- =====================================================

-- CREATE INDEX IF NOT EXISTS idx_dictamenes_uso_axo_folio ON dictamenes_uso_suelo(axo, folio);
-- CREATE INDEX IF NOT EXISTS idx_dictamenes_uso_solicitante ON dictamenes_uso_suelo(solicitante);
-- CREATE INDEX IF NOT EXISTS idx_dictamenes_uso_estatus ON dictamenes_uso_suelo(estatus);
-- CREATE INDEX IF NOT EXISTS idx_dictamenes_uso_fecha_vencimiento ON dictamenes_uso_suelo(fecha_vencimiento, estatus);
-- CREATE INDEX IF NOT EXISTS idx_dictamenes_uso_fecha_creacion ON dictamenes_uso_suelo(fecha_creacion);