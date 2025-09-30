-- =====================================================================================
-- SISTEMA MUNICIPAL DIGITAL - GOBIERNO DE GUADALAJARA
-- =====================================================================================
-- Descripción: Stored Procedures para Nuevas Licencias
-- Autor: Sistema de Refactorización Vue.js
-- Fecha: 2025-09-29
-- Versión: 1.0
-- =====================================================================================

-- =====================================================================================
-- NOTA: Este módulo reutiliza las tablas existentes y agrega funcionalidad específica
-- para el proceso de nueva licencia
-- =====================================================================================

-- Usar las tablas existentes de registro_solicitudes y empresas
-- Solo agregar la tabla específica de licencias

-- Crear tabla licencias si no existe
DROP TABLE IF EXISTS informix.licencias CASCADE;

CREATE TABLE informix.licencias (
    id SERIAL PRIMARY KEY,
    folio_licencia VARCHAR(20) UNIQUE NOT NULL,
    id_solicitud INTEGER REFERENCES informix.registro_solicitudes(id),
    id_empresa INTEGER REFERENCES informix.empresas(id),

    -- Datos de la licencia
    tipo_licencia VARCHAR(50) DEFAULT 'NUEVA' CHECK (tipo_licencia IN ('NUEVA', 'RENOVACION', 'AMPLIACION', 'CAMBIO_DOMICILIO')),
    giro_principal VARCHAR(100) NOT NULL,
    giro_secundario VARCHAR(100),
    superficie_m2 DECIMAL(10,2),
    numero_empleados INTEGER DEFAULT 0,

    -- Vigencia
    fecha_expedicion DATE,
    fecha_inicio_vigencia DATE,
    fecha_fin_vigencia DATE,
    dias_vigencia INTEGER DEFAULT 365,

    -- Estado
    estado VARCHAR(20) DEFAULT 'EN_TRAMITE' CHECK (estado IN ('EN_TRAMITE', 'VIGENTE', 'VENCIDA', 'CANCELADA', 'SUSPENDIDA')),

    -- Pagos
    monto_total DECIMAL(10,2),
    monto_pagado DECIMAL(10,2) DEFAULT 0,
    fecha_pago TIMESTAMP,
    referencia_pago VARCHAR(50),

    -- Control
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_creacion VARCHAR(50) DEFAULT 'sistema',
    usuario_modificacion VARCHAR(50) DEFAULT 'sistema',
    observaciones TEXT
);

-- Índices
CREATE INDEX idx_licencias_folio ON informix.licencias(folio_licencia);
CREATE INDEX idx_licencias_estado ON informix.licencias(estado);
CREATE INDEX idx_licencias_vigencia ON informix.licencias(fecha_fin_vigencia);

-- =====================================================================================
-- 1. SP_NUEVA_LICENCIA_INICIAR - Iniciar proceso de nueva licencia
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_nueva_licencia_iniciar(
    p_tipo_licencia VARCHAR(50),
    p_giro_principal VARCHAR(100),
    p_nombre_solicitante VARCHAR(255),
    p_rfc_solicitante VARCHAR(13),
    p_nombre_comercial VARCHAR(255),
    p_direccion_negocio TEXT,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_superficie_m2 DECIMAL(10,2) DEFAULT NULL,
    p_numero_empleados INTEGER DEFAULT 0
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    folio_licencia VARCHAR(20),
    id_licencia INTEGER
) AS $$
DECLARE
    nuevo_folio VARCHAR(20);
    nuevo_id INTEGER;
    id_solicitud_nueva INTEGER;
BEGIN
    -- Primero crear la solicitud base
    INSERT INTO informix.registro_solicitudes (
        folio_formulario,
        nombre_solicitante,
        rfc_solicitante,
        telefono_solicitante,
        email_solicitante,
        nombre_comercial,
        giro,
        direccion_negocio,
        superficie_m2,
        numero_empleados,
        estado,
        tipo_solicitud
    ) VALUES (
        informix.generar_folio_formulario(),
        p_nombre_solicitante,
        UPPER(p_rfc_solicitante),
        p_telefono,
        LOWER(p_email),
        p_nombre_comercial,
        p_giro_principal,
        p_direccion_negocio,
        p_superficie_m2,
        p_numero_empleados,
        'PENDIENTE',
        p_tipo_licencia
    ) RETURNING id INTO id_solicitud_nueva;

    -- Generar folio de licencia
    nuevo_folio := 'LIC-' || EXTRACT(YEAR FROM CURRENT_DATE) || '-' || LPAD(nextval('informix.licencias_id_seq')::VARCHAR, 6, '0');

    -- Crear registro de licencia
    INSERT INTO informix.licencias (
        folio_licencia,
        id_solicitud,
        tipo_licencia,
        giro_principal,
        superficie_m2,
        numero_empleados,
        estado,
        usuario_creacion
    ) VALUES (
        nuevo_folio,
        id_solicitud_nueva,
        p_tipo_licencia,
        p_giro_principal,
        p_superficie_m2,
        p_numero_empleados,
        'EN_TRAMITE',
        'sistema'
    ) RETURNING id INTO nuevo_id;

    RETURN QUERY SELECT TRUE, 'Licencia iniciada exitosamente'::TEXT, nuevo_folio, nuevo_id;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al iniciar licencia: ' || SQLERRM)::TEXT, NULL::VARCHAR(20), NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 2. SP_NUEVA_LICENCIA_LIST - Listar licencias con filtros
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_nueva_licencia_list(
    p_folio_licencia VARCHAR(20) DEFAULT NULL,
    p_tipo_licencia VARCHAR(50) DEFAULT NULL,
    p_estado VARCHAR(20) DEFAULT NULL,
    p_nombre_comercial VARCHAR(255) DEFAULT NULL,
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_limite INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    folio_licencia VARCHAR(20),
    tipo_licencia VARCHAR(50),
    giro_principal VARCHAR(100),
    nombre_comercial VARCHAR(255),
    nombre_solicitante VARCHAR(255),
    rfc_solicitante VARCHAR(13),
    direccion_negocio TEXT,
    estado VARCHAR(20),
    fecha_expedicion DATE,
    fecha_fin_vigencia DATE,
    dias_restantes INTEGER,
    monto_total DECIMAL(10,2),
    monto_pagado DECIMAL(10,2),
    total_registros BIGINT
) AS $$
DECLARE
    total_count BIGINT;
BEGIN
    -- Contar total
    SELECT COUNT(*) INTO total_count
    FROM informix.licencias l
    INNER JOIN informix.registro_solicitudes s ON l.id_solicitud = s.id
    WHERE (p_folio_licencia IS NULL OR l.folio_licencia ILIKE '%' || p_folio_licencia || '%')
      AND (p_tipo_licencia IS NULL OR l.tipo_licencia = p_tipo_licencia)
      AND (p_estado IS NULL OR l.estado = p_estado)
      AND (p_nombre_comercial IS NULL OR s.nombre_comercial ILIKE '%' || p_nombre_comercial || '%')
      AND (p_fecha_inicio IS NULL OR l.fecha_creacion >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR l.fecha_creacion <= p_fecha_fin + INTERVAL '1 day');

    -- Retornar resultados
    RETURN QUERY
    SELECT
        l.id,
        l.folio_licencia,
        l.tipo_licencia,
        l.giro_principal,
        s.nombre_comercial,
        s.nombre_solicitante,
        s.rfc_solicitante,
        s.direccion_negocio,
        l.estado,
        l.fecha_expedicion,
        l.fecha_fin_vigencia,
        CASE
            WHEN l.fecha_fin_vigencia IS NOT NULL
            THEN GREATEST(0, (l.fecha_fin_vigencia - CURRENT_DATE)::INTEGER)
            ELSE NULL
        END as dias_restantes,
        l.monto_total,
        l.monto_pagado,
        total_count as total_registros
    FROM informix.licencias l
    INNER JOIN informix.registro_solicitudes s ON l.id_solicitud = s.id
    WHERE (p_folio_licencia IS NULL OR l.folio_licencia ILIKE '%' || p_folio_licencia || '%')
      AND (p_tipo_licencia IS NULL OR l.tipo_licencia = p_tipo_licencia)
      AND (p_estado IS NULL OR l.estado = p_estado)
      AND (p_nombre_comercial IS NULL OR s.nombre_comercial ILIKE '%' || p_nombre_comercial || '%')
      AND (p_fecha_inicio IS NULL OR l.fecha_creacion >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR l.fecha_creacion <= p_fecha_fin + INTERVAL '1 day')
    ORDER BY l.fecha_creacion DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 3. SP_NUEVA_LICENCIA_APROBAR - Aprobar y expedir licencia
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_nueva_licencia_aprobar(
    p_id INTEGER,
    p_monto_total DECIMAL(10,2),
    p_dias_vigencia INTEGER DEFAULT 365,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    folio_licencia VARCHAR(20)
) AS $$
DECLARE
    v_folio VARCHAR(20);
    v_estado_actual VARCHAR(20);
BEGIN
    -- Verificar estado actual
    SELECT folio_licencia, estado INTO v_folio, v_estado_actual
    FROM informix.licencias
    WHERE id = p_id;

    IF v_folio IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada'::TEXT, NULL::VARCHAR(20);
        RETURN;
    END IF;

    IF v_estado_actual != 'EN_TRAMITE' THEN
        RETURN QUERY SELECT FALSE, 'La licencia no está en trámite'::TEXT, v_folio;
        RETURN;
    END IF;

    -- Aprobar licencia
    UPDATE informix.licencias SET
        estado = 'VIGENTE',
        fecha_expedicion = CURRENT_DATE,
        fecha_inicio_vigencia = CURRENT_DATE,
        fecha_fin_vigencia = CURRENT_DATE + (p_dias_vigencia || ' days')::INTERVAL,
        dias_vigencia = p_dias_vigencia,
        monto_total = p_monto_total,
        observaciones = p_observaciones,
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    -- Actualizar estado de la solicitud
    UPDATE informix.registro_solicitudes SET
        estado = 'APROBADO',
        folio_solicitud = v_folio
    WHERE id = (SELECT id_solicitud FROM informix.licencias WHERE id = p_id);

    RETURN QUERY SELECT TRUE, 'Licencia aprobada y expedida exitosamente'::TEXT, v_folio;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al aprobar licencia: ' || SQLERRM)::TEXT, NULL::VARCHAR(20);
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 4. SP_NUEVA_LICENCIA_REGISTRAR_PAGO - Registrar pago de licencia
-- =====================================================================================

CREATE OR REPLACE FUNCTION informix.sp_nueva_licencia_registrar_pago(
    p_id INTEGER,
    p_monto_pago DECIMAL(10,2),
    p_referencia_pago VARCHAR(50),
    p_fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    saldo_pendiente DECIMAL(10,2)
) AS $$
DECLARE
    v_monto_total DECIMAL(10,2);
    v_monto_pagado DECIMAL(10,2);
    v_nuevo_saldo DECIMAL(10,2);
BEGIN
    -- Obtener montos actuales
    SELECT monto_total, COALESCE(monto_pagado, 0)
    INTO v_monto_total, v_monto_pagado
    FROM informix.licencias
    WHERE id = p_id;

    IF v_monto_total IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada'::TEXT, NULL::DECIMAL(10,2);
        RETURN;
    END IF;

    -- Calcular nuevo saldo
    v_nuevo_saldo := v_monto_total - (v_monto_pagado + p_monto_pago);

    -- Actualizar pago
    UPDATE informix.licencias SET
        monto_pagado = v_monto_pagado + p_monto_pago,
        fecha_pago = p_fecha_pago,
        referencia_pago = p_referencia_pago,
        usuario_modificacion = 'sistema'
    WHERE id = p_id;

    IF v_nuevo_saldo <= 0 THEN
        RETURN QUERY SELECT TRUE, 'Pago registrado. Licencia pagada completamente'::TEXT, 0::DECIMAL(10,2);
    ELSE
        RETURN QUERY SELECT TRUE, 'Pago registrado exitosamente'::TEXT, v_nuevo_saldo;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, ('Error al registrar pago: ' || SQLERRM)::TEXT, NULL::DECIMAL(10,2);
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- DATOS DE PRUEBA
-- =====================================================================================

-- Insertar licencias de prueba usando las funciones
SELECT * FROM informix.sp_nueva_licencia_iniciar(
    'NUEVA', 'ABARROTES', 'JUAN GARCÍA LÓPEZ', 'GALJ800515XXX',
    'Abarrotes Don Juan', 'AV. JUÁREZ 123, COL. CENTRO',
    '33-1234-5678', 'juan.garcia@email.com', 45.5, 2
);

SELECT * FROM informix.sp_nueva_licencia_iniciar(
    'RENOVACION', 'RESTAURANTE', 'MARÍA HERNÁNDEZ', 'HERM900820XXX',
    'Restaurante La Guadalajara', 'CALLE INDEPENDENCIA 456',
    '33-2345-6789', 'maria.hernandez@email.com', 120.0, 8
);

-- Aprobar una licencia de prueba
SELECT * FROM informix.sp_nueva_licencia_aprobar(1, 2500.00, 365, 'Documentación completa');

-- Registrar un pago
SELECT * FROM informix.sp_nueva_licencia_registrar_pago(1, 1500.00, 'REF-2025-001', CURRENT_TIMESTAMP);

-- =====================================================================================
-- PERMISOS Y COMENTARIOS
-- =====================================================================================

-- Comentarios en las tablas y funciones
COMMENT ON TABLE informix.licencias IS 'Registro de licencias municipales';
COMMENT ON FUNCTION informix.sp_nueva_licencia_iniciar IS 'Inicia proceso de nueva licencia';
COMMENT ON FUNCTION informix.sp_nueva_licencia_list IS 'Lista licencias con filtros';
COMMENT ON FUNCTION informix.sp_nueva_licencia_aprobar IS 'Aprueba y expide licencia';
COMMENT ON FUNCTION informix.sp_nueva_licencia_registrar_pago IS 'Registra pago de licencia';

-- =====================================================================================
-- FIN DEL ARCHIVO
-- =====================================================================================