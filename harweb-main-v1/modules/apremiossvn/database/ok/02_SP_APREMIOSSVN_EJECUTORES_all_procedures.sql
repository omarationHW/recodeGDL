-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO APREMIOSSVN - EJECUTORES Y AUTORIZACIONES
-- Archivo: 02_SP_APREMIOSSVN_EJECUTORES_all_procedures.sql
-- ============================================

-- SP_APREMIOSSVN_EJECUTORES_LIST - Lista ejecutores del sistema
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTORES_LIST() RETURNS TABLE(
    id INTEGER,
    clave_ejecutor VARCHAR(20),
    nombre_ejecutor VARCHAR(255),
    tipo_ejecutor VARCHAR(50),
    zona_asignada VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(100),
    vigencia BOOLEAN,
    fecha_alta DATE,
    fecha_baja DATE,
    motivo_baja TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.clave_ejecutor,
        e.nombre_ejecutor,
        e.tipo_ejecutor,
        e.zona_asignada,
        e.telefono,
        e.email,
        e.vigencia,
        e.fecha_alta,
        e.fecha_baja,
        e.motivo_baja
    FROM public.ejecutores e
    ORDER BY e.nombre_ejecutor;
END;
$$;

-- SP_APREMIOSSVN_EJECUTOR_CREATE - Crear nuevo ejecutor
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTOR_CREATE(
    p_clave_ejecutor VARCHAR(20),
    p_nombre_ejecutor VARCHAR(255),
    p_tipo_ejecutor VARCHAR(50),
    p_zona_asignada VARCHAR(100),
    p_telefono VARCHAR(20),
    p_email VARCHAR(100)
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    ejecutor_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    clave_exists BOOLEAN;
BEGIN
    -- Validar clave única
    SELECT EXISTS(
        SELECT 1 FROM public.ejecutores 
        WHERE clave_ejecutor = p_clave_ejecutor
    ) INTO clave_exists;
    
    IF clave_exists THEN
        RETURN QUERY SELECT FALSE, 'La clave de ejecutor ya existe', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar ejecutor
    INSERT INTO public.ejecutores (
        clave_ejecutor,
        nombre_ejecutor,
        tipo_ejecutor,
        zona_asignada,
        telefono,
        email,
        vigencia,
        fecha_alta,
        fecha_creacion
    ) VALUES (
        p_clave_ejecutor,
        p_nombre_ejecutor,
        p_tipo_ejecutor,
        p_zona_asignada,
        p_telefono,
        p_email,
        TRUE,
        CURRENT_DATE,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Ejecutor creado exitosamente', new_id;
END;
$$;

-- SP_APREMIOSSVN_EJECUTOR_BUSCAR_CLAVE - Buscar ejecutor por clave
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTOR_BUSCAR_CLAVE(
    p_clave VARCHAR(20)
) RETURNS TABLE(
    id INTEGER,
    clave_ejecutor VARCHAR(20),
    nombre_ejecutor VARCHAR(255),
    tipo_ejecutor VARCHAR(50),
    zona_asignada VARCHAR(100),
    vigencia BOOLEAN
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.clave_ejecutor,
        e.nombre_ejecutor,
        e.tipo_ejecutor,
        e.zona_asignada,
        e.vigencia
    FROM public.ejecutores e
    WHERE e.clave_ejecutor ILIKE '%' || p_clave || '%'
    ORDER BY e.nombre_ejecutor;
END;
$$;

-- SP_APREMIOSSVN_EJECUTOR_BUSCAR_NOMBRE - Buscar ejecutor por nombre
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTOR_BUSCAR_NOMBRE(
    p_nombre VARCHAR(255)
) RETURNS TABLE(
    id INTEGER,
    clave_ejecutor VARCHAR(20),
    nombre_ejecutor VARCHAR(255),
    tipo_ejecutor VARCHAR(50),
    zona_asignada VARCHAR(100),
    vigencia BOOLEAN
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id,
        e.clave_ejecutor,
        e.nombre_ejecutor,
        e.tipo_ejecutor,
        e.zona_asignada,
        e.vigencia
    FROM public.ejecutores e
    WHERE e.nombre_ejecutor ILIKE '%' || p_nombre || '%'
    ORDER BY e.nombre_ejecutor;
END;
$$;

-- SP_APREMIOSSVN_EJECUTOR_TOGGLE_VIGENCIA - Activar/desactivar ejecutor
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EJECUTOR_TOGGLE_VIGENCIA(
    p_ejecutor_id INTEGER,
    p_motivo TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    ejecutor_info RECORD;
    nueva_vigencia BOOLEAN;
BEGIN
    -- Obtener información actual
    SELECT e.id, e.nombre_ejecutor, e.vigencia
    INTO ejecutor_info
    FROM public.ejecutores e
    WHERE e.id = p_ejecutor_id;
    
    IF ejecutor_info.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El ejecutor no existe';
        RETURN;
    END IF;
    
    nueva_vigencia := NOT ejecutor_info.vigencia;
    
    -- Actualizar vigencia
    UPDATE public.ejecutores 
    SET 
        vigencia = nueva_vigencia,
        fecha_baja = CASE WHEN nueva_vigencia = FALSE THEN CURRENT_DATE ELSE NULL END,
        motivo_baja = CASE WHEN nueva_vigencia = FALSE THEN p_motivo ELSE NULL END,
        fecha_actualizacion = NOW()
    WHERE id = p_ejecutor_id;
    
    -- Registrar en historial
    INSERT INTO public.historial_ejecutores (
        ejecutor_id,
        accion,
        vigencia_anterior,
        vigencia_nueva,
        motivo,
        fecha_cambio
    ) VALUES (
        p_ejecutor_id,
        CASE WHEN nueva_vigencia THEN 'ACTIVACION' ELSE 'DESACTIVACION' END,
        ejecutor_info.vigencia,
        nueva_vigencia,
        p_motivo,
        NOW()
    );
    
    RETURN QUERY SELECT TRUE, 
        CASE WHEN nueva_vigencia 
        THEN 'Ejecutor activado exitosamente'
        ELSE 'Ejecutor desactivado exitosamente'
        END;
END;
$$;

-- SP_APREMIOSSVN_AUTORIZACIONES_LIST - Lista de autorizaciones y descuentos
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_AUTORIZACIONES_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    numero_expediente VARCHAR(50),
    contribuyente VARCHAR(255),
    tipo_autorizacion VARCHAR(50),
    porcentaje_descuento NUMERIC(5,2),
    monto_autorizado NUMERIC(15,2),
    fecha_autorizacion DATE,
    autorizado_por VARCHAR(255),
    oficina VARCHAR(100),
    aplicacion VARCHAR(100),
    estado VARCHAR(30),
    observaciones TEXT,
    total_count BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    offset_val INTEGER;
BEGIN
    offset_val := (p_page - 1) * p_limit;
    
    RETURN QUERY
    SELECT 
        a.id,
        e.numero_expediente,
        e.contribuyente,
        a.tipo_autorizacion,
        a.porcentaje_descuento,
        a.monto_autorizado,
        a.fecha_autorizacion,
        a.autorizado_por,
        a.oficina,
        a.aplicacion,
        a.estado,
        a.observaciones,
        COUNT(*) OVER() as total_count
    FROM public.autorizaciones a
    JOIN public.expedientes e ON a.expediente_id = e.id
    WHERE (p_fecha_desde IS NULL OR a.fecha_autorizacion >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR a.fecha_autorizacion <= p_fecha_hasta)
    ORDER BY a.fecha_autorizacion DESC, a.id DESC
    LIMIT p_limit OFFSET offset_val;
END;
$$;

-- SP_APREMIOSSVN_AUTORIZACION_CREATE - Crear nueva autorización
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_AUTORIZACION_CREATE(
    p_expediente_id INTEGER,
    p_tipo_autorizacion VARCHAR(50),
    p_porcentaje_descuento NUMERIC(5,2),
    p_monto_autorizado NUMERIC(15,2),
    p_autorizado_por VARCHAR(255),
    p_oficina VARCHAR(100),
    p_aplicacion VARCHAR(100),
    p_observaciones TEXT DEFAULT NULL
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    autorizacion_id INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    new_id INTEGER;
    expediente_exists BOOLEAN;
BEGIN
    -- Validar que existe el expediente
    SELECT EXISTS(
        SELECT 1 FROM public.expedientes 
        WHERE id = p_expediente_id AND estado = 'ACTIVO'
    ) INTO expediente_exists;
    
    IF NOT expediente_exists THEN
        RETURN QUERY SELECT FALSE, 'El expediente no existe o no está activo', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insertar autorización
    INSERT INTO public.autorizaciones (
        expediente_id,
        tipo_autorizacion,
        porcentaje_descuento,
        monto_autorizado,
        fecha_autorizacion,
        autorizado_por,
        oficina,
        aplicacion,
        estado,
        observaciones,
        fecha_creacion
    ) VALUES (
        p_expediente_id,
        p_tipo_autorizacion,
        p_porcentaje_descuento,
        p_monto_autorizado,
        CURRENT_DATE,
        p_autorizado_por,
        p_oficina,
        p_aplicacion,
        'AUTORIZADO',
        p_observaciones,
        NOW()
    ) RETURNING id INTO new_id;
    
    RETURN QUERY SELECT TRUE, 'Autorización creada exitosamente', new_id;
END;
$$;

-- SP_APREMIOSSVN_REASIGNACION_FOLIO - Reasignar expediente a otro ejecutor
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REASIGNACION_FOLIO(
    p_expediente_id INTEGER,
    p_nuevo_ejecutor_id INTEGER,
    p_motivo_reasignacion TEXT,
    p_responsable VARCHAR(255)
) RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    expediente_info RECORD;
    ejecutor_info RECORD;
    ejecutor_anterior VARCHAR(255);
BEGIN
    -- Validar expediente
    SELECT e.id, e.numero_expediente, e.notificador
    INTO expediente_info
    FROM public.expedientes e
    WHERE e.id = p_expediente_id AND e.estado = 'ACTIVO';
    
    IF expediente_info.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El expediente no existe o no está activo';
        RETURN;
    END IF;
    
    -- Validar nuevo ejecutor
    SELECT ej.id, ej.nombre_ejecutor
    INTO ejecutor_info
    FROM public.ejecutores ej
    WHERE ej.id = p_nuevo_ejecutor_id AND ej.vigencia = TRUE;
    
    IF ejecutor_info.id IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El ejecutor no existe o no está vigente';
        RETURN;
    END IF;
    
    ejecutor_anterior := expediente_info.notificador;
    
    -- Actualizar expediente
    UPDATE public.expedientes 
    SET 
        notificador = ejecutor_info.nombre_ejecutor,
        fecha_actualizacion = NOW()
    WHERE id = p_expediente_id;
    
    -- Registrar reasignación
    INSERT INTO public.historial_reasignaciones (
        expediente_id,
        ejecutor_anterior,
        ejecutor_nuevo,
        motivo_reasignacion,
        responsable_cambio,
        fecha_reasignacion
    ) VALUES (
        p_expediente_id,
        ejecutor_anterior,
        ejecutor_info.nombre_ejecutor,
        p_motivo_reasignacion,
        p_responsable,
        NOW()
    );
    
    RETURN QUERY SELECT TRUE, 'Expediente reasignado exitosamente';
END;
$$;