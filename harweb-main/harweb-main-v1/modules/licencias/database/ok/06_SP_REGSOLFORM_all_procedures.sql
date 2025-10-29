-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA FORMULARIO REGISTRO DE SOLICITUDES
-- Convención: SP_REGSOLFORM_XXX
-- Generado: 2025-09-09
-- Tabla: formularios_solicitud
-- Módulo: 06 - REGISTROSOLICITUDFORM (Prioridad Alta)
-- ============================================

-- Tabla para formularios de registro detallado
CREATE TABLE IF NOT EXISTS public.formularios_solicitud (
    id SERIAL PRIMARY KEY,
    folio_formulario VARCHAR(100) NOT NULL UNIQUE,
    solicitud_id INTEGER, -- Referencia a solicitudes_licencias
    tipo_formulario VARCHAR(50) NOT NULL, -- 'LICENCIA_COMERCIAL', 'LICENCIA_INDUSTRIAL', 'ANUNCIO_PUBLICITARIO'
    
    -- Datos del solicitante (completos)
    nombre_completo VARCHAR(255) NOT NULL,
    apellido_paterno VARCHAR(100),
    apellido_materno VARCHAR(100),
    fecha_nacimiento DATE,
    lugar_nacimiento VARCHAR(150),
    nacionalidad VARCHAR(50),
    estado_civil VARCHAR(20),
    ocupacion VARCHAR(100),
    escolaridad VARCHAR(50),
    
    -- Identificación oficial
    rfc VARCHAR(20),
    curp VARCHAR(20),
    ine VARCHAR(20),
    pasaporte VARCHAR(20),
    
    -- Domicilio particular
    calle_particular VARCHAR(255),
    numero_ext_particular VARCHAR(10),
    numero_int_particular VARCHAR(10),
    colonia_particular VARCHAR(100),
    municipio_particular VARCHAR(100),
    estado_particular VARCHAR(100),
    cp_particular VARCHAR(10),
    telefono_particular VARCHAR(20),
    celular VARCHAR(20),
    email_personal VARCHAR(100),
    
    -- Datos del establecimiento
    nombre_establecimiento VARCHAR(255),
    giro_actividad VARCHAR(255) NOT NULL,
    descripcion_actividad TEXT,
    calle_negocio VARCHAR(255) NOT NULL,
    numero_ext_negocio VARCHAR(10),
    numero_int_negocio VARCHAR(10),
    colonia_negocio VARCHAR(100),
    municipio_negocio VARCHAR(100),
    estado_negocio VARCHAR(100),
    cp_negocio VARCHAR(10),
    telefono_negocio VARCHAR(20),
    email_negocio VARCHAR(100),
    
    -- Información del local
    superficie_total NUMERIC(10,2),
    superficie_construida NUMERIC(10,2),
    numero_niveles INTEGER,
    tipo_construccion VARCHAR(50), -- 'PROPIA', 'RENTADA', 'COMODATO'
    horario_funcionamiento VARCHAR(200),
    dias_operacion VARCHAR(100),
    numero_empleados INTEGER,
    
    -- Datos económicos
    capital_social NUMERIC(12,2),
    inversion_fija NUMERIC(12,2),
    inversion_variable NUMERIC(12,2),
    ingresos_anuales_estimados NUMERIC(12,2),
    
    -- Servicios públicos
    agua BOOLEAN DEFAULT FALSE,
    drenaje BOOLEAN DEFAULT FALSE,
    energia_electrica BOOLEAN DEFAULT FALSE,
    telefono BOOLEAN DEFAULT FALSE,
    internet BOOLEAN DEFAULT FALSE,
    gas BOOLEAN DEFAULT FALSE,
    
    -- Documentos anexos (JSON)
    documentos_requeridos TEXT, -- JSON con lista de documentos
    documentos_entregados TEXT, -- JSON con documentos recibidos
    
    -- Control
    estado_formulario VARCHAR(20) DEFAULT 'BORRADOR', -- 'BORRADOR', 'COMPLETO', 'ENVIADO', 'PROCESADO'
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_completado TIMESTAMP,
    fecha_enviado TIMESTAMP,
    usuario_captura VARCHAR(100),
    funcionario_revisor VARCHAR(100),
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para consultas optimizadas
CREATE INDEX IF NOT EXISTS idx_form_folio ON public.formularios_solicitud(folio_formulario);
CREATE INDEX IF NOT EXISTS idx_form_solicitud ON public.formularios_solicitud(solicitud_id);
CREATE INDEX IF NOT EXISTS idx_form_tipo ON public.formularios_solicitud(tipo_formulario);
CREATE INDEX IF NOT EXISTS idx_form_nombre ON public.formularios_solicitud(nombre_completo);
CREATE INDEX IF NOT EXISTS idx_form_rfc ON public.formularios_solicitud(rfc);
CREATE INDEX IF NOT EXISTS idx_form_establecimiento ON public.formularios_solicitud(nombre_establecimiento);
CREATE INDEX IF NOT EXISTS idx_form_estado ON public.formularios_solicitud(estado_formulario);
CREATE INDEX IF NOT EXISTS idx_form_usuario ON public.formularios_solicitud(usuario_captura);

-- ============================================

-- SP 1/6: SP_REGSOLFORM_LIST
-- Tipo: List/Read
-- Descripción: Lista formularios con filtros y paginación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLFORM_LIST(
    p_folio_formulario VARCHAR(100) DEFAULT NULL,
    p_nombre_completo VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_tipo_formulario VARCHAR(50) DEFAULT NULL,
    p_estado_formulario VARCHAR(20) DEFAULT NULL,
    p_usuario_captura VARCHAR(100) DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    folio_formulario VARCHAR(100),
    solicitud_id INTEGER,
    tipo_formulario VARCHAR(50),
    nombre_completo VARCHAR(255),
    rfc VARCHAR(20),
    nombre_establecimiento VARCHAR(255),
    giro_actividad VARCHAR(255),
    estado_formulario VARCHAR(20),
    fecha_creacion TIMESTAMP,
    fecha_completado TIMESTAMP,
    usuario_captura VARCHAR(100),
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM public.formularios_solicitud fs
    WHERE (p_folio_formulario IS NULL OR fs.folio_formulario ILIKE '%' || p_folio_formulario || '%')
      AND (p_nombre_completo IS NULL OR fs.nombre_completo ILIKE '%' || p_nombre_completo || '%')
      AND (p_rfc IS NULL OR fs.rfc ILIKE '%' || p_rfc || '%')
      AND (p_tipo_formulario IS NULL OR fs.tipo_formulario = upper(p_tipo_formulario))
      AND (p_estado_formulario IS NULL OR fs.estado_formulario = upper(p_estado_formulario))
      AND (p_usuario_captura IS NULL OR fs.usuario_captura ILIKE '%' || p_usuario_captura || '%')
      AND (p_fecha_desde IS NULL OR DATE(fs.fecha_creacion) >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR DATE(fs.fecha_creacion) <= p_fecha_hasta);

    -- Retornar resultados
    RETURN QUERY
    SELECT 
        fs.id,
        fs.folio_formulario,
        fs.solicitud_id,
        fs.tipo_formulario,
        fs.nombre_completo,
        fs.rfc,
        fs.nombre_establecimiento,
        fs.giro_actividad,
        fs.estado_formulario,
        fs.fecha_creacion,
        fs.fecha_completado,
        fs.usuario_captura,
        v_total_count as total_registros
    FROM public.formularios_solicitud fs
    WHERE (p_folio_formulario IS NULL OR fs.folio_formulario ILIKE '%' || p_folio_formulario || '%')
      AND (p_nombre_completo IS NULL OR fs.nombre_completo ILIKE '%' || p_nombre_completo || '%')
      AND (p_rfc IS NULL OR fs.rfc ILIKE '%' || p_rfc || '%')
      AND (p_tipo_formulario IS NULL OR fs.tipo_formulario = upper(p_tipo_formulario))
      AND (p_estado_formulario IS NULL OR fs.estado_formulario = upper(p_estado_formulario))
      AND (p_usuario_captura IS NULL OR fs.usuario_captura ILIKE '%' || p_usuario_captura || '%')
      AND (p_fecha_desde IS NULL OR DATE(fs.fecha_creacion) >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR DATE(fs.fecha_creacion) <= p_fecha_hasta)
    ORDER BY fs.fecha_creacion DESC, fs.id DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================

-- SP 2/6: SP_REGSOLFORM_GET
-- Tipo: Read
-- Descripción: Obtiene formulario completo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLFORM_GET(p_folio_formulario VARCHAR(100))
RETURNS TABLE(
    id INTEGER,
    folio_formulario VARCHAR(100),
    solicitud_id INTEGER,
    tipo_formulario VARCHAR(50),
    nombre_completo VARCHAR(255),
    apellido_paterno VARCHAR(100),
    apellido_materno VARCHAR(100),
    fecha_nacimiento DATE,
    rfc VARCHAR(20),
    curp VARCHAR(20),
    calle_particular VARCHAR(255),
    colonia_particular VARCHAR(100),
    cp_particular VARCHAR(10),
    telefono_particular VARCHAR(20),
    email_personal VARCHAR(100),
    nombre_establecimiento VARCHAR(255),
    giro_actividad VARCHAR(255),
    descripcion_actividad TEXT,
    calle_negocio VARCHAR(255),
    colonia_negocio VARCHAR(100),
    cp_negocio VARCHAR(10),
    superficie_total NUMERIC(10,2),
    numero_empleados INTEGER,
    capital_social NUMERIC(12,2),
    estado_formulario VARCHAR(20),
    fecha_creacion TIMESTAMP,
    observaciones TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que el formulario existe
    SELECT COUNT(*) INTO v_exists
    FROM public.formularios_solicitud
    WHERE folio_formulario = p_folio_formulario;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró el formulario: %', p_folio_formulario;
    END IF;

    -- Retornar campos principales del formulario
    RETURN QUERY
    SELECT 
        fs.id,
        fs.folio_formulario,
        fs.solicitud_id,
        fs.tipo_formulario,
        fs.nombre_completo,
        fs.apellido_paterno,
        fs.apellido_materno,
        fs.fecha_nacimiento,
        fs.rfc,
        fs.curp,
        fs.calle_particular,
        fs.colonia_particular,
        fs.cp_particular,
        fs.telefono_particular,
        fs.email_personal,
        fs.nombre_establecimiento,
        fs.giro_actividad,
        fs.descripcion_actividad,
        fs.calle_negocio,
        fs.colonia_negocio,
        fs.cp_negocio,
        fs.superficie_total,
        fs.numero_empleados,
        fs.capital_social,
        fs.estado_formulario,
        fs.fecha_creacion,
        fs.observaciones
    FROM public.formularios_solicitud fs
    WHERE fs.folio_formulario = p_folio_formulario;
END;
$$;

-- ============================================

-- SP 3/6: SP_REGSOLFORM_CREATE
-- Tipo: Create
-- Descripción: Crear nuevo formulario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLFORM_CREATE(
    p_folio_formulario VARCHAR(100),
    p_tipo_formulario VARCHAR(50),
    p_nombre_completo VARCHAR(255),
    p_giro_actividad VARCHAR(255),
    p_calle_negocio VARCHAR(255),
    p_apellido_paterno VARCHAR(100) DEFAULT NULL,
    p_apellido_materno VARCHAR(100) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_curp VARCHAR(20) DEFAULT NULL,
    p_nombre_establecimiento VARCHAR(255) DEFAULT NULL,
    p_usuario_captura VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT, id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_exists INTEGER;
BEGIN
    -- Validar campos requeridos
    IF p_folio_formulario IS NULL OR trim(p_folio_formulario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El folio del formulario es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_nombre_completo IS NULL OR trim(p_nombre_completo) = '' THEN
        RETURN QUERY SELECT FALSE, 'El nombre completo es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_giro_actividad IS NULL OR trim(p_giro_actividad) = '' THEN
        RETURN QUERY SELECT FALSE, 'El giro de actividad es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_calle_negocio IS NULL OR trim(p_calle_negocio) = '' THEN
        RETURN QUERY SELECT FALSE, 'La dirección del negocio es requerida.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar tipo de formulario
    IF upper(p_tipo_formulario) NOT IN ('LICENCIA_COMERCIAL', 'LICENCIA_INDUSTRIAL', 'ANUNCIO_PUBLICITARIO') THEN
        RETURN QUERY SELECT FALSE, 'Tipo de formulario no válido. Debe ser: LICENCIA_COMERCIAL, LICENCIA_INDUSTRIAL o ANUNCIO_PUBLICITARIO.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no exista el folio
    SELECT COUNT(*) INTO v_exists
    FROM public.formularios_solicitud
    WHERE folio_formulario = upper(trim(p_folio_formulario));

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un formulario con ese folio.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el nuevo formulario
    INSERT INTO public.formularios_solicitud (
        folio_formulario, tipo_formulario, nombre_completo, apellido_paterno,
        apellido_materno, rfc, curp, nombre_establecimiento, giro_actividad,
        calle_negocio, usuario_captura
    )
    VALUES (
        upper(trim(p_folio_formulario)),
        upper(trim(p_tipo_formulario)),
        upper(trim(p_nombre_completo)),
        upper(trim(p_apellido_paterno)),
        upper(trim(p_apellido_materno)),
        upper(trim(p_rfc)),
        upper(trim(p_curp)),
        upper(trim(p_nombre_establecimiento)),
        upper(trim(p_giro_actividad)),
        upper(trim(p_calle_negocio)),
        upper(trim(p_usuario_captura))
    )
    RETURNING public.formularios_solicitud.id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Formulario creado correctamente. Folio: ' || upper(trim(p_folio_formulario)), v_new_id;
END;
$$;

-- ============================================

-- SP 4/6: SP_REGSOLFORM_UPDATE_PERSONAL
-- Tipo: Update
-- Descripción: Actualizar datos personales del formulario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLFORM_UPDATE_PERSONAL(
    p_id INTEGER,
    p_apellido_paterno VARCHAR(100) DEFAULT NULL,
    p_apellido_materno VARCHAR(100) DEFAULT NULL,
    p_fecha_nacimiento DATE DEFAULT NULL,
    p_lugar_nacimiento VARCHAR(150) DEFAULT NULL,
    p_nacionalidad VARCHAR(50) DEFAULT NULL,
    p_estado_civil VARCHAR(20) DEFAULT NULL,
    p_ocupacion VARCHAR(100) DEFAULT NULL,
    p_curp VARCHAR(20) DEFAULT NULL,
    p_ine VARCHAR(20) DEFAULT NULL,
    p_calle_particular VARCHAR(255) DEFAULT NULL,
    p_colonia_particular VARCHAR(100) DEFAULT NULL,
    p_cp_particular VARCHAR(10) DEFAULT NULL,
    p_telefono_particular VARCHAR(20) DEFAULT NULL,
    p_celular VARCHAR(20) DEFAULT NULL,
    p_email_personal VARCHAR(100) DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_estado VARCHAR(20);
BEGIN
    -- Validar que el formulario existe y obtener estado
    SELECT COUNT(*), MAX(estado_formulario) INTO v_exists, v_estado
    FROM public.formularios_solicitud
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El formulario no existe.';
        RETURN;
    END IF;

    -- Verificar que se pueda modificar
    IF v_estado IN ('ENVIADO', 'PROCESADO') THEN
        RETURN QUERY SELECT FALSE, 'No se puede modificar un formulario en estado: ' || v_estado;
        RETURN;
    END IF;

    -- Actualizar datos personales
    UPDATE public.formularios_solicitud
    SET apellido_paterno = COALESCE(upper(trim(p_apellido_paterno)), apellido_paterno),
        apellido_materno = COALESCE(upper(trim(p_apellido_materno)), apellido_materno),
        fecha_nacimiento = COALESCE(p_fecha_nacimiento, fecha_nacimiento),
        lugar_nacimiento = COALESCE(upper(trim(p_lugar_nacimiento)), lugar_nacimiento),
        nacionalidad = COALESCE(upper(trim(p_nacionalidad)), nacionalidad),
        estado_civil = COALESCE(upper(trim(p_estado_civil)), estado_civil),
        ocupacion = COALESCE(upper(trim(p_ocupacion)), ocupacion),
        curp = COALESCE(upper(trim(p_curp)), curp),
        ine = COALESCE(upper(trim(p_ine)), ine),
        calle_particular = COALESCE(upper(trim(p_calle_particular)), calle_particular),
        colonia_particular = COALESCE(upper(trim(p_colonia_particular)), colonia_particular),
        cp_particular = COALESCE(p_cp_particular, cp_particular),
        telefono_particular = COALESCE(p_telefono_particular, telefono_particular),
        celular = COALESCE(p_celular, celular),
        email_personal = COALESCE(lower(trim(p_email_personal)), email_personal),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Datos personales actualizados correctamente.';
END;
$$;

-- ============================================

-- SP 5/6: SP_REGSOLFORM_UPDATE_NEGOCIO
-- Tipo: Update
-- Descripción: Actualizar datos del negocio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLFORM_UPDATE_NEGOCIO(
    p_id INTEGER,
    p_nombre_establecimiento VARCHAR(255) DEFAULT NULL,
    p_descripcion_actividad TEXT DEFAULT NULL,
    p_numero_ext_negocio VARCHAR(10) DEFAULT NULL,
    p_colonia_negocio VARCHAR(100) DEFAULT NULL,
    p_cp_negocio VARCHAR(10) DEFAULT NULL,
    p_telefono_negocio VARCHAR(20) DEFAULT NULL,
    p_superficie_total NUMERIC(10,2) DEFAULT NULL,
    p_numero_empleados INTEGER DEFAULT NULL,
    p_horario_funcionamiento VARCHAR(200) DEFAULT NULL,
    p_capital_social NUMERIC(12,2) DEFAULT NULL,
    p_inversion_fija NUMERIC(12,2) DEFAULT NULL,
    p_agua BOOLEAN DEFAULT NULL,
    p_drenaje BOOLEAN DEFAULT NULL,
    p_energia_electrica BOOLEAN DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_estado VARCHAR(20);
BEGIN
    -- Validar que el formulario existe y obtener estado
    SELECT COUNT(*), MAX(estado_formulario) INTO v_exists, v_estado
    FROM public.formularios_solicitud
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El formulario no existe.';
        RETURN;
    END IF;

    -- Verificar que se pueda modificar
    IF v_estado IN ('ENVIADO', 'PROCESADO') THEN
        RETURN QUERY SELECT FALSE, 'No se puede modificar un formulario en estado: ' || v_estado;
        RETURN;
    END IF;

    -- Actualizar datos del negocio
    UPDATE public.formularios_solicitud
    SET nombre_establecimiento = COALESCE(upper(trim(p_nombre_establecimiento)), nombre_establecimiento),
        descripcion_actividad = COALESCE(p_descripcion_actividad, descripcion_actividad),
        numero_ext_negocio = COALESCE(p_numero_ext_negocio, numero_ext_negocio),
        colonia_negocio = COALESCE(upper(trim(p_colonia_negocio)), colonia_negocio),
        cp_negocio = COALESCE(p_cp_negocio, cp_negocio),
        telefono_negocio = COALESCE(p_telefono_negocio, telefono_negocio),
        superficie_total = COALESCE(p_superficie_total, superficie_total),
        numero_empleados = COALESCE(p_numero_empleados, numero_empleados),
        horario_funcionamiento = COALESCE(p_horario_funcionamiento, horario_funcionamiento),
        capital_social = COALESCE(p_capital_social, capital_social),
        inversion_fija = COALESCE(p_inversion_fija, inversion_fija),
        agua = COALESCE(p_agua, agua),
        drenaje = COALESCE(p_drenaje, drenaje),
        energia_electrica = COALESCE(p_energia_electrica, energia_electrica),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Datos del negocio actualizados correctamente.';
END;
$$;

-- ============================================

-- SP 6/6: SP_REGSOLFORM_CAMBIAR_ESTADO
-- Tipo: Update
-- Descripción: Cambiar estado del formulario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_REGSOLFORM_CAMBIAR_ESTADO(
    p_folio_formulario VARCHAR(100),
    p_nuevo_estado VARCHAR(20),
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
    IF upper(p_nuevo_estado) NOT IN ('BORRADOR', 'COMPLETO', 'ENVIADO', 'PROCESADO') THEN
        RETURN QUERY SELECT FALSE, 'Estado no válido. Debe ser: BORRADOR, COMPLETO, ENVIADO o PROCESADO.';
        RETURN;
    END IF;

    -- Validar que el formulario existe
    SELECT COUNT(*) INTO v_exists
    FROM public.formularios_solicitud
    WHERE folio_formulario = p_folio_formulario;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El formulario no existe.';
        RETURN;
    END IF;

    -- Cambiar el estado y actualizar campos relacionados
    UPDATE public.formularios_solicitud
    SET estado_formulario = upper(p_nuevo_estado),
        observaciones = COALESCE(p_observaciones, observaciones),
        funcionario_revisor = COALESCE(upper(trim(p_funcionario_revisor)), funcionario_revisor),
        fecha_completado = CASE 
            WHEN upper(p_nuevo_estado) = 'COMPLETO' THEN CURRENT_TIMESTAMP 
            ELSE fecha_completado 
        END,
        fecha_enviado = CASE 
            WHEN upper(p_nuevo_estado) = 'ENVIADO' THEN CURRENT_TIMESTAMP 
            ELSE fecha_enviado 
        END,
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE folio_formulario = p_folio_formulario;

    RETURN QUERY SELECT TRUE, 'Estado del formulario cambiado correctamente a: ' || upper(p_nuevo_estado);
END;
$$;

-- ============================================
-- DATOS DE PRUEBA
-- ============================================

INSERT INTO public.formularios_solicitud (
    folio_formulario, tipo_formulario, nombre_completo, apellido_paterno, apellido_materno,
    rfc, curp, nombre_establecimiento, giro_actividad, calle_negocio, colonia_negocio,
    superficie_total, numero_empleados, capital_social, usuario_captura
) VALUES 
    ('FORM-2025-001', 'LICENCIA_COMERCIAL', 'JUAN', 'PÉREZ', 'GARCÍA',
     'PEGJ850101ABC', 'PEGJ850101HJCRNN05', 'ABARROTES PÉREZ', 'COMERCIO AL POR MENOR',
     'AV. JUÁREZ #123', 'CENTRO', 50.00, 3, 150000.00, 'ADMIN'),
    ('FORM-2025-002', 'ANUNCIO_PUBLICITARIO', 'MARÍA', 'LÓPEZ', 'HERNÁNDEZ',
     'LOHM750215DEF', 'LOHM750215MJCPRR08', 'SERVICIOS LÓPEZ', 'SERVICIOS PROFESIONALES',
     'CALLE MORELOS #456', 'REFORMA', 25.00, 2, 75000.00, 'ADMIN'),
    ('FORM-2025-003', 'LICENCIA_INDUSTRIAL', 'CARLOS', 'RUIZ', 'MENDOZA',
     'RMC901201GHI', 'RMC901201HJCRNN09', 'CONSTRUCTORA INDUSTRIAL', 'CONSTRUCCIÓN',
     'BLVD. UNIVERSIDAD #789', 'UNIVERSITARIA', 200.00, 15, 500000.00, 'ADMIN')
ON CONFLICT (folio_formulario) DO NOTHING;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
NOTAS PARA LA IMPLEMENTACIÓN:

1. Tabla requerida: public.formularios_solicitud
   - Campos únicos: folio_formulario
   - Datos completos del solicitante (personales y negocio)
   - Estados: BORRADOR, COMPLETO, ENVIADO, PROCESADO
   - Tipos: LICENCIA_COMERCIAL, LICENCIA_INDUSTRIAL, ANUNCIO_PUBLICITARIO

2. Endpoints del controlador Laravel:
   - listarFormularios -> SP_REGSOLFORM_LIST(filtros múltiples)
   - obtenerFormulario -> SP_REGSOLFORM_GET(folio_formulario)
   - crearFormulario -> SP_REGSOLFORM_CREATE(datos básicos)
   - actualizarPersonal -> SP_REGSOLFORM_UPDATE_PERSONAL(id, datos personales)
   - actualizarNegocio -> SP_REGSOLFORM_UPDATE_NEGOCIO(id, datos negocio)
   - cambiarEstado -> SP_REGSOLFORM_CAMBIAR_ESTADO(folio, estado)

3. Funcionalidades especiales:
   - Formulario por secciones (personal/negocio)
   - Control de modificación por estado
   - Validación de campos requeridos por tipo
   - Servicios públicos con checkboxes
   - Datos económicos detallados
   - Documentos como JSON

4. Campos de control:
   - Fechas de seguimiento por estado
   - Usuario captura vs funcionario revisor
   - Observaciones por cambio
   - Referencias a solicitudes
   - Trazabilidad completa del proceso
*/