-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA MODIFICACIÓN DE LICENCIAS
-- Convención: SP_MODLIC_XXX
-- Generado: 2025-09-09
-- Módulo: 08 - MODLICFRM (Prioridad Media)
-- ============================================

-- SP 1/7: SP_MODLIC_LIST
-- Tipo: List/Read
-- Descripción: Lista solicitudes de modificación de licencias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_MODLIC_LIST(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_tipo_modificacion VARCHAR(50) DEFAULT NULL,
    p_estado_modificacion VARCHAR(30) DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    folio_modificacion VARCHAR(100),
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    tipo_modificacion VARCHAR(50),
    descripcion_cambios TEXT,
    fecha_solicitud DATE,
    fecha_aprobacion DATE,
    estado_modificacion VARCHAR(30),
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
    FROM public.modificaciones_licencias ml
    WHERE (p_numero_licencia IS NULL OR ml.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR ml.propietario ILIKE '%' || p_propietario || '%')
      AND (p_tipo_modificacion IS NULL OR ml.tipo_modificacion = upper(p_tipo_modificacion))
      AND (p_estado_modificacion IS NULL OR ml.estado_modificacion = upper(p_estado_modificacion))
      AND (p_fecha_desde IS NULL OR ml.fecha_solicitud >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR ml.fecha_solicitud <= p_fecha_hasta);

    -- Retornar resultados
    RETURN QUERY
    SELECT 
        ml.id,
        ml.folio_modificacion,
        ml.numero_licencia,
        ml.propietario,
        ml.tipo_modificacion,
        ml.descripcion_cambios,
        ml.fecha_solicitud,
        ml.fecha_aprobacion,
        ml.estado_modificacion,
        ml.funcionario_revisor,
        v_total_count as total_registros
    FROM public.modificaciones_licencias ml
    WHERE (p_numero_licencia IS NULL OR ml.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR ml.propietario ILIKE '%' || p_propietario || '%')
      AND (p_tipo_modificacion IS NULL OR ml.tipo_modificacion = upper(p_tipo_modificacion))
      AND (p_estado_modificacion IS NULL OR ml.estado_modificacion = upper(p_estado_modificacion))
      AND (p_fecha_desde IS NULL OR ml.fecha_solicitud >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR ml.fecha_solicitud <= p_fecha_hasta)
    ORDER BY ml.fecha_solicitud DESC, ml.id DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================

-- SP 2/7: SP_MODLIC_GET
-- Tipo: Read
-- Descripción: Obtiene detalle de solicitud de modificación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_MODLIC_GET(p_folio_modificacion VARCHAR(100))
RETURNS TABLE(
    id INTEGER,
    folio_modificacion VARCHAR(100),
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    tipo_modificacion VARCHAR(50),
    descripcion_cambios TEXT,
    datos_actuales TEXT,
    datos_propuestos TEXT,
    justificacion TEXT,
    fecha_solicitud DATE,
    fecha_revision DATE,
    fecha_aprobacion DATE,
    fecha_aplicacion DATE,
    estado_modificacion VARCHAR(30),
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
    -- Validar que la solicitud existe
    SELECT COUNT(*) INTO v_exists
    FROM public.modificaciones_licencias
    WHERE folio_modificacion = p_folio_modificacion;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró la solicitud de modificación: %', p_folio_modificacion;
    END IF;

    -- Retornar el registro completo
    RETURN QUERY
    SELECT 
        ml.id,
        ml.folio_modificacion,
        ml.numero_licencia,
        ml.propietario,
        ml.razon_social,
        ml.rfc,
        ml.tipo_modificacion,
        ml.descripcion_cambios,
        ml.datos_actuales,
        ml.datos_propuestos,
        ml.justificacion,
        ml.fecha_solicitud,
        ml.fecha_revision,
        ml.fecha_aprobacion,
        ml.fecha_aplicacion,
        ml.estado_modificacion,
        ml.documentos_requeridos,
        ml.documentos_entregados,
        ml.observaciones,
        ml.funcionario_revisor,
        ml.usuario_registro,
        ml.fecha_registro
    FROM public.modificaciones_licencias ml
    WHERE ml.folio_modificacion = p_folio_modificacion;
END;
$$;

-- ============================================

-- SP 3/7: SP_MODLIC_CREATE
-- Tipo: Create
-- Descripción: Crear solicitud de modificación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_MODLIC_CREATE(
    p_folio_modificacion VARCHAR(100),
    p_numero_licencia VARCHAR(100),
    p_tipo_modificacion VARCHAR(50),
    p_descripcion_cambios TEXT,
    p_datos_actuales TEXT,
    p_datos_propuestos TEXT,
    p_justificacion TEXT,
    p_propietario VARCHAR(255) DEFAULT NULL,
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
    IF p_folio_modificacion IS NULL OR trim(p_folio_modificacion) = '' THEN
        RETURN QUERY SELECT FALSE, 'El folio de modificación es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_numero_licencia IS NULL OR trim(p_numero_licencia) = '' THEN
        RETURN QUERY SELECT FALSE, 'El número de licencia es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_descripcion_cambios IS NULL OR trim(p_descripcion_cambios) = '' THEN
        RETURN QUERY SELECT FALSE, 'La descripción de cambios es requerida.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar tipo de modificación
    IF upper(p_tipo_modificacion) NOT IN ('CAMBIO_PROPIETARIO', 'CAMBIO_DOMICILIO', 'CAMBIO_GIRO', 'AMPLIACION', 'REDUCCION', 'OTROS') THEN
        RETURN QUERY SELECT FALSE, 'Tipo de modificación no válido. Debe ser: CAMBIO_PROPIETARIO, CAMBIO_DOMICILIO, CAMBIO_GIRO, AMPLIACION, REDUCCION u OTROS.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no exista el folio
    SELECT COUNT(*) INTO v_exists
    FROM public.modificaciones_licencias
    WHERE folio_modificacion = upper(trim(p_folio_modificacion));

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una solicitud de modificación con ese folio.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que la licencia existe
    SELECT COUNT(*) INTO v_lic_exists
    FROM public.licencias_comerciales
    WHERE numero_licencia = upper(trim(p_numero_licencia)) AND estado = 'VIGENTE';

    IF v_lic_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No se encontró una licencia vigente con ese número.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar la nueva solicitud
    INSERT INTO public.modificaciones_licencias (
        folio_modificacion, numero_licencia, propietario, tipo_modificacion,
        descripcion_cambios, datos_actuales, datos_propuestos, justificacion,
        usuario_registro
    )
    VALUES (
        upper(trim(p_folio_modificacion)),
        upper(trim(p_numero_licencia)),
        upper(trim(p_propietario)),
        upper(trim(p_tipo_modificacion)),
        p_descripcion_cambios,
        p_datos_actuales,
        p_datos_propuestos,
        p_justificacion,
        upper(trim(p_usuario_registro))
    )
    RETURNING public.modificaciones_public.id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Solicitud de modificación registrada correctamente. Folio: ' || upper(trim(p_folio_modificacion)), v_new_id;
END;
$$;

-- ============================================

-- SP 4/7: SP_MODLIC_UPDATE
-- Tipo: Update
-- Descripción: Actualizar solicitud de modificación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_MODLIC_UPDATE(
    p_id INTEGER,
    p_descripcion_cambios TEXT DEFAULT NULL,
    p_datos_propuestos TEXT DEFAULT NULL,
    p_justificacion TEXT DEFAULT NULL,
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
    SELECT COUNT(*), MAX(estado_modificacion) INTO v_exists, v_estado
    FROM public.modificaciones_licencias
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La solicitud de modificación no existe.';
        RETURN;
    END IF;

    -- Verificar que se pueda modificar
    IF v_estado IN ('APLICADA', 'RECHAZADA', 'CANCELADA') THEN
        RETURN QUERY SELECT FALSE, 'No se puede modificar una solicitud en estado: ' || v_estado;
        RETURN;
    END IF;

    -- Actualizar la solicitud
    UPDATE public.modificaciones_licencias
    SET descripcion_cambios = COALESCE(p_descripcion_cambios, descripcion_cambios),
        datos_propuestos = COALESCE(p_datos_propuestos, datos_propuestos),
        justificacion = COALESCE(p_justificacion, justificacion),
        documentos_entregados = COALESCE(p_documentos_entregados, documentos_entregados),
        observaciones = COALESCE(p_observaciones, observaciones),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Solicitud de modificación actualizada correctamente.';
END;
$$;

-- ============================================

-- SP 5/7: SP_MODLIC_CAMBIAR_ESTADO
-- Tipo: Update
-- Descripción: Cambiar estado de solicitud de modificación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_MODLIC_CAMBIAR_ESTADO(
    p_folio_modificacion VARCHAR(100),
    p_nuevo_estado VARCHAR(30),
    p_observaciones TEXT DEFAULT NULL,
    p_funcionario_revisor VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar estados permitidos
    IF upper(p_nuevo_estado) NOT IN ('RECIBIDA', 'EN_REVISION', 'OBSERVACIONES', 'APROBADA', 'RECHAZADA', 'APLICADA', 'CANCELADA') THEN
        RETURN QUERY SELECT FALSE, 'Estado no válido. Debe ser: RECIBIDA, EN_REVISION, OBSERVACIONES, APROBADA, RECHAZADA, APLICADA o CANCELADA.';
        RETURN;
    END IF;

    -- Validar que la solicitud existe
    SELECT COUNT(*) INTO v_exists
    FROM public.modificaciones_licencias
    WHERE folio_modificacion = p_folio_modificacion;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La solicitud de modificación no existe.';
        RETURN;
    END IF;

    -- Cambiar el estado
    UPDATE public.modificaciones_licencias
    SET estado_modificacion = upper(p_nuevo_estado),
        fecha_revision = CASE 
            WHEN upper(p_nuevo_estado) = 'EN_REVISION' THEN CURRENT_DATE 
            ELSE fecha_revision 
        END,
        fecha_aprobacion = CASE 
            WHEN upper(p_nuevo_estado) = 'APROBADA' THEN CURRENT_DATE 
            ELSE fecha_aprobacion 
        END,
        fecha_aplicacion = CASE 
            WHEN upper(p_nuevo_estado) = 'APLICADA' THEN CURRENT_DATE 
            ELSE fecha_aplicacion 
        END,
        observaciones = COALESCE(p_observaciones, observaciones),
        funcionario_revisor = COALESCE(upper(trim(p_funcionario_revisor)), funcionario_revisor),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE folio_modificacion = p_folio_modificacion;

    RETURN QUERY SELECT TRUE, 'Estado de modificación cambiado correctamente a: ' || upper(p_nuevo_estado);
END;
$$;

-- ============================================

-- SP 6/7: SP_MODLIC_APLICAR_CAMBIOS
-- Tipo: Update
-- Descripción: Aplicar modificaciones a la licencia original
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_MODLIC_APLICAR_CAMBIOS(
    p_folio_modificacion VARCHAR(100),
    p_funcionario_aplicador VARCHAR(100)
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_estado VARCHAR(30);
    v_numero_licencia VARCHAR(100);
    v_tipo_modificacion VARCHAR(50);
    v_datos_propuestos TEXT;
    modification_data JSONB;
BEGIN
    -- Validar que la solicitud existe y está aprobada
    SELECT COUNT(*), MAX(estado_modificacion), MAX(numero_licencia), MAX(tipo_modificacion), MAX(datos_propuestos) 
    INTO v_exists, v_estado, v_numero_licencia, v_tipo_modificacion, v_datos_propuestos
    FROM public.modificaciones_licencias
    WHERE folio_modificacion = p_folio_modificacion;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La solicitud de modificación no existe.';
        RETURN;
    END IF;

    IF v_estado != 'APROBADA' THEN
        RETURN QUERY SELECT FALSE, 'Solo se pueden aplicar modificaciones aprobadas. Estado actual: ' || v_estado;
        RETURN;
    END IF;

    -- Intentar parsear los datos propuestos como JSON
    BEGIN
        modification_data := v_datos_propuestos::JSONB;
    EXCEPTION WHEN OTHERS THEN
        modification_data := NULL;
    END;

    -- Aplicar cambios según el tipo de modificación
    CASE upper(v_tipo_modificacion)
        WHEN 'CAMBIO_PROPIETARIO' THEN
            UPDATE public.licencias_comerciales
            SET propietario = COALESCE(modification_data->>'propietario', propietario),
                razon_social = COALESCE(modification_data->>'razon_social', razon_social),
                rfc = COALESCE(modification_data->>'rfc', rfc),
                observaciones = 'Modificación aplicada. Folio: ' || p_folio_modificacion,
                fecha_actualizacion = CURRENT_TIMESTAMP
            WHERE numero_licencia = v_numero_licencia;
            
        WHEN 'CAMBIO_DOMICILIO' THEN
            UPDATE public.licencias_comerciales
            SET direccion = COALESCE(modification_data->>'direccion', direccion),
                colonia = COALESCE(modification_data->>'colonia', colonia),
                codigo_postal = COALESCE(modification_data->>'codigo_postal', codigo_postal),
                observaciones = 'Modificación aplicada. Folio: ' || p_folio_modificacion,
                fecha_actualizacion = CURRENT_TIMESTAMP
            WHERE numero_licencia = v_numero_licencia;
            
        WHEN 'CAMBIO_GIRO' THEN
            UPDATE public.licencias_comerciales
            SET giro = COALESCE(modification_data->>'giro', giro),
                actividad = COALESCE(modification_data->>'actividad', actividad),
                observaciones = 'Modificación aplicada. Folio: ' || p_folio_modificacion,
                fecha_actualizacion = CURRENT_TIMESTAMP
            WHERE numero_licencia = v_numero_licencia;
            
        ELSE
            -- Para otros tipos, solo registrar en observaciones
            UPDATE public.licencias_comerciales
            SET observaciones = 'Modificación aplicada. Folio: ' || p_folio_modificacion,
                fecha_actualizacion = CURRENT_TIMESTAMP
            WHERE numero_licencia = v_numero_licencia;
    END CASE;

    -- Marcar la modificación como aplicada
    UPDATE public.modificaciones_licencias
    SET estado_modificacion = 'APLICADA',
        fecha_aplicacion = CURRENT_DATE,
        funcionario_revisor = upper(trim(p_funcionario_aplicador)),
        observaciones = COALESCE(observaciones || ' | ', '') || 'Cambios aplicados a la licencia',
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE folio_modificacion = p_folio_modificacion;

    RETURN QUERY SELECT TRUE, 'Modificaciones aplicadas correctamente a la licencia ' || v_numero_licencia;
END;
$$;

-- ============================================

-- SP 7/7: SP_MODLIC_PENDIENTES
-- Tipo: Read
-- Descripción: Obtener modificaciones pendientes de revisión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_MODLIC_PENDIENTES(
    p_dias_limite INTEGER DEFAULT 7,
    p_funcionario VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(
    folio_modificacion VARCHAR(100),
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    tipo_modificacion VARCHAR(50),
    fecha_solicitud DATE,
    estado_modificacion VARCHAR(30),
    funcionario_revisor VARCHAR(100),
    dias_transcurridos INTEGER,
    prioridad VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ml.folio_modificacion,
        ml.numero_licencia,
        ml.propietario,
        ml.tipo_modificacion,
        ml.fecha_solicitud,
        ml.estado_modificacion,
        ml.funcionario_revisor,
        (CURRENT_DATE - ml.fecha_solicitud)::INTEGER as dias_transcurridos,
        CASE 
            WHEN (CURRENT_DATE - ml.fecha_solicitud)::INTEGER > p_dias_limite THEN 'URGENTE'
            WHEN (CURRENT_DATE - ml.fecha_solicitud)::INTEGER > (p_dias_limite * 0.7) THEN 'ALTA'
            ELSE 'NORMAL'
        END as prioridad
    FROM public.modificaciones_licencias ml
    WHERE ml.estado_modificacion IN ('RECIBIDA', 'EN_REVISION', 'OBSERVACIONES', 'APROBADA')
      AND (p_funcionario IS NULL OR ml.funcionario_revisor ILIKE '%' || p_funcionario || '%')
    ORDER BY 
        (CURRENT_DATE - ml.fecha_solicitud)::INTEGER DESC,
        ml.fecha_registro ASC;
END;
$$;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
NOTAS PARA LA IMPLEMENTACIÓN:

1. Tabla requerida: public.modificaciones_licencias
   - Campos únicos: folio_modificacion
   - Campos requeridos: numero_licencia, tipo_modificacion, descripcion_cambios
   - Estados: RECIBIDA, EN_REVISION, OBSERVACIONES, APROBADA, RECHAZADA, APLICADA, CANCELADA
   - Tipos: CAMBIO_PROPIETARIO, CAMBIO_DOMICILIO, CAMBIO_GIRO, AMPLIACION, REDUCCION, OTROS

2. Endpoints del controlador Laravel:
   - listarModificaciones -> SP_MODLIC_LIST(filtros múltiples)
   - obtenerModificacion -> SP_MODLIC_GET(folio_modificacion)
   - crearModificacion -> SP_MODLIC_CREATE(datos completos)
   - actualizarModificacion -> SP_MODLIC_UPDATE(id, datos)
   - cambiarEstadoModificacion -> SP_MODLIC_CAMBIAR_ESTADO(folio, estado)
   - aplicarModificacion -> SP_MODLIC_APLICAR_CAMBIOS(folio, funcionario)
   - modificacionesPendientes -> SP_MODLIC_PENDIENTES(dias_limite)

3. Funcionalidades especiales:
   - Comparación datos actuales vs propuestos
   - Aplicación automática de cambios a licencia original
   - Manejo de datos en formato JSON para flexibilidad
   - Control de flujo por estados
   - Sistema de prioridades por tiempo transcurrido
   - Validación de licencia vigente

4. Campos especiales:
   - datos_actuales: Estado antes de la modificación
   - datos_propuestos: Cambios solicitados (JSON)
   - Fechas de seguimiento por cada estado
   - Control de documentación requerida
*/