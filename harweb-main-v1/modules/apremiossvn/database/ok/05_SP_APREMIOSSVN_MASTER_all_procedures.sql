-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO APREMIOSSVN - PROCEDIMIENTOS MAESTROS CONSOLIDADOS
-- Archivo: 05_SP_APREMIOSSVN_MASTER_all_procedures.sql
-- Basado en: Múltiples archivos de la carpeta pre
-- ============================================

-- =============================================
-- SECCIÓN: AUTORIZACIONES Y DESCUENTOS
-- =============================================

-- SP_APREMIOSSVN_AUTORIZADES_SEARCH - Buscar folio con descuentos autorizados
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_AUTORIZADES_SEARCH(
    p_folio INTEGER,
    p_id_rec INTEGER,
    p_id_modulo INTEGER,
    p_usuario_id INTEGER
) RETURNS TABLE(
    folio INTEGER,
    diligencia TEXT,
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    porcentaje_descuento NUMERIC,
    fecha_autorizacion DATE,
    autorizado_por VARCHAR(255),
    vigencia CHAR(1)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.folio,
        a.diligencia,
        a.importe_global,
        a.importe_multa,
        a.importe_recargo,
        a.importe_gastos,
        a.porcentaje_descuento,
        a.fecha_autorizacion,
        a.autorizado_por,
        a.vigencia
    FROM public.ta_autorizaciones a
    WHERE a.folio = p_folio 
    AND a.id_rec = p_id_rec 
    AND a.id_modulo = p_id_modulo
    AND a.vigencia = 'A'
    ORDER BY a.fecha_autorizacion DESC;
END;
$$;

-- SP_APREMIOSSVN_AUTORIZACION_ALTA - Crear nueva autorización
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_AUTORIZACION_ALTA(
    p_folio INTEGER,
    p_id_rec INTEGER,
    p_porcentaje_descuento NUMERIC,
    p_autorizado_por VARCHAR(255),
    p_oficina VARCHAR(100),
    p_aplicacion VARCHAR(100)
) RETURNS TABLE(
    result TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO public.ta_autorizaciones (
        folio,
        id_rec,
        porcentaje_descuento,
        fecha_autorizacion,
        autorizado_por,
        oficina,
        aplicacion,
        vigencia
    ) VALUES (
        p_folio,
        p_id_rec,
        p_porcentaje_descuento,
        CURRENT_DATE,
        p_autorizado_por,
        p_oficina,
        p_aplicacion,
        'A'
    );
    
    RETURN QUERY SELECT 'Autorización registrada exitosamente'::TEXT;
END;
$$;

-- =============================================
-- SECCIÓN: CONSULTAS HISTÓRICAS
-- =============================================

-- SP_APREMIOSSVN_CONS_HIS - Obtener historial de consultas
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CONS_HIS(
    p_folio INTEGER,
    p_modulo INTEGER
) RETURNS TABLE(
    folio INTEGER,
    fecha_movimiento DATE,
    tipo_movimiento VARCHAR(50),
    importe NUMERIC,
    usuario VARCHAR(255),
    observaciones TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.folio,
        h.fecha_movimiento,
        h.tipo_movimiento,
        h.importe,
        h.usuario,
        h.observaciones
    FROM public.ta_historial h
    WHERE h.folio = p_folio AND h.modulo = p_modulo
    ORDER BY h.fecha_movimiento DESC;
END;
$$;

-- =============================================
-- SECCIÓN: ACCESO Y USUARIOS
-- =============================================

-- SP_APREMIOSSVN_ACCESO_LOGIN - Login de usuario
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_ACCESO_LOGIN(
    p_usuario VARCHAR(50),
    p_password VARCHAR(100)
) RETURNS TABLE(
    usuario_id INTEGER,
    nombre VARCHAR(255),
    nivel_acceso INTEGER,
    resultado TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    usuario_info RECORD;
    password_hash VARCHAR(100);
BEGIN
    -- Obtener información del usuario
    SELECT u.id, u.nombre, u.nivel_acceso, u.password_hash
    INTO usuario_info
    FROM public.ta_usuarios u
    WHERE u.usuario = p_usuario AND u.activo = TRUE;
    
    IF usuario_info.id IS NULL THEN
        RETURN QUERY SELECT NULL::INTEGER, NULL::VARCHAR, NULL::INTEGER, 'Usuario no encontrado'::TEXT;
        RETURN;
    END IF;
    
    -- Verificar contraseña (en producción usar funciones de hash seguras)
    IF usuario_info.password_hash = p_password THEN
        -- Actualizar último acceso
        UPDATE public.ta_usuarios 
        SET ultimo_acceso = NOW()
        WHERE id = usuario_info.id;
        
        RETURN QUERY SELECT usuario_info.id, usuario_info.nombre, usuario_info.nivel_acceso, 'OK'::TEXT;
    ELSE
        RETURN QUERY SELECT NULL::INTEGER, NULL::VARCHAR, NULL::INTEGER, 'Contraseña incorrecta'::TEXT;
    END IF;
END;
$$;

-- =============================================
-- SECCIÓN: LISTADOS Y REPORTES
-- =============================================

-- SP_APREMIOSSVN_LISTADOS_GET - Obtener listados de cobranza
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_LISTADOS_GET(
    p_clave VARCHAR(20),
    p_vigencia CHAR(1) DEFAULT 'A'
) RETURNS TABLE(
    clave VARCHAR(20),
    descripcion VARCHAR(255),
    fecha_creacion DATE,
    total_expedientes INTEGER,
    monto_total NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.clave,
        l.descripcion,
        l.fecha_creacion,
        l.total_expedientes,
        l.monto_total
    FROM public.ta_listados l
    WHERE (p_clave IS NULL OR l.clave = p_clave)
    AND l.vigencia = p_vigencia
    ORDER BY l.fecha_creacion DESC;
END;
$$;

-- =============================================
-- SECCIÓN: FACTURACIÓN
-- =============================================

-- SP_APREMIOSSVN_FACTURACION_LIST - Lista movimientos de facturación
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FACTURACION_LIST(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_recaudadora INTEGER DEFAULT NULL
) RETURNS TABLE(
    id INTEGER,
    folio INTEGER,
    fecha_facturacion DATE,
    monto NUMERIC,
    recaudadora INTEGER,
    nombre_recaudadora VARCHAR(255),
    estado VARCHAR(30)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.id,
        f.folio,
        f.fecha_facturacion,
        f.monto,
        f.recaudadora,
        r.nombre as nombre_recaudadora,
        f.estado
    FROM public.ta_facturacion f
    JOIN public.ta_recaudadoras r ON f.recaudadora = r.id
    WHERE f.fecha_facturacion BETWEEN p_fecha_desde AND p_fecha_hasta
    AND (p_recaudadora IS NULL OR f.recaudadora = p_recaudadora)
    ORDER BY f.fecha_facturacion DESC;
END;
$$;

-- =============================================
-- SECCIÓN: MODIFICACIONES DE EXPEDIENTES
-- =============================================

-- SP_APREMIOSSVN_MODIFICAR_EXPEDIENTE - Modificar expediente de apremio
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_MODIFICAR_EXPEDIENTE(
    p_folio INTEGER,
    p_nuevo_importe NUMERIC,
    p_motivo TEXT,
    p_usuario VARCHAR(255)
) RETURNS TABLE(
    result TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    expediente_actual RECORD;
BEGIN
    -- Obtener datos actuales
    SELECT folio, importe_global INTO expediente_actual
    FROM public.ta_expedientes
    WHERE folio = p_folio;
    
    IF expediente_actual.folio IS NULL THEN
        RETURN QUERY SELECT 'Expediente no encontrado'::TEXT;
        RETURN;
    END IF;
    
    -- Actualizar expediente
    UPDATE public.ta_expedientes
    SET 
        importe_global = p_nuevo_importe,
        fecha_modificacion = CURRENT_DATE,
        usuario_modificacion = p_usuario
    WHERE folio = p_folio;
    
    -- Registrar en historial
    INSERT INTO public.ta_historial_modificaciones (
        folio,
        importe_anterior,
        importe_nuevo,
        motivo,
        fecha_modificacion,
        usuario
    ) VALUES (
        p_folio,
        expediente_actual.importe_global,
        p_nuevo_importe,
        p_motivo,
        CURRENT_DATE,
        p_usuario
    );
    
    RETURN QUERY SELECT 'Expediente modificado exitosamente'::TEXT;
END;
$$;

-- =============================================
-- SECCIÓN: REQUERIMIENTOS
-- =============================================

-- SP_APREMIOSSVN_EMITIR_REQUERIMIENTO - Emitir requerimiento de pago
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_EMITIR_REQUERIMIENTO(
    p_folio INTEGER,
    p_tipo_requerimiento VARCHAR(50),
    p_ejecutor INTEGER
) RETURNS TABLE(
    result TEXT,
    numero_requerimiento INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    nuevo_numero INTEGER;
BEGIN
    -- Generar número consecutivo
    SELECT COALESCE(MAX(numero_requerimiento), 0) + 1 
    INTO nuevo_numero
    FROM public.ta_requerimientos
    WHERE EXTRACT(YEAR FROM fecha_emision) = EXTRACT(YEAR FROM CURRENT_DATE);
    
    -- Insertar requerimiento
    INSERT INTO public.ta_requerimientos (
        folio,
        numero_requerimiento,
        tipo_requerimiento,
        fecha_emision,
        ejecutor,
        estado
    ) VALUES (
        p_folio,
        nuevo_numero,
        p_tipo_requerimiento,
        CURRENT_DATE,
        p_ejecutor,
        'EMITIDO'
    );
    
    RETURN QUERY SELECT 'Requerimiento emitido exitosamente'::TEXT, nuevo_numero;
END;
$$;

-- =============================================
-- SECCIÓN: UTILIDADES DEL SISTEMA
-- =============================================

-- SP_APREMIOSSVN_DATE_TO_WORDS - Convertir fecha a palabras
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_DATE_TO_WORDS(
    p_fecha DATE
) RETURNS TEXT LANGUAGE plpgsql AS $$
DECLARE
    resultado TEXT;
    dia INTEGER;
    mes INTEGER;
    año INTEGER;
    nombre_mes TEXT;
BEGIN
    dia := EXTRACT(DAY FROM p_fecha);
    mes := EXTRACT(MONTH FROM p_fecha);
    año := EXTRACT(YEAR FROM p_fecha);
    
    nombre_mes := CASE mes
        WHEN 1 THEN 'enero'
        WHEN 2 THEN 'febrero'
        WHEN 3 THEN 'marzo'
        WHEN 4 THEN 'abril'
        WHEN 5 THEN 'mayo'
        WHEN 6 THEN 'junio'
        WHEN 7 THEN 'julio'
        WHEN 8 THEN 'agosto'
        WHEN 9 THEN 'septiembre'
        WHEN 10 THEN 'octubre'
        WHEN 11 THEN 'noviembre'
        WHEN 12 THEN 'diciembre'
    END;
    
    resultado := dia || ' de ' || nombre_mes || ' de ' || año;
    
    RETURN resultado;
END;
$$;