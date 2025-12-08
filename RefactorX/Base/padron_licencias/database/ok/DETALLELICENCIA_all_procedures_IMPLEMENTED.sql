-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: comun
-- ============================================
\c padron_licencias;
SET search_path TO comun, public;

-- ============================================
-- STORED PROCEDURES PARA DETALLE Y SALDO DE LICENCIAS
-- Convención: SP_DETALLELICENCIA_XXX
-- Implementado: 2025-11-20
-- Tablas: comun.licencias, comun.pagos_licencia, comun.adeudos_licencia, comun.conceptos_pago
-- Módulo: DETALLELICENCIA - Detalle y saldo de licencias
-- ============================================

-- ============================================
-- TABLAS NECESARIAS PARA EL MÓDULO
-- ============================================

-- Tabla principal de licencias (si no existe)
CREATE TABLE IF NOT EXISTS comun.licencias (
    id_licencia SERIAL PRIMARY KEY,
    numero_licencia VARCHAR(100) NOT NULL UNIQUE,
    folio VARCHAR(100),
    tipo_licencia VARCHAR(50),
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255) NOT NULL,
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    direccion TEXT,
    giro VARCHAR(255),
    superficie_autorizada NUMERIC(10,2),
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    monto_anual NUMERIC(12,2) DEFAULT 0.00,
    monto_base NUMERIC(12,2) DEFAULT 0.00,
    estado VARCHAR(20) DEFAULT 'VIGENTE',
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de pagos de licencias
CREATE TABLE IF NOT EXISTS comun.pagos_licencia (
    id_pago SERIAL PRIMARY KEY,
    id_licencia INTEGER NOT NULL REFERENCES comun.licencias(id_licencia),
    numero_recibo VARCHAR(100) NOT NULL UNIQUE,
    folio_pago VARCHAR(100),
    fecha_pago DATE NOT NULL,
    ejercicio_fiscal INTEGER NOT NULL,
    concepto VARCHAR(255),
    monto_pagado NUMERIC(12,2) NOT NULL,
    recargos NUMERIC(12,2) DEFAULT 0.00,
    descuento NUMERIC(12,2) DEFAULT 0.00,
    total_pagado NUMERIC(12,2) NOT NULL,
    forma_pago VARCHAR(50), -- 'EFECTIVO', 'TARJETA', 'TRANSFERENCIA', 'CHEQUE'
    referencia_pago VARCHAR(100),
    observaciones TEXT,
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cancelado BOOLEAN DEFAULT FALSE,
    fecha_cancelacion TIMESTAMP,
    motivo_cancelacion TEXT
);

-- Tabla de adeudos de licencias
CREATE TABLE IF NOT EXISTS comun.adeudos_licencia (
    id_adeudo SERIAL PRIMARY KEY,
    id_licencia INTEGER NOT NULL REFERENCES comun.licencias(id_licencia),
    ejercicio_fiscal INTEGER NOT NULL,
    concepto VARCHAR(255) NOT NULL,
    monto_original NUMERIC(12,2) NOT NULL,
    monto_recargos NUMERIC(12,2) DEFAULT 0.00,
    monto_actualizacion NUMERIC(12,2) DEFAULT 0.00,
    monto_total NUMERIC(12,2) NOT NULL,
    monto_pagado NUMERIC(12,2) DEFAULT 0.00,
    saldo_pendiente NUMERIC(12,2) NOT NULL,
    fecha_vencimiento DATE,
    estado VARCHAR(20) DEFAULT 'PENDIENTE', -- 'PENDIENTE', 'PAGADO', 'VENCIDO'
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(id_licencia, ejercicio_fiscal, concepto)
);

-- Tabla de conceptos de pago
CREATE TABLE IF NOT EXISTS comun.conceptos_pago (
    id_concepto SERIAL PRIMARY KEY,
    codigo_concepto VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NOT NULL,
    tipo VARCHAR(50), -- 'ANUAL', 'RENOVACION', 'REFRENDO', 'MULTA', 'RECARGO'
    monto_base NUMERIC(12,2) DEFAULT 0.00,
    aplica_recargos BOOLEAN DEFAULT TRUE,
    activo BOOLEAN DEFAULT TRUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para optimización
CREATE INDEX IF NOT EXISTS idx_pagos_licencia ON comun.pagos_licencia(id_licencia);
CREATE INDEX IF NOT EXISTS idx_pagos_fecha ON comun.pagos_licencia(fecha_pago);
CREATE INDEX IF NOT EXISTS idx_pagos_ejercicio ON comun.pagos_licencia(ejercicio_fiscal);
CREATE INDEX IF NOT EXISTS idx_adeudos_licencia ON comun.adeudos_licencia(id_licencia);
CREATE INDEX IF NOT EXISTS idx_adeudos_ejercicio ON comun.adeudos_licencia(ejercicio_fiscal);
CREATE INDEX IF NOT EXISTS idx_adeudos_estado ON comun.adeudos_licencia(estado);

-- ============================================
-- SP 1/4: sp_get_saldo_licencia
-- Tipo: Report/Query
-- Descripción: Obtiene el saldo y adeudo actual de una licencia
--              Calcula adeudos pendientes, recargos y total a pagar
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_get_saldo_licencia(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL
)
RETURNS TABLE(
    id_licencia INTEGER,
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    razon_social VARCHAR(255),
    direccion TEXT,
    giro VARCHAR(255),
    estado_licencia VARCHAR(20),
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    dias_vencimiento INTEGER,
    monto_anual NUMERIC(12,2),
    total_adeudos NUMERIC(12,2),
    total_recargos NUMERIC(12,2),
    total_pagado NUMERIC(12,2),
    saldo_pendiente NUMERIC(12,2),
    ejercicios_adeudo INTEGER,
    ultimo_pago_fecha DATE,
    ultimo_pago_monto NUMERIC(12,2),
    detalle_adeudos JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_licencia INTEGER;
    v_total_adeudos NUMERIC(12,2);
    v_total_recargos NUMERIC(12,2);
    v_total_pagado NUMERIC(12,2);
    v_saldo_pendiente NUMERIC(12,2);
BEGIN
    -- Validar parámetros
    IF p_id_licencia IS NULL AND p_numero_licencia IS NULL THEN
        RAISE EXCEPTION 'Debe proporcionar número de licencia o ID de licencia';
    END IF;

    -- Obtener ID de licencia si solo se proporcionó número
    IF p_id_licencia IS NULL THEN
        SELECT l.id_licencia INTO v_id_licencia
        FROM comun.licencias l
        WHERE l.numero_licencia = p_numero_licencia;

        IF v_id_licencia IS NULL THEN
            RAISE EXCEPTION 'Licencia no encontrada: %', p_numero_licencia;
        END IF;
    ELSE
        v_id_licencia := p_id_licencia;
    END IF;

    -- Calcular totales de adeudos
    SELECT
        COALESCE(SUM(a.monto_original), 0),
        COALESCE(SUM(a.monto_recargos + a.monto_actualizacion), 0),
        COALESCE(SUM(a.saldo_pendiente), 0)
    INTO v_total_adeudos, v_total_recargos, v_saldo_pendiente
    FROM comun.adeudos_licencia a
    WHERE a.id_licencia = v_id_licencia
      AND a.estado IN ('PENDIENTE', 'VENCIDO');

    -- Calcular total pagado
    SELECT COALESCE(SUM(p.total_pagado), 0)
    INTO v_total_pagado
    FROM comun.pagos_licencia p
    WHERE p.id_licencia = v_id_licencia
      AND p.cancelado = FALSE;

    -- Retornar resultado con detalle completo
    RETURN QUERY
    SELECT
        l.id_licencia,
        l.numero_licencia,
        l.propietario,
        l.razon_social,
        l.direccion,
        l.giro,
        l.estado,
        l.fecha_expedicion,
        l.fecha_vencimiento,
        CASE
            WHEN l.fecha_vencimiento IS NULL THEN NULL
            ELSE (l.fecha_vencimiento - CURRENT_DATE)::INTEGER
        END as dias_vencimiento,
        l.monto_anual,
        v_total_adeudos as total_adeudos,
        v_total_recargos as total_recargos,
        v_total_pagado as total_pagado,
        v_saldo_pendiente as saldo_pendiente,
        (
            SELECT COUNT(DISTINCT a.ejercicio_fiscal)
            FROM comun.adeudos_licencia a
            WHERE a.id_licencia = v_id_licencia
              AND a.estado IN ('PENDIENTE', 'VENCIDO')
        )::INTEGER as ejercicios_adeudo,
        (
            SELECT p.fecha_pago
            FROM comun.pagos_licencia p
            WHERE p.id_licencia = v_id_licencia
              AND p.cancelado = FALSE
            ORDER BY p.fecha_pago DESC
            LIMIT 1
        ) as ultimo_pago_fecha,
        (
            SELECT p.total_pagado
            FROM comun.pagos_licencia p
            WHERE p.id_licencia = v_id_licencia
              AND p.cancelado = FALSE
            ORDER BY p.fecha_pago DESC
            LIMIT 1
        ) as ultimo_pago_monto,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'ejercicio', a.ejercicio_fiscal,
                    'concepto', a.concepto,
                    'monto_original', a.monto_original,
                    'recargos', a.monto_recargos,
                    'actualizacion', a.monto_actualizacion,
                    'total', a.monto_total,
                    'pagado', a.monto_pagado,
                    'saldo', a.saldo_pendiente,
                    'estado', a.estado,
                    'fecha_vencimiento', a.fecha_vencimiento
                )
            )
            FROM (
                SELECT *
                FROM comun.adeudos_licencia
                WHERE id_licencia = v_id_licencia
                  AND estado IN ('PENDIENTE', 'VENCIDO')
                ORDER BY ejercicio_fiscal DESC, concepto
            ) a
        ) as detalle_adeudos
    FROM comun.licencias l
    WHERE l.id_licencia = v_id_licencia;
END;
$$;

COMMENT ON FUNCTION comun.sp_get_saldo_licencia(VARCHAR, INTEGER) IS
'Obtiene el saldo completo y adeudos de una licencia con cálculo de recargos y total a pagar';

-- ============================================
-- SP 2/4: sp_get_detalle_licencia
-- Tipo: Read/Report
-- Descripción: Obtiene el detalle completo de una licencia
--              Incluye información general, adeudos y últimos pagos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_get_detalle_licencia(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL
)
RETURNS TABLE(
    -- Datos generales
    id_licencia INTEGER,
    numero_licencia VARCHAR(100),
    folio VARCHAR(100),
    tipo_licencia VARCHAR(50),
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    direccion TEXT,
    giro VARCHAR(255),
    superficie_autorizada NUMERIC(10,2),
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    dias_para_vencer INTEGER,
    monto_anual NUMERIC(12,2),
    monto_base NUMERIC(12,2),
    estado VARCHAR(20),
    -- Datos financieros
    total_adeudos NUMERIC(12,2),
    total_recargos NUMERIC(12,2),
    total_pagado_historico NUMERIC(12,2),
    saldo_pendiente NUMERIC(12,2),
    ejercicios_con_adeudo INTEGER,
    -- Último pago
    ultimo_pago_recibo VARCHAR(100),
    ultimo_pago_fecha DATE,
    ultimo_pago_monto NUMERIC(12,2),
    -- Datos de registro
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    -- Detalles JSONB
    adeudos_detalle JSONB,
    pagos_recientes JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_licencia INTEGER;
BEGIN
    -- Validar parámetros
    IF p_id_licencia IS NULL AND p_numero_licencia IS NULL THEN
        RAISE EXCEPTION 'Debe proporcionar número de licencia o ID de licencia';
    END IF;

    -- Obtener ID de licencia
    IF p_id_licencia IS NULL THEN
        SELECT l.id_licencia INTO v_id_licencia
        FROM comun.licencias l
        WHERE l.numero_licencia = p_numero_licencia;

        IF v_id_licencia IS NULL THEN
            RAISE EXCEPTION 'Licencia no encontrada: %', p_numero_licencia;
        END IF;
    ELSE
        v_id_licencia := p_id_licencia;
    END IF;

    -- Retornar detalle completo
    RETURN QUERY
    SELECT
        -- Datos generales
        l.id_licencia,
        l.numero_licencia,
        l.folio,
        l.tipo_licencia,
        l.cuenta_predial,
        l.propietario,
        l.razon_social,
        l.rfc,
        l.direccion,
        l.giro,
        l.superficie_autorizada,
        l.fecha_expedicion,
        l.fecha_vencimiento,
        CASE
            WHEN l.fecha_vencimiento IS NULL THEN NULL
            ELSE (l.fecha_vencimiento - CURRENT_DATE)::INTEGER
        END as dias_para_vencer,
        l.monto_anual,
        l.monto_base,
        l.estado,
        -- Datos financieros
        COALESCE((
            SELECT SUM(a.monto_original)
            FROM comun.adeudos_licencia a
            WHERE a.id_licencia = l.id_licencia
              AND a.estado IN ('PENDIENTE', 'VENCIDO')
        ), 0) as total_adeudos,
        COALESCE((
            SELECT SUM(a.monto_recargos + a.monto_actualizacion)
            FROM comun.adeudos_licencia a
            WHERE a.id_licencia = l.id_licencia
              AND a.estado IN ('PENDIENTE', 'VENCIDO')
        ), 0) as total_recargos,
        COALESCE((
            SELECT SUM(p.total_pagado)
            FROM comun.pagos_licencia p
            WHERE p.id_licencia = l.id_licencia
              AND p.cancelado = FALSE
        ), 0) as total_pagado_historico,
        COALESCE((
            SELECT SUM(a.saldo_pendiente)
            FROM comun.adeudos_licencia a
            WHERE a.id_licencia = l.id_licencia
              AND a.estado IN ('PENDIENTE', 'VENCIDO')
        ), 0) as saldo_pendiente,
        COALESCE((
            SELECT COUNT(DISTINCT a.ejercicio_fiscal)
            FROM comun.adeudos_licencia a
            WHERE a.id_licencia = l.id_licencia
              AND a.estado IN ('PENDIENTE', 'VENCIDO')
        ), 0)::INTEGER as ejercicios_con_adeudo,
        -- Último pago
        (
            SELECT p.numero_recibo
            FROM comun.pagos_licencia p
            WHERE p.id_licencia = l.id_licencia
              AND p.cancelado = FALSE
            ORDER BY p.fecha_pago DESC
            LIMIT 1
        ) as ultimo_pago_recibo,
        (
            SELECT p.fecha_pago
            FROM comun.pagos_licencia p
            WHERE p.id_licencia = l.id_licencia
              AND p.cancelado = FALSE
            ORDER BY p.fecha_pago DESC
            LIMIT 1
        ) as ultimo_pago_fecha,
        (
            SELECT p.total_pagado
            FROM comun.pagos_licencia p
            WHERE p.id_licencia = l.id_licencia
              AND p.cancelado = FALSE
            ORDER BY p.fecha_pago DESC
            LIMIT 1
        ) as ultimo_pago_monto,
        -- Datos de registro
        l.usuario_registro,
        l.fecha_registro,
        l.fecha_actualizacion,
        -- Adeudos detallados
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id_adeudo', a.id_adeudo,
                    'ejercicio', a.ejercicio_fiscal,
                    'concepto', a.concepto,
                    'monto_original', a.monto_original,
                    'recargos', a.monto_recargos,
                    'actualizacion', a.monto_actualizacion,
                    'total', a.monto_total,
                    'pagado', a.monto_pagado,
                    'saldo', a.saldo_pendiente,
                    'estado', a.estado,
                    'fecha_vencimiento', a.fecha_vencimiento,
                    'dias_vencidos', CASE
                        WHEN a.fecha_vencimiento < CURRENT_DATE THEN (CURRENT_DATE - a.fecha_vencimiento)::INTEGER
                        ELSE 0
                    END
                )
                ORDER BY a.ejercicio_fiscal DESC, a.concepto
            )
            FROM comun.adeudos_licencia a
            WHERE a.id_licencia = l.id_licencia
              AND a.estado IN ('PENDIENTE', 'VENCIDO')
        ) as adeudos_detalle,
        -- Últimos 5 pagos
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'id_pago', p.id_pago,
                    'numero_recibo', p.numero_recibo,
                    'fecha_pago', p.fecha_pago,
                    'ejercicio', p.ejercicio_fiscal,
                    'concepto', p.concepto,
                    'monto_pagado', p.monto_pagado,
                    'recargos', p.recargos,
                    'descuento', p.descuento,
                    'total_pagado', p.total_pagado,
                    'forma_pago', p.forma_pago,
                    'usuario', p.usuario_registro
                )
                ORDER BY p.fecha_pago DESC
            )
            FROM (
                SELECT *
                FROM comun.pagos_licencia
                WHERE id_licencia = l.id_licencia
                  AND cancelado = FALSE
                ORDER BY fecha_pago DESC
                LIMIT 5
            ) p
        ) as pagos_recientes
    FROM comun.licencias l
    WHERE l.id_licencia = v_id_licencia;
END;
$$;

COMMENT ON FUNCTION comun.sp_get_detalle_licencia(VARCHAR, INTEGER) IS
'Obtiene el detalle completo de una licencia con información financiera, adeudos y pagos recientes';

-- ============================================
-- SP 3/4: sp_get_historial_pagos
-- Tipo: Report/List
-- Descripción: Obtiene el historial completo de pagos de una licencia
--              Con filtros por fecha, ejercicio y paginación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_get_historial_pagos(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_ejercicio_fiscal INTEGER DEFAULT NULL,
    p_incluir_cancelados BOOLEAN DEFAULT FALSE,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id_pago INTEGER,
    numero_recibo VARCHAR(100),
    folio_pago VARCHAR(100),
    fecha_pago DATE,
    ejercicio_fiscal INTEGER,
    concepto VARCHAR(255),
    monto_pagado NUMERIC(12,2),
    recargos NUMERIC(12,2),
    descuento NUMERIC(12,2),
    total_pagado NUMERIC(12,2),
    forma_pago VARCHAR(50),
    referencia_pago VARCHAR(100),
    observaciones TEXT,
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP,
    cancelado BOOLEAN,
    fecha_cancelacion TIMESTAMP,
    motivo_cancelacion TEXT,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_licencia INTEGER;
    v_total_count BIGINT;
BEGIN
    -- Validar parámetros
    IF p_id_licencia IS NULL AND p_numero_licencia IS NULL THEN
        RAISE EXCEPTION 'Debe proporcionar número de licencia o ID de licencia';
    END IF;

    -- Obtener ID de licencia
    IF p_id_licencia IS NULL THEN
        SELECT l.id_licencia INTO v_id_licencia
        FROM comun.licencias l
        WHERE l.numero_licencia = p_numero_licencia;

        IF v_id_licencia IS NULL THEN
            RAISE EXCEPTION 'Licencia no encontrada: %', p_numero_licencia;
        END IF;
    ELSE
        v_id_licencia := p_id_licencia;
    END IF;

    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM comun.pagos_licencia p
    WHERE p.id_licencia = v_id_licencia
      AND (p_incluir_cancelados = TRUE OR p.cancelado = FALSE)
      AND (p_fecha_inicio IS NULL OR p.fecha_pago >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR p.fecha_pago <= p_fecha_fin)
      AND (p_ejercicio_fiscal IS NULL OR p.ejercicio_fiscal = p_ejercicio_fiscal);

    -- Retornar historial de pagos
    RETURN QUERY
    SELECT
        p.id_pago,
        p.numero_recibo,
        p.folio_pago,
        p.fecha_pago,
        p.ejercicio_fiscal,
        p.concepto,
        p.monto_pagado,
        p.recargos,
        p.descuento,
        p.total_pagado,
        p.forma_pago,
        p.referencia_pago,
        p.observaciones,
        p.usuario_registro,
        p.fecha_registro,
        p.cancelado,
        p.fecha_cancelacion,
        p.motivo_cancelacion,
        v_total_count as total_registros
    FROM comun.pagos_licencia p
    WHERE p.id_licencia = v_id_licencia
      AND (p_incluir_cancelados = TRUE OR p.cancelado = FALSE)
      AND (p_fecha_inicio IS NULL OR p.fecha_pago >= p_fecha_inicio)
      AND (p_fecha_fin IS NULL OR p.fecha_pago <= p_fecha_fin)
      AND (p_ejercicio_fiscal IS NULL OR p.ejercicio_fiscal = p_ejercicio_fiscal)
    ORDER BY p.fecha_pago DESC, p.fecha_registro DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

COMMENT ON FUNCTION comun.sp_get_historial_pagos(VARCHAR, INTEGER, DATE, DATE, INTEGER, BOOLEAN, INTEGER, INTEGER) IS
'Obtiene el historial completo de pagos de una licencia con filtros avanzados y paginación';

-- ============================================
-- SP 4/4: sp_calcular_adeudo_licencia
-- Tipo: Function/Calculation
-- Descripción: Calcula el adeudo total de una licencia incluyendo recargos
--              Actualiza automáticamente los montos de recargos y actualización
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_calcular_adeudo_licencia(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_tasa_recargo_mensual NUMERIC(5,4) DEFAULT 0.02, -- 2% mensual por defecto
    p_actualizar_registros BOOLEAN DEFAULT TRUE
)
RETURNS TABLE(
    id_licencia INTEGER,
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    total_ejercicios INTEGER,
    total_adeudo_original NUMERIC(12,2),
    total_recargos_calculados NUMERIC(12,2),
    total_actualizacion NUMERIC(12,2),
    total_general NUMERIC(12,2),
    total_pagado NUMERIC(12,2),
    saldo_pendiente_total NUMERIC(12,2),
    fecha_calculo TIMESTAMP,
    detalle_por_ejercicio JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_licencia INTEGER;
    v_adeudo RECORD;
    v_meses_vencidos INTEGER;
    v_recargo_calculado NUMERIC(12,2);
    v_actualizacion NUMERIC(12,2);
    v_total_ejercicios INTEGER;
    v_total_adeudo NUMERIC(12,2);
    v_total_recargos NUMERIC(12,2);
    v_total_actualizacion NUMERIC(12,2);
    v_total_general NUMERIC(12,2);
    v_total_pagado NUMERIC(12,2);
    v_saldo_total NUMERIC(12,2);
BEGIN
    -- Validar parámetros
    IF p_id_licencia IS NULL AND p_numero_licencia IS NULL THEN
        RAISE EXCEPTION 'Debe proporcionar número de licencia o ID de licencia';
    END IF;

    -- Obtener ID de licencia
    IF p_id_licencia IS NULL THEN
        SELECT l.id_licencia INTO v_id_licencia
        FROM comun.licencias l
        WHERE l.numero_licencia = p_numero_licencia;

        IF v_id_licencia IS NULL THEN
            RAISE EXCEPTION 'Licencia no encontrada: %', p_numero_licencia;
        END IF;
    ELSE
        v_id_licencia := p_id_licencia;
    END IF;

    -- Inicializar totales
    v_total_adeudo := 0;
    v_total_recargos := 0;
    v_total_actualizacion := 0;

    -- Calcular recargos para cada adeudo pendiente
    FOR v_adeudo IN
        SELECT * FROM comun.adeudos_licencia
        WHERE id_licencia = v_id_licencia
          AND estado IN ('PENDIENTE', 'VENCIDO')
    LOOP
        -- Calcular meses de vencimiento
        IF v_adeudo.fecha_vencimiento IS NOT NULL AND v_adeudo.fecha_vencimiento < CURRENT_DATE THEN
            v_meses_vencidos := EXTRACT(YEAR FROM AGE(CURRENT_DATE, v_adeudo.fecha_vencimiento)) * 12
                              + EXTRACT(MONTH FROM AGE(CURRENT_DATE, v_adeudo.fecha_vencimiento));
        ELSE
            v_meses_vencidos := 0;
        END IF;

        -- Calcular recargo (2% mensual sobre saldo pendiente)
        IF v_meses_vencidos > 0 THEN
            v_recargo_calculado := v_adeudo.saldo_pendiente * p_tasa_recargo_mensual * v_meses_vencidos;
        ELSE
            v_recargo_calculado := 0;
        END IF;

        -- Calcular actualización (1.5% anual sobre monto original)
        v_actualizacion := v_adeudo.monto_original * 0.015 * (v_meses_vencidos / 12.0);

        -- Actualizar registro si se solicita
        IF p_actualizar_registros THEN
            UPDATE comun.adeudos_licencia
            SET monto_recargos = v_recargo_calculado,
                monto_actualizacion = v_actualizacion,
                monto_total = monto_original + v_recargo_calculado + v_actualizacion,
                fecha_actualizacion = CURRENT_TIMESTAMP
            WHERE id_adeudo = v_adeudo.id_adeudo;
        END IF;

        -- Acumular totales
        v_total_adeudo := v_total_adeudo + v_adeudo.monto_original;
        v_total_recargos := v_total_recargos + v_recargo_calculado;
        v_total_actualizacion := v_total_actualizacion + v_actualizacion;
    END LOOP;

    -- Calcular totales generales
    v_total_general := v_total_adeudo + v_total_recargos + v_total_actualizacion;

    SELECT COALESCE(SUM(total_pagado), 0)
    INTO v_total_pagado
    FROM comun.pagos_licencia
    WHERE id_licencia = v_id_licencia
      AND cancelado = FALSE;

    v_saldo_total := v_total_general - v_total_pagado;

    SELECT COUNT(DISTINCT ejercicio_fiscal)
    INTO v_total_ejercicios
    FROM comun.adeudos_licencia
    WHERE id_licencia = v_id_licencia
      AND estado IN ('PENDIENTE', 'VENCIDO');

    -- Retornar resultado
    RETURN QUERY
    SELECT
        l.id_licencia,
        l.numero_licencia,
        l.propietario,
        v_total_ejercicios::INTEGER as total_ejercicios,
        v_total_adeudo as total_adeudo_original,
        v_total_recargos as total_recargos_calculados,
        v_total_actualizacion as total_actualizacion,
        v_total_general as total_general,
        v_total_pagado as total_pagado,
        v_saldo_total as saldo_pendiente_total,
        CURRENT_TIMESTAMP as fecha_calculo,
        (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'ejercicio', a.ejercicio_fiscal,
                    'concepto', a.concepto,
                    'monto_original', a.monto_original,
                    'meses_vencidos', CASE
                        WHEN a.fecha_vencimiento IS NOT NULL AND a.fecha_vencimiento < CURRENT_DATE
                        THEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, a.fecha_vencimiento)) * 12
                           + EXTRACT(MONTH FROM AGE(CURRENT_DATE, a.fecha_vencimiento))
                        ELSE 0
                    END,
                    'recargos', a.monto_recargos,
                    'actualizacion', a.monto_actualizacion,
                    'total', a.monto_total,
                    'pagado', a.monto_pagado,
                    'saldo', a.saldo_pendiente,
                    'estado', a.estado,
                    'fecha_vencimiento', a.fecha_vencimiento
                )
                ORDER BY a.ejercicio_fiscal DESC
            )
            FROM comun.adeudos_licencia a
            WHERE a.id_licencia = l.id_licencia
              AND a.estado IN ('PENDIENTE', 'VENCIDO')
        ) as detalle_por_ejercicio
    FROM comun.licencias l
    WHERE l.id_licencia = v_id_licencia;
END;
$$;

COMMENT ON FUNCTION comun.sp_calcular_adeudo_licencia(VARCHAR, INTEGER, NUMERIC, BOOLEAN) IS
'Calcula el adeudo total de una licencia incluyendo recargos y actualización, con opción de actualizar registros';

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

-- Otorgar permisos de ejecución a rol de aplicación
GRANT EXECUTE ON FUNCTION comun.sp_get_saldo_licencia(VARCHAR, INTEGER) TO padron_licencias_app;
GRANT EXECUTE ON FUNCTION comun.sp_get_detalle_licencia(VARCHAR, INTEGER) TO padron_licencias_app;
GRANT EXECUTE ON FUNCTION comun.sp_get_historial_pagos(VARCHAR, INTEGER, DATE, DATE, INTEGER, BOOLEAN, INTEGER, INTEGER) TO padron_licencias_app;
GRANT EXECUTE ON FUNCTION comun.sp_calcular_adeudo_licencia(VARCHAR, INTEGER, NUMERIC, BOOLEAN) TO padron_licencias_app;

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
-- Total de Stored Procedures: 4
--
-- 1. sp_get_saldo_licencia - Obtiene saldo y adeudo actual con cálculos
-- 2. sp_get_detalle_licencia - Detalle completo de licencia con financiero
-- 3. sp_get_historial_pagos - Historial de pagos con filtros avanzados
-- 4. sp_calcular_adeudo_licencia - Calcula adeudos con recargos y actualización
--
-- Tablas utilizadas:
-- - comun.licencias (licencias principales)
-- - comun.pagos_licencia (registro de pagos)
-- - comun.adeudos_licencia (adeudos pendientes)
-- - comun.conceptos_pago (catálogo de conceptos)
--
-- Características implementadas:
-- - Cálculo automático de recargos por mora (2% mensual)
-- - Cálculo de actualización (1.5% anual)
-- - Detalle de adeudos por ejercicio fiscal
-- - Historial completo de pagos
-- - Soporte para pagos cancelados
-- - Paginación en consultas
-- - Validaciones de datos
-- - Manejo de errores
-- - Índices para optimización
-- - Comentarios descriptivos
-- ============================================
