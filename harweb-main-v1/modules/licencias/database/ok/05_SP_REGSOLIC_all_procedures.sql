-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA REGISTRO DE SOLICITUDES
-- Convención: SP_REGSOLIC_XXX
-- Generado: 2025-09-09
-- Tabla: solicitudes_licencias
-- Módulo: 05 - REGSOLICFRM (Prioridad Alta)
-- ============================================

-- Tabla para solicitudes de licencias
CREATE TABLE IF NOT EXISTS public.solicitudes_licencias (
    id SERIAL PRIMARY KEY,
    folio_solicitud VARCHAR(100) NOT NULL UNIQUE,
    tipo_solicitud VARCHAR(50) NOT NULL, -- 'LICENCIA_NUEVA', 'RENOVACION', 'MODIFICACION', 'ANUNCIO_NUEVO'
    numero_tramite VARCHAR(100),
    cuenta_predial VARCHAR(50),
    solicitante VARCHAR(255) NOT NULL,
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    curp VARCHAR(20),
    direccion_solicitante TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion_negocio TEXT NOT NULL,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    giro_solicitado VARCHAR(255) NOT NULL,
    actividad_especifica TEXT,
    superficie_solicitada NUMERIC(10,2),
    numero_empleados_estimado INTEGER,
    horario_propuesto VARCHAR(100),
    inversion_estimada NUMERIC(12,2),
    fecha_solicitud DATE DEFAULT CURRENT_DATE,
    fecha_recepcion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_revision DATE,
    fecha_respuesta DATE,
    estado VARCHAR(30) DEFAULT 'RECIBIDA', -- 'RECIBIDA', 'EN_REVISION', 'OBSERVACIONES', 'APROBADA', 'RECHAZADA', 'CANCELADA'
    dictamen TEXT,
    observaciones TEXT,
    documentos_entregados TEXT, -- JSON o lista de documentos
    funcionario_revisor VARCHAR(100),
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para consultas optimizadas
CREATE INDEX IF NOT EXISTS idx_sol_folio ON public.solicitudes_licencias(folio_solicitud);
CREATE INDEX IF NOT EXISTS idx_sol_tipo ON public.solicitudes_licencias(tipo_solicitud);
CREATE INDEX IF NOT EXISTS idx_sol_solicitante ON public.solicitudes_licencias(solicitante);
CREATE INDEX IF NOT EXISTS idx_sol_rfc ON public.solicitudes_licencias(rfc);
CREATE INDEX IF NOT EXISTS idx_sol_estado ON public.solicitudes_licencias(estado);
CREATE INDEX IF NOT EXISTS idx_sol_fecha_sol ON public.solicitudes_licencias(fecha_solicitud);
CREATE INDEX IF NOT EXISTS idx_sol_giro ON public.solicitudes_licencias(giro_solicitado);
CREATE INDEX IF NOT EXISTS idx_sol_funcionario ON public.solicitudes_licencias(funcionario_revisor);

-- ============================================

-- SP 1/7: SP_REGSOLIC_LIST
-- Tipo: List/Read
-- Descripción: Lista solicitudes con filtros y paginación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLIC_LIST(
    p_folio_solicitud VARCHAR(100) DEFAULT NULL,
    p_solicitante VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_tipo_solicitud VARCHAR(50) DEFAULT NULL,
    p_estado VARCHAR(30) DEFAULT NULL,
    p_giro VARCHAR(255) DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_funcionario_revisor VARCHAR(100) DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    folio_solicitud VARCHAR(100),
    tipo_solicitud VARCHAR(50),
    numero_tramite VARCHAR(100),
    solicitante VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    direccion_negocio TEXT,
    giro_solicitado VARCHAR(255),
    fecha_solicitud DATE,
    fecha_recepcion TIMESTAMP,
    estado VARCHAR(30),
    funcionario_revisor VARCHAR(100),
    dias_transcurridos INTEGER,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM public.solicitudes_licencias sl
    WHERE (p_folio_solicitud IS NULL OR sl.folio_solicitud ILIKE '%' || p_folio_solicitud || '%')
      AND (p_solicitante IS NULL OR sl.solicitante ILIKE '%' || p_solicitante || '%')
      AND (p_rfc IS NULL OR sl.rfc ILIKE '%' || p_rfc || '%')
      AND (p_tipo_solicitud IS NULL OR sl.tipo_solicitud = upper(p_tipo_solicitud))
      AND (p_estado IS NULL OR sl.estado = upper(p_estado))
      AND (p_giro IS NULL OR sl.giro_solicitado ILIKE '%' || p_giro || '%')
      AND (p_fecha_desde IS NULL OR sl.fecha_solicitud >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR sl.fecha_solicitud <= p_fecha_hasta)
      AND (p_funcionario_revisor IS NULL OR sl.funcionario_revisor ILIKE '%' || p_funcionario_revisor || '%');

    -- Retornar resultados
    RETURN QUERY
    SELECT 
        sl.id,
        sl.folio_solicitud,
        sl.tipo_solicitud,
        sl.numero_tramite,
        sl.solicitante,
        sl.razon_social,
        sl.rfc,
        sl.direccion_negocio,
        sl.giro_solicitado,
        sl.fecha_solicitud,
        sl.fecha_recepcion,
        sl.estado,
        sl.funcionario_revisor,
        (CURRENT_DATE - sl.fecha_solicitud)::INTEGER as dias_transcurridos,
        v_total_count as total_registros
    FROM public.solicitudes_licencias sl
    WHERE (p_folio_solicitud IS NULL OR sl.folio_solicitud ILIKE '%' || p_folio_solicitud || '%')
      AND (p_solicitante IS NULL OR sl.solicitante ILIKE '%' || p_solicitante || '%')
      AND (p_rfc IS NULL OR sl.rfc ILIKE '%' || p_rfc || '%')
      AND (p_tipo_solicitud IS NULL OR sl.tipo_solicitud = upper(p_tipo_solicitud))
      AND (p_estado IS NULL OR sl.estado = upper(p_estado))
      AND (p_giro IS NULL OR sl.giro_solicitado ILIKE '%' || p_giro || '%')
      AND (p_fecha_desde IS NULL OR sl.fecha_solicitud >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR sl.fecha_solicitud <= p_fecha_hasta)
      AND (p_funcionario_revisor IS NULL OR sl.funcionario_revisor ILIKE '%' || p_funcionario_revisor || '%')
    ORDER BY sl.fecha_recepcion DESC, sl.id DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================

-- SP 2/7: SP_REGSOLIC_GET
-- Tipo: Read
-- Descripción: Obtiene detalle completo de una solicitud
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLIC_GET(p_folio_solicitud VARCHAR(100))
RETURNS TABLE(
    id INTEGER,
    folio_solicitud VARCHAR(100),
    tipo_solicitud VARCHAR(50),
    numero_tramite VARCHAR(100),
    cuenta_predial VARCHAR(50),
    solicitante VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    curp VARCHAR(20),
    direccion_solicitante TEXT,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion_negocio TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    giro_solicitado VARCHAR(255),
    actividad_especifica TEXT,
    superficie_solicitada NUMERIC(10,2),
    numero_empleados_estimado INTEGER,
    horario_propuesto VARCHAR(100),
    inversion_estimada NUMERIC(12,2),
    fecha_solicitud DATE,
    fecha_recepcion TIMESTAMP,
    fecha_revision DATE,
    fecha_respuesta DATE,
    estado VARCHAR(30),
    dictamen TEXT,
    observaciones TEXT,
    documentos_entregados TEXT,
    funcionario_revisor VARCHAR(100),
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP,
    dias_transcurridos INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que la solicitud existe
    SELECT COUNT(*) INTO v_exists
    FROM public.solicitudes_licencias
    WHERE folio_solicitud = p_folio_solicitud;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró la solicitud: %', p_folio_solicitud;
    END IF;

    -- Retornar el registro completo
    RETURN QUERY
    SELECT 
        sl.id,
        sl.folio_solicitud,
        sl.tipo_solicitud,
        sl.numero_tramite,
        sl.cuenta_predial,
        sl.solicitante,
        sl.razon_social,
        sl.rfc,
        sl.curp,
        sl.direccion_solicitante,
        sl.telefono,
        sl.email,
        sl.direccion_negocio,
        sl.colonia,
        sl.codigo_postal,
        sl.giro_solicitado,
        sl.actividad_especifica,
        sl.superficie_solicitada,
        sl.numero_empleados_estimado,
        sl.horario_propuesto,
        sl.inversion_estimada,
        sl.fecha_solicitud,
        sl.fecha_recepcion,
        sl.fecha_revision,
        sl.fecha_respuesta,
        sl.estado,
        sl.dictamen,
        sl.observaciones,
        sl.documentos_entregados,
        sl.funcionario_revisor,
        sl.usuario_registro,
        sl.fecha_registro,
        (CURRENT_DATE - sl.fecha_solicitud)::INTEGER as dias_transcurridos
    FROM public.solicitudes_licencias sl
    WHERE sl.folio_solicitud = p_folio_solicitud;
END;
$$;

-- ============================================

-- SP 3/7: SP_REGSOLIC_CREATE
-- Tipo: Create
-- Descripción: Crear nueva solicitud
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLIC_CREATE(
    p_folio_solicitud VARCHAR(100),
    p_tipo_solicitud VARCHAR(50),
    p_solicitante VARCHAR(255),
    p_direccion_negocio TEXT,
    p_giro_solicitado VARCHAR(255),
    p_razon_social VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_curp VARCHAR(20) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_actividad_especifica TEXT DEFAULT NULL,
    p_superficie_solicitada NUMERIC(10,2) DEFAULT NULL,
    p_inversion_estimada NUMERIC(12,2) DEFAULT NULL,
    p_usuario_registro VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT, id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_exists INTEGER;
BEGIN
    -- Validar campos requeridos
    IF p_folio_solicitud IS NULL OR trim(p_folio_solicitud) = '' THEN
        RETURN QUERY SELECT FALSE, 'El folio de solicitud es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_solicitante IS NULL OR trim(p_solicitante) = '' THEN
        RETURN QUERY SELECT FALSE, 'El nombre del solicitante es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_direccion_negocio IS NULL OR trim(p_direccion_negocio) = '' THEN
        RETURN QUERY SELECT FALSE, 'La dirección del negocio es requerida.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_giro_solicitado IS NULL OR trim(p_giro_solicitado) = '' THEN
        RETURN QUERY SELECT FALSE, 'El giro solicitado es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar tipo de solicitud
    IF upper(p_tipo_solicitud) NOT IN ('LICENCIA_NUEVA', 'RENOVACION', 'MODIFICACION', 'ANUNCIO_NUEVO') THEN
        RETURN QUERY SELECT FALSE, 'Tipo de solicitud no válido. Debe ser: LICENCIA_NUEVA, RENOVACION, MODIFICACION o ANUNCIO_NUEVO.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no exista el folio
    SELECT COUNT(*) INTO v_exists
    FROM public.solicitudes_licencias
    WHERE folio_solicitud = upper(trim(p_folio_solicitud));

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una solicitud con ese folio.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar la nueva solicitud
    INSERT INTO public.solicitudes_licencias (
        folio_solicitud, tipo_solicitud, solicitante, razon_social, rfc, curp,
        telefono, email, direccion_negocio, colonia, giro_solicitado,
        actividad_especifica, superficie_solicitada, inversion_estimada, usuario_registro
    )
    VALUES (
        upper(trim(p_folio_solicitud)),
        upper(trim(p_tipo_solicitud)),
        upper(trim(p_solicitante)),
        upper(trim(p_razon_social)),
        upper(trim(p_rfc)),
        upper(trim(p_curp)),
        p_telefono,
        lower(trim(p_email)),
        upper(trim(p_direccion_negocio)),
        upper(trim(p_colonia)),
        upper(trim(p_giro_solicitado)),
        p_actividad_especifica,
        p_superficie_solicitada,
        p_inversion_estimada,
        upper(trim(p_usuario_registro))
    )
    RETURNING public.solicitudes_public.id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Solicitud registrada correctamente con folio: ' || upper(trim(p_folio_solicitud)), v_new_id;
END;
$$;

-- ============================================

-- SP 4/7: SP_REGSOLIC_UPDATE
-- Tipo: Update
-- Descripción: Actualizar solicitud existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLIC_UPDATE(
    p_id INTEGER,
    p_solicitante VARCHAR(255) DEFAULT NULL,
    p_razon_social VARCHAR(255) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_direccion_negocio TEXT DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_actividad_especifica TEXT DEFAULT NULL,
    p_superficie_solicitada NUMERIC(10,2) DEFAULT NULL,
    p_numero_empleados_estimado INTEGER DEFAULT NULL,
    p_horario_propuesto VARCHAR(100) DEFAULT NULL,
    p_inversion_estimada NUMERIC(12,2) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_estado VARCHAR(30);
BEGIN
    -- Validar que el ID existe y obtener estado
    SELECT COUNT(*), MAX(estado) INTO v_exists, v_estado
    FROM public.solicitudes_licencias
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La solicitud no existe.';
        RETURN;
    END IF;

    -- Verificar que la solicitud se pueda modificar
    IF v_estado NOT IN ('RECIBIDA', 'EN_REVISION', 'OBSERVACIONES') THEN
        RETURN QUERY SELECT FALSE, 'No se puede modificar una solicitud en estado: ' || v_estado;
        RETURN;
    END IF;

    -- Actualizar solo los campos proporcionados
    UPDATE public.solicitudes_licencias
    SET solicitante = COALESCE(upper(trim(p_solicitante)), solicitante),
        razon_social = COALESCE(upper(trim(p_razon_social)), razon_social),
        telefono = COALESCE(p_telefono, telefono),
        email = COALESCE(lower(trim(p_email)), email),
        direccion_negocio = COALESCE(upper(trim(p_direccion_negocio)), direccion_negocio),
        colonia = COALESCE(upper(trim(p_colonia)), colonia),
        actividad_especifica = COALESCE(p_actividad_especifica, actividad_especifica),
        superficie_solicitada = COALESCE(p_superficie_solicitada, superficie_solicitada),
        numero_empleados_estimado = COALESCE(p_numero_empleados_estimado, numero_empleados_estimado),
        horario_propuesto = COALESCE(p_horario_propuesto, horario_propuesto),
        inversion_estimada = COALESCE(p_inversion_estimada, inversion_estimada),
        observaciones = COALESCE(p_observaciones, observaciones),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Solicitud actualizada correctamente.';
END;
$$;

-- ============================================

-- SP 5/7: SP_REGSOLIC_CAMBIAR_ESTADO
-- Tipo: Update
-- Descripción: Cambiar estado de una solicitud
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLIC_CAMBIAR_ESTADO(
    p_folio_solicitud VARCHAR(100),
    p_nuevo_estado VARCHAR(30),
    p_dictamen TEXT DEFAULT NULL,
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
    IF upper(p_nuevo_estado) NOT IN ('RECIBIDA', 'EN_REVISION', 'OBSERVACIONES', 'APROBADA', 'RECHAZADA', 'CANCELADA') THEN
        RETURN QUERY SELECT FALSE, 'Estado no válido. Debe ser: RECIBIDA, EN_REVISION, OBSERVACIONES, APROBADA, RECHAZADA o CANCELADA.';
        RETURN;
    END IF;

    -- Validar que la solicitud existe
    SELECT COUNT(*) INTO v_exists
    FROM public.solicitudes_licencias
    WHERE folio_solicitud = p_folio_solicitud;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La solicitud no existe.';
        RETURN;
    END IF;

    -- Cambiar el estado y actualizar campos relacionados
    UPDATE public.solicitudes_licencias
    SET estado = upper(p_nuevo_estado),
        dictamen = COALESCE(p_dictamen, dictamen),
        observaciones = COALESCE(p_observaciones, observaciones),
        funcionario_revisor = COALESCE(upper(trim(p_funcionario_revisor)), funcionario_revisor),
        fecha_revision = CASE 
            WHEN upper(p_nuevo_estado) = 'EN_REVISION' THEN CURRENT_DATE 
            ELSE fecha_revision 
        END,
        fecha_respuesta = CASE 
            WHEN upper(p_nuevo_estado) IN ('APROBADA', 'RECHAZADA') THEN CURRENT_DATE 
            ELSE fecha_respuesta 
        END,
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE folio_solicitud = p_folio_solicitud;

    RETURN QUERY SELECT TRUE, 'Estado de solicitud cambiado correctamente a: ' || upper(p_nuevo_estado);
END;
$$;

-- ============================================

-- SP 6/7: SP_REGSOLIC_ASIGNAR_TRAMITE
-- Tipo: Update
-- Descripción: Asignar número de trámite a una solicitud
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLIC_ASIGNAR_TRAMITE(
    p_folio_solicitud VARCHAR(100),
    p_numero_tramite VARCHAR(100)
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_tramite_existe INTEGER;
BEGIN
    -- Validar que la solicitud existe
    SELECT COUNT(*) INTO v_exists
    FROM public.solicitudes_licencias
    WHERE folio_solicitud = p_folio_solicitud;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La solicitud no existe.';
        RETURN;
    END IF;

    -- Validar que el número de trámite no esté en uso
    SELECT COUNT(*) INTO v_tramite_existe
    FROM public.solicitudes_licencias
    WHERE numero_tramite = p_numero_tramite
      AND folio_solicitud != p_folio_solicitud;

    IF v_tramite_existe > 0 THEN
        RETURN QUERY SELECT FALSE, 'El número de trámite ya está asignado a otra solicitud.';
        RETURN;
    END IF;

    -- Asignar el número de trámite
    UPDATE public.solicitudes_licencias
    SET numero_tramite = upper(trim(p_numero_tramite)),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE folio_solicitud = p_folio_solicitud;

    RETURN QUERY SELECT TRUE, 'Número de trámite asignado correctamente: ' || upper(trim(p_numero_tramite));
END;
$$;

-- ============================================

-- SP 7/7: SP_REGSOLIC_PENDIENTES
-- Tipo: Read
-- Descripción: Obtener solicitudes pendientes de revisión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLIC_PENDIENTES(
    p_dias_limite INTEGER DEFAULT 15,
    p_funcionario VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(
    folio_solicitud VARCHAR(100),
    solicitante VARCHAR(255),
    giro_solicitado VARCHAR(255),
    fecha_solicitud DATE,
    estado VARCHAR(30),
    funcionario_revisor VARCHAR(100),
    dias_transcurridos INTEGER,
    prioridad VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sl.folio_solicitud,
        sl.solicitante,
        sl.giro_solicitado,
        sl.fecha_solicitud,
        sl.estado,
        sl.funcionario_revisor,
        (CURRENT_DATE - sl.fecha_solicitud)::INTEGER as dias_transcurridos,
        CASE 
            WHEN (CURRENT_DATE - sl.fecha_solicitud)::INTEGER > p_dias_limite THEN 'URGENTE'
            WHEN (CURRENT_DATE - sl.fecha_solicitud)::INTEGER > (p_dias_limite * 0.7) THEN 'ALTA'
            ELSE 'NORMAL'
        END as prioridad
    FROM public.solicitudes_licencias sl
    WHERE sl.estado IN ('RECIBIDA', 'EN_REVISION', 'OBSERVACIONES')
      AND (p_funcionario IS NULL OR sl.funcionario_revisor ILIKE '%' || p_funcionario || '%')
    ORDER BY 
        (CURRENT_DATE - sl.fecha_solicitud)::INTEGER DESC,
        sl.fecha_recepcion ASC;
END;
$$;

-- ============================================
-- DATOS DE PRUEBA
-- ============================================

INSERT INTO public.solicitudes_licencias (
    folio_solicitud, tipo_solicitud, solicitante, razon_social, rfc,
    telefono, email, direccion_negocio, colonia, giro_solicitado,
    actividad_especifica, superficie_solicitada, inversion_estimada, usuario_registro
) VALUES 
    ('SOL-2025-001', 'LICENCIA_NUEVA', 'JUAN PÉREZ GARCÍA', 'ABARROTES PÉREZ SA', 'PEGJ850101ABC',
     '33-1234-5678', 'juan.perez@email.com', 'AV. JUÁREZ #123', 'CENTRO', 'COMERCIO AL POR MENOR',
     'Venta de abarrotes y productos de primera necesidad', 50.00, 150000.00, 'ADMIN'),
    ('SOL-2025-002', 'ANUNCIO_NUEVO', 'MARÍA LÓPEZ HERNÁNDEZ', 'SERVICIOS LÓPEZ SC', 'LOHM750215DEF',
     '33-2345-6789', 'maria.lopez@email.com', 'CALLE MORELOS #456', 'REFORMA', 'SERVICIOS PROFESIONALES',
     'Consultoria en sistemas y redes', 25.00, 75000.00, 'ADMIN'),
    ('SOL-2025-003', 'RENOVACION', 'EMPRESA CONSTRUCTORA SA', 'CONSTRUCTORA INDUSTRIAL SA', 'ECI901201GHI',
     '33-3456-7890', 'contacto@constructora.com', 'BLVD. UNIVERSIDAD #789', 'UNIVERSITARIA', 'CONSTRUCCIÓN',
     'Construcción de obras civiles y edificaciones', 200.00, 500000.00, 'ADMIN')
ON CONFLICT (folio_solicitud) DO NOTHING;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
NOTAS PARA LA IMPLEMENTACIÓN:

1. Tabla requerida: public.solicitudes_licencias
   - Campos únicos: folio_solicitud
   - Campos requeridos: solicitante, direccion_negocio, giro_solicitado
   - Estados: RECIBIDA, EN_REVISION, OBSERVACIONES, APROBADA, RECHAZADA, CANCELADA
   - Tipos: LICENCIA_NUEVA, RENOVACION, MODIFICACION, ANUNCIO_NUEVO

2. Endpoints del controlador Laravel:
   - listarSolicitudes -> SP_REGSOLIC_LIST(filtros múltiples)
   - obtenerSolicitud -> SP_REGSOLIC_GET(folio_solicitud)
   - crearSolicitud -> SP_REGSOLIC_CREATE(datos completos)
   - actualizarSolicitud -> SP_REGSOLIC_UPDATE(id, datos)
   - cambiarEstadoSolicitud -> SP_REGSOLIC_CAMBIAR_ESTADO(folio, estado, dictamen)
   - asignarTramite -> SP_REGSOLIC_ASIGNAR_TRAMITE(folio, numero_tramite)
   - solicitudesPendientes -> SP_REGSOLIC_PENDIENTES(dias_limite, funcionario)

3. Funcionalidades especiales:
   - Control de flujo por estados
   - Asignación de números de trámite
   - Sistema de prioridades por días transcurridos
   - Seguimiento por funcionario revisor
   - Cálculo automático de días transcurridos
   - Validación de modificabilidad por estado

4. Campos de control:
   - Fechas de seguimiento (solicitud, recepción, revisión, respuesta)
   - Dictamen y observaciones
   - Documentos entregados (JSON)
   - Trazabilidad completa
*/