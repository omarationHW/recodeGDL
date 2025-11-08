-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA CONSULTA PREDIAL
-- Convención: SP_CONSULTAPREDIAL_XXX
-- Generado: 2025-09-09
-- Tabla: predial_info
-- Módulo: 01 - CONSULTAPREDIAL (Prioridad Alta)
-- ============================================

-- Crear esquema y tabla base si no existe
CREATE SCHEMA IF NOT EXISTS licencias;

-- Tabla principal para información predial
CREATE TABLE IF NOT EXISTS public.predial_info (
    id SERIAL PRIMARY KEY,
    cuenta_predial VARCHAR(50) NOT NULL UNIQUE,
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno NUMERIC(10,2),
    superficie_construccion NUMERIC(10,2),
    uso_suelo VARCHAR(100),
    zona VARCHAR(50),
    valor_catastral NUMERIC(15,2),
    estado VARCHAR(20) DEFAULT 'ACTIVO',
    coordenada_x NUMERIC(12,6),
    coordenada_y NUMERIC(12,6),
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para optimización
CREATE INDEX IF NOT EXISTS idx_predial_cuenta ON public.predial_info(cuenta_predial);
CREATE INDEX IF NOT EXISTS idx_predial_propietario ON public.predial_info(propietario);
CREATE INDEX IF NOT EXISTS idx_predial_direccion ON public.predial_info(direccion);
CREATE INDEX IF NOT EXISTS idx_predial_colonia ON public.predial_info(colonia);
CREATE INDEX IF NOT EXISTS idx_predial_estado ON public.predial_info(estado);

-- ============================================

-- SP 1/4: SP_CONSULTAPREDIAL_LIST
-- Tipo: List/Read
-- Descripción: Lista información predial con filtros y paginación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTAPREDIAL_LIST(
    p_cuenta_predial VARCHAR(50) DEFAULT NULL,
    p_propietario VARCHAR(255) DEFAULT NULL,
    p_direccion TEXT DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id INTEGER,
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno NUMERIC(10,2),
    superficie_construccion NUMERIC(10,2),
    uso_suelo VARCHAR(100),
    zona VARCHAR(50),
    valor_catastral NUMERIC(15,2),
    estado VARCHAR(20),
    coordenada_x NUMERIC(12,6),
    coordenada_y NUMERIC(12,6),
    observaciones TEXT,
    fecha_registro TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros
    SELECT COUNT(*) INTO v_total_count
    FROM public.predial_info pi
    WHERE (p_cuenta_predial IS NULL OR pi.cuenta_predial ILIKE '%' || p_cuenta_predial || '%')
      AND (p_propietario IS NULL OR pi.propietario ILIKE '%' || p_propietario || '%')
      AND (p_direccion IS NULL OR pi.direccion ILIKE '%' || p_direccion || '%')
      AND (p_colonia IS NULL OR pi.colonia ILIKE '%' || p_colonia || '%')
      AND pi.estado = 'ACTIVO';

    -- Retornar resultados paginados
    RETURN QUERY
    SELECT 
        pi.id,
        pi.cuenta_predial,
        pi.propietario,
        pi.direccion,
        pi.colonia,
        pi.codigo_postal,
        pi.superficie_terreno,
        pi.superficie_construccion,
        pi.uso_suelo,
        pi.zona,
        pi.valor_catastral,
        pi.estado,
        pi.coordenada_x,
        pi.coordenada_y,
        pi.observaciones,
        pi.fecha_registro,
        pi.fecha_actualizacion,
        v_total_count as total_registros
    FROM public.predial_info pi
    WHERE (p_cuenta_predial IS NULL OR pi.cuenta_predial ILIKE '%' || p_cuenta_predial || '%')
      AND (p_propietario IS NULL OR pi.propietario ILIKE '%' || p_propietario || '%')
      AND (p_direccion IS NULL OR pi.direccion ILIKE '%' || p_direccion || '%')
      AND (p_colonia IS NULL OR pi.colonia ILIKE '%' || p_colonia || '%')
      AND pi.estado = 'ACTIVO'
    ORDER BY pi.fecha_actualizacion DESC, pi.id DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================

-- SP 2/4: SP_CONSULTAPREDIAL_GET
-- Tipo: Read
-- Descripción: Obtiene detalle específico de un predio por cuenta predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTAPREDIAL_GET(p_cuenta_predial VARCHAR(50))
RETURNS TABLE(
    id INTEGER,
    cuenta_predial VARCHAR(50),
    propietario VARCHAR(255),
    direccion TEXT,
    colonia VARCHAR(100),
    codigo_postal VARCHAR(10),
    superficie_terreno NUMERIC(10,2),
    superficie_construccion NUMERIC(10,2),
    uso_suelo VARCHAR(100),
    zona VARCHAR(50),
    valor_catastral NUMERIC(15,2),
    estado VARCHAR(20),
    coordenada_x NUMERIC(12,6),
    coordenada_y NUMERIC(12,6),
    observaciones TEXT,
    fecha_registro TIMESTAMP,
    fecha_actualizacion TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que la cuenta predial existe
    SELECT COUNT(*) INTO v_exists
    FROM public.predial_info
    WHERE cuenta_predial = p_cuenta_predial AND estado = 'ACTIVO';

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No se encontró información para la cuenta predial: %', p_cuenta_predial;
    END IF;

    -- Retornar el registro
    RETURN QUERY
    SELECT 
        pi.id,
        pi.cuenta_predial,
        pi.propietario,
        pi.direccion,
        pi.colonia,
        pi.codigo_postal,
        pi.superficie_terreno,
        pi.superficie_construccion,
        pi.uso_suelo,
        pi.zona,
        pi.valor_catastral,
        pi.estado,
        pi.coordenada_x,
        pi.coordenada_y,
        pi.observaciones,
        pi.fecha_registro,
        pi.fecha_actualizacion
    FROM public.predial_info pi
    WHERE pi.cuenta_predial = p_cuenta_predial
      AND pi.estado = 'ACTIVO';
END;
$$;

-- ============================================

-- SP 3/4: SP_CONSULTAPREDIAL_CREATE
-- Tipo: Create
-- Descripción: Crea un nuevo registro predial
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTAPREDIAL_CREATE(
    p_cuenta_predial VARCHAR(50),
    p_propietario VARCHAR(255),
    p_direccion TEXT,
    p_colonia VARCHAR(100),
    p_codigo_postal VARCHAR(10) DEFAULT NULL,
    p_superficie_terreno NUMERIC(10,2) DEFAULT NULL,
    p_superficie_construccion NUMERIC(10,2) DEFAULT NULL,
    p_uso_suelo VARCHAR(100) DEFAULT NULL,
    p_zona VARCHAR(50) DEFAULT NULL,
    p_valor_catastral NUMERIC(15,2) DEFAULT NULL,
    p_coordenada_x NUMERIC(12,6) DEFAULT NULL,
    p_coordenada_y NUMERIC(12,6) DEFAULT NULL,
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT, id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_exists INTEGER;
BEGIN
    -- Validar campos requeridos
    IF p_cuenta_predial IS NULL OR trim(p_cuenta_predial) = '' THEN
        RETURN QUERY SELECT FALSE, 'La cuenta predial es requerida.', NULL::INTEGER;
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

    -- Validar que no exista la cuenta predial
    SELECT COUNT(*) INTO v_exists
    FROM public.predial_info
    WHERE cuenta_predial = upper(trim(p_cuenta_predial));

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un registro con esa cuenta predial.', NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el nuevo registro
    INSERT INTO public.predial_info (
        cuenta_predial, propietario, direccion, colonia, codigo_postal,
        superficie_terreno, superficie_construccion, uso_suelo, zona,
        valor_catastral, coordenada_x, coordenada_y, observaciones
    )
    VALUES (
        upper(trim(p_cuenta_predial)),
        upper(trim(p_propietario)),
        upper(trim(p_direccion)),
        upper(trim(p_colonia)),
        p_codigo_postal,
        p_superficie_terreno,
        p_superficie_construccion,
        upper(trim(p_uso_suelo)),
        upper(trim(p_zona)),
        p_valor_catastral,
        p_coordenada_x,
        p_coordenada_y,
        p_observaciones
    )
    RETURNING public.predial_info.id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro predial creado correctamente.', v_new_id;
END;
$$;

-- ============================================

-- SP 4/4: SP_CONSULTAPREDIAL_UPDATE
-- Tipo: Update
-- Descripción: Actualiza información predial existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION SP_CONSULTAPREDIAL_UPDATE(
    p_id INTEGER,
    p_propietario VARCHAR(255),
    p_direccion TEXT,
    p_colonia VARCHAR(100),
    p_codigo_postal VARCHAR(10) DEFAULT NULL,
    p_superficie_terreno NUMERIC(10,2) DEFAULT NULL,
    p_superficie_construccion NUMERIC(10,2) DEFAULT NULL,
    p_uso_suelo VARCHAR(100) DEFAULT NULL,
    p_zona VARCHAR(50) DEFAULT NULL,
    p_valor_catastral NUMERIC(15,2) DEFAULT NULL,
    p_coordenada_x NUMERIC(12,6) DEFAULT NULL,
    p_coordenada_y NUMERIC(12,6) DEFAULT NULL,
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
    FROM public.predial_info
    WHERE id = p_id AND estado = 'ACTIVO';

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El registro predial no existe o está inactivo.';
        RETURN;
    END IF;

    -- Validar campos requeridos
    IF p_propietario IS NULL OR trim(p_propietario) = '' THEN
        RETURN QUERY SELECT FALSE, 'El propietario es requerido.';
        RETURN;
    END IF;

    IF p_direccion IS NULL OR trim(p_direccion) = '' THEN
        RETURN QUERY SELECT FALSE, 'La dirección es requerida.';
        RETURN;
    END IF;

    -- Actualizar el registro
    UPDATE public.predial_info
    SET propietario = upper(trim(p_propietario)),
        direccion = upper(trim(p_direccion)),
        colonia = upper(trim(p_colonia)),
        codigo_postal = p_codigo_postal,
        superficie_terreno = p_superficie_terreno,
        superficie_construccion = p_superficie_construccion,
        uso_suelo = upper(trim(p_uso_suelo)),
        zona = upper(trim(p_zona)),
        valor_catastral = p_valor_catastral,
        coordenada_x = p_coordenada_x,
        coordenada_y = p_coordenada_y,
        observaciones = p_observaciones,
        fecha_actualizacion = CURRENT_TIMESTAMP
    WHERE id = p_id;

    RETURN QUERY SELECT TRUE, 'Registro predial actualizado correctamente.';
END;
$$;

-- ============================================
-- FUNCIÓN AUXILIAR PARA TRIGGER
-- ============================================

CREATE OR REPLACE FUNCTION public.actualizar_fecha_modificacion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Trigger para actualización automática de fecha
DROP TRIGGER IF EXISTS tr_actualizar_predial_fecha ON public.predial_info;
CREATE TRIGGER tr_actualizar_predial_fecha
    BEFORE UPDATE ON public.predial_info
    FOR EACH ROW
    EXECUTE FUNCTION public.actualizar_fecha_modificacion();

-- ============================================
-- DATOS DE PRUEBA
-- ============================================

INSERT INTO public.predial_info (
    cuenta_predial, propietario, direccion, colonia, codigo_postal,
    superficie_terreno, superficie_construccion, uso_suelo, zona,
    valor_catastral, coordenada_x, coordenada_y, observaciones
) VALUES 
    ('001-001-001-01', 'JUAN PÉREZ GARCÍA', 'AV. JUÁREZ #123', 'CENTRO', '44100', 
     150.00, 120.00, 'COMERCIAL', 'ZONA A', 250000.00, 
     -103.350, 20.676, 'Predio para licencia comercial'),
    ('001-001-002-01', 'MARÍA LÓPEZ HERNÁNDEZ', 'CALLE MORELOS #456', 'REFORMA', '44200', 
     200.00, 180.00, 'HABITACIONAL', 'ZONA B', 350000.00, 
     -103.351, 20.677, 'Uso habitacional con potencial comercial'),
    ('001-001-003-01', 'EMPRESA CONSTRUCTORA SA', 'BLVD. UNIVERSIDAD #789', 'UNIVERSITARIA', '44300', 
     500.00, 400.00, 'INDUSTRIAL', 'ZONA C', 1500000.00, 
     -103.352, 20.678, 'Predio industrial para licencia de funcionamiento')
ON CONFLICT (cuenta_predial) DO NOTHING;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
NOTAS PARA LA IMPLEMENTACIÓN:

1. Tabla requerida: public.predial_info
   - Campos principales: cuenta_predial, propietario, direccion, colonia
   - Campos opcionales: coordenadas, superficies, valor_catastral
   - Control: estado, fecha_registro, fecha_actualizacion

2. Endpoints del controlador Laravel:
   - consultaPredialList -> SP_CONSULTAPREDIAL_LIST(filtros, limite, offset)
   - consultaPredialGet -> SP_CONSULTAPREDIAL_GET(cuenta_predial)
   - consultaPredialCreate -> SP_CONSULTAPREDIAL_CREATE(datos completos)
   - consultaPredialUpdate -> SP_CONSULTAPREDIAL_UPDATE(id, datos)

3. Validaciones implementadas:
   - Campos requeridos: cuenta_predial, propietario, direccion
   - Cuenta predial única
   - Registro activo para consultas
   - Conversión automática a mayúsculas

4. Funcionalidades:
   - Búsqueda con filtros múltiples (ILIKE)
   - Paginación completa
   - Conteo total de registros
   - Soft delete (estado = ACTIVO/INACTIVO)
   - Trigger automático para fechas
*/