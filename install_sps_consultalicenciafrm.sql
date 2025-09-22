-- ============================================
-- INSTALACIÓN DE STORED PROCEDURES PARA CONSULTALICENCIAFRM
-- Base: PostgreSQL 192.168.6.146:5432 "padron_licencias"
-- Esquema: informix
-- Fecha: 2025-09-20
-- ============================================

\c padron_licencias;
SET search_path TO informix, public;

-- Crear esquema informix si no existe
CREATE SCHEMA IF NOT EXISTS informix;

-- ============================================
-- SP 1/5: SP_CONSULTALICENCIA_GET
-- Descripción: Obtiene detalle completo de una licencia
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_CONSULTALICENCIA_GET(p_numero_licencia VARCHAR(100))
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
    -- Buscar en tabla licencias (estructura original)
    SELECT COUNT(*) INTO v_exists
    FROM public.licencias
    WHERE licencia = p_numero_licencia;

    IF v_exists > 0 THEN
        RETURN QUERY
        SELECT
            l.id_licencia::INTEGER,
            l.licencia::VARCHAR(100),
            COALESCE(l.folio, '')::VARCHAR(100),
            COALESCE(l.tipo, 'COMERCIAL')::VARCHAR(50),
            COALESCE(l.cuenta_predial, '')::VARCHAR(50),
            COALESCE(l.propietario, '')::VARCHAR(255),
            COALESCE(l.razon_social, l.propietario)::VARCHAR(255),
            COALESCE(l.rfc, '')::VARCHAR(20),
            COALESCE(l.ubicacion, '')::TEXT,
            COALESCE(l.colonia, '')::VARCHAR(100),
            COALESCE(l.cp, '')::VARCHAR(10),
            COALESCE(l.telefono_prop, '')::VARCHAR(20),
            COALESCE(l.email, '')::VARCHAR(100),
            COALESCE(l.actividad, '')::VARCHAR(255),
            COALESCE(l.actividad, '')::VARCHAR(255),
            l.superficie::NUMERIC(10,2),
            COALESCE(l.horario, '')::VARCHAR(100),
            COALESCE(l.empleados, 0)::INTEGER,
            l.fecha_solicitud::DATE,
            l.fecha_otorgamiento::DATE,
            l.vigente::DATE,
            CASE
                WHEN l.bloqueado = 1 THEN 'BLOQUEADA'
                WHEN l.vigente < CURRENT_DATE THEN 'VENCIDA'
                WHEN l.estado = 'C' THEN 'CANCELADA'
                ELSE 'VIGENTE'
            END::VARCHAR(20),
            COALESCE(l.observa, '')::TEXT,
            COALESCE(l.capturista, '')::VARCHAR(100),
            l.fecha_mov::TIMESTAMP,
            CASE
                WHEN l.vigente IS NULL THEN NULL
                ELSE (l.vigente - CURRENT_DATE)::INTEGER
            END as dias_para_vencer,
            CASE
                WHEN l.bloqueado = 0 AND l.estado != 'C' AND (l.vigente IS NULL OR l.vigente >= CURRENT_DATE)
                THEN TRUE
                ELSE FALSE
            END as esta_vigente
        FROM public.licencias l
        WHERE l.licencia = p_numero_licencia;
    ELSE
        RAISE EXCEPTION 'No se encontró la licencia: %', p_numero_licencia;
    END IF;
END;
$$;

-- ============================================
-- SP 2/5: SP_CONSULTALICENCIA_CREATE
-- Descripción: Crear nueva licencia comercial
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_CONSULTALICENCIA_CREATE(
    p_numero_licencia VARCHAR(100),
    p_razon_social VARCHAR(255),
    p_domicilio_establecimiento TEXT,
    p_giro_comercial VARCHAR(255),
    p_nombre_comercial VARCHAR(255) DEFAULT NULL,
    p_rfc VARCHAR(20) DEFAULT NULL,
    p_colonia VARCHAR(100) DEFAULT NULL,
    p_telefono VARCHAR(20) DEFAULT NULL,
    p_email VARCHAR(100) DEFAULT NULL,
    p_numero_empleados INTEGER DEFAULT 0
)
RETURNS TABLE(success BOOLEAN, message TEXT, numero_licencia VARCHAR(100))
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
    v_exists INTEGER;
    v_max_id INTEGER;
BEGIN
    -- Validar campos requeridos
    IF p_numero_licencia IS NULL OR trim(p_numero_licencia) = '' THEN
        RETURN QUERY SELECT FALSE, 'El número de licencia es requerido.', NULL::VARCHAR(100);
        RETURN;
    END IF;

    IF p_razon_social IS NULL OR trim(p_razon_social) = '' THEN
        RETURN QUERY SELECT FALSE, 'La razón social es requerida.', NULL::VARCHAR(100);
        RETURN;
    END IF;

    -- Validar que no exista el número de licencia
    SELECT COUNT(*) INTO v_exists
    FROM public.licencias
    WHERE licencia = upper(trim(p_numero_licencia));

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una licencia con ese número.', NULL::VARCHAR(100);
        RETURN;
    END IF;

    -- Obtener próximo ID
    SELECT COALESCE(MAX(id_licencia), 0) + 1 INTO v_max_id FROM public.licencias;

    -- Insertar la nueva licencia en estructura original
    INSERT INTO public.licencias (
        id_licencia, licencia, propietario, razon_social, rfc, ubicacion, colonia,
        actividad, telefono_prop, email, empleados, fecha_otorgamiento, vigente,
        fecha_mov, capturista, estado, bloqueado
    )
    VALUES (
        v_max_id,
        upper(trim(p_numero_licencia)),
        upper(trim(p_razon_social)),
        upper(trim(COALESCE(p_nombre_comercial, p_razon_social))),
        upper(trim(p_rfc)),
        upper(trim(p_domicilio_establecimiento)),
        upper(trim(p_colonia)),
        upper(trim(p_giro_comercial)),
        p_telefono,
        lower(trim(p_email)),
        p_numero_empleados,
        CURRENT_DATE,
        CURRENT_DATE + INTERVAL '1 year',
        CURRENT_TIMESTAMP,
        current_user,
        'V',
        0
    );

    RETURN QUERY SELECT TRUE, 'Licencia creada correctamente.', upper(trim(p_numero_licencia));
END;
$$;

-- ============================================
-- SP 3/5: SP_CONSULTALICENCIA_CAMBIAR_ESTADO
-- Descripción: Cambiar estado de una licencia
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_CONSULTALICENCIA_CAMBIAR_ESTADO(
    p_numero_licencia VARCHAR(100),
    p_nuevo_estatus VARCHAR(20),
    p_observaciones TEXT DEFAULT NULL
)
RETURNS TABLE(success BOOLEAN, message TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar estados permitidos
    IF upper(p_nuevo_estatus) NOT IN ('ACTIVA', 'SUSPENDIDA', 'CANCELADA', 'VENCIDA', 'RENOVACION') THEN
        RETURN QUERY SELECT FALSE, 'Estado no válido. Debe ser: ACTIVA, SUSPENDIDA, CANCELADA, VENCIDA o RENOVACION.';
        RETURN;
    END IF;

    -- Validar que la licencia existe
    SELECT COUNT(*) INTO v_exists
    FROM public.licencias
    WHERE licencia = p_numero_licencia;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'La licencia no existe.';
        RETURN;
    END IF;

    -- Cambiar el estado en la estructura original
    UPDATE public.licencias
    SET estado = CASE
            WHEN upper(p_nuevo_estatus) = 'ACTIVA' THEN 'V'
            WHEN upper(p_nuevo_estatus) = 'CANCELADA' THEN 'C'
            WHEN upper(p_nuevo_estatus) = 'SUSPENDIDA' THEN 'S'
            ELSE 'V'
        END,
        observa = COALESCE(p_observaciones, observa),
        fecha_mov = CURRENT_TIMESTAMP
    WHERE licencia = p_numero_licencia;

    RETURN QUERY SELECT TRUE, 'Estado de licencia cambiado correctamente a: ' || upper(p_nuevo_estatus);
END;
$$;

-- ============================================
-- SP 4/5: SP_CONSULTALICENCIA_VENCIDAS
-- Descripción: Obtener licencias próximas a vencer o vencidas
-- ============================================

CREATE OR REPLACE FUNCTION informix.SP_CONSULTALICENCIA_VENCIDAS(
    p_dias_anticipacion INTEGER DEFAULT 30,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    numero_licencia VARCHAR(100),
    razon_social VARCHAR(255),
    giro_comercial VARCHAR(255),
    fecha_vencimiento DATE,
    dias_para_vencer INTEGER,
    estatus VARCHAR(20),
    telefono VARCHAR(20),
    email VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.licencia::VARCHAR(100),
        COALESCE(l.razon_social, l.propietario)::VARCHAR(255),
        COALESCE(l.actividad, '')::VARCHAR(255),
        l.vigente::DATE,
        (l.vigente - CURRENT_DATE)::INTEGER as dias_para_vencer,
        CASE
            WHEN l.vigente < CURRENT_DATE THEN 'VENCIDA'
            WHEN l.bloqueado = 1 THEN 'BLOQUEADA'
            WHEN l.estado = 'C' THEN 'CANCELADA'
            ELSE 'ACTIVA'
        END::VARCHAR(20),
        COALESCE(l.telefono_prop, '')::VARCHAR(20),
        COALESCE(l.email, '')::VARCHAR(100)
    FROM public.licencias l
    WHERE l.vigente IS NOT NULL
      AND l.estado != 'C'
      AND l.vigente <= CURRENT_DATE + INTERVAL '1 day' * p_dias_anticipacion
    ORDER BY l.vigente ASC
    LIMIT p_limite OFFSET p_offset;
END;
$$;

-- ============================================
-- SP 5/5: spget_lic_adeudos
-- Descripción: Obtiene adeudos de licencia por año
-- ============================================

CREATE OR REPLACE FUNCTION informix.spget_lic_adeudos(v_id integer, v_tipo varchar)
RETURNS TABLE(
    id_licencia integer,
    axo integer,
    licencia integer,
    anuncio integer,
    formas numeric,
    desc_formas numeric,
    derechos numeric,
    desc_derechos numeric,
    derechos2 numeric,
    recargos numeric,
    desc_recargos numeric,
    actualizacion numeric,
    gastos numeric,
    multas numeric,
    saldo numeric,
    concepto varchar,
    bloq varchar
) AS $$
BEGIN
    IF v_tipo = 'L' THEN
        RETURN QUERY
            SELECT
                d.id_licencia,
                d.axo,
                d.licencia,
                d.anuncio,
                d.formas,
                d.desc_formas,
                d.derechos,
                d.desc_derechos,
                d.derechos2,
                d.recargos,
                d.desc_recargos,
                d.actualizacion,
                d.gastos,
                d.multas,
                d.saldo,
                d.concepto,
                d.bloq
            FROM public.detsal_lic d
            WHERE d.id_licencia = v_id AND d.cvepago = 0;
    ELSIF v_tipo = 'A' THEN
        RETURN QUERY
            SELECT
                d.id_licencia,
                d.axo,
                d.licencia,
                d.anuncio,
                d.formas,
                d.desc_formas,
                d.derechos,
                d.desc_derechos,
                d.derechos2,
                d.recargos,
                d.desc_recargos,
                d.actualizacion,
                d.gastos,
                d.multas,
                d.saldo,
                d.concepto,
                d.bloq
            FROM public.detsal_lic d
            WHERE d.anuncio = v_id AND d.cvepago = 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VALIDAR INSTALACIÓN
-- ============================================

-- Mostrar SPs instalados
SELECT
    proname as nombre_sp,
    prosrc as definicion
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'informix'
AND (
    proname ILIKE '%sp_consultalicencia%' OR
    proname ILIKE '%spget_lic_adeudos%'
)
ORDER BY proname;

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
RESUMEN DE SPs INSTALADOS EN ESQUEMA INFORMIX:

1. SP_CONSULTALICENCIA_GET(p_numero_licencia)
   - Obtiene detalle completo de una licencia
   - Usa tabla public.licencias con estructura original

2. SP_CONSULTALICENCIA_CREATE(datos_licencia)
   - Crea nueva licencia en tabla public.licencias
   - Validaciones de campos requeridos

3. SP_CONSULTALICENCIA_CAMBIAR_ESTADO(numero, estado, observaciones)
   - Cambia estado de licencia
   - Estados: ACTIVA, SUSPENDIDA, CANCELADA, VENCIDA, RENOVACION

4. SP_CONSULTALICENCIA_VENCIDAS(dias_anticipacion, limite, offset)
   - Lista licencias próximas a vencer
   - Incluye información de contacto

5. spget_lic_adeudos(id, tipo)
   - Obtiene adeudos de licencia desde public.detsal_lic
   - Tipo 'L' para licencias, 'A' para anuncios

TABLAS UTILIZADAS:
- public.licencias (tabla principal)
- public.detsal_lic (adeudos)
- public.bloqueo (bloqueos)
- public.pagos (pagos)

NOTAS:
- Todos los SPs están en esquema informix
- Usan datos reales de tablas existentes
- Compatible con estructura original de Informix
- Validaciones y manejo de errores incluido
*/