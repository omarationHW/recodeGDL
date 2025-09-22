-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA CONSULTA DE ANUNCIOS
-- Convención: SP_CONSULTAANUNCIO_XXX
-- Generado: 2025-09-09
-- Tabla: anuncios_publicitarios
-- Módulo: 04 - CONSULTAANUNCIOFRM (Prioridad Alta)
-- ============================================

-- Tabla para anuncios publicitarios
CREATE TABLE IF NOT EXISTS public.anuncios_publicitarios (
    id SERIAL PRIMARY KEY,
    numero_anuncio VARCHAR(100) NOT NULL UNIQUE,
    folio VARCHAR(100),
    tipo_anuncio VARCHAR(50), -- 'LUMINOSO', 'BANNER', 'ESPECTACULAR', 'ROTULO'
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255) NOT NULL,
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    direccion_anuncio TEXT NOT NULL,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    telefono VARCHAR(20),
    email VARCHAR(100),
    descripcion_anuncio TEXT,
    dimensiones VARCHAR(100), -- Ej: "3x2 metros"
    material VARCHAR(100),
    iluminacion VARCHAR(50), -- 'SI', 'NO', 'PARCIAL'
    altura_instalacion NUMERIC(5,2),
    mensaje_publicitario TEXT,
    empresa_anunciante VARCHAR(255),
    fecha_solicitud DATE,
    fecha_autorizacion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(20) DEFAULT 'VIGENTE', -- 'VIGENTE', 'VENCIDO', 'SUSPENDIDO', 'CANCELADO'
    costo_anual NUMERIC(10,2),
    observaciones TEXT,
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para consultas optimizadas
CREATE INDEX IF NOT EXISTS idx_anu_numero ON public.anuncios_publicitarios(numero_anuncio);
CREATE INDEX IF NOT EXISTS idx_anu_folio ON public.anuncios_publicitarios(folio);
CREATE INDEX IF NOT EXISTS idx_anu_tipo ON public.anuncios_publicitarios(tipo_anuncio);
CREATE INDEX IF NOT EXISTS idx_anu_propietario ON public.anuncios_publicitarios(propietario);
CREATE INDEX IF NOT EXISTS idx_anu_empresa ON public.anuncios_publicitarios(empresa_anunciante);
CREATE INDEX IF NOT EXISTS idx_anu_estado ON public.anuncios_publicitarios(estado);
CREATE INDEX IF NOT EXISTS idx_anu_fecha_venc ON public.anuncios_publicitarios(fecha_vencimiento);
CREATE INDEX IF NOT EXISTS idx_anu_direccion ON public.anuncios_publicitarios(direccion_anuncio);

-- ============================================

-- SP 1/6: SP_CONSULTAANUNCIO_LIST
-- Tipo: List/Read
-- Descripción: Lista anuncios con filtros y paginación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTAANUNCIO_LIST(
    p_numero_anuncio VARCHAR(100) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_empresa_anunciante VARCHAR(255) DEFAULT NULL,
    p_tipo_anuncio VARCHAR(50) DEFAULT NULL,
    p_direccion TEXT DEFAULT NULL,
    p_estado VARCHAR(20) DEFAULT NULL,
    p_vigentes_solo BOOLEAN DEFAULT FALSE,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    numero_anuncio VARCHAR(100),
    folio VARCHAR(100),
    tipo_anuncio VARCHAR(50),
    propietario VARCHAR(255),
    empresa_anunciante VARCHAR(255),
    direccion_anuncio TEXT,
    colonia VARCHAR(100),
    descripcion_anuncio TEXT,
    dimensiones VARCHAR(100),
    fecha_autorizacion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(20),
    dias_para_vencer INTEGER,
    costo_anual NUMERIC(10,2),
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
    FROM public.anuncios_publicitarios ap
    WHERE (p_numero_anuncio IS NULL OR ap.numero_anuncio ILIKE '%' || p_numero_anuncio || '%')
      AND (p_propietario IS NULL OR ap.propietario ILIKE '%' || p_propietario || '%')
      AND (p_empresa_anunciante IS NULL OR ap.empresa_anunciante ILIKE '%' || p_empresa_anunciante || '%')
      AND (p_tipo_anuncio IS NULL OR ap.tipo_anuncio = upper(p_tipo_anuncio))
      AND (p_direccion IS NULL OR ap.direccion_anuncio ILIKE '%' || p_direccion || '%')
      AND (p_estado IS NULL OR ap.estado = v_estado_filtro);

    -- Retornar resultados
    RETURN QUERY
    SELECT 
        ap.id,
        ap.numero_anuncio,
        ap.folio,
        ap.tipo_anuncio,
        ap.propietario,
        ap.empresa_anunciante,
        ap.direccion_anuncio,
        ap.colonia,
        ap.descripcion_anuncio,
        ap.dimensiones,
        ap.fecha_autorizacion,
        ap.fecha_vencimiento,
        ap.estado,
        CASE 
            WHEN ap.fecha_vencimiento IS NULL THEN NULL
            ELSE (ap.fecha_vencimiento - CURRENT_DATE)::INTEGER
        END as dias_para_vencer,
        ap.costo_anual,
        v_total_count as total_registros
    FROM public.anuncios_publicitarios ap
    WHERE (p_numero_anuncio IS NULL OR ap.numero_anuncio ILIKE '%' || p_numero_anuncio || '%')
      AND (p_propietario IS NULL OR ap.propietario ILIKE '%' || p_propietario || '%')
      AND (p_empresa_anunciante IS NULL OR ap.empresa_anunciante ILIKE '%' || p_empresa_anunciante || '%')
      AND (p_tipo_anuncio IS NULL OR ap.tipo_anuncio = upper(p_tipo_anuncio))
      AND (p_direccion IS NULL OR ap.direccion_anuncio ILIKE '%' || p_direccion || '%')
      AND (p_estado IS NULL OR ap.estado = v_estado_filtro)
    ORDER BY ap.fecha_vencimiento DESC, ap.fecha_registro DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================

-- SP 2/6: SP_CONSULTAANUNCIO_GET
-- Tipo: Read
-- Descripción: Obtiene detalle completo de un anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTAANUNCIO_GET(p_numero_anuncio VARCHAR(100))
RETURNS TABLE(
    id INTEGER,
    numero_anuncio VARCHAR(100),
    folio VARCHAR(100),
    tipo_anuncio VARCHAR(50),
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    direccion_anuncio TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    telefono VARCHAR(20),
    email VARCHAR(100),
    descripcion_anuncio TEXT,
    dimensiones VARCHAR(100),
    material VARCHAR(100),
    iluminacion VARCHAR(50),
    altura_instalacion NUMERIC(5,2),
    mensaje_publicitario TEXT,
    empresa_anunciante VARCHAR(255),
    fecha_solicitud DATE,
    fecha_autorizacion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(20),
    costo_anual NUMERIC(10,2),
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
    -- Validar que el anuncio existe
    SELECT COUNT(*) INTO v_exists
    FROM public.anuncios_publicitarios
    WHERE numero_anuncio = p_numero_anuncio;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró el anuncio: %', p_numero_anuncio;
    END IF;

    -- Retornar el registro completo
    RETURN QUERY
    SELECT 
        ap.id,
        ap.numero_anuncio,
        ap.folio,
        ap.tipo_anuncio,
        ap.cuenta_predial,
        ap.propietario,
        ap.razon_social,
        ap.rfc,
        ap.direccion_anuncio,
        ap.colonia,
        ap.codigo_postal,
        ap.telefono,
        ap.email,
        ap.descripcion_anuncio,
        ap.dimensiones,
        ap.material,
        ap.iluminacion,
        ap.altura_instalacion,
        ap.mensaje_publicitario,
        ap.empresa_anunciante,
        ap.fecha_solicitud,
        ap.fecha_autorizacion,
        ap.fecha_vencimiento,
        ap.estado,
        ap.costo_anual,
        ap.observaciones,
        ap.usuario_registro,
        ap.fecha_registro,
        CASE 
            WHEN ap.fecha_vencimiento IS NULL THEN NULL
            ELSE (ap.fecha_vencimiento - CURRENT_DATE)::INTEGER
        END as dias_para_vencer,
        CASE 
            WHEN ap.estado = 'VIGENTE' AND (ap.fecha_vencimiento IS NULL OR ap.fecha_vencimiento >= CURRENT_DATE) 
            THEN TRUE 
            ELSE FALSE 
        END as esta_vigente
    FROM public.anuncios_publicitarios ap
    WHERE ap.numero_anuncio = p_numero_anuncio;
END;
$$;

-- ============================================

-- SP 3/6: SP_CONSULTAANUNCIO_CREATE
-- Tipo: Create
-- Descripción: Crear nuevo anuncio publicitario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTAANUNCIO_CREATE(
    p_numero_anuncio VARCHAR(100),
    p_folio VARCHAR(100),
    p_tipo_anuncio VARCHAR(50),
    p_propietario VARCHAR(255),
    p_direccion_anuncio TEXT,
    p_colonia VARCHAR(100),
    p_descripcion_anuncio TEXT,
    p_dimensiones VARCHAR(100) DEFAULT NULL,
    p_empresa_anunciante VARCHAR(255) DEFAULT NULL,
    p_fecha_autorizacion DATE DEFAULT CURRENT_DATE,
    p_fecha_vencimiento DATE DEFAULT NULL,
    p_costo_anual NUMERIC(10,2) DEFAULT NULL,
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
    IF p_numero_anuncio IS NULL OR trim(p_numero_anuncio) = '' THEN
        RETURN QUERY SELECT FALSE, 'El número de anuncio es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_propietario IS NULL OR trim(p_propietario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El propietario es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_direccion_anuncio IS NULL OR trim(p_direccion_anuncio) = '' THEN
        RETURN QUERY SELECT FALSE, 'La dirección del anuncio es requerida.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar tipo de anuncio
    IF p_tipo_anuncio IS NOT NULL AND upper(p_tipo_anuncio) NOT IN ('LUMINOSO', 'BANNER', 'ESPECTACULAR', 'ROTULO') THEN
        RETURN QUERY SELECT FALSE, 'Tipo de anuncio no válido. Debe ser: LUMINOSO, BANNER, ESPECTACULAR o ROTULO.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no exista el número de anuncio
    SELECT COUNT(*) INTO v_exists
    FROM public.anuncios_publicitarios
    WHERE numero_anuncio = upper(trim(p_numero_anuncio));

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un anuncio con ese número.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el nuevo anuncio
    INSERT INTO public.anuncios_publicitarios (
        numero_anuncio, folio, tipo_anuncio, propietario, direccion_anuncio,
        colonia, descripcion_anuncio, dimensiones, empresa_anunciante,
        fecha_autorizacion, fecha_vencimiento, costo_anual, usuario_registro
    )
    VALUES (
        upper(trim(p_numero_anuncio)),
        upper(trim(p_folio)),
        upper(trim(p_tipo_anuncio)),
        upper(trim(p_propietario)),
        upper(trim(p_direccion_anuncio)),
        upper(trim(p_colonia)),
        p_descripcion_anuncio,
        p_dimensiones,
        upper(trim(p_empresa_anunciante)),
        p_fecha_autorizacion,
        p_fecha_vencimiento,
        p_costo_anual,
        upper(trim(p_usuario_registro))
    )
    RETURNING public.anuncios_publicitarios.id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Anuncio creado correctamente.', v_new_id;
END;
$$;

-- ============================================

-- SP 4/6: SP_CONSULTAANUNCIO_UPDATE
-- Tipo: Update
-- Descripción: Actualizar anuncio existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTAANUNCIO_UPDATE(
    p_id INTEGER,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_razon_social VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_direccion_anuncio TEXT DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_descripcion_anuncio TEXT DEFAULT NULL,
    p_dimensiones VARCHAR(100) DEFAULT NULL,
    p_material VARCHAR(100) DEFAULT NULL,
    p_iluminacion VARCHAR(50) DEFAULT NULL,
    p_altura_instalacion NUMERIC(5,2) DEFAULT NULL,
    p_mensaje_publicitario TEXT DEFAULT NULL,
    p_empresa_anunciante VARCHAR(255) DEFAULT NULL,
    p_fecha_vencimiento DATE DEFAULT NULL,
    p_costo_anual NUMERIC(10,2) DEFAULT NULL,
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
    FROM public.anuncios_publicitarios
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio no existe.';
        RETURN;
    END IF;

    -- Validar iluminación si se proporciona
    IF p_iluminacion IS NOT NULL AND upper(p_iluminacion) NOT IN ('SI', 'NO', 'PARCIAL') THEN
        RETURN QUERY SELECT FALSE, 'Iluminación no válida. Debe ser: SI, NO o PARCIAL.';
        RETURN;
    END IF;

    -- Actualizar solo los campos proporcionados
    UPDATE public.anuncios_publicitarios
    SET propietario = COALESCE(upper(trim(p_propietario)), propietario),
        razon_social = COALESCE(upper(trim(p_razon_social)), razon_social),
        rfc = COALESCE(upper(trim(p_rfc)), rfc),
        direccion_anuncio = COALESCE(upper(trim(p_direccion_anuncio)), direccion_anuncio),
        colonia = COALESCE(upper(trim(p_colonia)), colonia),
        telefono = COALESCE(p_telefono, telefono),
        email = COALESCE(lower(trim(p_email)), email),
        descripcion_anuncio = COALESCE(p_descripcion_anuncio, descripcion_anuncio),
        dimensiones = COALESCE(p_dimensiones, dimensiones),
        material = COALESCE(upper(trim(p_material)), material),
        iluminacion = COALESCE(upper(trim(p_iluminacion)), iluminacion),
        altura_instalacion = COALESCE(p_altura_instalacion, altura_instalacion),
        mensaje_publicitario = COALESCE(p_mensaje_publicitario, mensaje_publicitario),
        empresa_anunciante = COALESCE(upper(trim(p_empresa_anunciante)), empresa_anunciante),
        fecha_vencimiento = COALESCE(p_fecha_vencimiento, fecha_vencimiento),
        costo_anual = COALESCE(p_costo_anual, costo_anual),
        observaciones = COALESCE(p_observaciones, observaciones),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Anuncio actualizado correctamente.';
END;
$$;

-- ============================================

-- SP 5/6: SP_CONSULTAANUNCIO_CAMBIAR_ESTADO
-- Tipo: Update
-- Descripción: Cambiar estado de un anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTAANUNCIO_CAMBIAR_ESTADO(
    p_numero_anuncio VARCHAR(100),
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
    IF upper(p_nuevo_estado) NOT IN ('VIGENTE', 'VENCIDO', 'SUSPENDIDO', 'CANCELADO') THEN
        RETURN QUERY SELECT FALSE, 'Estado no válido. Debe ser: VIGENTE, VENCIDO, SUSPENDIDO o CANCELADO.';
        RETURN;
    END IF;

    -- Validar que el anuncio existe
    SELECT COUNT(*) INTO v_exists
    FROM public.anuncios_publicitarios
    WHERE numero_anuncio = p_numero_anuncio;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio no existe.';
        RETURN;
    END IF;

    -- Cambiar el estado
    UPDATE public.anuncios_publicitarios
    SET estado = upper(p_nuevo_estado),
        observaciones = COALESCE(p_observaciones, observaciones),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE numero_anuncio = p_numero_anuncio;

    RETURN QUERY SELECT TRUE, 'Estado del anuncio cambiado correctamente a: ' || upper(p_nuevo_estado);
END;
$$;

-- ============================================

-- SP 6/6: SP_CONSULTAANUNCIO_VENCIDOS
-- Tipo: Read
-- Descripción: Obtener anuncios próximos a vencer o vencidos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTAANUNCIO_VENCIDOS(
    p_dias_adelanto INTEGER DEFAULT 30,
    p_solo_vencidos BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
    numero_anuncio VARCHAR(100),
    propietario VARCHAR(255),
    empresa_anunciante VARCHAR(255),
    direccion_anuncio TEXT,
    fecha_vencimiento DATE,
    dias_para_vencer INTEGER,
    estado VARCHAR(20),
    urgencia VARCHAR(20),
    costo_anual NUMERIC(10,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ap.numero_anuncio,
        ap.propietario,
        ap.empresa_anunciante,
        ap.direccion_anuncio,
        ap.fecha_vencimiento,
        (ap.fecha_vencimiento - CURRENT_DATE)::INTEGER as dias_para_vencer,
        ap.estado,
        CASE 
            WHEN ap.fecha_vencimiento < CURRENT_DATE THEN 'VENCIDO'
            WHEN (ap.fecha_vencimiento - CURRENT_DATE)::INTEGER <= 7 THEN 'CRITICO'
            WHEN (ap.fecha_vencimiento - CURRENT_DATE)::INTEGER <= 30 THEN 'ALERTA'
            ELSE 'NORMAL'
        END as urgencia,
        ap.costo_anual
    FROM public.anuncios_publicitarios ap
    WHERE ap.fecha_vencimiento IS NOT NULL
      AND ap.estado = 'VIGENTE'
      AND (
          (p_solo_vencidos AND ap.fecha_vencimiento < CURRENT_DATE) OR
          (NOT p_solo_vencidos AND ap.fecha_vencimiento <= CURRENT_DATE + INTERVAL '1 day' * p_dias_adelanto)
      )
    ORDER BY ap.fecha_vencimiento ASC;
END;
$$;

-- ============================================
-- DATOS DE PRUEBA
-- ============================================

INSERT INTO public.anuncios_publicitarios (
    numero_anuncio, folio, tipo_anuncio, propietario, direccion_anuncio, colonia,
    descripcion_anuncio, dimensiones, empresa_anunciante, fecha_autorizacion, 
    fecha_vencimiento, costo_anual, usuario_registro
) VALUES 
    ('ANU-LUM-2025-001', 'AFOL-2025-001', 'LUMINOSO', 
     'JUAN PÉREZ GARCÍA', 'AV. JUÁREZ #123', 'CENTRO',
     'Anuncio luminoso para tienda de abarrotes', '3x2 metros', 'ABARROTES PÉREZ',
     '2025-01-15', '2026-01-15', 15000.00, 'ADMIN'),
    ('ANU-BAN-2025-002', 'AFOL-2025-002', 'BANNER',
     'MARÍA LÓPEZ HERNÁNDEZ', 'CALLE MORELOS #456', 'REFORMA',
     'Banner publicitario para servicios', '4x1 metros', 'SERVICIOS LÓPEZ',
     '2025-02-10', '2026-02-10', 8000.00, 'ADMIN'),
    ('ANU-ESP-2025-003', 'AFOL-2025-003', 'ESPECTACULAR',
     'EMPRESA CONSTRUCTORA SA', 'BLVD. UNIVERSIDAD #789', 'UNIVERSITARIA',
     'Espectacular para empresa constructora', '8x4 metros', 'CONSTRUCTORA INDUSTRIAL',
     '2025-03-05', '2026-03-05', 35000.00, 'ADMIN')
ON CONFLICT (numero_anuncio) DO NOTHING;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
NOTAS PARA LA IMPLEMENTACIÓN:

1. Tabla requerida: public.anuncios_publicitarios
   - Campos únicos: numero_anuncio
   - Campos requeridos: propietario, direccion_anuncio, descripcion_anuncio
   - Estados: VIGENTE, VENCIDO, SUSPENDIDO, CANCELADO
   - Tipos: LUMINOSO, BANNER, ESPECTACULAR, ROTULO

2. Endpoints del controlador Laravel:
   - consultarAnuncios -> SP_CONSULTAANUNCIO_LIST(filtros múltiples)
   - obtenerAnuncio -> SP_CONSULTAANUNCIO_GET(numero_anuncio)
   - crearAnuncio -> SP_CONSULTAANUNCIO_CREATE(datos completos)
   - actualizarAnuncio -> SP_CONSULTAANUNCIO_UPDATE(id, datos)
   - cambiarEstadoAnuncio -> SP_CONSULTAANUNCIO_CAMBIAR_ESTADO(numero, estado)
   - anunciosVencidos -> SP_CONSULTAANUNCIO_VENCIDOS(dias_adelanto)

3. Funcionalidades especiales:
   - Control de dimensiones y materiales
   - Gestión de iluminación (SI/NO/PARCIAL)
   - Altura de instalación
   - Empresa anunciante separada del propietario
   - Sistema de alertas por vencimiento
   - Control de costos anuales

4. Validaciones específicas:
   - Tipos de anuncio válidos
   - Estados permitidos
   - Iluminación controlada
   - Número único de anuncio
*/