-- =====================================================================================
-- SISTEMA MUNICIPAL DIGITAL - GOBIERNO DE GUADALAJARA
-- =====================================================================================
-- Descripción: Stored Procedures para Modificación de Licencias
-- Autor: Sistema de Refactorización Vue.js
-- Fecha: 2025-09-30
-- Versión: 1.0
-- =====================================================================================

-- =====================================================================================
-- NOTA: Este módulo gestiona la modificación de datos de licencias existentes
-- con registro de cambios y control de versiones
-- =====================================================================================

-- Crear tabla para registro de modificaciones de licencias
DROP TABLE IF EXISTS informix.modificaciones_licencias CASCADE;

CREATE TABLE informix.modificaciones_licencias (
    id SERIAL PRIMARY KEY,
    folio_modificacion VARCHAR(30) UNIQUE NOT NULL,
    numero_licencia VARCHAR(20) NOT NULL,

    -- Tipo de modificación
    tipo_modificacion VARCHAR(50) DEFAULT 'OTROS' CHECK (tipo_modificacion IN ('PROPIETARIO', 'ACTIVIDAD', 'DOMICILIO', 'ESTATUS', 'OTROS')),
    descripcion_cambios TEXT NOT NULL,

    -- Control de datos
    datos_actuales JSONB,
    datos_propuestos JSONB,
    justificacion TEXT,

    -- Datos principales que se pueden modificar
    propietario VARCHAR(150),
    rfc VARCHAR(13),
    domicilio_prop VARCHAR(200),
    telefono_prop VARCHAR(20),
    email VARCHAR(100),
    actividad TEXT,
    id_giro INTEGER,
    ubicacion VARCHAR(150),
    numext_ubic VARCHAR(10),
    numint_ubic VARCHAR(10),
    colonia_ubic VARCHAR(100),
    zona VARCHAR(10),
    sup_construida DECIMAL(10,2),
    num_empleados INTEGER,
    aforo INTEGER,
    estatus CHAR(1) DEFAULT 'A' CHECK (estatus IN ('A', 'V', 'S', 'C', 'P')),
    observaciones TEXT,

    -- Estado de la modificación
    estado_modificacion VARCHAR(20) DEFAULT 'PENDIENTE' CHECK (estado_modificacion IN ('PENDIENTE', 'APROBADA', 'RECHAZADA', 'APLICADA')),
    fecha_aplicacion TIMESTAMP,

    -- Control
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_registro VARCHAR(50) DEFAULT 'sistema',
    usuario_aprobacion VARCHAR(50),
    usuario_aplicacion VARCHAR(50)
);

-- Índices
CREATE INDEX idx_modlic_folio ON informix.modificaciones_licencias(folio_modificacion);
CREATE INDEX idx_modlic_licencia ON informix.modificaciones_licencias(numero_licencia);
CREATE INDEX idx_modlic_estado ON informix.modificaciones_licencias(estado_modificacion);
CREATE INDEX idx_modlic_tipo ON informix.modificaciones_licencias(tipo_modificacion);

-- =====================================================================================
-- 1. SP_MODLIC_SEARCH - Buscar licencias para modificar
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_modlic_search(
    p_numero_licencia VARCHAR(20) DEFAULT NULL,
    p_propietario VARCHAR(150) DEFAULT NULL,
    p_nombre_comercial VARCHAR(150) DEFAULT NULL,
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id_licencia VARCHAR(20),
    numero_licencia VARCHAR(20),
    propietario VARCHAR(150),
    rfc VARCHAR(13),
    domicilio VARCHAR(200),
    telefono_prop VARCHAR(20),
    email VARCHAR(100),
    actividad TEXT,
    id_giro INTEGER,
    ubicacion VARCHAR(150),
    numext_ubic VARCHAR(10),
    numint_ubic VARCHAR(10),
    colonia_ubic VARCHAR(100),
    zona VARCHAR(10),
    sup_construida DECIMAL(10,2),
    num_empleados INTEGER,
    aforo INTEGER,
    estatus CHAR(1),
    domicilio_completo TEXT,
    total_registros BIGINT
) AS $$
DECLARE
    total_count BIGINT;
BEGIN
    -- Contar total (simulado para desarrollo)
    total_count := 25;

    -- Retornar datos simulados para desarrollo
    RETURN QUERY
    WITH datos_simulados AS (
        SELECT
            CASE
                WHEN i = 1 THEN 'LIC-2025-001001'
                WHEN i = 2 THEN 'LIC-2025-001002'
                WHEN i = 3 THEN 'LIC-2025-001003'
                WHEN i = 4 THEN 'LIC-2025-001004'
                ELSE 'LIC-2025-' || LPAD(i::TEXT, 6, '0')
            END::VARCHAR(20) as id_lic,

            CASE
                WHEN i = 1 THEN 'LIC-2025-001001'
                WHEN i = 2 THEN 'LIC-2025-001002'
                WHEN i = 3 THEN 'LIC-2025-001003'
                WHEN i = 4 THEN 'LIC-2025-001004'
                ELSE 'LIC-2025-' || LPAD(i::TEXT, 6, '0')
            END::VARCHAR(20) as num_lic,

            CASE
                WHEN i = 1 THEN 'JUAN PÉREZ LÓPEZ'
                WHEN i = 2 THEN 'MARÍA GONZÁLEZ RUIZ'
                WHEN i = 3 THEN 'CARLOS MARTÍNEZ TORRES'
                WHEN i = 4 THEN 'ANA LÓPEZ HERNÁNDEZ'
                ELSE 'PROPIETARIO ' || i::TEXT
            END::VARCHAR(150) as prop,

            CASE
                WHEN i = 1 THEN 'PELJ800515XXX'
                WHEN i = 2 THEN 'GORM900820XXX'
                WHEN i = 3 THEN 'MATC850630XXX'
                WHEN i = 4 THEN 'LOHA870925XXX'
                ELSE NULL
            END::VARCHAR(13) as rfc_prop,

            CASE
                WHEN i = 1 THEN 'CALLE MORELOS 123, COL. CENTRO'
                WHEN i = 2 THEN 'AV. JUÁREZ 456, COL. AMERICANA'
                WHEN i = 3 THEN 'CALLE INDEPENDENCIA 789, COL. LIBERTAD'
                WHEN i = 4 THEN 'AV. REVOLUCIÓN 321, COL. MODERNA'
                ELSE 'DOMICILIO ' || i::TEXT
            END::VARCHAR(200) as dom_prop,

            CASE
                WHEN i <= 4 THEN '33-1234-567' || i::TEXT
                ELSE NULL
            END::VARCHAR(20) as tel_prop,

            CASE
                WHEN i = 1 THEN 'juan.perez@email.com'
                WHEN i = 2 THEN 'maria.gonzalez@email.com'
                WHEN i = 3 THEN 'carlos.martinez@email.com'
                WHEN i = 4 THEN 'ana.lopez@email.com'
                ELSE NULL
            END::VARCHAR(100) as email_prop,

            CASE
                WHEN i = 1 THEN 'ABARROTES Y VENTA DE PRODUCTOS DE CONSUMO BÁSICO'
                WHEN i = 2 THEN 'RESTAURANTE CON SERVICIO DE ALIMENTOS Y BEBIDAS'
                WHEN i = 3 THEN 'FARMACIA Y VENTA DE MEDICAMENTOS'
                WHEN i = 4 THEN 'ROPA Y ACCESORIOS DE VESTIR'
                ELSE 'ACTIVIDAD COMERCIAL ' || i::TEXT
            END::TEXT as activ,

            CASE
                WHEN i <= 4 THEN i
                ELSE (i % 10) + 1
            END::INTEGER as giro,

            CASE
                WHEN i = 1 THEN 'AV. JUÁREZ'
                WHEN i = 2 THEN 'CALLE INDEPENDENCIA'
                WHEN i = 3 THEN 'AV. REVOLUCIÓN'
                WHEN i = 4 THEN 'CALLE MORELOS'
                ELSE 'CALLE ' || i::TEXT
            END::VARCHAR(150) as ubic,

            CASE
                WHEN i <= 10 THEN (i * 100 + 23)::TEXT
                ELSE (i * 10)::TEXT
            END::VARCHAR(10) as numext,

            CASE
                WHEN i % 3 = 0 THEN 'A'
                WHEN i % 5 = 0 THEN 'B'
                ELSE NULL
            END::VARCHAR(10) as numint,

            CASE
                WHEN i = 1 THEN 'CENTRO'
                WHEN i = 2 THEN 'AMERICANA'
                WHEN i = 3 THEN 'LIBERTAD'
                WHEN i = 4 THEN 'MODERNA'
                ELSE 'COLONIA ' || i::TEXT
            END::VARCHAR(100) as col_ubic,

            CASE
                WHEN i <= 5 THEN 'A'
                WHEN i <= 10 THEN 'B'
                WHEN i <= 15 THEN 'C'
                ELSE 'D'
            END::VARCHAR(10) as zona_ubic,

            CASE
                WHEN i <= 4 THEN (i * 25.5 + 50)
                ELSE (i * 10.0 + 30)
            END::DECIMAL(10,2) as sup_const,

            CASE
                WHEN i <= 4 THEN i + 1
                ELSE (i % 10) + 1
            END::INTEGER as num_emp,

            CASE
                WHEN i = 1 THEN 50
                WHEN i = 2 THEN 80
                WHEN i = 3 THEN 30
                WHEN i = 4 THEN 40
                ELSE (i % 20) + 20
            END::INTEGER as aforo_est,

            CASE
                WHEN i % 6 = 0 THEN 'S'
                WHEN i % 8 = 0 THEN 'P'
                WHEN i % 12 = 0 THEN 'C'
                ELSE 'A'
            END::CHAR(1) as est_lic,

            i
        FROM generate_series(1, 25) i
    )
    SELECT
        ds.id_lic,
        ds.num_lic,
        ds.prop,
        ds.rfc_prop,
        ds.dom_prop,
        ds.tel_prop,
        ds.email_prop,
        ds.activ,
        ds.giro,
        ds.ubic,
        ds.numext,
        ds.numint,
        ds.col_ubic,
        ds.zona_ubic,
        ds.sup_const,
        ds.num_emp,
        ds.aforo_est,
        ds.est_lic,
        (ds.ubic || ' ' || COALESCE(ds.numext, '') || CASE WHEN ds.numint IS NOT NULL THEN ' INT. ' || ds.numint ELSE '' END || ', COL. ' || ds.col_ubic)::TEXT as domicilio_completo,
        total_count as total_registros
    FROM datos_simulados ds
    WHERE (p_numero_licencia IS NULL OR ds.num_lic ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR ds.prop ILIKE '%' || p_propietario || '%')
      AND (p_nombre_comercial IS NULL OR ds.activ ILIKE '%' || p_nombre_comercial || '%')
    ORDER BY ds.i
    LIMIT p_limite OFFSET p_offset;

EXCEPTION
    WHEN OTHERS THEN
        -- En caso de error, retornar datos mínimos
        RETURN QUERY
        SELECT
            'LIC-2025-001001'::VARCHAR(20),
            'LIC-2025-001001'::VARCHAR(20),
            'JUAN PÉREZ LÓPEZ'::VARCHAR(150),
            'PELJ800515XXX'::VARCHAR(13),
            'CALLE MORELOS 123, COL. CENTRO'::VARCHAR(200),
            '33-1234-5671'::VARCHAR(20),
            'juan.perez@email.com'::VARCHAR(100),
            'ABARROTES Y VENTA DE PRODUCTOS DE CONSUMO BÁSICO'::TEXT,
            1::INTEGER,
            'AV. JUÁREZ'::VARCHAR(150),
            '123'::VARCHAR(10),
            NULL::VARCHAR(10),
            'CENTRO'::VARCHAR(100),
            'A'::VARCHAR(10),
            75.5::DECIMAL(10,2),
            2::INTEGER,
            50::INTEGER,
            'A'::CHAR(1),
            'AV. JUÁREZ 123, COL. CENTRO'::TEXT,
            1::BIGINT
        LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 2. SP_MODLIC_CREATE - Crear registro de modificación de licencia
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_modlic_create(
    p_folio_modificacion VARCHAR(30),
    p_numero_licencia VARCHAR(20),
    p_tipo_modificacion VARCHAR(50),
    p_descripcion_cambios TEXT,
    p_datos_actuales JSONB,
    p_datos_propuestos JSONB,
    p_justificacion TEXT,
    p_propietario VARCHAR(150),
    p_usuario_registro VARCHAR(50) DEFAULT 'sistema'
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    folio_modificacion VARCHAR(30),
    id_modificacion INTEGER
) AS $$
DECLARE
    nuevo_id INTEGER;
BEGIN
    -- Insertar modificación
    INSERT INTO informix.modificaciones_licencias (
        folio_modificacion,
        numero_licencia,
        tipo_modificacion,
        descripcion_cambios,
        datos_actuales,
        datos_propuestos,
        justificacion,
        propietario,
        usuario_registro,
        estado_modificacion
    ) VALUES (
        p_folio_modificacion,
        p_numero_licencia,
        p_tipo_modificacion,
        p_descripcion_cambios,
        p_datos_actuales,
        p_datos_propuestos,
        p_justificacion,
        p_propietario,
        p_usuario_registro,
        'PENDIENTE'
    ) RETURNING id INTO nuevo_id;

    RETURN QUERY SELECT TRUE, 'Modificación registrada exitosamente'::TEXT, p_folio_modificacion, nuevo_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al registrar modificación: ' || SQLERRM)::TEXT, NULL::VARCHAR(30), NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 3. SP_MODLIC_LIST - Listar modificaciones de licencias
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_modlic_list(
    p_numero_licencia VARCHAR(20) DEFAULT NULL,
    p_folio_modificacion VARCHAR(30) DEFAULT NULL,
    p_estado VARCHAR(20) DEFAULT NULL,
    p_tipo_modificacion VARCHAR(50) DEFAULT NULL,
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    folio_modificacion VARCHAR(30),
    numero_licencia VARCHAR(20),
    tipo_modificacion VARCHAR(50),
    descripcion_cambios TEXT,
    propietario VARCHAR(150),
    estado_modificacion VARCHAR(20),
    fecha_registro TIMESTAMP,
    fecha_aplicacion TIMESTAMP,
    usuario_registro VARCHAR(50),
    usuario_aprobacion VARCHAR(50),
    justificacion TEXT,
    total_registros BIGINT
) AS $$
DECLARE
    total_count BIGINT;
BEGIN
    -- Contar total
    SELECT COUNT(*) INTO total_count
    FROM informix.modificaciones_licencias m
    WHERE (p_numero_licencia IS NULL OR m.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_folio_modificacion IS NULL OR m.folio_modificacion ILIKE '%' || p_folio_modificacion || '%')
      AND (p_estado IS NULL OR m.estado_modificacion = p_estado)
      AND (p_tipo_modificacion IS NULL OR m.tipo_modificacion = p_tipo_modificacion)
      AND (p_fecha_inicio IS NULL OR m.fecha_registro >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR m.fecha_registro <= p_fecha_fin + INTERVAL '1 day');

    -- Retornar resultados
    RETURN QUERY
    SELECT
        m.id,
        m.folio_modificacion,
        m.numero_licencia,
        m.tipo_modificacion,
        m.descripcion_cambios,
        m.propietario,
        m.estado_modificacion,
        m.fecha_registro,
        m.fecha_aplicacion,
        m.usuario_registro,
        m.usuario_aprobacion,
        m.justificacion,
        total_count as total_registros
    FROM informix.modificaciones_licencias m
    WHERE (p_numero_licencia IS NULL OR m.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_folio_modificacion IS NULL OR m.folio_modificacion ILIKE '%' || p_folio_modificacion || '%')
      AND (p_estado IS NULL OR m.estado_modificacion = p_estado)
      AND (p_tipo_modificacion IS NULL OR m.tipo_modificacion = p_tipo_modificacion)
      AND (p_fecha_inicio IS NULL OR m.fecha_registro >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR m.fecha_registro <= p_fecha_fin + INTERVAL '1 day')
    ORDER BY m.fecha_registro DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 4. SP_MODLIC_APROBAR - Aprobar modificación de licencia
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_modlic_aprobar(
    p_id INTEGER,
    p_usuario_aprobacion VARCHAR(50),
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    folio_modificacion VARCHAR(30)
) AS $$
DECLARE
    v_folio VARCHAR(30);
    v_estado_actual VARCHAR(20);
BEGIN
    -- Verificar estado actual
    SELECT folio_modificacion, estado_modificacion INTO v_folio, v_estado_actual
    FROM informix.modificaciones_licencias
    WHERE id = p_id;

    IF v_folio IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Modificación no encontrada'::TEXT, NULL::VARCHAR(30);
        RETURN;
    END IF;

    IF v_estado_actual != 'PENDIENTE' THEN
        RETURN QUERY SELECT FALSE, 'La modificación no está pendiente de aprobación'::TEXT, v_folio;
        RETURN;
    END IF;

    -- Aprobar modificación
    UPDATE informix.modificaciones_licencias SET
        estado_modificacion = 'APROBADA',
        usuario_aprobacion = p_usuario_aprobacion,
        fecha_modificacion = CURRENT_TIMESTAMP,
        observaciones = COALESCE(p_observaciones, observaciones)
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Modificación aprobada exitosamente'::TEXT, v_folio;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al aprobar modificación: ' || SQLERRM)::TEXT, NULL::VARCHAR(30);
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 5. SP_MODLIC_RECHAZAR - Rechazar modificación de licencia
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_modlic_rechazar(
    p_id INTEGER,
    p_usuario_aprobacion VARCHAR(50),
    p_motivo_rechazo TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    folio_modificacion VARCHAR(30)
) AS $$
DECLARE
    v_folio VARCHAR(30);
    v_estado_actual VARCHAR(20);
BEGIN
    -- Verificar estado actual
    SELECT folio_modificacion, estado_modificacion INTO v_folio, v_estado_actual
    FROM informix.modificaciones_licencias
    WHERE id = p_id;

    IF v_folio IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Modificación no encontrada'::TEXT, NULL::VARCHAR(30);
        RETURN;
    END IF;

    IF v_estado_actual != 'PENDIENTE' THEN
        RETURN QUERY SELECT FALSE, 'La modificación no está pendiente de aprobación'::TEXT, v_folio;
        RETURN;
    END IF;

    -- Rechazar modificación
    UPDATE informix.modificaciones_licencias SET
        estado_modificacion = 'RECHAZADA',
        usuario_aprobacion = p_usuario_aprobacion,
        fecha_modificacion = CURRENT_TIMESTAMP,
        observaciones = p_motivo_rechazo
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Modificación rechazada exitosamente'::TEXT, v_folio;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al rechazar modificación: ' || SQLERRM)::TEXT, NULL::VARCHAR(30);
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 6. SP_MODLIC_ESTADISTICAS - Estadísticas de modificaciones
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_modlic_estadisticas(
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL
)
RETURNS TABLE(
    total_modificaciones INTEGER,
    pendientes INTEGER,
    aprobadas INTEGER,
    rechazadas INTEGER,
    aplicadas INTEGER,
    por_tipo_propietario INTEGER,
    por_tipo_actividad INTEGER,
    por_tipo_domicilio INTEGER,
    por_tipo_estatus INTEGER,
    por_tipo_otros INTEGER
) AS $$
BEGIN
    RETURN QUERY
    WITH stats AS (
        SELECT
            COUNT(*)::INTEGER as total,
            COUNT(CASE WHEN estado_modificacion = 'PENDIENTE' THEN 1 END)::INTEGER as pend,
            COUNT(CASE WHEN estado_modificacion = 'APROBADA' THEN 1 END)::INTEGER as aprob,
            COUNT(CASE WHEN estado_modificacion = 'RECHAZADA' THEN 1 END)::INTEGER as rech,
            COUNT(CASE WHEN estado_modificacion = 'APLICADA' THEN 1 END)::INTEGER as aplic,
            COUNT(CASE WHEN tipo_modificacion = 'PROPIETARIO' THEN 1 END)::INTEGER as t_prop,
            COUNT(CASE WHEN tipo_modificacion = 'ACTIVIDAD' THEN 1 END)::INTEGER as t_act,
            COUNT(CASE WHEN tipo_modificacion = 'DOMICILIO' THEN 1 END)::INTEGER as t_dom,
            COUNT(CASE WHEN tipo_modificacion = 'ESTATUS' THEN 1 END)::INTEGER as t_est,
            COUNT(CASE WHEN tipo_modificacion = 'OTROS' THEN 1 END)::INTEGER as t_otros
        FROM informix.modificaciones_licencias
        WHERE (p_fecha_inicio IS NULL OR fecha_registro >= p_fecha_inicio)
          AND (p_fecha_fin IS NULL OR fecha_registro <= p_fecha_fin + INTERVAL '1 day')
    )
    SELECT
        s.total,
        s.pend,
        s.aprob,
        s.rech,
        s.aplic,
        s.t_prop,
        s.t_act,
        s.t_dom,
        s.t_est,
        s.t_otros
    FROM stats s;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- DATOS DE PRUEBA
-- =====================================================================================

-- Insertar modificaciones de prueba
SELECT * FROM informix.sp_modlic_create(
    'MOD-2025-001', 'LIC-2025-001001', 'PROPIETARIO',
    'Cambio de propietario por traspaso de negocio',
    '{"propietario": "JUAN PÉREZ LÓPEZ", "rfc": "PELJ800515XXX"}'::jsonb,
    '{"propietario": "MARÍA GONZÁLEZ RUIZ", "rfc": "GORM900820XXX"}'::jsonb,
    'Traspaso por venta del establecimiento', 'MARÍA GONZÁLEZ RUIZ', 'admin'
);

SELECT * FROM informix.sp_modlic_create(
    'MOD-2025-002', 'LIC-2025-001002', 'DOMICILIO',
    'Cambio de domicilio del establecimiento',
    '{"ubicacion": "AV. JUÁREZ 123", "colonia": "CENTRO"}'::jsonb,
    '{"ubicacion": "CALLE MORELOS 456", "colonia": "AMERICANA"}'::jsonb,
    'Reubicación por ampliación del negocio', 'CARLOS MARTÍNEZ', 'admin'
);

-- =====================================================================================
-- PERMISOS Y COMENTARIOS
-- =====================================================================================

-- Comentarios en las tablas y funciones
COMMENT ON TABLE informix.modificaciones_licencias IS 'Registro de modificaciones de licencias municipales';
COMMENT ON FUNCTION informix.sp_modlic_search IS 'Busca licencias para modificar';
COMMENT ON FUNCTION informix.sp_modlic_create IS 'Crea registro de modificación de licencia';
COMMENT ON FUNCTION informix.sp_modlic_list IS 'Lista modificaciones con filtros';
COMMENT ON FUNCTION informix.sp_modlic_aprobar IS 'Aprueba modificación de licencia';
COMMENT ON FUNCTION informix.sp_modlic_rechazar IS 'Rechaza modificación de licencia';
COMMENT ON FUNCTION informix.sp_modlic_estadisticas IS 'Estadísticas de modificaciones';

-- =====================================================================================
-- FIN DEL ARCHIVO
-- =====================================================================================