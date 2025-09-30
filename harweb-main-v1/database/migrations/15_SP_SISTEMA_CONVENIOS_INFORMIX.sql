-- =====================================================
-- STORED PROCEDURES: SISTEMA DE CONVENIOS DE PAGO
-- Módulo: Licencias - HARWEB Guadalajara
-- Descripción: Sistema completo de convenios con intereses y parcialidades
-- Fecha: 2025-09-29
-- Versión: 1.0
-- =====================================================

-- SP 1: LISTAR CONVENIOS CON PAGINACIÓN Y FILTROS
CREATE OR REPLACE FUNCTION sp_sistema_convenios_list(
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0,
    p_filtro TEXT DEFAULT '',
    p_estatus VARCHAR(20) DEFAULT 'TODOS',
    p_tipo_convenio VARCHAR(30) DEFAULT 'TODOS',
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL
)
RETURNS TABLE (
    id_convenio INTEGER,
    numero_convenio VARCHAR(50),
    numero_licencia VARCHAR(50),
    nombre_contribuyente VARCHAR(200),
    rfc VARCHAR(15),
    tipo_convenio VARCHAR(30),
    monto_total DECIMAL(15,2),
    monto_pagado DECIMAL(15,2),
    monto_pendiente DECIMAL(15,2),
    numero_parcialidades INTEGER,
    parcialidades_pagadas INTEGER,
    parcialidades_pendientes INTEGER,
    fecha_convenio DATE,
    fecha_vencimiento DATE,
    tasa_interes DECIMAL(5,2),
    estatus VARCHAR(20),
    observaciones TEXT,
    fecha_ultimo_pago DATE,
    porcentaje_avance DECIMAL(5,2),
    dias_vencido INTEGER,
    usuario_responsable VARCHAR(50),
    fecha_creacion TIMESTAMP,
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
    IF p_filtro != '' THEN
        v_where := v_where || ' AND (UPPER(c.numero_convenio) LIKE UPPER(''%' || p_filtro || '%'')
                                 OR UPPER(c.numero_licencia) LIKE UPPER(''%' || p_filtro || '%'')
                                 OR UPPER(c.nombre_contribuyente) LIKE UPPER(''%' || p_filtro || '%'')
                                 OR UPPER(c.rfc) LIKE UPPER(''%' || p_filtro || '%''))';
    END IF;

    IF p_estatus != 'TODOS' THEN
        v_where := v_where || ' AND c.estatus = ''' || p_estatus || '''';
    END IF;

    IF p_tipo_convenio != 'TODOS' THEN
        v_where := v_where || ' AND c.tipo_convenio = ''' || p_tipo_convenio || '''';
    END IF;

    IF p_fecha_inicio IS NOT NULL THEN
        v_where := v_where || ' AND c.fecha_convenio >= ''' || p_fecha_inicio || '''';
    END IF;

    IF p_fecha_fin IS NOT NULL THEN
        v_where := v_where || ' AND c.fecha_convenio <= ''' || p_fecha_fin || '''';
    END IF;

    -- Obtener total de registros
    v_sql := 'SELECT COUNT(*) FROM convenios_pago c WHERE 1=1 ' || v_where;
    EXECUTE v_sql INTO v_total;

    -- Query principal con paginación
    v_sql := '
    SELECT
        c.id_convenio,
        c.numero_convenio,
        c.numero_licencia,
        c.nombre_contribuyente,
        c.rfc,
        c.tipo_convenio,
        c.monto_total,
        COALESCE(
            (SELECT SUM(p.monto_pago)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio AND p.estatus = ''PAGADO''),
            0
        ) as monto_pagado,
        c.monto_total - COALESCE(
            (SELECT SUM(p.monto_pago)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio AND p.estatus = ''PAGADO''),
            0
        ) as monto_pendiente,
        c.numero_parcialidades,
        COALESCE(
            (SELECT COUNT(*)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio AND p.estatus = ''PAGADO''),
            0
        ) as parcialidades_pagadas,
        c.numero_parcialidades - COALESCE(
            (SELECT COUNT(*)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio AND p.estatus = ''PAGADO''),
            0
        ) as parcialidades_pendientes,
        c.fecha_convenio,
        c.fecha_vencimiento,
        c.tasa_interes,
        c.estatus,
        c.observaciones,
        (SELECT MAX(p.fecha_pago)
         FROM parcialidades_convenio p
         WHERE p.id_convenio = c.id_convenio AND p.estatus = ''PAGADO'') as fecha_ultimo_pago,
        CASE
            WHEN c.numero_parcialidades > 0 THEN
                ROUND(
                    (COALESCE(
                        (SELECT COUNT(*)
                         FROM parcialidades_convenio p
                         WHERE p.id_convenio = c.id_convenio AND p.estatus = ''PAGADO''),
                        0
                    ) * 100.0 / c.numero_parcialidades),
                    2
                )
            ELSE 0
        END as porcentaje_avance,
        CASE
            WHEN c.fecha_vencimiento < CURRENT_DATE AND c.estatus = ''ACTIVO''
            THEN EXTRACT(DAY FROM CURRENT_DATE - c.fecha_vencimiento)::INTEGER
            ELSE 0
        END as dias_vencido,
        c.usuario_responsable,
        c.fecha_creacion,
        ' || v_total || ' as total_registros
    FROM convenios_pago c
    WHERE 1=1 ' || v_where || '
    ORDER BY c.fecha_convenio DESC, c.numero_convenio
    LIMIT ' || p_limite || ' OFFSET ' || p_offset;

    RETURN QUERY EXECUTE v_sql;
END;
$$;

-- SP 2: OBTENER DETALLE COMPLETO DE CONVENIO
CREATE OR REPLACE FUNCTION sp_sistema_convenios_detalle(
    p_id_convenio INTEGER
)
RETURNS TABLE (
    -- Datos del convenio
    id_convenio INTEGER,
    numero_convenio VARCHAR(50),
    numero_licencia VARCHAR(50),
    nombre_contribuyente VARCHAR(200),
    rfc VARCHAR(15),
    curp VARCHAR(20),
    domicilio TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    tipo_convenio VARCHAR(30),
    concepto_adeudo TEXT,
    monto_original DECIMAL(15,2),
    monto_total DECIMAL(15,2),
    monto_pagado DECIMAL(15,2),
    monto_pendiente DECIMAL(15,2),
    numero_parcialidades INTEGER,
    parcialidades_pagadas INTEGER,
    fecha_convenio DATE,
    fecha_vencimiento DATE,
    tasa_interes DECIMAL(5,2),
    forma_pago VARCHAR(30),
    dia_pago INTEGER,
    estatus VARCHAR(20),
    observaciones TEXT,
    clausulas_especiales TEXT,
    usuario_responsable VARCHAR(50),
    fecha_creacion TIMESTAMP,
    fecha_modificacion TIMESTAMP,
    -- Estadísticas calculadas
    porcentaje_avance DECIMAL(5,2),
    dias_vencido INTEGER,
    interes_total DECIMAL(15,2),
    proxima_parcialidad_fecha DATE,
    proxima_parcialidad_monto DECIMAL(15,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_convenio,
        c.numero_convenio,
        c.numero_licencia,
        c.nombre_contribuyente,
        c.rfc,
        c.curp,
        c.domicilio,
        c.telefono,
        c.email,
        c.tipo_convenio,
        c.concepto_adeudo,
        c.monto_original,
        c.monto_total,
        COALESCE(
            (SELECT SUM(p.monto_pago)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio AND p.estatus = 'PAGADO'),
            0
        ) as monto_pagado,
        c.monto_total - COALESCE(
            (SELECT SUM(p.monto_pago)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio AND p.estatus = 'PAGADO'),
            0
        ) as monto_pendiente,
        c.numero_parcialidades,
        COALESCE(
            (SELECT COUNT(*)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio AND p.estatus = 'PAGADO'),
            0
        ) as parcialidades_pagadas,
        c.fecha_convenio,
        c.fecha_vencimiento,
        c.tasa_interes,
        c.forma_pago,
        c.dia_pago,
        c.estatus,
        c.observaciones,
        c.clausulas_especiales,
        c.usuario_responsable,
        c.fecha_creacion,
        c.fecha_modificacion,
        -- Cálculos
        CASE
            WHEN c.numero_parcialidades > 0 THEN
                ROUND(
                    (COALESCE(
                        (SELECT COUNT(*)
                         FROM parcialidades_convenio p
                         WHERE p.id_convenio = c.id_convenio AND p.estatus = 'PAGADO'),
                        0
                    ) * 100.0 / c.numero_parcialidades),
                    2
                )
            ELSE 0
        END as porcentaje_avance,
        CASE
            WHEN c.fecha_vencimiento < CURRENT_DATE AND c.estatus = 'ACTIVO'
            THEN EXTRACT(DAY FROM CURRENT_DATE - c.fecha_vencimiento)::INTEGER
            ELSE 0
        END as dias_vencido,
        COALESCE(
            (SELECT SUM(p.interes_generado)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio),
            0
        ) as interes_total,
        (SELECT MIN(p.fecha_vencimiento)
         FROM parcialidades_convenio p
         WHERE p.id_convenio = c.id_convenio AND p.estatus = 'PENDIENTE') as proxima_parcialidad_fecha,
        (SELECT p.monto_pago
         FROM parcialidades_convenio p
         WHERE p.id_convenio = c.id_convenio AND p.estatus = 'PENDIENTE'
         ORDER BY p.numero_parcialidad LIMIT 1) as proxima_parcialidad_monto
    FROM convenios_pago c
    WHERE c.id_convenio = p_id_convenio;
END;
$$;

-- SP 3: CREAR NUEVO CONVENIO CON PARCIALIDADES
CREATE OR REPLACE FUNCTION sp_sistema_convenios_create(
    p_numero_licencia VARCHAR(50),
    p_nombre_contribuyente VARCHAR(200),
    p_rfc VARCHAR(15),
    p_curp VARCHAR(20) DEFAULT NULL,
    p_domicilio TEXT DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_tipo_convenio VARCHAR(30),
    p_concepto_adeudo TEXT,
    p_monto_original DECIMAL(15,2),
    p_numero_parcialidades INTEGER,
    p_tasa_interes DECIMAL(5,2) DEFAULT 0,
    p_forma_pago VARCHAR(30) DEFAULT 'MENSUAL',
    p_dia_pago INTEGER DEFAULT 15,
    p_observaciones TEXT DEFAULT NULL,
    p_clausulas_especiales TEXT DEFAULT NULL,
    p_usuario_responsable VARCHAR(50)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_convenio INTEGER,
    numero_convenio VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_convenio INTEGER;
    v_numero_convenio VARCHAR(50);
    v_monto_parcialidad DECIMAL(15,2);
    v_fecha_vencimiento DATE;
    v_monto_total DECIMAL(15,2);
    i INTEGER;
BEGIN
    -- Generar número de convenio
    SELECT 'CONV-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' ||
           LPAD((COALESCE(MAX(CAST(SUBSTRING(numero_convenio FROM 10) AS INTEGER)), 0) + 1)::TEXT, 6, '0')
    INTO v_numero_convenio
    FROM convenios_pago
    WHERE numero_convenio LIKE 'CONV-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-%';

    -- Calcular monto total con intereses
    v_monto_total := p_monto_original * (1 + (p_tasa_interes / 100));

    -- Calcular monto por parcialidad
    v_monto_parcialidad := v_monto_total / p_numero_parcialidades;

    -- Calcular fecha de vencimiento (90 días + periodo de parcialidades)
    v_fecha_vencimiento := CURRENT_DATE + INTERVAL '90 days' +
                          (p_numero_parcialidades || ' months')::INTERVAL;

    -- Insertar convenio principal
    INSERT INTO convenios_pago (
        numero_convenio, numero_licencia, nombre_contribuyente, rfc, curp,
        domicilio, telefono, email, tipo_convenio, concepto_adeudo,
        monto_original, monto_total, numero_parcialidades, fecha_convenio,
        fecha_vencimiento, tasa_interes, forma_pago, dia_pago,
        estatus, observaciones, clausulas_especiales, usuario_responsable,
        fecha_creacion, fecha_modificacion
    ) VALUES (
        v_numero_convenio, p_numero_licencia, p_nombre_contribuyente, p_rfc, p_curp,
        p_domicilio, p_telefono, p_email, p_tipo_convenio, p_concepto_adeudo,
        p_monto_original, v_monto_total, p_numero_parcialidades, CURRENT_DATE,
        v_fecha_vencimiento, p_tasa_interes, p_forma_pago, p_dia_pago,
        'ACTIVO', p_observaciones, p_clausulas_especiales, p_usuario_responsable,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    ) RETURNING id_convenio INTO v_id_convenio;

    -- Generar parcialidades
    FOR i IN 1..p_numero_parcialidades LOOP
        INSERT INTO parcialidades_convenio (
            id_convenio, numero_parcialidad, monto_pago, fecha_vencimiento,
            estatus, interes_generado, fecha_creacion
        ) VALUES (
            v_id_convenio,
            i,
            v_monto_parcialidad,
            CURRENT_DATE + (i || ' months')::INTERVAL,
            'PENDIENTE',
            0,
            CURRENT_TIMESTAMP
        );
    END LOOP;

    RETURN QUERY SELECT true, 'Convenio creado exitosamente', v_id_convenio, v_numero_convenio;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Error al crear convenio: ' || SQLERRM, NULL::INTEGER, NULL::VARCHAR;
END;
$$;

-- SP 4: REGISTRAR PAGO DE PARCIALIDAD
CREATE OR REPLACE FUNCTION sp_sistema_convenios_pago_parcialidad(
    p_id_convenio INTEGER,
    p_numero_parcialidad INTEGER,
    p_monto_pagado DECIMAL(15,2),
    p_fecha_pago DATE DEFAULT CURRENT_DATE,
    p_forma_pago VARCHAR(30) DEFAULT 'EFECTIVO',
    p_referencia_pago VARCHAR(100) DEFAULT NULL,
    p_observaciones_pago TEXT DEFAULT NULL,
    p_usuario_cajero VARCHAR(50)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    recibo_pago VARCHAR(50),
    siguiente_parcialidad INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_parcialidad_existe BOOLEAN;
    v_parcialidad_estatus VARCHAR(20);
    v_monto_parcialidad DECIMAL(15,2);
    v_recibo_pago VARCHAR(50);
    v_interes_mora DECIMAL(15,2) := 0;
    v_dias_atraso INTEGER;
    v_fecha_vencimiento DATE;
    v_siguiente_parcialidad INTEGER;
    v_convenio_completo BOOLEAN;
BEGIN
    -- Verificar que existe la parcialidad
    SELECT
        COUNT(*) > 0,
        MAX(estatus),
        MAX(monto_pago),
        MAX(fecha_vencimiento)
    INTO
        v_parcialidad_existe,
        v_parcialidad_estatus,
        v_monto_parcialidad,
        v_fecha_vencimiento
    FROM parcialidades_convenio
    WHERE id_convenio = p_id_convenio AND numero_parcialidad = p_numero_parcialidad;

    IF NOT v_parcialidad_existe THEN
        RETURN QUERY SELECT false, 'Parcialidad no encontrada', NULL::VARCHAR, NULL::INTEGER;
        RETURN;
    END IF;

    IF v_parcialidad_estatus = 'PAGADO' THEN
        RETURN QUERY SELECT false, 'Parcialidad ya está pagada', NULL::VARCHAR, NULL::INTEGER;
        RETURN;
    END IF;

    -- Calcular interés moratorio si hay atraso
    IF p_fecha_pago > v_fecha_vencimiento THEN
        v_dias_atraso := EXTRACT(DAY FROM p_fecha_pago - v_fecha_vencimiento);
        v_interes_mora := v_monto_parcialidad * 0.02 * (v_dias_atraso / 30.0); -- 2% mensual
    END IF;

    -- Generar número de recibo
    SELECT 'REC-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' ||
           LPAD((COALESCE(MAX(CAST(SUBSTRING(recibo_pago FROM 13) AS INTEGER)), 0) + 1)::TEXT, 4, '0')
    INTO v_recibo_pago
    FROM pagos_parcialidades
    WHERE recibo_pago LIKE 'REC-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-%';

    -- Actualizar parcialidad
    UPDATE parcialidades_convenio SET
        estatus = 'PAGADO',
        fecha_pago = p_fecha_pago,
        monto_pagado = p_monto_pagado,
        interes_generado = v_interes_mora,
        fecha_modificacion = CURRENT_TIMESTAMP
    WHERE id_convenio = p_id_convenio AND numero_parcialidad = p_numero_parcialidad;

    -- Registrar el pago
    INSERT INTO pagos_parcialidades (
        id_convenio, numero_parcialidad, recibo_pago, monto_pago,
        interes_mora, fecha_pago, forma_pago, referencia_pago,
        observaciones, usuario_cajero, fecha_creacion
    ) VALUES (
        p_id_convenio, p_numero_parcialidad, v_recibo_pago, p_monto_pagado,
        v_interes_mora, p_fecha_pago, p_forma_pago, p_referencia_pago,
        p_observaciones_pago, p_usuario_cajero, CURRENT_TIMESTAMP
    );

    -- Buscar siguiente parcialidad pendiente
    SELECT MIN(numero_parcialidad)
    INTO v_siguiente_parcialidad
    FROM parcialidades_convenio
    WHERE id_convenio = p_id_convenio AND estatus = 'PENDIENTE';

    -- Verificar si el convenio está completamente pagado
    SELECT COUNT(*) = 0
    INTO v_convenio_completo
    FROM parcialidades_convenio
    WHERE id_convenio = p_id_convenio AND estatus = 'PENDIENTE';

    -- Actualizar estatus del convenio si está completo
    IF v_convenio_completo THEN
        UPDATE convenios_pago SET
            estatus = 'LIQUIDADO',
            fecha_modificacion = CURRENT_TIMESTAMP
        WHERE id_convenio = p_id_convenio;
    END IF;

    RETURN QUERY SELECT
        true,
        'Pago registrado exitosamente' ||
        CASE WHEN v_interes_mora > 0 THEN ' (con interés moratorio: $' || v_interes_mora || ')' ELSE '' END,
        v_recibo_pago,
        v_siguiente_parcialidad;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Error al procesar pago: ' || SQLERRM, NULL::VARCHAR, NULL::INTEGER;
END;
$$;

-- SP 5: MODIFICAR CONVENIO EXISTENTE
CREATE OR REPLACE FUNCTION sp_sistema_convenios_update(
    p_id_convenio INTEGER,
    p_nombre_contribuyente VARCHAR(200) DEFAULT NULL,
    p_domicilio TEXT DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_clausulas_especiales TEXT DEFAULT NULL,
    p_usuario_modificacion VARCHAR(50)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE convenios_pago SET
        nombre_contribuyente = COALESCE(p_nombre_contribuyente, nombre_contribuyente),
        domicilio = COALESCE(p_domicilio, domicilio),
        telefono = COALESCE(p_telefono, telefono),
        email = COALESCE(p_email, email),
        observaciones = COALESCE(p_observaciones, observaciones),
        clausulas_especiales = COALESCE(p_clausulas_especiales, clausulas_especiales),
        fecha_modificacion = CURRENT_TIMESTAMP
    WHERE id_convenio = p_id_convenio;

    IF FOUND THEN
        -- Registrar modificación en historial
        INSERT INTO historial_convenios (
            id_convenio, accion, descripcion, usuario, fecha_accion
        ) VALUES (
            p_id_convenio, 'MODIFICACION',
            'Convenio modificado por usuario: ' || p_usuario_modificacion,
            p_usuario_modificacion, CURRENT_TIMESTAMP
        );

        RETURN QUERY SELECT true, 'Convenio actualizado exitosamente';
    ELSE
        RETURN QUERY SELECT false, 'Convenio no encontrado';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Error al actualizar convenio: ' || SQLERRM;
END;
$$;

-- SP 6: ESTADÍSTICAS DEL SISTEMA DE CONVENIOS
CREATE OR REPLACE FUNCTION sp_sistema_convenios_estadisticas(
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_tipo_convenio VARCHAR(30) DEFAULT 'TODOS'
)
RETURNS TABLE (
    total_convenios INTEGER,
    convenios_activos INTEGER,
    convenios_liquidados INTEGER,
    convenios_vencidos INTEGER,
    monto_total_convenios DECIMAL(15,2),
    monto_pagado_total DECIMAL(15,2),
    monto_pendiente_total DECIMAL(15,2),
    parcialidades_totales INTEGER,
    parcialidades_pagadas INTEGER,
    parcialidades_vencidas INTEGER,
    promedio_parcialidades DECIMAL(10,2),
    tasa_cumplimiento DECIMAL(5,2),
    interes_total_generado DECIMAL(15,2),
    -- Por tipo de convenio
    convenios_licencias INTEGER,
    convenios_multas INTEGER,
    convenios_otros INTEGER,
    -- Tendencias mensuales
    convenios_mes_actual INTEGER,
    monto_mes_actual DECIMAL(15,2),
    pagos_mes_actual INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_where_clause TEXT := '';
BEGIN
    -- Construir filtros de fecha
    IF p_fecha_inicio IS NOT NULL THEN
        v_where_clause := v_where_clause || ' AND c.fecha_convenio >= ''' || p_fecha_inicio || '''';
    END IF;

    IF p_fecha_fin IS NOT NULL THEN
        v_where_clause := v_where_clause || ' AND c.fecha_convenio <= ''' || p_fecha_fin || '''';
    END IF;

    IF p_tipo_convenio != 'TODOS' THEN
        v_where_clause := v_where_clause || ' AND c.tipo_convenio = ''' || p_tipo_convenio || '''';
    END IF;

    RETURN QUERY
    SELECT
        -- Totales generales
        COUNT(*)::INTEGER as total_convenios,
        COUNT(CASE WHEN c.estatus = 'ACTIVO' THEN 1 END)::INTEGER as convenios_activos,
        COUNT(CASE WHEN c.estatus = 'LIQUIDADO' THEN 1 END)::INTEGER as convenios_liquidados,
        COUNT(CASE WHEN c.estatus = 'ACTIVO' AND c.fecha_vencimiento < CURRENT_DATE THEN 1 END)::INTEGER as convenios_vencidos,

        COALESCE(SUM(c.monto_total), 0) as monto_total_convenios,
        COALESCE(SUM(
            (SELECT SUM(p.monto_pago)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio AND p.estatus = 'PAGADO')
        ), 0) as monto_pagado_total,
        COALESCE(SUM(c.monto_total) - SUM(
            (SELECT COALESCE(SUM(p.monto_pago), 0)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio AND p.estatus = 'PAGADO')
        ), 0) as monto_pendiente_total,

        -- Parcialidades
        COALESCE(SUM(c.numero_parcialidades), 0)::INTEGER as parcialidades_totales,
        COALESCE(SUM(
            (SELECT COUNT(*)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio AND p.estatus = 'PAGADO')
        ), 0)::INTEGER as parcialidades_pagadas,
        COALESCE(SUM(
            (SELECT COUNT(*)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio AND p.estatus = 'PENDIENTE'
             AND p.fecha_vencimiento < CURRENT_DATE)
        ), 0)::INTEGER as parcialidades_vencidas,

        CASE
            WHEN COUNT(*) > 0 THEN ROUND(AVG(c.numero_parcialidades), 2)
            ELSE 0
        END as promedio_parcialidades,

        CASE
            WHEN SUM(c.numero_parcialidades) > 0 THEN
                ROUND(
                    (SUM(
                        (SELECT COUNT(*)
                         FROM parcialidades_convenio p
                         WHERE p.id_convenio = c.id_convenio AND p.estatus = 'PAGADO')
                    ) * 100.0 / SUM(c.numero_parcialidades)),
                    2
                )
            ELSE 0
        END as tasa_cumplimiento,

        COALESCE(SUM(
            (SELECT SUM(p.interes_generado)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio)
        ), 0) as interes_total_generado,

        -- Por tipo
        COUNT(CASE WHEN c.tipo_convenio = 'LICENCIA' THEN 1 END)::INTEGER as convenios_licencias,
        COUNT(CASE WHEN c.tipo_convenio = 'MULTA' THEN 1 END)::INTEGER as convenios_multas,
        COUNT(CASE WHEN c.tipo_convenio NOT IN ('LICENCIA', 'MULTA') THEN 1 END)::INTEGER as convenios_otros,

        -- Mes actual
        COUNT(CASE WHEN DATE_TRUNC('month', c.fecha_convenio) = DATE_TRUNC('month', CURRENT_DATE) THEN 1 END)::INTEGER as convenios_mes_actual,
        COALESCE(SUM(CASE WHEN DATE_TRUNC('month', c.fecha_convenio) = DATE_TRUNC('month', CURRENT_DATE) THEN c.monto_total END), 0) as monto_mes_actual,
        COALESCE(SUM(
            (SELECT COUNT(*)
             FROM parcialidades_convenio p
             WHERE p.id_convenio = c.id_convenio
             AND p.estatus = 'PAGADO'
             AND DATE_TRUNC('month', p.fecha_pago) = DATE_TRUNC('month', CURRENT_DATE))
        ), 0)::INTEGER as pagos_mes_actual

    FROM convenios_pago c
    WHERE 1=1 AND c.estatus IS NOT NULL
    EXECUTE 'WHERE 1=1 ' || v_where_clause;
END;
$$;

-- =====================================================
-- COMENTARIOS Y DOCUMENTACIÓN
-- =====================================================

COMMENT ON FUNCTION sp_sistema_convenios_list IS 'Lista convenios con paginación, filtros y estadísticas calculadas';
COMMENT ON FUNCTION sp_sistema_convenios_detalle IS 'Obtiene detalle completo de un convenio específico con todas sus parcialidades';
COMMENT ON FUNCTION sp_sistema_convenios_create IS 'Crea nuevo convenio con generación automática de parcialidades';
COMMENT ON FUNCTION sp_sistema_convenios_pago_parcialidad IS 'Registra pago de parcialidad con cálculo de intereses moratorios';
COMMENT ON FUNCTION sp_sistema_convenios_update IS 'Modifica datos de convenio existente con historial de cambios';
COMMENT ON FUNCTION sp_sistema_convenios_estadisticas IS 'Genera estadísticas completas del sistema de convenios';

-- =====================================================
-- ÍNDICES RECOMENDADOS PARA OPTIMIZACIÓN
-- =====================================================

-- CREATE INDEX IF NOT EXISTS idx_convenios_fecha_estatus ON convenios_pago(fecha_convenio, estatus);
-- CREATE INDEX IF NOT EXISTS idx_convenios_numero ON convenios_pago(numero_convenio);
-- CREATE INDEX IF NOT EXISTS idx_convenios_licencia ON convenios_pago(numero_licencia);
-- CREATE INDEX IF NOT EXISTS idx_parcialidades_convenio_estatus ON parcialidades_convenio(id_convenio, estatus);
-- CREATE INDEX IF NOT EXISTS idx_parcialidades_fecha_vencimiento ON parcialidades_convenio(fecha_vencimiento, estatus);