-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA SISTEMA DE BÚSQUEDA GENERAL
-- Convención: SP_BUSQUE_XXX
-- Generado: 2025-09-09
-- Tabla: busqueda_general
-- Módulo: 02 - BUSQUE (Prioridad Alta)
-- ============================================

-- Tabla para búsquedas generales del sistema
CREATE TABLE IF NOT EXISTS public.busqueda_general (
    id SERIAL PRIMARY KEY,
    tipo_registro VARCHAR(50) NOT NULL, -- 'LICENCIA', 'ANUNCIO', 'TRAMITE', 'PREDIAL'
    folio VARCHAR(100),
    numero_licencia VARCHAR(100),
    numero_anuncio VARCHAR(100),
    numero_tramite VARCHAR(100),
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    giro VARCHAR(255),
    actividad VARCHAR(255),
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    fecha_alta DATE,
    fecha_vencimiento DATE,
    observaciones TEXT,
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_busque_tipo ON public.busqueda_general(tipo_registro);
CREATE INDEX IF NOT EXISTS idx_busque_folio ON public.busqueda_general(folio);
CREATE INDEX IF NOT EXISTS idx_busque_licencia ON public.busqueda_general(numero_licencia);
CREATE INDEX IF NOT EXISTS idx_busque_anuncio ON public.busqueda_general(numero_anuncio);
CREATE INDEX IF NOT EXISTS idx_busque_tramite ON public.busqueda_general(numero_tramite);
CREATE INDEX IF NOT EXISTS idx_busque_predial ON public.busqueda_general(cuenta_predial);
CREATE INDEX IF NOT EXISTS idx_busque_propietario ON public.busqueda_general(propietario);
CREATE INDEX IF NOT EXISTS idx_busque_estado ON public.busqueda_general(estado);

-- ============================================

-- SP 1/5: SP_BUSQUE_GENERAL
-- Tipo: Search
-- Descripción: Búsqueda general en todos los tipos de registro
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BUSQUE_GENERAL(
    p_termino_busqueda VARCHAR(255) DEFAULT NULL,
    p_tipo_registro VARCHAR(50) DEFAULT NULL,
    p_estado VARCHAR(20) DEFAULT 'ACTIVO',
    p_limite INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    tipo_registro VARCHAR(50),
    folio VARCHAR(100),
    numero_licencia VARCHAR(100),
    numero_anuncio VARCHAR(100),
    numero_tramite VARCHAR(100),
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    giro VARCHAR(255),
    actividad VARCHAR(255),
    estado VARCHAR(20),
    fecha_alta DATE,
    fecha_vencimiento DATE,
    observaciones TEXT,
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM public.busqueda_general bg
    WHERE (p_termino_busqueda IS NULL OR 
           bg.folio ILIKE '%' || p_termino_busqueda || '%' OR
           bg.numero_licencia ILIKE '%' || p_termino_busqueda || '%' OR
           bg.numero_anuncio ILIKE '%' || p_termino_busqueda || '%' OR
           bg.numero_tramite ILIKE '%' || p_termino_busqueda || '%' OR
           bg.cuenta_predial ILIKE '%' || p_termino_busqueda || '%' OR
           bg.propietario ILIKE '%' || p_termino_busqueda || '%' OR
           bg.direccion ILIKE '%' || p_termino_busqueda || '%' OR
           bg.giro ILIKE '%' || p_termino_busqueda || '%')
      AND (p_tipo_registro IS NULL OR bg.tipo_registro = upper(p_tipo_registro))
      AND bg.estado = p_estado;

    -- Retornar resultados
    RETURN QUERY
    SELECT 
        bg.id,
        bg.tipo_registro,
        bg.folio,
        bg.numero_licencia,
        bg.numero_anuncio,
        bg.numero_tramite,
        bg.cuenta_predial,
        bg.propietario,
        bg.direccion,
        bg.colonia,
        bg.giro,
        bg.actividad,
        bg.estado,
        bg.fecha_alta,
        bg.fecha_vencimiento,
        bg.observaciones,
        bg.usuario_registro,
        bg.fecha_registro,
        v_total_count as total_registros
    FROM public.busqueda_general bg
    WHERE (p_termino_busqueda IS NULL OR 
           bg.folio ILIKE '%' || p_termino_busqueda || '%' OR
           bg.numero_licencia ILIKE '%' || p_termino_busqueda || '%' OR
           bg.numero_anuncio ILIKE '%' || p_termino_busqueda || '%' OR
           bg.numero_tramite ILIKE '%' || p_termino_busqueda || '%' OR
           bg.cuenta_predial ILIKE '%' || p_termino_busqueda || '%' OR
           bg.propietario ILIKE '%' || p_termino_busqueda || '%' OR
           bg.direccion ILIKE '%' || p_termino_busqueda || '%' OR
           bg.giro ILIKE '%' || p_termino_busqueda || '%')
      AND (p_tipo_registro IS NULL OR bg.tipo_registro = upper(p_tipo_registro))
      AND bg.estado = p_estado
    ORDER BY bg.fecha_registro DESC, bg.id DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================

-- SP 2/5: SP_BUSQUE_POR_FOLIO
-- Tipo: Search
-- Descripción: Búsqueda específica por folio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BUSQUE_POR_FOLIO(p_folio VARCHAR(100))
RETURNS TABLE(
    id INTEGER,
    tipo_registro VARCHAR(50),
    folio VARCHAR(100),
    numero_licencia VARCHAR(100),
    numero_anuncio VARCHAR(100),
    numero_tramite VARCHAR(100),
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    giro VARCHAR(255),
    actividad VARCHAR(255),
    estado VARCHAR(20),
    fecha_alta DATE,
    fecha_vencimiento DATE,
    observaciones TEXT,
    usuario_registro VARCHAR(100),
    fecha_registro TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que el folio existe
    SELECT COUNT(*) INTO v_exists
    FROM public.busqueda_general
    WHERE folio = p_folio AND estado = 'ACTIVO';

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró información para el folio: %', p_folio;
    END IF;

    -- Retornar el registro
    RETURN QUERY
    SELECT 
        bg.id,
        bg.tipo_registro,
        bg.folio,
        bg.numero_licencia,
        bg.numero_anuncio,
        bg.numero_tramite,
        bg.cuenta_predial,
        bg.propietario,
        bg.direccion,
        bg.colonia,
        bg.giro,
        bg.actividad,
        bg.estado,
        bg.fecha_alta,
        bg.fecha_vencimiento,
        bg.observaciones,
        bg.usuario_registro,
        bg.fecha_registro
    FROM public.busqueda_general bg
    WHERE bg.folio = p_folio AND bg.estado = 'ACTIVO';
END;
$$;

-- ============================================

-- SP 3/5: SP_BUSQUE_CREATE
-- Tipo: Create
-- Descripción: Crear nuevo registro para búsqueda
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BUSQUE_CREATE(
    p_tipo_registro VARCHAR(50),
    p_folio VARCHAR(100),
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_numero_anuncio VARCHAR(100) DEFAULT NULL,
    p_numero_tramite VARCHAR(100) DEFAULT NULL,
    p_cuenta_predial VARCHAR(50) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_direccion TEXT DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_giro VARCHAR(255) DEFAULT NULL,
    p_actividad VARCHAR(255) DEFAULT NULL,
    p_fecha_alta DATE DEFAULT NULL,
    p_fecha_vencimiento DATE DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL,
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
    IF p_tipo_registro IS NULL OR trim(p_tipo_registro) = '' THEN
        RETURN QUERY SELECT FALSE, 'El tipo de registro es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar tipos permitidos
    IF upper(p_tipo_registro) NOT IN ('LICENCIA', 'ANUNCIO', 'TRAMITE', 'PREDIAL') THEN
        RETURN QUERY SELECT FALSE, 'Tipo de registro no válido. Debe ser: LICENCIA, ANUNCIO, TRAMITE o PREDIAL.', NULL::INTEGER;
        RETURN;
    END IF;

    IF p_folio IS NULL OR trim(p_folio) = '' THEN
        RETURN QUERY SELECT FALSE, 'El folio es requerido.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no exista el folio
    SELECT COUNT(*) INTO v_exists
    FROM public.busqueda_general
    WHERE folio = upper(trim(p_folio));

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un registro con ese folio.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el nuevo registro
    INSERT INTO public.busqueda_general (
        tipo_registro, folio, numero_licencia, numero_anuncio, numero_tramite,
        cuenta_predial, propietario, direccion, colonia, giro, actividad,
        fecha_alta, fecha_vencimiento, observaciones, usuario_registro
    )
    VALUES (
        upper(trim(p_tipo_registro)),
        upper(trim(p_folio)),
        upper(trim(p_numero_licencia)),
        upper(trim(p_numero_anuncio)),
        upper(trim(p_numero_tramite)),
        upper(trim(p_cuenta_predial)),
        upper(trim(p_propietario)),
        upper(trim(p_direccion)),
        upper(trim(p_colonia)),
        upper(trim(p_giro)),
        upper(trim(p_actividad)),
        p_fecha_alta,
        p_fecha_vencimiento,
        p_observaciones,
        upper(trim(p_usuario_registro))
    )
    RETURNING public.busqueda_general.id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro creado correctamente para búsqueda.', v_new_id;
END;
$$;

-- ============================================

-- SP 4/5: SP_BUSQUE_UPDATE
-- Tipo: Update
-- Descripción: Actualizar registro existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BUSQUE_UPDATE(
    p_id INTEGER,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_direccion TEXT DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_giro VARCHAR(255) DEFAULT NULL,
    p_actividad VARCHAR(255) DEFAULT NULL,
    p_fecha_alta DATE DEFAULT NULL,
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
    FROM public.busqueda_general
    WHERE id = p_id AND estado = 'ACTIVO';

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El registro no existe o está inactivo.';
        RETURN;
    END IF;

    -- Actualizar solo los campos que no son NULL
    UPDATE public.busqueda_general
    SET propietario = COALESCE(upper(trim(p_propietario)), propietario),
        direccion = COALESCE(upper(trim(p_direccion)), direccion),
        colonia = COALESCE(upper(trim(p_colonia)), colonia),
        giro = COALESCE(upper(trim(p_giro)), giro),
        actividad = COALESCE(upper(trim(p_actividad)), actividad),
        fecha_alta = COALESCE(p_fecha_alta, fecha_alta),
        fecha_vencimiento = COALESCE(p_fecha_vencimiento, fecha_vencimiento),
        observaciones = COALESCE(p_observaciones, observaciones),
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Registro actualizado correctamente.';
END;
$$;

-- ============================================

-- SP 5/5: SP_BUSQUE_DELETE
-- Tipo: Delete
-- Descripción: Desactivar registro (soft delete)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_BUSQUE_DELETE(p_id INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que el ID existe
    SELECT COUNT(*) INTO v_exists
    FROM public.busqueda_general
    WHERE id = p_id;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El registro no existe.';
        RETURN;
    END IF;

    -- Desactivar el registro (soft delete)
    UPDATE public.busqueda_general
    SET estado = 'INACTIVO',
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Registro desactivado correctamente.';
END;
$$;

-- ============================================
-- DATOS DE PRUEBA
-- ============================================

INSERT INTO public.busqueda_general (
    tipo_registro, folio, numero_licencia, cuenta_predial, propietario, 
    direccion, colonia, giro, actividad, fecha_alta, usuario_registro
) VALUES 
    ('LICENCIA', 'LIC-2025-001', 'L-001-2025', '001-001-001-01', 
     'JUAN PÉREZ GARCÍA', 'AV. JUÁREZ #123', 'CENTRO', 
     'COMERCIO AL POR MENOR', 'VENTA DE ABARROTES', '2025-01-15', 'ADMIN'),
    ('ANUNCIO', 'ANU-2025-001', NULL, '001-001-002-01', 
     'MARÍA LÓPEZ HERNÁNDEZ', 'CALLE MORELOS #456', 'REFORMA', 
     'PUBLICIDAD', 'ANUNCIO LUMINOSO', '2025-02-10', 'ADMIN'),
    ('TRAMITE', 'TRA-2025-001', NULL, '001-001-003-01', 
     'EMPRESA CONSTRUCTORA SA', 'BLVD. UNIVERSIDAD #789', 'UNIVERSITARIA', 
     'CONSTRUCCIÓN', 'LICENCIA DE CONSTRUCCIÓN', '2025-03-05', 'ADMIN')
ON CONFLICT (folio) DO NOTHING;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
NOTAS PARA LA IMPLEMENTACIÓN:

1. Tabla requerida: public.busqueda_general
   - Campos clave: tipo_registro, folio (único)
   - Números opcionales: numero_licencia, numero_anuncio, numero_tramite
   - Información general: propietario, direccion, giro, actividad

2. Endpoints del controlador Laravel:
   - busquedaGeneral -> SP_BUSQUE_GENERAL(termino, tipo, estado, limite, offset)
   - buscarPorFolio -> SP_BUSQUE_POR_FOLIO(folio)
   - crearRegistroBusqueda -> SP_BUSQUE_CREATE(datos completos)
   - actualizarRegistroBusqueda -> SP_BUSQUE_UPDATE(id, datos)
   - eliminarRegistroBusqueda -> SP_BUSQUE_DELETE(id)

3. Tipos de registro permitidos:
   - LICENCIA: Licencias comerciales
   - ANUNCIO: Anuncios publicitarios
   - TRAMITE: Trámites en proceso
   - PREDIAL: Información predial

4. Funcionalidades especiales:
   - Búsqueda multi-campo con un solo término
   - Filtrado por tipo de registro
   - Paginación completa
   - Soft delete con estados
   - Índices optimizados para búsquedas rápidas
*/