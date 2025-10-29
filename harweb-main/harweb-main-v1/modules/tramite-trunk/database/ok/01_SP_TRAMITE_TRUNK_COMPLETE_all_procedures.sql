-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO TRAMITE-TRUNK - PROCEDIMIENTOS COMPLETOS
-- Archivo: 01_SP_TRAMITE_TRUNK_COMPLETE_all_procedures.sql
-- Basado en: abstenmov, busque, conspag400 y todos los archivos de la carpeta pre
-- ============================================

-- =============================================
-- SECCIÓN: ABSTENCIÓN DE MOVIMIENTOS
-- =============================================

-- SP_TRAMITE_TRUNK_OBTENER_DATOS_PREDIO - Obtener datos completos del predio
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_OBTENER_DATOS_PREDIO(
    p_cvecuenta INTEGER
) RETURNS TABLE(
    datos_predio JSONB,
    datos_propietario JSONB,
    datos_ubicacion JSONB,
    datos_regprop JSONB
) LANGUAGE plpgsql AS $$
DECLARE
    v_predio RECORD;
    v_ubicacion RECORD;
    v_regprop RECORD;
    v_contrib RECORD;
BEGIN
    -- Obtener datos del predio desde catastro
    SELECT * INTO v_predio 
    FROM tramite_trunk.catastro 
    WHERE cvecuenta = p_cvecuenta;
    
    -- Obtener datos de ubicación
    SELECT * INTO v_ubicacion 
    FROM tramite_trunk.ubicacion 
    WHERE cvecuenta = p_cvecuenta;
    
    -- Obtener registro de propiedad vigente y que encabeza
    SELECT * INTO v_regprop 
    FROM tramite_trunk.regprop 
    WHERE cvecuenta = p_cvecuenta 
    AND vigencia = 'V' 
    AND encabeza = 'S';
    
    -- Si hay registro de propiedad, obtener datos del contribuyente
    IF v_regprop.cvecont IS NOT NULL THEN
        SELECT * INTO v_contrib 
        FROM tramite_trunk.contrib 
        WHERE cvecont = v_regprop.cvecont;
    END IF;
    
    RETURN QUERY
    SELECT 
        to_jsonb(v_predio) as datos_predio,
        to_jsonb(v_contrib) as datos_propietario,
        to_jsonb(v_ubicacion) as datos_ubicacion,
        to_jsonb(v_regprop) as datos_regprop;
END;
$$;

-- SP_TRAMITE_TRUNK_REGISTRAR_ABSTENCION - Registrar abstención de movimientos
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_REGISTRAR_ABSTENCION(
    p_cvecuenta INTEGER,
    p_axoefec INTEGER,
    p_bimefec INTEGER,
    p_observacion TEXT,
    p_usuario VARCHAR(50)
) RETURNS TABLE(
    resultado TEXT,
    mensaje TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    v_convcta RECORD;
    v_catastro RECORD;
BEGIN
    -- Verificar que existe cuenta activa
    SELECT * INTO v_convcta 
    FROM tramite_trunk.convcta 
    WHERE cvecuenta = p_cvecuenta;
    
    IF v_convcta.cvecuenta IS NULL OR COALESCE(v_convcta.claveutm, '') = '' THEN
        RETURN QUERY SELECT 'ERROR'::TEXT, 'No hay cuenta activa para el predio especificado'::TEXT;
        RETURN;
    END IF;
    
    -- Verificar estado del predio en catastro
    SELECT * INTO v_catastro 
    FROM tramite_trunk.catastro 
    WHERE cvecuenta = p_cvecuenta;
    
    IF v_catastro.vigente = 'C' THEN
        RETURN QUERY SELECT 'ERROR'::TEXT, 'Esta cuenta está cancelada, la abstención no es posible'::TEXT;
        RETURN;
    END IF;
    
    -- Verificar si ya existe abstención activa
    IF v_catastro.cvemov = 12 THEN
        RETURN QUERY SELECT 'ERROR'::TEXT, 'Ya existe una abstención activa para este predio'::TEXT;
        RETURN;
    END IF;
    
    -- Registrar la abstención
    UPDATE tramite_trunk.catastro 
    SET cvemov = 12,
        axoefec = p_axoefec,
        bimefec = p_bimefec,
        observacion = p_observacion,
        feccap = NOW(),
        capturista = p_usuario
    WHERE cvecuenta = p_cvecuenta;
    
    -- Registrar en historial de movimientos
    INSERT INTO tramite_trunk.historial_movimientos (
        cvecuenta, tipo_movimiento, usuario, fecha_movimiento, 
        observaciones, axo_efectivo, bim_efectivo
    ) VALUES (
        p_cvecuenta, 'ABSTENCION_REGISTRO', p_usuario, NOW(),
        p_observacion, p_axoefec, p_bimefec
    );
    
    RETURN QUERY SELECT 'OK'::TEXT, 'Abstención registrada exitosamente'::TEXT;
END;
$$;

-- SP_TRAMITE_TRUNK_ELIMINAR_ABSTENCION - Eliminar abstención de movimientos
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_ELIMINAR_ABSTENCION(
    p_cvecuenta INTEGER,
    p_axoefec INTEGER,
    p_bimefec INTEGER,
    p_observacion TEXT,
    p_usuario VARCHAR(50)
) RETURNS TABLE(
    resultado TEXT,
    mensaje TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    v_convcta RECORD;
    v_catastro RECORD;
BEGIN
    -- Verificar que existe cuenta activa
    SELECT * INTO v_convcta 
    FROM tramite_trunk.convcta 
    WHERE cvecuenta = p_cvecuenta;
    
    IF v_convcta.cvecuenta IS NULL OR COALESCE(v_convcta.claveutm, '') = '' THEN
        RETURN QUERY SELECT 'ERROR'::TEXT, 'No hay cuenta activa para el predio especificado'::TEXT;
        RETURN;
    END IF;
    
    -- Verificar estado del predio en catastro
    SELECT * INTO v_catastro 
    FROM tramite_trunk.catastro 
    WHERE cvecuenta = p_cvecuenta;
    
    IF v_catastro.vigente = 'C' THEN
        RETURN QUERY SELECT 'ERROR'::TEXT, 'Esta cuenta está cancelada, no se puede eliminar la abstención'::TEXT;
        RETURN;
    END IF;
    
    -- Verificar que existe abstención activa para eliminar
    IF v_catastro.cvemov != 12 THEN
        RETURN QUERY SELECT 'ERROR'::TEXT, 'No existe abstención activa para eliminar'::TEXT;
        RETURN;
    END IF;
    
    -- Eliminar la abstención (cambiar movimiento a 14)
    UPDATE tramite_trunk.catastro 
    SET cvemov = 14,
        axoefec = p_axoefec,
        bimefec = p_bimefec,
        observacion = p_observacion,
        feccap = NOW(),
        capturista = p_usuario
    WHERE cvecuenta = p_cvecuenta;
    
    -- Registrar en historial de movimientos
    INSERT INTO tramite_trunk.historial_movimientos (
        cvecuenta, tipo_movimiento, usuario, fecha_movimiento, 
        observaciones, axo_efectivo, bim_efectivo
    ) VALUES (
        p_cvecuenta, 'ABSTENCION_ELIMINACION', p_usuario, NOW(),
        p_observacion, p_axoefec, p_bimefec
    );
    
    RETURN QUERY SELECT 'OK'::TEXT, 'Abstención eliminada exitosamente'::TEXT;
END;
$$;

-- =============================================
-- SECCIÓN: BÚSQUEDAS AVANZADAS
-- =============================================

-- SP_TRAMITE_TRUNK_BUSCAR_POR_NOMBRE - Búsqueda por nombre del propietario
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_BUSCAR_POR_NOMBRE(
    p_nombre TEXT,
    p_limite INTEGER DEFAULT 300
) RETURNS TABLE(
    cvecont INTEGER,
    nombre_completo TEXT,
    domicilio_exterior TEXT,
    domicilio_interior TEXT,
    calle_domicilio TEXT,
    clave_catastral TEXT,
    cuenta INTEGER,
    urbano_rustico TEXT,
    recaudadora INTEGER,
    subpredio INTEGER,
    vigente TEXT,
    calle_ubicacion TEXT,
    numero_exterior TEXT,
    numero_interior TEXT,
    cve_regprop INTEGER,
    cvecuenta INTEGER,
    cve_ubicacion INTEGER,
    cve_calle INTEGER,
    encabeza TEXT,
    descripcion_calidad TEXT,
    porcentaje FLOAT,
    rfc TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rp.cvecont,
        c.nombre_completo,
        c.noexterior as domicilio_exterior,
        c.interior as domicilio_interior,
        c.calle as calle_domicilio,
        cc.cvecatnva as clave_catastral,
        cc.cuenta,
        cc.urbrus as urbano_rustico,
        cc.recaud as recaudadora,
        cc.subpredio,
        cc.vigente,
        u.calle as calle_ubicacion,
        u.noexterior as numero_exterior,
        u.interior as numero_interior,
        cat.cveregprop as cve_regprop,
        cat.cvecuenta,
        cat.cveubic as cve_ubicacion,
        u.cvecalle as cve_calle,
        rp.encabeza,
        cp.descripcion as descripcion_calidad,
        rp.porcentaje,
        c.rfc
    FROM tramite_trunk.regprop rp
    JOIN tramite_trunk.contrib c ON c.cvecont = rp.cvecont
    JOIN tramite_trunk.convcta cc ON cc.cvecuenta = rp.cvecuenta
    JOIN tramite_trunk.catastro cat ON cat.cvecuenta = rp.cvecuenta 
        AND cat.cveregprop = rp.cveregprop
    JOIN tramite_trunk.ubicacion u ON u.cveubic = cat.cveubic
    LEFT JOIN tramite_trunk.c_calidpro cp ON cp.cvereg = rp.cvereg
    WHERE c.nombre_completo ILIKE '%' || p_nombre || '%'
    AND rp.vigencia = 'V'
    ORDER BY c.nombre_completo
    LIMIT p_limite;
END;
$$;

-- SP_TRAMITE_TRUNK_BUSCAR_POR_UBICACION - Búsqueda por ubicación (calle y número)
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_BUSCAR_POR_UBICACION(
    p_calle TEXT,
    p_numero_exterior TEXT DEFAULT NULL,
    p_limite INTEGER DEFAULT 300
) RETURNS TABLE(
    cvecont INTEGER,
    nombre_completo TEXT,
    domicilio_exterior TEXT,
    domicilio_interior TEXT,
    calle_domicilio TEXT,
    clave_catastral TEXT,
    cuenta INTEGER,
    urbano_rustico TEXT,
    recaudadora INTEGER,
    subpredio INTEGER,
    vigente TEXT,
    calle_ubicacion TEXT,
    numero_exterior TEXT,
    numero_interior TEXT,
    cve_regprop INTEGER,
    cvecuenta INTEGER,
    cve_ubicacion INTEGER,
    cve_calle INTEGER,
    encabeza TEXT,
    descripcion_calidad TEXT,
    porcentaje FLOAT,
    rfc TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rp.cvecont,
        c.nombre_completo,
        c.noexterior as domicilio_exterior,
        c.interior as domicilio_interior,
        c.calle as calle_domicilio,
        cc.cvecatnva as clave_catastral,
        cc.cuenta,
        cc.urbrus as urbano_rustico,
        cc.recaud as recaudadora,
        cc.subpredio,
        cc.vigente,
        u.calle as calle_ubicacion,
        u.noexterior as numero_exterior,
        u.interior as numero_interior,
        cat.cveregprop as cve_regprop,
        cat.cvecuenta,
        cat.cveubic as cve_ubicacion,
        u.cvecalle as cve_calle,
        rp.encabeza,
        cp.descripcion as descripcion_calidad,
        rp.porcentaje,
        c.rfc
    FROM tramite_trunk.regprop rp
    JOIN tramite_trunk.contrib c ON c.cvecont = rp.cvecont
    JOIN tramite_trunk.convcta cc ON cc.cvecuenta = rp.cvecuenta
    JOIN tramite_trunk.catastro cat ON cat.cvecuenta = rp.cvecuenta 
        AND cat.cveregprop = rp.cveregprop
    JOIN tramite_trunk.ubicacion u ON u.cveubic = cat.cveubic
    LEFT JOIN tramite_trunk.c_calidpro cp ON cp.cvereg = rp.cvereg
    WHERE u.calle ILIKE '%' || p_calle || '%'
    AND (p_numero_exterior IS NULL OR p_numero_exterior = '' OR 
         u.noexterior ILIKE '%' || p_numero_exterior || '%')
    AND rp.vigencia = 'V'
    ORDER BY u.calle, u.noexterior
    LIMIT p_limite;
END;
$$;

-- SP_TRAMITE_TRUNK_BUSCAR_POR_CLAVE_CATASTRAL - Búsqueda por clave catastral
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_BUSCAR_POR_CLAVE_CATASTRAL(
    p_zona TEXT,
    p_manzana TEXT,
    p_predio TEXT DEFAULT NULL,
    p_subpredio TEXT DEFAULT NULL,
    p_limite INTEGER DEFAULT 300
) RETURNS TABLE(
    clave_catastral TEXT,
    subpredio INTEGER,
    cvecuenta INTEGER,
    recaudadora INTEGER,
    urbano_rustico TEXT,
    cuenta INTEGER,
    nombre_completo TEXT,
    calle_domicilio TEXT,
    exterior_domicilio TEXT,
    interior_domicilio TEXT,
    calle_ubicacion TEXT,
    exterior_ubicacion TEXT,
    interior_ubicacion TEXT,
    rfc TEXT,
    descripcion_calidad TEXT,
    encabeza TEXT,
    porcentaje FLOAT
) LANGUAGE plpgsql AS $$
DECLARE
    v_clave_busqueda TEXT;
BEGIN
    -- Construir clave de búsqueda
    IF p_predio IS NULL OR p_predio = '' THEN
        v_clave_busqueda := p_zona || p_manzana || '%';
    ELSE
        v_clave_busqueda := p_zona || p_manzana || p_predio;
    END IF;
    
    RETURN QUERY
    SELECT 
        cc.cvecatnva as clave_catastral,
        cc.subpredio,
        cc.cvecuenta,
        cc.recaud as recaudadora,
        cc.urbrus as urbano_rustico,
        cc.cuenta,
        c.nombre_completo,
        c.calle as calle_domicilio,
        c.noexterior as exterior_domicilio,
        c.interior as interior_domicilio,
        u.calle as calle_ubicacion,
        u.noexterior as exterior_ubicacion,
        u.interior as interior_ubicacion,
        c.rfc,
        cp.descripcion as descripcion_calidad,
        rp.encabeza,
        rp.porcentaje
    FROM tramite_trunk.convcta cc
    JOIN tramite_trunk.catastro cat ON cat.cvecuenta = cc.cvecuenta
    JOIN tramite_trunk.regprop rp ON rp.cvecuenta = cc.cvecuenta 
        AND rp.cveregprop = cat.cveregprop 
        AND rp.encabeza = 'S'
    JOIN tramite_trunk.contrib c ON c.cvecont = rp.cvecont
    JOIN tramite_trunk.ubicacion u ON u.cvecuenta = cc.cvecuenta 
        AND u.vigencia = 'V'
    LEFT JOIN tramite_trunk.c_calidpro cp ON cp.cvereg = rp.cvereg
    WHERE cc.cvecatnva ILIKE v_clave_busqueda
    AND (p_subpredio IS NULL OR p_subpredio = '' OR 
         cc.subpredio::TEXT = p_subpredio)
    ORDER BY cc.cvecatnva, cc.subpredio
    LIMIT p_limite;
END;
$$;

-- SP_TRAMITE_TRUNK_BUSCAR_POR_RFC - Búsqueda por RFC del propietario
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_BUSCAR_POR_RFC(
    p_rfc TEXT,
    p_limite INTEGER DEFAULT 300
) RETURNS TABLE(
    cvecont INTEGER,
    nombre_completo TEXT,
    domicilio_exterior TEXT,
    domicilio_interior TEXT,
    calle_domicilio TEXT,
    clave_catastral TEXT,
    cuenta INTEGER,
    urbano_rustico TEXT,
    recaudadora INTEGER,
    subpredio INTEGER,
    vigente TEXT,
    calle_ubicacion TEXT,
    numero_exterior TEXT,
    numero_interior TEXT,
    cve_regprop INTEGER,
    cvecuenta INTEGER,
    cve_ubicacion INTEGER,
    cve_calle INTEGER,
    encabeza TEXT,
    descripcion_calidad TEXT,
    porcentaje FLOAT,
    rfc TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rp.cvecont,
        c.nombre_completo,
        c.noexterior as domicilio_exterior,
        c.interior as domicilio_interior,
        c.calle as calle_domicilio,
        cc.cvecatnva as clave_catastral,
        cc.cuenta,
        cc.urbrus as urbano_rustico,
        cc.recaud as recaudadora,
        cc.subpredio,
        cc.vigente,
        u.calle as calle_ubicacion,
        u.noexterior as numero_exterior,
        u.interior as numero_interior,
        cat.cveregprop as cve_regprop,
        cat.cvecuenta,
        cat.cveubic as cve_ubicacion,
        u.cvecalle as cve_calle,
        rp.encabeza,
        cp.descripcion as descripcion_calidad,
        rp.porcentaje,
        c.rfc
    FROM tramite_trunk.regprop rp
    JOIN tramite_trunk.contrib c ON c.cvecont = rp.cvecont
    JOIN tramite_trunk.convcta cc ON cc.cvecuenta = rp.cvecuenta
    JOIN tramite_trunk.catastro cat ON cat.cvecuenta = rp.cvecuenta 
        AND cat.cveregprop = rp.cveregprop
    JOIN tramite_trunk.ubicacion u ON u.cveubic = cat.cveubic
    LEFT JOIN tramite_trunk.c_calidpro cp ON cp.cvereg = rp.cvereg
    WHERE c.rfc ILIKE '%' || p_rfc || '%'
    AND rp.vigencia = 'V'
    ORDER BY c.rfc
    LIMIT p_limite;
END;
$$;

-- SP_TRAMITE_TRUNK_BUSCAR_POR_CUENTA - Búsqueda por datos de cuenta
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_BUSCAR_POR_CUENTA(
    p_recaudadora INTEGER,
    p_urbano_rustico TEXT,
    p_cuenta INTEGER,
    p_limite INTEGER DEFAULT 300
) RETURNS TABLE(
    cvecont INTEGER,
    nombre_completo TEXT,
    domicilio_exterior TEXT,
    domicilio_interior TEXT,
    calle_domicilio TEXT,
    clave_catastral TEXT,
    cuenta INTEGER,
    urbano_rustico TEXT,
    recaudadora INTEGER,
    subpredio INTEGER,
    vigente TEXT,
    calle_ubicacion TEXT,
    numero_exterior TEXT,
    numero_interior TEXT,
    cve_regprop INTEGER,
    cvecuenta INTEGER,
    cve_ubicacion INTEGER,
    cve_calle INTEGER,
    encabeza TEXT,
    descripcion_calidad TEXT,
    porcentaje FLOAT,
    rfc TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rp.cvecont,
        c.nombre_completo,
        c.noexterior as domicilio_exterior,
        c.interior as domicilio_interior,
        c.calle as calle_domicilio,
        cc.cvecatnva as clave_catastral,
        cc.cuenta,
        cc.urbrus as urbano_rustico,
        cc.recaud as recaudadora,
        cc.subpredio,
        cc.vigente,
        u.calle as calle_ubicacion,
        u.noexterior as numero_exterior,
        u.interior as numero_interior,
        cat.cveregprop as cve_regprop,
        cat.cvecuenta,
        cat.cveubic as cve_ubicacion,
        u.cvecalle as cve_calle,
        rp.encabeza,
        cp.descripcion as descripcion_calidad,
        rp.porcentaje,
        c.rfc
    FROM tramite_trunk.regprop rp
    JOIN tramite_trunk.contrib c ON c.cvecont = rp.cvecont
    JOIN tramite_trunk.convcta cc ON cc.cvecuenta = rp.cvecuenta
    JOIN tramite_trunk.catastro cat ON cat.cvecuenta = rp.cvecuenta 
        AND cat.cveregprop = rp.cveregprop
    JOIN tramite_trunk.ubicacion u ON u.cveubic = cat.cveubic
    LEFT JOIN tramite_trunk.c_calidpro cp ON cp.cvereg = rp.cvereg
    WHERE cc.recaud = p_recaudadora
    AND cc.urbrus = p_urbano_rustico
    AND cc.cuenta = p_cuenta
    AND rp.vigencia = 'V'
    LIMIT p_limite;
END;
$$;

-- =============================================
-- SECCIÓN: CONSULTA DE PAGOS
-- =============================================

-- SP_TRAMITE_TRUNK_CONSULTAR_PAGOS - Consultar pagos del sistema 400
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_CONSULTAR_PAGOS(
    p_cvecuenta INTEGER,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    folio_pago INTEGER,
    fecha_pago DATE,
    recaudadora INTEGER,
    caja VARCHAR(10),
    operacion INTEGER,
    importe_pago NUMERIC,
    concepto VARCHAR(255),
    periodo VARCHAR(20),
    estado VARCHAR(20),
    observaciones TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p400.folio,
        p400.fecha,
        p400.recaud as recaudadora,
        p400.caja,
        p400.operacion,
        p400.importe as importe_pago,
        COALESCE(p400.concepto, 'PAGO PREDIAL') as concepto,
        CONCAT(p400.axo, '-', LPAD(p400.bimestre::TEXT, 2, '0')) as periodo,
        CASE 
            WHEN p400.cancelado = 'S' THEN 'CANCELADO'
            WHEN p400.vigente = 'V' THEN 'VIGENTE'
            ELSE 'INACTIVO'
        END as estado,
        p400.observaciones
    FROM tramite_trunk.p400cont p400
    WHERE p400.cvecuenta = p_cvecuenta
    AND (p_fecha_desde IS NULL OR p400.fecha >= p_fecha_desde)
    AND (p_fecha_hasta IS NULL OR p400.fecha <= p_fecha_hasta)
    ORDER BY p400.fecha DESC, p400.folio DESC;
END;
$$;

-- =============================================
-- SECCIÓN: UTILIDADES Y REPORTES
-- =============================================

-- SP_TRAMITE_TRUNK_ESTADISTICAS_ABSTENCIONES - Estadísticas de abstenciones
CREATE OR REPLACE FUNCTION SP_TRAMITE_TRUNK_ESTADISTICAS_ABSTENCIONES(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
) RETURNS TABLE(
    total_abstenciones_activas INTEGER,
    abstenciones_registradas_periodo INTEGER,
    abstenciones_eliminadas_periodo INTEGER,
    usuarios_mas_activos JSONB,
    recaudadoras_mas_afectadas JSONB
) LANGUAGE plpgsql AS $$
DECLARE
    v_fecha_desde DATE;
    v_fecha_hasta DATE;
BEGIN
    v_fecha_desde := COALESCE(p_fecha_desde, CURRENT_DATE - INTERVAL '30 days');
    v_fecha_hasta := COALESCE(p_fecha_hasta, CURRENT_DATE);
    
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER 
         FROM tramite_trunk.catastro 
         WHERE cvemov = 12) as total_abstenciones_activas,
        
        (SELECT COUNT(*)::INTEGER 
         FROM tramite_trunk.historial_movimientos 
         WHERE tipo_movimiento = 'ABSTENCION_REGISTRO'
         AND fecha_movimiento BETWEEN v_fecha_desde AND v_fecha_hasta) as abstenciones_registradas_periodo,
        
        (SELECT COUNT(*)::INTEGER 
         FROM tramite_trunk.historial_movimientos 
         WHERE tipo_movimiento = 'ABSTENCION_ELIMINACION'
         AND fecha_movimiento BETWEEN v_fecha_desde AND v_fecha_hasta) as abstenciones_eliminadas_periodo,
        
        (SELECT jsonb_agg(jsonb_build_object(
            'usuario', usuario,
            'total_operaciones', total_operaciones
        ) ORDER BY total_operaciones DESC)
         FROM (
             SELECT usuario, COUNT(*) as total_operaciones
             FROM tramite_trunk.historial_movimientos
             WHERE tipo_movimiento IN ('ABSTENCION_REGISTRO', 'ABSTENCION_ELIMINACION')
             AND fecha_movimiento BETWEEN v_fecha_desde AND v_fecha_hasta
             GROUP BY usuario
             ORDER BY total_operaciones DESC
             LIMIT 5
         ) usuarios) as usuarios_mas_activos,
        
        (SELECT jsonb_agg(jsonb_build_object(
            'recaudadora', cc.recaud,
            'total_abstenciones', total_abstenciones
        ) ORDER BY total_abstenciones DESC)
         FROM (
             SELECT cc.recaud, COUNT(*) as total_abstenciones
             FROM tramite_trunk.catastro cat
             JOIN tramite_trunk.convcta cc ON cc.cvecuenta = cat.cvecuenta
             WHERE cat.cvemov = 12
             GROUP BY cc.recaud
             ORDER BY total_abstenciones DESC
             LIMIT 5
         ) recaudadoras) as recaudadoras_mas_afectadas;
END;
$$;