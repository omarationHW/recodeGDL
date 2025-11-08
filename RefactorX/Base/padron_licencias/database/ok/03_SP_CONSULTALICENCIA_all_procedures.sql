-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA CONSULTA DE LICENCIAS
-- Convención: SP_CONSULTALICENCIA_XXX
-- Generado: 2025-09-09
-- Tabla: licencias_comerciales
-- Módulo: 03 - CONSULTALICENCIAFRM (Prioridad Alta)
-- ============================================

-- Tabla para licencias comerciales
CREATE TABLE IF NOT EXISTS public.licencias_comerciales (
    id SERIAL PRIMARY KEY,
    numero_licencia VARCHAR(100) NOT NULL UNIQUE,
    folio VARCHAR(100),
    tipo_licencia VARCHAR(50), -- 'COMERCIAL', 'INDUSTRIAL', 'SERVICIOS'
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255) NOT NULL,
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    direccion TEXT NOT NULL,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    telefono VARCHAR(20),
    email VARCHAR(100),
    giro VARCHAR(255),
    actividad VARCHAR(255),
    superficie_autorizada NUMERIC(10,2),
    horario_operacion VARCHAR(100),
    numero_empleados INTEGER,
    fecha_solicitud DATE,
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(20) DEFAULT 'VIGENTE', -- 'VIGENTE', 'VENCIDA', 'SUSPENDIDA', 'CANCELADA'
    observaciones TEXT,
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para consultas optimizadas
CREATE INDEX IF NOT EXISTS idx_lic_numero ON public.licencias_comerciales(numero_licencia);
CREATE INDEX IF NOT EXISTS idx_lic_folio ON public.licencias_comerciales(folio);
CREATE INDEX IF NOT EXISTS idx_lic_tipo ON public.licencias_comerciales(tipo_licencia);
CREATE INDEX IF NOT EXISTS idx_lic_propietario ON public.licencias_comerciales(propietario);
CREATE INDEX IF NOT EXISTS idx_lic_rfc ON public.licencias_comerciales(rfc);
CREATE INDEX IF NOT EXISTS idx_lic_estado ON public.licencias_comerciales(estado);
CREATE INDEX IF NOT EXISTS idx_lic_giro ON public.licencias_comerciales(giro);
CREATE INDEX IF NOT EXISTS idx_lic_fecha_venc ON public.licencias_comerciales(fecha_vencimiento);

-- ============================================

-- SP 1/6: SP_CONSULTALICENCIA_LIST
-- Tipo: List/Read
-- Descripción: Lista licencias con filtros y paginación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTALICENCIA_LIST(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_giro VARCHAR(255) DEFAULT NULL,
    p_tipo_licencia VARCHAR(50) DEFAULT NULL,
    p_estado VARCHAR(20) DEFAULT NULL,
    p_vigentes_solo BOOLEAN DEFAULT FALSE,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    numero_licencia VARCHAR(100),
    folio VARCHAR(100),
    tipo_licencia VARCHAR(50),
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    direccion TEXT,
    colonia VARCHAR(100),
    giro VARCHAR(255),
    actividad VARCHAR(255),
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(20),
    dias_para_vencer INTEGER,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
    v_estado_filtro VARCHAR(20);
BEGIN
    -- Determinar filtro de estado
    IF p_vigentes_solo THEN
        v_estado_filtro := 'VIGENTE';
    ELSE
        v_estado_filtro := COALESCE(p_estado, 'VIGENTE');
    END IF;

    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM public.licencias_comerciales lc
    WHERE (p_numero_licencia IS NULL OR lc.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR lc.propietario ILIKE '%' || p_propietario || '%')
      AND (p_rfc IS NULL OR lc.rfc ILIKE '%' || p_rfc || '%')
      AND (p_giro IS NULL OR lc.giro ILIKE '%' || p_giro || '%')
      AND (p_tipo_licencia IS NULL OR lc.tipo_licencia = upper(p_tipo_licencia))
      AND (p_estado IS NULL OR lc.estado = v_estado_filtro);

    -- Retornar resultados
    RETURN QUERY
    SELECT 
        lc.id,
        lc.numero_licencia,
        lc.folio,
        lc.tipo_licencia,
        lc.cuenta_predial,
        lc.propietario,
        lc.razon_social,
        lc.rfc,
        lc.direccion,
        lc.colonia,
        lc.giro,
        lc.actividad,
        lc.fecha_expedicion,
        lc.fecha_vencimiento,
        lc.estado,
        CASE 
            WHEN lc.fecha_vencimiento IS NULL THEN NULL
            ELSE (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER
        END as dias_para_vencer,
        v_total_count as total_registros
    FROM public.licencias_comerciales lc
    WHERE (p_numero_licencia IS NULL OR lc.numero_licencia ILIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR lc.propietario ILIKE '%' || p_propietario || '%')
      AND (p_rfc IS NULL OR lc.rfc ILIKE '%' || p_rfc || '%')
      AND (p_giro IS NULL OR lc.giro ILIKE '%' || p_giro || '%')
      AND (p_tipo_licencia IS NULL OR lc.tipo_licencia = upper(p_tipo_licencia))
      AND (p_estado IS NULL OR lc.estado = v_estado_filtro)
    ORDER BY lc.fecha_vencimiento DESC, lc.fecha_registro DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================

-- SP 2/6: SP_CONSULTALICENCIA_GET
-- Tipo: Read
-- Descripción: Obtiene detalle completo de una licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTALICENCIA_GET(p_numero_licencia VARCHAR(100))
RETURNS TABLE(
    id INTEGER,
    numero_licencia VARCHAR(100),
    folio VARCHAR(100),
    tipo_licencia VARCHAR(50),
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    telefono VARCHAR(20),
    email VARCHAR(100),
    giro VARCHAR(255),
    actividad VARCHAR(255),
    superficie_autorizada NUMERIC(10,2),
    horario_operacion VARCHAR(100),
    numero_empleados INTEGER,
    fecha_solicitud DATE,
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(20),
    observaciones TEXT,
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP,
    dias_para_vencer INTEGER,
    esta_vigente BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que la licencia existe
    SELECT COUNT(*) INTO v_exists
    FROM public.licencias_comerciales
    WHERE numero_licencia = p_numero_licencia;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró la licencia: %', p_numero_licencia;
    END IF;

    -- Retornar el registro completo
    RETURN QUERY
    SELECT 
        lc.id,
        lc.numero_licencia,
        lc.folio,
        lc.tipo_licencia,
        lc.cuenta_predial,
        lc.propietario,
        lc.razon_social,
        lc.rfc,
        lc.direccion,
        lc.colonia,
        lc.codigo_postal,
        lc.telefono,
        lc.email,
        lc.giro,
        lc.actividad,
        lc.superficie_autorizada,
        lc.horario_operacion,
        lc.numero_empleados,
        lc.fecha_solicitud,
        lc.fecha_expedicion,
        lc.fecha_vencimiento,
        lc.estado,
        lc.observaciones,
        lc.usuario_registro,
        lc.fecha_registro,
        CASE 
            WHEN lc.fecha_vencimiento IS NULL THEN NULL
            ELSE (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER
        END as dias_para_vencer,
        CASE 
            WHEN lc.estado = 'VIGENTE' AND (lc.fecha_vencimiento IS NULL OR lc.fecha_vencimiento >= CURRENT_DATE) 
            THEN TRUE 
            ELSE FALSE 
        END as esta_vigente
    FROM public.licencias_comerciales lc
    WHERE lc.numero_licencia = p_numero_licencia;
END;
$$;

-- ============================================

-- SP 3/6: SP_CONSULTALICENCIA_CREATE
-- Tipo: Create
-- Descripción: Crear nueva licencia comercial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTALICENCIA_CREATE(
    p_numero_licencia VARCHAR(100),
    p_folio VARCHAR(100),
    p_tipo_licencia VARCHAR(50),
    p_propietario VARCHAR(255),
    p_razon_social VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_direccion TEXT,
    p_colonia VARCHAR(100),
    p_giro VARCHAR(255),
    p_actividad VARCHAR(255) DEFAULT NULL,
    p_superficie_autorizada NUMERIC(10,2) DEFAULT NULL,
    p_fecha_expedicion DATE DEFAULT CURRENT_DATE,
    p_fecha_vencimiento DATE DEFAULT NULL,
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
    IF p_numero_licencia IS NULL OR trim(p_numero_licencia) = '' THEN
        RETURN QUERY SELECT FALSE, 'El número de licencia es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_propietario IS NULL OR trim(p_propietario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El propietario es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_direccion IS NULL OR trim(p_direccion) = '' THEN
        RETURN QUERY SELECT FALSE, 'La dirección es requerida.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar tipo de licencia
    IF p_tipo_licencia IS NOT NULL AND upper(p_tipo_licencia) NOT IN ('COMERCIAL', 'INDUSTRIAL', 'SERVICIOS') THEN
        RETURN QUERY SELECT FALSE, 'Tipo de licencia no válido. Debe ser: COMERCIAL, INDUSTRIAL o SERVICIOS.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no exista el número de licencia
    SELECT COUNT(*) INTO v_exists
    FROM public.licencias_comerciales
    WHERE numero_licencia = upper(trim(p_numero_licencia));

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una licencia con ese número.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar la nueva licencia
    INSERT INTO public.licencias_comerciales (
        numero_licencia, folio, tipo_licencia, propietario, razon_social, rfc,
        direccion, colonia, giro, actividad, superficie_autorizada,
        fecha_expedicion, fecha_vencimiento, usuario_registro
    )
    VALUES (
        upper(trim(p_numero_licencia)),
        upper(trim(p_folio)),
        upper(trim(p_tipo_licencia)),
        upper(trim(p_propietario)),
        upper(trim(p_razon_social)),
        upper(trim(p_rfc)),
        upper(trim(p_direccion)),
        upper(trim(p_colonia)),
        upper(trim(p_giro)),
        upper(trim(p_actividad)),
        p_superficie_autorizada,
        p_fecha_expedicion,
        p_fecha_vencimiento,
        upper(trim(p_usuario_registro))
    )
    RETURNING public.licencias_comerciales.id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Licencia creada correctamente.', v_new_id;
END;
$$;

-- ============================================

-- SP 4/6: SP_CONSULTALICENCIA_UPDATE
-- Tipo: Update
-- Descripción: Actualizar licencia existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTALICENCIA_UPDATE(
    p_id INTEGER,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_razon_social VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_direccion TEXT DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_giro VARCHAR(255) DEFAULT NULL,
    p_actividad VARCHAR(255) DEFAULT NULL,
    p_superficie_autorizada NUMERIC(10,2) DEFAULT NULL,
    p_horario_operacion VARCHAR(100) DEFAULT NULL,
    p_numero_empleados INTEGER DEFAULT NULL,
    p_fecha_vencimiento DATE DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que el ID existe
    SELECT COUNT(*) INTO v_exists
    FROM public.licencias_comerciales
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La licencia no existe.';
        RETURN;
    END IF;

    -- Actualizar solo los campos proporcionados
    UPDATE public.licencias_comerciales
    SET propietario = COALESCE(upper(trim(p_propietario)), propietario),
        razon_social = COALESCE(upper(trim(p_razon_social)), razon_social),
        rfc = COALESCE(upper(trim(p_rfc)), rfc),
        direccion = COALESCE(upper(trim(p_direccion)), direccion),
        colonia = COALESCE(upper(trim(p_colonia)), colonia),
        telefono = COALESCE(p_telefono, telefono),
        email = COALESCE(lower(trim(p_email)), email),
        giro = COALESCE(upper(trim(p_giro)), giro),
        actividad = COALESCE(upper(trim(p_actividad)), actividad),
        superficie_autorizada = COALESCE(p_superficie_autorizada, superficie_autorizada),
        horario_operacion = COALESCE(p_horario_operacion, horario_operacion),
        numero_empleados = COALESCE(p_numero_empleados, numero_empleados),
        fecha_vencimiento = COALESCE(p_fecha_vencimiento, fecha_vencimiento),
        observaciones = COALESCE(p_observaciones, observaciones),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Licencia actualizada correctamente.';
END;
$$;

-- ============================================

-- SP 5/6: SP_CONSULTALICENCIA_CAMBIAR_ESTADO
-- Tipo: Update
-- Descripción: Cambiar estado de una licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTALICENCIA_CAMBIAR_ESTADO(
    p_numero_licencia VARCHAR(100),
    p_nuevo_estado VARCHAR(20),
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar estados permitidos
    IF upper(p_nuevo_estado) NOT IN ('VIGENTE', 'VENCIDA', 'SUSPENDIDA', 'CANCELADA') THEN
        RETURN QUERY SELECT FALSE, 'Estado no válido. Debe ser: VIGENTE, VENCIDA, SUSPENDIDA o CANCELADA.';
        RETURN;
    END IF;

    -- Validar que la licencia existe
    SELECT COUNT(*) INTO v_exists
    FROM public.licencias_comerciales
    WHERE numero_licencia = p_numero_licencia;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La licencia no existe.';
        RETURN;
    END IF;

    -- Cambiar el estado
    UPDATE public.licencias_comerciales
    SET estado = upper(p_nuevo_estado),
        observaciones = COALESCE(p_observaciones, observaciones),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE numero_licencia = p_numero_licencia;

    RETURN QUERY SELECT TRUE, 'Estado de licencia cambiado correctamente a: ' || upper(p_nuevo_estado);
END;
$$;

-- ============================================

-- SP 6/6: SP_CONSULTALICENCIA_VENCIDAS
-- Tipo: Read
-- Descripción: Obtener licencias próximas a vencer o vencidas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTALICENCIA_VENCIDAS(
    p_dias_adelanto INTEGER DEFAULT 30,
    p_solo_vencidas BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
    numero_licencia VARCHAR(100),
    propietario VARCHAR(255),
    giro VARCHAR(255),
    fecha_vencimiento DATE,
    dias_para_vencer INTEGER,
    estado VARCHAR(20),
    urgencia VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        lc.numero_licencia,
        lc.propietario,
        lc.giro,
        lc.fecha_vencimiento,
        (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER as dias_para_vencer,
        lc.estado,
        CASE 
            WHEN lc.fecha_vencimiento < CURRENT_DATE THEN 'VENCIDA'
            WHEN (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER <= 7 THEN 'CRITICA'
            WHEN (lc.fecha_vencimiento - CURRENT_DATE)::INTEGER <= 30 THEN 'ALERTA'
            ELSE 'NORMAL'
        END as urgencia
    FROM public.licencias_comerciales lc
    WHERE lc.fecha_vencimiento IS NOT NULL
      AND lc.estado = 'VIGENTE'
      AND (
          (p_solo_vencidas AND lc.fecha_vencimiento < CURRENT_DATE) OR
          (NOT p_solo_vencidas AND lc.fecha_vencimiento <= CURRENT_DATE + INTERVAL '1 day' * p_dias_adelanto)
      )
    ORDER BY lc.fecha_vencimiento ASC;
END;
$$;

-- ============================================
-- DATOS DE PRUEBA
-- ============================================

INSERT INTO public.licencias_comerciales (
    numero_licencia, folio, tipo_licencia, propietario, razon_social, rfc,
    direccion, colonia, giro, actividad, fecha_expedicion, fecha_vencimiento, usuario_registro
) VALUES 
    ('LIC-COM-2025-001', 'FOL-2025-001', 'COMERCIAL', 
     'JUAN PÉREZ GARCÍA', 'ABARROTES PÉREZ SA', 'PEGJ850101ABC',
     'AV. JUÁREZ #123', 'CENTRO', 'COMERCIO AL POR MENOR', 'VENTA DE ABARROTES',
     '2025-01-15', '2026-01-15', 'ADMIN'),
    ('LIC-SER-2025-002', 'FOL-2025-002', 'SERVICIOS',
     'MARÍA LÓPEZ HERNÁNDEZ', 'SERVICIOS LÓPEZ SC', 'LOHM750215DEF',
     'CALLE MORELOS #456', 'REFORMA', 'SERVICIOS', 'CONSULTORIA',
     '2025-02-10', '2026-02-10', 'ADMIN'),
    ('LIC-IND-2025-003', 'FOL-2025-003', 'INDUSTRIAL',
     'EMPRESA CONSTRUCTORA SA', 'CONSTRUCTORA INDUSTRIAL SA', 'ECI901201GHI',
     'BLVD. UNIVERSIDAD #789', 'UNIVERSITARIA', 'INDUSTRIAL', 'CONSTRUCCIÓN',
     '2025-03-05', '2026-03-05', 'ADMIN')
ON CONFLICT (numero_licencia) DO NOTHING;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
NOTAS PARA LA IMPLEMENTACIÓN:

1. Tabla requerida: public.licencias_comerciales
   - Campos únicos: numero_licencia
   - Campos requeridos: propietario, direccion, giro
   - Estados: VIGENTE, VENCIDA, SUSPENDIDA, CANCELADA
   - Tipos: COMERCIAL, INDUSTRIAL, SERVICIOS

2. Endpoints del controlador Laravel:
   - consultarLicencias -> SP_CONSULTALICENCIA_LIST(filtros múltiples)
   - obtenerLicencia -> SP_CONSULTALICENCIA_GET(numero_licencia)
   - crearLicencia -> SP_CONSULTALICENCIA_CREATE(datos completos)
   - actualizarLicencia -> SP_CONSULTALICENCIA_UPDATE(id, datos)
   - cambiarEstadoLicencia -> SP_CONSULTALICENCIA_CAMBIAR_ESTADO(numero, estado)
   - licenciasVencidas -> SP_CONSULTALICENCIA_VENCIDAS(dias_adelanto)

3. Funcionalidades especiales:
   - Cálculo automático de días para vencer
   - Filtro por vigentes solamente
   - Sistema de alertas por vencimiento
   - Cambio de estado con observaciones
   - Búsqueda multi-criterio

4. Validaciones:
   - Número de licencia único
   - Estados y tipos válidos
   - Campos requeridos según tipo
   - RFC formato válido (opcional)
*/