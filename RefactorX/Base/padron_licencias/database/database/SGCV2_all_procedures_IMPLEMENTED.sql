-- =============================================
-- SGCV2 - Sistema de Gestión Catastral v2
-- Stored Procedures Completos
-- =============================================
-- Módulo: padron_licencias
-- Componente: SGCv2
-- Fecha: 2025-11-21
-- Total SPs: 9
-- Schema: comun
-- =============================================

-- =============================================
-- SECCIÓN 1: TABLAS AUXILIARES
-- =============================================

-- Tabla principal de predios (si no existe)
CREATE TABLE IF NOT EXISTS comun.predios (
    id BIGSERIAL PRIMARY KEY,
    cuenta VARCHAR(50) NOT NULL UNIQUE,
    clave_catastral VARCHAR(100),
    propietario VARCHAR(500),
    domicilio VARCHAR(500),
    numero_exterior VARCHAR(20),
    numero_interior VARCHAR(20),
    colonia VARCHAR(200),
    cp VARCHAR(10),
    municipio VARCHAR(100) DEFAULT 'Guadalajara',
    estado VARCHAR(50) DEFAULT 'Jalisco',
    superficie_terreno NUMERIC(15,2) DEFAULT 0,
    superficie_construccion NUMERIC(15,2) DEFAULT 0,
    valor_terreno NUMERIC(18,2) DEFAULT 0,
    valor_construccion NUMERIC(18,2) DEFAULT 0,
    valor_catastral NUMERIC(18,2) DEFAULT 0,
    uso_suelo VARCHAR(100),
    tipo_predio VARCHAR(50),
    fecha_avaluo DATE,
    fecha_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    observaciones TEXT
);

-- Índices para predios
CREATE INDEX IF NOT EXISTS idx_predios_cuenta ON comun.predios(cuenta);
CREATE INDEX IF NOT EXISTS idx_predios_propietario ON comun.predios(propietario);
CREATE INDEX IF NOT EXISTS idx_predios_colonia ON comun.predios(colonia);
CREATE INDEX IF NOT EXISTS idx_predios_clave_catastral ON comun.predios(clave_catastral);

-- Tabla de trámites SGC
CREATE TABLE IF NOT EXISTS comun.sgc_tramites (
    id BIGSERIAL PRIMARY KEY,
    cuenta VARCHAR(50) NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    estatus VARCHAR(50) DEFAULT 'PENDIENTE',
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMP,
    usuario_alta VARCHAR(100),
    usuario_modificacion VARCHAR(100),
    observaciones TEXT,
    prioridad INTEGER DEFAULT 0,
    CONSTRAINT fk_sgc_tramites_cuenta FOREIGN KEY (cuenta)
        REFERENCES comun.predios(cuenta) ON UPDATE CASCADE
);

-- Índices para trámites
CREATE INDEX IF NOT EXISTS idx_sgc_tramites_cuenta ON comun.sgc_tramites(cuenta);
CREATE INDEX IF NOT EXISTS idx_sgc_tramites_estatus ON comun.sgc_tramites(estatus);
CREATE INDEX IF NOT EXISTS idx_sgc_tramites_fecha ON comun.sgc_tramites(fecha_inicio);

-- Tabla de historial de trámites (auditoría)
CREATE TABLE IF NOT EXISTS comun.sgc_tramites_historial (
    id BIGSERIAL PRIMARY KEY,
    tramite_id BIGINT NOT NULL,
    estatus_anterior VARCHAR(50),
    estatus_nuevo VARCHAR(50),
    observaciones TEXT,
    usuario VARCHAR(100),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(50),
    CONSTRAINT fk_sgc_historial_tramite FOREIGN KEY (tramite_id)
        REFERENCES comun.sgc_tramites(id) ON DELETE CASCADE
);

-- Índice para historial
CREATE INDEX IF NOT EXISTS idx_sgc_historial_tramite ON comun.sgc_tramites_historial(tramite_id);

-- =============================================
-- SECCIÓN 2: STORED PROCEDURES
-- =============================================

-- =============================================
-- SP 1: sp_sgcv2_search_by_cuenta
-- Buscar predios por cuenta catastral
-- =============================================
DROP FUNCTION IF EXISTS comun.sp_sgcv2_search_by_cuenta(VARCHAR);

CREATE OR REPLACE FUNCTION comun.sp_sgcv2_search_by_cuenta(
    p_cuenta VARCHAR
)
RETURNS TABLE(
    cuenta VARCHAR,
    propietario VARCHAR,
    domicilio VARCHAR,
    superficie NUMERIC,
    valor_catastral NUMERIC,
    estado VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cuenta_search VARCHAR;
BEGIN
    -- Validar parámetro
    IF p_cuenta IS NULL OR TRIM(p_cuenta) = '' THEN
        RAISE EXCEPTION 'El parámetro cuenta es requerido';
    END IF;

    -- Preparar búsqueda (exacta o parcial)
    v_cuenta_search := TRIM(p_cuenta);

    RETURN QUERY
    SELECT
        p.cuenta::VARCHAR,
        COALESCE(p.propietario, 'Sin propietario')::VARCHAR,
        COALESCE(
            CONCAT_WS(', ',
                p.domicilio,
                NULLIF(p.numero_exterior, ''),
                p.colonia
            ),
            'Sin domicilio'
        )::VARCHAR AS domicilio,
        COALESCE(p.superficie_terreno, 0)::NUMERIC AS superficie,
        COALESCE(p.valor_catastral, 0)::NUMERIC AS valor_catastral,
        CASE
            WHEN p.activo THEN 'ACTIVO'
            ELSE 'INACTIVO'
        END::VARCHAR AS estado
    FROM comun.predios p
    WHERE p.cuenta ILIKE v_cuenta_search || '%'
       OR p.cuenta = v_cuenta_search
    ORDER BY
        CASE WHEN p.cuenta = v_cuenta_search THEN 0 ELSE 1 END,
        p.cuenta
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en sp_sgcv2_search_by_cuenta: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION comun.sp_sgcv2_search_by_cuenta(VARCHAR) IS
'Busca predios por cuenta catastral (exacta o parcial con ILIKE)';

-- =============================================
-- SP 2: sp_sgcv2_search_by_propietario
-- Buscar predios por nombre de propietario
-- =============================================
DROP FUNCTION IF EXISTS comun.sp_sgcv2_search_by_propietario(VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_sgcv2_search_by_propietario(
    p_nombre VARCHAR,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    cuenta VARCHAR,
    propietario VARCHAR,
    domicilio VARCHAR,
    superficie NUMERIC,
    valor_catastral NUMERIC,
    estado VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_nombre_search VARCHAR;
    v_limit INTEGER;
BEGIN
    -- Validar parámetro
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El parámetro nombre es requerido';
    END IF;

    -- Preparar búsqueda
    v_nombre_search := '%' || TRIM(p_nombre) || '%';
    v_limit := COALESCE(p_limit, 50);

    -- Limitar máximo
    IF v_limit > 500 THEN
        v_limit := 500;
    END IF;

    RETURN QUERY
    SELECT
        p.cuenta::VARCHAR,
        COALESCE(p.propietario, 'Sin propietario')::VARCHAR,
        COALESCE(
            CONCAT_WS(', ',
                p.domicilio,
                NULLIF(p.numero_exterior, ''),
                p.colonia
            ),
            'Sin domicilio'
        )::VARCHAR AS domicilio,
        COALESCE(p.superficie_terreno, 0)::NUMERIC AS superficie,
        COALESCE(p.valor_catastral, 0)::NUMERIC AS valor_catastral,
        CASE
            WHEN p.activo THEN 'ACTIVO'
            ELSE 'INACTIVO'
        END::VARCHAR AS estado
    FROM comun.predios p
    WHERE p.propietario ILIKE v_nombre_search
      AND p.activo = TRUE
    ORDER BY p.propietario, p.cuenta
    LIMIT v_limit;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en sp_sgcv2_search_by_propietario: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION comun.sp_sgcv2_search_by_propietario(VARCHAR, INTEGER) IS
'Busca predios por nombre de propietario con ILIKE';

-- =============================================
-- SP 3: sp_sgcv2_search_by_domicilio
-- Buscar predios por domicilio
-- =============================================
DROP FUNCTION IF EXISTS comun.sp_sgcv2_search_by_domicilio(VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION comun.sp_sgcv2_search_by_domicilio(
    p_calle VARCHAR,
    p_numero VARCHAR DEFAULT NULL,
    p_colonia VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    cuenta VARCHAR,
    propietario VARCHAR,
    domicilio_completo VARCHAR,
    colonia VARCHAR,
    superficie NUMERIC,
    valor_catastral NUMERIC,
    estado VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_calle_search VARCHAR;
    v_numero_search VARCHAR;
    v_colonia_search VARCHAR;
BEGIN
    -- Validar al menos calle
    IF p_calle IS NULL OR TRIM(p_calle) = '' THEN
        RAISE EXCEPTION 'El parámetro calle es requerido';
    END IF;

    -- Preparar filtros
    v_calle_search := '%' || TRIM(p_calle) || '%';
    v_numero_search := NULLIF(TRIM(COALESCE(p_numero, '')), '');
    v_colonia_search := CASE
        WHEN p_colonia IS NOT NULL AND TRIM(p_colonia) <> ''
        THEN '%' || TRIM(p_colonia) || '%'
        ELSE NULL
    END;

    RETURN QUERY
    SELECT
        p.cuenta::VARCHAR,
        COALESCE(p.propietario, 'Sin propietario')::VARCHAR,
        COALESCE(
            CONCAT_WS(' ',
                p.domicilio,
                '#' || NULLIF(p.numero_exterior, ''),
                CASE WHEN p.numero_interior IS NOT NULL AND p.numero_interior <> ''
                     THEN 'Int. ' || p.numero_interior
                     ELSE NULL
                END
            ),
            'Sin domicilio'
        )::VARCHAR AS domicilio_completo,
        COALESCE(p.colonia, 'Sin colonia')::VARCHAR AS colonia,
        COALESCE(p.superficie_terreno, 0)::NUMERIC AS superficie,
        COALESCE(p.valor_catastral, 0)::NUMERIC AS valor_catastral,
        CASE
            WHEN p.activo THEN 'ACTIVO'
            ELSE 'INACTIVO'
        END::VARCHAR AS estado
    FROM comun.predios p
    WHERE p.domicilio ILIKE v_calle_search
      AND p.activo = TRUE
      AND (v_numero_search IS NULL OR p.numero_exterior = v_numero_search)
      AND (v_colonia_search IS NULL OR p.colonia ILIKE v_colonia_search)
    ORDER BY p.colonia, p.domicilio, p.numero_exterior
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en sp_sgcv2_search_by_domicilio: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION comun.sp_sgcv2_search_by_domicilio(VARCHAR, VARCHAR, VARCHAR) IS
'Busca predios por domicilio con filtros opcionales de número y colonia';

-- =============================================
-- SP 4: sp_sgcv2_get_predio_detail
-- Obtener detalle completo de un predio
-- =============================================
DROP FUNCTION IF EXISTS comun.sp_sgcv2_get_predio_detail(VARCHAR);

CREATE OR REPLACE FUNCTION comun.sp_sgcv2_get_predio_detail(
    p_cuenta VARCHAR
)
RETURNS TABLE(
    cuenta VARCHAR,
    clave_catastral VARCHAR,
    propietario VARCHAR,
    domicilio VARCHAR,
    numero_exterior VARCHAR,
    numero_interior VARCHAR,
    colonia VARCHAR,
    cp VARCHAR,
    municipio VARCHAR,
    estado_geografico VARCHAR,
    superficie_terreno NUMERIC,
    superficie_construccion NUMERIC,
    valor_terreno NUMERIC,
    valor_construccion NUMERIC,
    valor_catastral NUMERIC,
    uso_suelo VARCHAR,
    tipo_predio VARCHAR,
    fecha_avaluo DATE,
    fecha_alta TIMESTAMP,
    fecha_modificacion TIMESTAMP,
    estado_registro VARCHAR,
    observaciones TEXT,
    total_tramites BIGINT,
    tramites_pendientes BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Validar parámetro
    IF p_cuenta IS NULL OR TRIM(p_cuenta) = '' THEN
        RAISE EXCEPTION 'El parámetro cuenta es requerido';
    END IF;

    RETURN QUERY
    SELECT
        p.cuenta::VARCHAR,
        COALESCE(p.clave_catastral, '')::VARCHAR,
        COALESCE(p.propietario, 'Sin propietario')::VARCHAR,
        COALESCE(p.domicilio, '')::VARCHAR,
        COALESCE(p.numero_exterior, '')::VARCHAR,
        COALESCE(p.numero_interior, '')::VARCHAR,
        COALESCE(p.colonia, '')::VARCHAR,
        COALESCE(p.cp, '')::VARCHAR,
        COALESCE(p.municipio, 'Guadalajara')::VARCHAR,
        COALESCE(p.estado, 'Jalisco')::VARCHAR AS estado_geografico,
        COALESCE(p.superficie_terreno, 0)::NUMERIC,
        COALESCE(p.superficie_construccion, 0)::NUMERIC,
        COALESCE(p.valor_terreno, 0)::NUMERIC,
        COALESCE(p.valor_construccion, 0)::NUMERIC,
        COALESCE(p.valor_catastral, 0)::NUMERIC,
        COALESCE(p.uso_suelo, 'Sin especificar')::VARCHAR,
        COALESCE(p.tipo_predio, 'Sin especificar')::VARCHAR,
        p.fecha_avaluo,
        p.fecha_alta,
        p.fecha_modificacion,
        CASE
            WHEN p.activo THEN 'ACTIVO'
            ELSE 'INACTIVO'
        END::VARCHAR AS estado_registro,
        COALESCE(p.observaciones, '')::TEXT,
        COALESCE(
            (SELECT COUNT(*) FROM comun.sgc_tramites t WHERE t.cuenta = p.cuenta),
            0
        )::BIGINT AS total_tramites,
        COALESCE(
            (SELECT COUNT(*) FROM comun.sgc_tramites t
             WHERE t.cuenta = p.cuenta AND t.estatus IN ('PENDIENTE', 'EN_PROCESO')),
            0
        )::BIGINT AS tramites_pendientes
    FROM comun.predios p
    WHERE p.cuenta = TRIM(p_cuenta);

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en sp_sgcv2_get_predio_detail: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION comun.sp_sgcv2_get_predio_detail(VARCHAR) IS
'Obtiene el detalle completo de un predio por cuenta catastral';

-- =============================================
-- SP 5: sp_sgcv2_get_tramites_by_cuenta
-- Obtener trámites de una cuenta
-- =============================================
DROP FUNCTION IF EXISTS comun.sp_sgcv2_get_tramites_by_cuenta(VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION comun.sp_sgcv2_get_tramites_by_cuenta(
    p_cuenta VARCHAR,
    p_estatus VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    tramite_id BIGINT,
    tipo VARCHAR,
    descripcion TEXT,
    fecha_inicio TIMESTAMP,
    fecha_fin TIMESTAMP,
    estatus VARCHAR,
    observaciones TEXT,
    usuario_alta VARCHAR,
    dias_transcurridos INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_estatus_filter VARCHAR;
BEGIN
    -- Validar parámetro cuenta
    IF p_cuenta IS NULL OR TRIM(p_cuenta) = '' THEN
        RAISE EXCEPTION 'El parámetro cuenta es requerido';
    END IF;

    -- Preparar filtro de estatus
    v_estatus_filter := NULLIF(TRIM(COALESCE(p_estatus, '')), '');

    RETURN QUERY
    SELECT
        t.id AS tramite_id,
        t.tipo::VARCHAR,
        COALESCE(t.descripcion, '')::TEXT,
        t.fecha_inicio,
        t.fecha_fin,
        t.estatus::VARCHAR,
        COALESCE(t.observaciones, '')::TEXT,
        COALESCE(t.usuario_alta, '')::VARCHAR,
        EXTRACT(DAY FROM (COALESCE(t.fecha_fin, CURRENT_TIMESTAMP) - t.fecha_inicio))::INTEGER AS dias_transcurridos
    FROM comun.sgc_tramites t
    WHERE t.cuenta = TRIM(p_cuenta)
      AND (v_estatus_filter IS NULL OR t.estatus = v_estatus_filter)
    ORDER BY t.fecha_inicio DESC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en sp_sgcv2_get_tramites_by_cuenta: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION comun.sp_sgcv2_get_tramites_by_cuenta(VARCHAR, VARCHAR) IS
'Obtiene los trámites de una cuenta con filtro opcional de estatus';

-- =============================================
-- SP 6: sp_sgcv2_create_tramite
-- Crear nuevo trámite
-- =============================================
DROP FUNCTION IF EXISTS comun.sp_sgcv2_create_tramite(VARCHAR, VARCHAR, TEXT, VARCHAR);

CREATE OR REPLACE FUNCTION comun.sp_sgcv2_create_tramite(
    p_cuenta VARCHAR,
    p_tipo VARCHAR,
    p_descripcion TEXT,
    p_usuario VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    tramite_id BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_cuenta_existe BOOLEAN;
    v_nuevo_tramite_id BIGINT;
BEGIN
    -- Validar parámetros requeridos
    IF p_cuenta IS NULL OR TRIM(p_cuenta) = '' THEN
        RETURN QUERY SELECT FALSE, 'El parámetro cuenta es requerido'::TEXT, NULL::BIGINT;
        RETURN;
    END IF;

    IF p_tipo IS NULL OR TRIM(p_tipo) = '' THEN
        RETURN QUERY SELECT FALSE, 'El parámetro tipo es requerido'::TEXT, NULL::BIGINT;
        RETURN;
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El parámetro usuario es requerido'::TEXT, NULL::BIGINT;
        RETURN;
    END IF;

    -- Verificar que la cuenta existe
    SELECT EXISTS(
        SELECT 1 FROM comun.predios WHERE cuenta = TRIM(p_cuenta)
    ) INTO v_cuenta_existe;

    IF NOT v_cuenta_existe THEN
        RETURN QUERY SELECT FALSE,
            ('La cuenta ' || p_cuenta || ' no existe en el sistema')::TEXT,
            NULL::BIGINT;
        RETURN;
    END IF;

    -- Crear el trámite
    INSERT INTO comun.sgc_tramites (
        cuenta,
        tipo,
        descripcion,
        estatus,
        fecha_inicio,
        usuario_alta
    ) VALUES (
        TRIM(p_cuenta),
        TRIM(p_tipo),
        COALESCE(TRIM(p_descripcion), ''),
        'PENDIENTE',
        CURRENT_TIMESTAMP,
        TRIM(p_usuario)
    )
    RETURNING id INTO v_nuevo_tramite_id;

    -- Registrar en historial
    INSERT INTO comun.sgc_tramites_historial (
        tramite_id,
        estatus_anterior,
        estatus_nuevo,
        observaciones,
        usuario,
        fecha_cambio
    ) VALUES (
        v_nuevo_tramite_id,
        NULL,
        'PENDIENTE',
        'Trámite creado',
        TRIM(p_usuario),
        CURRENT_TIMESTAMP
    );

    RETURN QUERY SELECT TRUE,
        ('Trámite creado exitosamente con ID: ' || v_nuevo_tramite_id)::TEXT,
        v_nuevo_tramite_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE,
            ('Error al crear trámite: ' || SQLERRM)::TEXT,
            NULL::BIGINT;
END;
$$;

COMMENT ON FUNCTION comun.sp_sgcv2_create_tramite(VARCHAR, VARCHAR, TEXT, VARCHAR) IS
'Crea un nuevo trámite validando que la cuenta exista';

-- =============================================
-- SP 7: sp_sgcv2_update_tramite_status
-- Actualizar estatus de trámite
-- =============================================
DROP FUNCTION IF EXISTS comun.sp_sgcv2_update_tramite_status(BIGINT, VARCHAR, TEXT, VARCHAR);

CREATE OR REPLACE FUNCTION comun.sp_sgcv2_update_tramite_status(
    p_tramite_id BIGINT,
    p_nuevo_estatus VARCHAR,
    p_observaciones TEXT,
    p_usuario VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tramite_existe BOOLEAN;
    v_estatus_actual VARCHAR;
    v_estatus_validos VARCHAR[] := ARRAY['PENDIENTE', 'EN_PROCESO', 'COMPLETADO', 'CANCELADO', 'RECHAZADO'];
BEGIN
    -- Validar parámetros requeridos
    IF p_tramite_id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El parámetro tramite_id es requerido'::TEXT;
        RETURN;
    END IF;

    IF p_nuevo_estatus IS NULL OR TRIM(p_nuevo_estatus) = '' THEN
        RETURN QUERY SELECT FALSE, 'El parámetro nuevo_estatus es requerido'::TEXT;
        RETURN;
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El parámetro usuario es requerido'::TEXT;
        RETURN;
    END IF;

    -- Validar estatus válido
    IF NOT (UPPER(TRIM(p_nuevo_estatus)) = ANY(v_estatus_validos)) THEN
        RETURN QUERY SELECT FALSE,
            ('Estatus inválido. Valores permitidos: ' || array_to_string(v_estatus_validos, ', '))::TEXT;
        RETURN;
    END IF;

    -- Verificar que el trámite existe y obtener estatus actual
    SELECT t.estatus INTO v_estatus_actual
    FROM comun.sgc_tramites t
    WHERE t.id = p_tramite_id;

    IF v_estatus_actual IS NULL THEN
        RETURN QUERY SELECT FALSE,
            ('El trámite con ID ' || p_tramite_id || ' no existe')::TEXT;
        RETURN;
    END IF;

    -- Verificar que no sea el mismo estatus
    IF UPPER(TRIM(p_nuevo_estatus)) = v_estatus_actual THEN
        RETURN QUERY SELECT FALSE,
            ('El trámite ya tiene el estatus ' || v_estatus_actual)::TEXT;
        RETURN;
    END IF;

    -- Actualizar el trámite
    UPDATE comun.sgc_tramites
    SET
        estatus = UPPER(TRIM(p_nuevo_estatus)),
        observaciones = COALESCE(p_observaciones, observaciones),
        usuario_modificacion = TRIM(p_usuario),
        fecha_fin = CASE
            WHEN UPPER(TRIM(p_nuevo_estatus)) IN ('COMPLETADO', 'CANCELADO', 'RECHAZADO')
            THEN CURRENT_TIMESTAMP
            ELSE fecha_fin
        END
    WHERE id = p_tramite_id;

    -- Registrar en historial
    INSERT INTO comun.sgc_tramites_historial (
        tramite_id,
        estatus_anterior,
        estatus_nuevo,
        observaciones,
        usuario,
        fecha_cambio
    ) VALUES (
        p_tramite_id,
        v_estatus_actual,
        UPPER(TRIM(p_nuevo_estatus)),
        COALESCE(TRIM(p_observaciones), 'Cambio de estatus'),
        TRIM(p_usuario),
        CURRENT_TIMESTAMP
    );

    RETURN QUERY SELECT TRUE,
        ('Estatus actualizado de ' || v_estatus_actual || ' a ' || UPPER(TRIM(p_nuevo_estatus)))::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE,
            ('Error al actualizar estatus: ' || SQLERRM)::TEXT;
END;
$$;

COMMENT ON FUNCTION comun.sp_sgcv2_update_tramite_status(BIGINT, VARCHAR, TEXT, VARCHAR) IS
'Actualiza el estatus de un trámite y registra el cambio en historial';

-- =============================================
-- SP 8: sp_sgcv2_get_estadisticas
-- Obtener estadísticas del sistema
-- =============================================
DROP FUNCTION IF EXISTS comun.sp_sgcv2_get_estadisticas(DATE, DATE);

CREATE OR REPLACE FUNCTION comun.sp_sgcv2_get_estadisticas(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
)
RETURNS TABLE(
    total_predios BIGINT,
    predios_activos BIGINT,
    predios_inactivos BIGINT,
    tramites_pendientes BIGINT,
    tramites_en_proceso BIGINT,
    tramites_completados BIGINT,
    tramites_cancelados BIGINT,
    tramites_total BIGINT,
    valor_catastral_total NUMERIC,
    superficie_total NUMERIC,
    promedio_dias_tramite NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_fecha_desde TIMESTAMP;
    v_fecha_hasta TIMESTAMP;
BEGIN
    -- Establecer fechas por defecto (último año si no se especifica)
    v_fecha_desde := COALESCE(p_fecha_desde::TIMESTAMP, CURRENT_DATE - INTERVAL '1 year');
    v_fecha_hasta := COALESCE(p_fecha_hasta::TIMESTAMP, CURRENT_DATE) + INTERVAL '1 day' - INTERVAL '1 second';

    RETURN QUERY
    SELECT
        -- Estadísticas de predios
        (SELECT COUNT(*) FROM comun.predios)::BIGINT AS total_predios,
        (SELECT COUNT(*) FROM comun.predios WHERE activo = TRUE)::BIGINT AS predios_activos,
        (SELECT COUNT(*) FROM comun.predios WHERE activo = FALSE)::BIGINT AS predios_inactivos,

        -- Estadísticas de trámites (filtradas por fecha)
        (SELECT COUNT(*) FROM comun.sgc_tramites
         WHERE estatus = 'PENDIENTE'
         AND fecha_inicio BETWEEN v_fecha_desde AND v_fecha_hasta)::BIGINT AS tramites_pendientes,

        (SELECT COUNT(*) FROM comun.sgc_tramites
         WHERE estatus = 'EN_PROCESO'
         AND fecha_inicio BETWEEN v_fecha_desde AND v_fecha_hasta)::BIGINT AS tramites_en_proceso,

        (SELECT COUNT(*) FROM comun.sgc_tramites
         WHERE estatus = 'COMPLETADO'
         AND fecha_inicio BETWEEN v_fecha_desde AND v_fecha_hasta)::BIGINT AS tramites_completados,

        (SELECT COUNT(*) FROM comun.sgc_tramites
         WHERE estatus IN ('CANCELADO', 'RECHAZADO')
         AND fecha_inicio BETWEEN v_fecha_desde AND v_fecha_hasta)::BIGINT AS tramites_cancelados,

        (SELECT COUNT(*) FROM comun.sgc_tramites
         WHERE fecha_inicio BETWEEN v_fecha_desde AND v_fecha_hasta)::BIGINT AS tramites_total,

        -- Valores totales
        COALESCE((SELECT SUM(valor_catastral) FROM comun.predios WHERE activo = TRUE), 0)::NUMERIC AS valor_catastral_total,
        COALESCE((SELECT SUM(superficie_terreno) FROM comun.predios WHERE activo = TRUE), 0)::NUMERIC AS superficie_total,

        -- Promedio de días para completar trámites
        COALESCE(
            (SELECT AVG(EXTRACT(DAY FROM (fecha_fin - fecha_inicio)))
             FROM comun.sgc_tramites
             WHERE estatus = 'COMPLETADO'
             AND fecha_fin IS NOT NULL
             AND fecha_inicio BETWEEN v_fecha_desde AND v_fecha_hasta),
            0
        )::NUMERIC AS promedio_dias_tramite;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en sp_sgcv2_get_estadisticas: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION comun.sp_sgcv2_get_estadisticas(DATE, DATE) IS
'Obtiene estadísticas generales del sistema catastral con filtro opcional de fechas';

-- =============================================
-- SP 9: sp_sgcv2_search_advanced
-- Búsqueda avanzada con múltiples criterios
-- =============================================
DROP FUNCTION IF EXISTS comun.sp_sgcv2_search_advanced(VARCHAR, VARCHAR, VARCHAR, VARCHAR, NUMERIC, NUMERIC);

CREATE OR REPLACE FUNCTION comun.sp_sgcv2_search_advanced(
    p_cuenta VARCHAR DEFAULT NULL,
    p_propietario VARCHAR DEFAULT NULL,
    p_colonia VARCHAR DEFAULT NULL,
    p_uso_suelo VARCHAR DEFAULT NULL,
    p_valor_min NUMERIC DEFAULT NULL,
    p_valor_max NUMERIC DEFAULT NULL
)
RETURNS TABLE(
    cuenta VARCHAR,
    clave_catastral VARCHAR,
    propietario VARCHAR,
    domicilio_completo VARCHAR,
    colonia VARCHAR,
    uso_suelo VARCHAR,
    superficie_terreno NUMERIC,
    valor_catastral NUMERIC,
    estado VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_sql TEXT;
    v_where_parts TEXT[] := ARRAY[]::TEXT[];
    v_cuenta VARCHAR;
    v_propietario VARCHAR;
    v_colonia VARCHAR;
    v_uso_suelo VARCHAR;
BEGIN
    -- Preparar filtros
    v_cuenta := NULLIF(TRIM(COALESCE(p_cuenta, '')), '');
    v_propietario := NULLIF(TRIM(COALESCE(p_propietario, '')), '');
    v_colonia := NULLIF(TRIM(COALESCE(p_colonia, '')), '');
    v_uso_suelo := NULLIF(TRIM(COALESCE(p_uso_suelo, '')), '');

    -- Validar que al menos un criterio esté presente
    IF v_cuenta IS NULL
       AND v_propietario IS NULL
       AND v_colonia IS NULL
       AND v_uso_suelo IS NULL
       AND p_valor_min IS NULL
       AND p_valor_max IS NULL THEN
        RAISE EXCEPTION 'Debe proporcionar al menos un criterio de búsqueda';
    END IF;

    -- Construir consulta dinámica con RETURN QUERY
    RETURN QUERY
    SELECT
        p.cuenta::VARCHAR,
        COALESCE(p.clave_catastral, '')::VARCHAR,
        COALESCE(p.propietario, 'Sin propietario')::VARCHAR,
        COALESCE(
            CONCAT_WS(', ',
                p.domicilio,
                '#' || NULLIF(p.numero_exterior, ''),
                p.colonia,
                'CP ' || NULLIF(p.cp, '')
            ),
            'Sin domicilio'
        )::VARCHAR AS domicilio_completo,
        COALESCE(p.colonia, '')::VARCHAR AS colonia,
        COALESCE(p.uso_suelo, 'Sin especificar')::VARCHAR AS uso_suelo,
        COALESCE(p.superficie_terreno, 0)::NUMERIC,
        COALESCE(p.valor_catastral, 0)::NUMERIC,
        CASE
            WHEN p.activo THEN 'ACTIVO'
            ELSE 'INACTIVO'
        END::VARCHAR AS estado
    FROM comun.predios p
    WHERE p.activo = TRUE
      AND (v_cuenta IS NULL OR p.cuenta ILIKE v_cuenta || '%')
      AND (v_propietario IS NULL OR p.propietario ILIKE '%' || v_propietario || '%')
      AND (v_colonia IS NULL OR p.colonia ILIKE '%' || v_colonia || '%')
      AND (v_uso_suelo IS NULL OR p.uso_suelo ILIKE '%' || v_uso_suelo || '%')
      AND (p_valor_min IS NULL OR p.valor_catastral >= p_valor_min)
      AND (p_valor_max IS NULL OR p.valor_catastral <= p_valor_max)
    ORDER BY p.valor_catastral DESC, p.cuenta
    LIMIT 200;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error en sp_sgcv2_search_advanced: %', SQLERRM;
        RETURN;
END;
$$;

COMMENT ON FUNCTION comun.sp_sgcv2_search_advanced(VARCHAR, VARCHAR, VARCHAR, VARCHAR, NUMERIC, NUMERIC) IS
'Búsqueda avanzada de predios con múltiples criterios opcionales';

-- =============================================
-- SECCIÓN 3: VERIFICACIÓN DE INSTALACIÓN
-- =============================================

-- Verificar que todas las funciones fueron creadas
DO $$
DECLARE
    v_count INTEGER;
    v_functions TEXT[] := ARRAY[
        'sp_sgcv2_search_by_cuenta',
        'sp_sgcv2_search_by_propietario',
        'sp_sgcv2_search_by_domicilio',
        'sp_sgcv2_get_predio_detail',
        'sp_sgcv2_get_tramites_by_cuenta',
        'sp_sgcv2_create_tramite',
        'sp_sgcv2_update_tramite_status',
        'sp_sgcv2_get_estadisticas',
        'sp_sgcv2_search_advanced'
    ];
    v_func TEXT;
    v_missing TEXT[] := ARRAY[]::TEXT[];
BEGIN
    FOREACH v_func IN ARRAY v_functions LOOP
        SELECT COUNT(*) INTO v_count
        FROM information_schema.routines
        WHERE routine_schema = 'comun'
        AND routine_name = v_func;

        IF v_count = 0 THEN
            v_missing := array_append(v_missing, v_func);
        END IF;
    END LOOP;

    IF array_length(v_missing, 1) > 0 THEN
        RAISE WARNING 'Funciones faltantes: %', array_to_string(v_missing, ', ');
    ELSE
        RAISE NOTICE '✓ Todas las 9 funciones SGCV2 instaladas correctamente en schema comun';
    END IF;
END;
$$;

-- =============================================
-- RESUMEN DE FUNCIONES INSTALADAS
-- =============================================
/*
FUNCIONES SGCV2 IMPLEMENTADAS:
=============================

1. comun.sp_sgcv2_search_by_cuenta(p_cuenta)
   - Busca predios por cuenta catastral
   - Soporta búsqueda exacta y parcial (ILIKE)

2. comun.sp_sgcv2_search_by_propietario(p_nombre, p_limit)
   - Busca predios por nombre de propietario
   - Límite configurable (default 50, max 500)

3. comun.sp_sgcv2_search_by_domicilio(p_calle, p_numero, p_colonia)
   - Busca predios por domicilio
   - Filtros opcionales de número y colonia

4. comun.sp_sgcv2_get_predio_detail(p_cuenta)
   - Obtiene detalle completo de un predio
   - Incluye conteo de trámites asociados

5. comun.sp_sgcv2_get_tramites_by_cuenta(p_cuenta, p_estatus)
   - Lista trámites de una cuenta
   - Filtro opcional por estatus

6. comun.sp_sgcv2_create_tramite(p_cuenta, p_tipo, p_descripcion, p_usuario)
   - Crea nuevo trámite
   - Valida existencia de cuenta
   - Registra en historial

7. comun.sp_sgcv2_update_tramite_status(p_tramite_id, p_nuevo_estatus, p_observaciones, p_usuario)
   - Actualiza estatus de trámite
   - Valida estatus permitidos
   - Registra cambio en historial

8. comun.sp_sgcv2_get_estadisticas(p_fecha_desde, p_fecha_hasta)
   - Obtiene estadísticas del sistema
   - Filtro opcional de fechas

9. comun.sp_sgcv2_search_advanced(p_cuenta, p_propietario, p_colonia, p_uso_suelo, p_valor_min, p_valor_max)
   - Búsqueda avanzada multicriterio
   - Todos los parámetros opcionales

TABLAS AUXILIARES CREADAS:
==========================
- comun.predios (tabla principal de predios)
- comun.sgc_tramites (trámites del sistema)
- comun.sgc_tramites_historial (auditoría de cambios)

ESTATUS VÁLIDOS PARA TRÁMITES:
==============================
- PENDIENTE
- EN_PROCESO
- COMPLETADO
- CANCELADO
- RECHAZADO
*/

-- =============================================
-- FIN DEL SCRIPT
-- =============================================
