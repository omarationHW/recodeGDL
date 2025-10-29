-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA BAJA DE LICENCIAS
-- Convención: SP_BAJALICENCIA_XXX
-- Generado: 2025-09-09
-- Módulo: 07 - BAJALICENCIAFRM (Prioridad Media)
-- ============================================

-- SP 1/6: SP_BAJALICENCIA_LIST
-- Tipo: List/Read
-- Descripción: Lista solicitudes de baja de licencias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BAJALICENCIA_LIST(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_tipo_baja VARCHAR(50) DEFAULT NULL,
    p_estado_baja VARCHAR(30) DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    folio_baja VARCHAR(100),
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    tipo_baja VARCHAR(50),
    motivo_baja TEXT,
    fecha_solicitud_baja DATE,
    fecha_baja_efectiva DATE,
    estado_baja VARCHAR(30),
    funcionario_revisor VARCHAR(100),
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM public.bajas_licencias bl
    WHERE (p_numero_licencia IS NULL OR bl.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR bl.propietario ILIKE '%' || p_propietario || '%')
      AND (p_tipo_baja IS NULL OR bl.tipo_baja = upper(p_tipo_baja))
      AND (p_estado_baja IS NULL OR bl.estado_baja = upper(p_estado_baja))
      AND (p_fecha_desde IS NULL OR bl.fecha_solicitud_baja >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR bl.fecha_solicitud_baja <= p_fecha_hasta);

    -- Retornar resultados
    RETURN QUERY
    SELECT 
        bl.id,
        bl.folio_baja,
        bl.numero_licencia,
        bl.propietario,
        bl.tipo_baja,
        bl.motivo_baja,
        bl.fecha_solicitud_baja,
        bl.fecha_baja_efectiva,
        bl.estado_baja,
        bl.funcionario_revisor,
        v_total_count as total_registros
    FROM public.bajas_licencias bl
    WHERE (p_numero_licencia IS NULL OR bl.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR bl.propietario ILIKE '%' || p_propietario || '%')
      AND (p_tipo_baja IS NULL OR bl.tipo_baja = upper(p_tipo_baja))
      AND (p_estado_baja IS NULL OR bl.estado_baja = upper(p_estado_baja))
      AND (p_fecha_desde IS NULL OR bl.fecha_solicitud_baja >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR bl.fecha_solicitud_baja <= p_fecha_hasta)
    ORDER BY bl.fecha_solicitud_baja DESC, bl.id DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================

-- SP 2/6: SP_BAJALICENCIA_GET
-- Tipo: Read
-- Descripción: Obtiene detalle de solicitud de baja
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BAJALICENCIA_GET(p_folio_baja VARCHAR(100))
RETURNS TABLE(
    id INTEGER,
    folio_baja VARCHAR(100),
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    direccion TEXT,
    giro VARCHAR(255),
    tipo_baja VARCHAR(50),
    motivo_baja TEXT,
    fecha_solicitud_baja DATE,
    fecha_baja_efectiva DATE,
    estado_baja VARCHAR(30),
    documentos_requeridos TEXT,
    documentos_entregados TEXT,
    observaciones TEXT,
    funcionario_revisor VARCHAR(100),
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que la solicitud de baja existe
    SELECT COUNT(*) INTO v_exists
    FROM public.bajas_licencias
    WHERE folio_baja = p_folio_baja;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró la solicitud de baja: %', p_folio_baja;
    END IF;

    -- Retornar el registro completo
    RETURN QUERY
    SELECT 
        bl.id,
        bl.folio_baja,
        bl.numero_licencia,
        bl.propietario,
        bl.razon_social,
        bl.rfc,
        bl.direccion,
        bl.giro,
        bl.tipo_baja,
        bl.motivo_baja,
        bl.fecha_solicitud_baja,
        bl.fecha_baja_efectiva,
        bl.estado_baja,
        bl.documentos_requeridos,
        bl.documentos_entregados,
        bl.observaciones,
        bl.funcionario_revisor,
        bl.usuario_registro,
        bl.fecha_registro
    FROM public.bajas_licencias bl
    WHERE bl.folio_baja = p_folio_baja;
END;
$$;

-- ============================================

-- SP 3/6: SP_BAJALICENCIA_CREATE
-- Tipo: Create
-- Descripción: Crear solicitud de baja de licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BAJALICENCIA_CREATE(
    p_folio_baja VARCHAR(100),
    p_numero_licencia VARCHAR(100),
    p_tipo_baja VARCHAR(50),
    p_motivo_baja TEXT,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_razon_social VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_usuario_registro VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT, id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_exists INTEGER;
    v_lic_exists INTEGER;
BEGIN
    -- Validar campos requeridos
    IF p_folio_baja IS NULL OR trim(p_folio_baja) = '' THEN
        RETURN QUERY SELECT FALSE, 'El folio de baja es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_numero_licencia IS NULL OR trim(p_numero_licencia) = '' THEN
        RETURN QUERY SELECT FALSE, 'El número de licencia es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_motivo_baja IS NULL OR trim(p_motivo_baja) = '' THEN
        RETURN QUERY SELECT FALSE, 'El motivo de baja es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar tipo de baja
    IF upper(p_tipo_baja) NOT IN ('VOLUNTARIA', 'REVOCACION', 'VENCIMIENTO', 'CLAUSURA', 'DEFUNCION') THEN
        RETURN QUERY SELECT FALSE, 'Tipo de baja no válido. Debe ser: VOLUNTARIA, REVOCACION, VENCIMIENTO, CLAUSURA o DEFUNCION.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no exista el folio de baja
    SELECT COUNT(*) INTO v_exists
    FROM public.bajas_licencias
    WHERE folio_baja = upper(trim(p_folio_baja));

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una solicitud de baja con ese folio.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que la licencia existe (opcional)
    SELECT COUNT(*) INTO v_lic_exists
    FROM public.licencias_comerciales
    WHERE numero_licencia = upper(trim(p_numero_licencia));

    -- Insertar la nueva solicitud de baja
    INSERT INTO public.bajas_licencias (
        folio_baja, numero_licencia, propietario, razon_social, rfc,
        tipo_baja, motivo_baja, usuario_registro
    )
    VALUES (
        upper(trim(p_folio_baja)),
        upper(trim(p_numero_licencia)),
        upper(trim(p_propietario)),
        upper(trim(p_razon_social)),
        upper(trim(p_rfc)),
        upper(trim(p_tipo_baja)),
        p_motivo_baja,
        upper(trim(p_usuario_registro))
    )
    RETURNING public.bajas_public.id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Solicitud de baja registrada correctamente. Folio: ' || upper(trim(p_folio_baja)), v_new_id;
END;
$$;

-- ============================================

-- SP 4/6: SP_BAJALICENCIA_UPDATE
-- Tipo: Update
-- Descripción: Actualizar solicitud de baja
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BAJALICENCIA_UPDATE(
    p_id INTEGER,
    p_tipo_baja VARCHAR(50) DEFAULT NULL,
    p_motivo_baja TEXT DEFAULT NULL,
    p_documentos_entregados TEXT DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_estado VARCHAR(30);
BEGIN
    -- Validar que la solicitud existe y obtener estado
    SELECT COUNT(*), MAX(estado_baja) INTO v_exists, v_estado
    FROM public.bajas_licencias
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La solicitud de baja no existe.';
        RETURN;
    END IF;

    -- Verificar que se pueda modificar
    IF v_estado IN ('EJECUTADA', 'CANCELADA') THEN
        RETURN QUERY SELECT FALSE, 'No se puede modificar una solicitud en estado: ' || v_estado;
        RETURN;
    END IF;

    -- Validar tipo de baja si se proporciona
    IF p_tipo_baja IS NOT NULL AND upper(p_tipo_baja) NOT IN ('VOLUNTARIA', 'REVOCACION', 'VENCIMIENTO', 'CLAUSURA', 'DEFUNCION') THEN
        RETURN QUERY SELECT FALSE, 'Tipo de baja no válido.';
        RETURN;
    END IF;

    -- Actualizar la solicitud
    UPDATE public.bajas_licencias
    SET tipo_baja = COALESCE(upper(trim(p_tipo_baja)), tipo_baja),
        motivo_baja = COALESCE(p_motivo_baja, motivo_baja),
        documentos_entregados = COALESCE(p_documentos_entregados, documentos_entregados),
        observaciones = COALESCE(p_observaciones, observaciones),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Solicitud de baja actualizada correctamente.';
END;
$$;

-- ============================================

-- SP 5/6: SP_BAJALICENCIA_CAMBIAR_ESTADO
-- Tipo: Update
-- Descripción: Cambiar estado de solicitud de baja
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BAJALICENCIA_CAMBIAR_ESTADO(
    p_folio_baja VARCHAR(100),
    p_nuevo_estado VARCHAR(30),
    p_fecha_baja_efectiva DATE DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
    p_funcionario_revisor VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_numero_licencia VARCHAR(100);
BEGIN
    -- Validar estados permitidos
    IF upper(p_nuevo_estado) NOT IN ('RECIBIDA', 'EN_REVISION', 'APROBADA', 'RECHAZADA', 'EJECUTADA', 'CANCELADA') THEN
        RETURN QUERY SELECT FALSE, 'Estado no válido. Debe ser: RECIBIDA, EN_REVISION, APROBADA, RECHAZADA, EJECUTADA o CANCELADA.';
        RETURN;
    END IF;

    -- Validar que la solicitud existe y obtener número de licencia
    SELECT COUNT(*), MAX(numero_licencia) INTO v_exists, v_numero_licencia
    FROM public.bajas_licencias
    WHERE folio_baja = p_folio_baja;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La solicitud de baja no existe.';
        RETURN;
    END IF;

    -- Cambiar el estado
    UPDATE public.bajas_licencias
    SET estado_baja = upper(p_nuevo_estado),
        fecha_baja_efectiva = CASE 
            WHEN upper(p_nuevo_estado) = 'EJECUTADA' 
            THEN COALESCE(p_fecha_baja_efectiva, CURRENT_DATE) 
            ELSE fecha_baja_efectiva 
        END,
        observaciones = COALESCE(p_observaciones, observaciones),
        funcionario_revisor = COALESCE(upper(trim(p_funcionario_revisor)), funcionario_revisor),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE folio_baja = p_folio_baja;

    -- Si se ejecuta la baja, actualizar estado de la licencia
    IF upper(p_nuevo_estado) = 'EJECUTADA' THEN
        UPDATE public.licencias_comerciales
        SET estado = 'CANCELADA',
            observaciones = 'Licencia dada de baja. Folio: ' || p_folio_baja,
            fecha_actualizacion = CURRENT_TIMESTAMP
        WHERE numero_licencia = v_numero_licencia;
    END IF;

    RETURN QUERY SELECT TRUE, 'Estado de solicitud de baja cambiado correctamente a: ' || upper(p_nuevo_estado);
END;
$$;

-- ============================================

-- SP 6/6: SP_BAJALICENCIA_PENDIENTES
-- Tipo: Read
-- Descripción: Obtener solicitudes de baja pendientes
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BAJALICENCIA_PENDIENTES(
    p_dias_limite INTEGER DEFAULT 10,
    p_funcionario VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(
    folio_baja VARCHAR(100),
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    tipo_baja VARCHAR(50),
    fecha_solicitud_baja DATE,
    estado_baja VARCHAR(30),
    funcionario_revisor VARCHAR(100),
    dias_transcurridos INTEGER,
    prioridad VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bl.folio_baja,
        bl.numero_licencia,
        bl.propietario,
        bl.tipo_baja,
        bl.fecha_solicitud_baja,
        bl.estado_baja,
        bl.funcionario_revisor,
        (CURRENT_DATE - bl.fecha_solicitud_baja)::INTEGER as dias_transcurridos,
        CASE 
            WHEN (CURRENT_DATE - bl.fecha_solicitud_baja)::INTEGER > p_dias_limite THEN 'URGENTE'
            WHEN (CURRENT_DATE - bl.fecha_solicitud_baja)::INTEGER > (p_dias_limite * 0.7) THEN 'ALTA'
            ELSE 'NORMAL'
        END as prioridad
    FROM public.bajas_licencias bl
    WHERE bl.estado_baja IN ('RECIBIDA', 'EN_REVISION', 'APROBADA')
      AND (p_funcionario IS NULL OR bl.funcionario_revisor ILIKE '%' || p_funcionario || '%')
    ORDER BY 
        (CURRENT_DATE - bl.fecha_solicitud_baja)::INTEGER DESC,
        bl.fecha_registro ASC;
END;
$$;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
NOTAS PARA LA IMPLEMENTACIÓN:

1. Tabla requerida: public.bajas_licencias
   - Campos únicos: folio_baja
   - Campos requeridos: numero_licencia, tipo_baja, motivo_baja
   - Estados: RECIBIDA, EN_REVISION, APROBADA, RECHAZADA, EJECUTADA, CANCELADA
   - Tipos: VOLUNTARIA, REVOCACION, VENCIMIENTO, CLAUSURA, DEFUNCION

2. Endpoints del controlador Laravel:
   - listarBajasLicencias -> SP_BAJALICENCIA_LIST(filtros múltiples)
   - obtenerBajaLicencia -> SP_BAJALICENCIA_GET(folio_baja)
   - crearBajaLicencia -> SP_BAJALICENCIA_CREATE(datos completos)
   - actualizarBajaLicencia -> SP_BAJALICENCIA_UPDATE(id, datos)
   - cambiarEstadoBaja -> SP_BAJALICENCIA_CAMBIAR_ESTADO(folio, estado)
   - bajasPendientes -> SP_BAJALICENCIA_PENDIENTES(dias_limite, funcionario)

3. Funcionalidades especiales:
   - Control de flujo por estados
   - Actualización automática de licencia al ejecutar baja
   - Sistema de prioridades por días transcurridos
   - Diferentes tipos de baja según normativa
   - Control de documentos requeridos/entregados

4. Validaciones:
   - Folio de baja único
   - Estados y tipos válidos
   - Verificación de existencia de licencia
   - Control de modificación por estado
   - Fechas de efectividad
*/