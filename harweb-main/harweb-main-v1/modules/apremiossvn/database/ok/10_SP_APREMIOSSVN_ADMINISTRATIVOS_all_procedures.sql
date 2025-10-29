-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO APREMIOSSVN - PROCEDIMIENTOS ADMINISTRATIVOS
-- Archivo: 10_SP_APREMIOSSVN_ADMINISTRATIVOS_all_procedures.sql
-- Basado en: FirmaElectronica, Prenomina, sfrm_chgpass y otros archivos administrativos
-- ============================================

-- =============================================
-- SECCIÓN: FIRMA ELECTRÓNICA
-- =============================================

-- SP_APREMIOSSVN_FIRMA_LISTAR_FOLIOS - Lista folios para firma electrónica
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FIRMA_LISTAR_FOLIOS(
    p_modulo INTEGER,
    p_fecha_emision DATE
) RETURNS TABLE(
    clave_requerimiento INTEGER,
    fecha_emision DATE,
    folio INTEGER,
    tipo_diligencia INTEGER,
    cadena_original_1 VARCHAR(500),
    cadena_original_2 VARCHAR(500),
    descripcion_diligencia VARCHAR(50)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.cvereq as clave_requerimiento,
        f.fecemi as fecha_emision,
        f.folio,
        f.diligencia as tipo_diligencia,
        f.cadena1 as cadena_original_1,
        f.cadena2 as cadena_original_2,
        CASE 
            WHEN f.diligencia = 1 THEN 'NOTIFICACIÓN'
            WHEN f.diligencia = 2 THEN 'REQUERIMIENTO'
            WHEN f.diligencia = 3 THEN 'SECUESTRO'
            ELSE 'OTRO'
        END as descripcion_diligencia
    FROM public.folios_firma f
    WHERE f.modulo = p_modulo 
    AND f.fecemi = p_fecha_emision
    ORDER BY f.folio;
END;
$$;

-- SP_APREMIOSSVN_FIRMA_GENERAR - Generar firma electrónica
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FIRMA_GENERAR(
    p_id_modulo INTEGER,
    p_tipo_formato INTEGER,
    p_id_documento INTEGER,
    p_fecha DATE,
    p_cadena_original VARCHAR(1000),
    p_ruta_archivo VARCHAR(500)
) RETURNS TABLE(
    codigo_resultado INTEGER,
    mensaje VARCHAR(255)
) LANGUAGE plpgsql AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar si ya existe firma para este documento
    SELECT COUNT(*) INTO v_exists
    FROM public.firmas_generadas 
    WHERE id_modulo = p_id_modulo 
    AND id_documento = p_id_documento;
    
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 1, 'Ya existe firma electrónica para este documento'::VARCHAR(255);
        RETURN;
    END IF;
    
    -- Insertar nueva firma
    INSERT INTO public.firmas_generadas (
        id_modulo, tipo_formato, id_documento, fecha_generacion, 
        cadena_original, ruta_archivo, estado, fecha_creacion
    ) VALUES (
        p_id_modulo, p_tipo_formato, p_id_documento, p_fecha,
        p_cadena_original, p_ruta_archivo, 'GENERADA', NOW()
    );
    
    RETURN QUERY SELECT 0, 'Firma electrónica generada correctamente'::VARCHAR(255);
END;
$$;

-- SP_APREMIOSSVN_FIRMA_INSERTAR - Insertar firma en apremios
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FIRMA_INSERTAR(
    p_secuencia INTEGER,
    p_digito_verificador VARCHAR(50),
    p_clave_registro INTEGER,
    p_fecha_alta DATE,
    p_vigencia VARCHAR(1),
    p_firmante VARCHAR(255),
    p_cargo VARCHAR(100),
    p_validez VARCHAR(50),
    p_fecha_firma VARCHAR(50),
    p_hash VARCHAR(255)
) RETURNS TABLE(
    registro_grabado INTEGER,
    ya_existe INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar si ya existe el registro
    SELECT COUNT(*) INTO v_exists
    FROM public.apremios_firmados 
    WHERE secuencia = p_secuencia;
    
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 0, 1;
        RETURN;
    END IF;
    
    -- Insertar nuevo registro firmado
    INSERT INTO public.apremios_firmados (
        secuencia, digito_verificador, id_modulo, fecha_graba, 
        vigencia, firmante, cargo, validez, fecha_firmado, hash
    ) VALUES (
        p_secuencia, p_digito_verificador, p_clave_registro, p_fecha_alta,
        p_vigencia, p_firmante, p_cargo, p_validez, p_fecha_firma, p_hash
    );
    
    RETURN QUERY SELECT 1, 0;
END;
$$;

-- SP_APREMIOSSVN_FIRMA_LISTAR_GENERADAS - Listar firmas generadas
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_FIRMA_LISTAR_GENERADAS(
    p_modulo INTEGER,
    p_fecha DATE
) RETURNS TABLE(
    secuencia INTEGER,
    digito_verificador VARCHAR(50),
    modulo INTEGER,
    id_modulo INTEGER,
    fecha_graba TIMESTAMP,
    firmante VARCHAR(255),
    cargo VARCHAR(100),
    fecha_firmado VARCHAR(50),
    hash VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        fea.secuencia,
        fea.digverificador as digito_verificador,
        fea.modulo,
        fea.id_modulo,
        fea.fechagraba as fecha_graba,
        f.firmante,
        fea.cargo,
        fea.fecha_firmado,
        fea.hash
    FROM public.tb_fea fea
    JOIN public.tb_firmante f ON f.puesto = fea.cargo
    WHERE fea.modulo = p_modulo 
    AND CAST(fea.fechagraba AS DATE) = p_fecha
    ORDER BY fea.secuencia;
END;
$$;

-- =============================================
-- SECCIÓN: PRENÓMINA DE EJECUTORES
-- =============================================

-- SP_APREMIOSSVN_PRENOMINA_RECAUDADORAS - Catálogo de recaudadoras para prenómina
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_PRENOMINA_RECAUDADORAS() RETURNS TABLE(
    id_rec SMALLINT,
    nombre TEXT,
    recaudadora TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id_rec,
        z.zona::TEXT as nombre,
        r.recaudadora::TEXT
    FROM public.ta_12_recaudadoras r
    JOIN public.ta_12_zonas z ON r.id_zona = z.id_zona
    WHERE r.id_rec < 8 -- Filtro original del sistema
    ORDER BY r.id_rec;
END;
$$;

-- SP_APREMIOSSVN_PRENOMINA_REPORTE - Reporte completo de prenómina
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_PRENOMINA_REPORTE(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_recaudadora_desde SMALLINT,
    p_recaudadora_hasta SMALLINT
) RETURNS TABLE(
    zona SMALLINT,
    ejecutor SMALLINT,
    fecha_rfc DATE,
    iniciales_rfc VARCHAR(4),
    homoclave_rfc VARCHAR(3),
    nombre_ejecutor VARCHAR(255),
    total_gastos NUMERIC,
    cantidad_diligencias INTEGER,
    recaudadora VARCHAR(255),
    zona_descripcion VARCHAR(255),
    promedio_gastos NUMERIC,
    dias_laborados INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id_rec as zona,
        a.ejecutor,
        e.fec_rfc as fecha_rfc,
        e.ini_rfc as iniciales_rfc,
        e.hom_rfc as homoclave_rfc,
        e.nombre as nombre_ejecutor,
        SUM(a.importe_gastos) as total_gastos,
        COUNT(*)::INTEGER as cantidad_diligencias,
        r.recaudadora,
        z.zona as zona_descripcion,
        AVG(a.importe_gastos) as promedio_gastos,
        (DATE_PART('day', p_fecha_hasta - p_fecha_desde) + 1)::INTEGER as dias_laborados
    FROM public.ta_15_apremios a
    JOIN public.ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    JOIN public.ta_12_recaudadoras r ON e.id_rec = r.id_rec
    JOIN public.ta_12_zonas z ON r.id_zona = z.id_zona
    WHERE a.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
    AND a.vigencia = '2' -- Solo expedientes pagados
    AND a.clave_practicado = 'P' -- Solo diligencias practicadas
    AND e.id_rec BETWEEN p_recaudadora_desde AND p_recaudadora_hasta
    AND a.importe_gastos > 0 -- Solo con gastos
    GROUP BY e.id_rec, a.ejecutor, e.fec_rfc, e.ini_rfc, e.hom_rfc, 
             e.nombre, r.recaudadora, z.zona
    ORDER BY e.id_rec, a.ejecutor;
END;
$$;

-- SP_APREMIOSSVN_PRENOMINA_RESUMEN - Resumen de prenómina por recaudadora
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_PRENOMINA_RESUMEN(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
) RETURNS TABLE(
    recaudadora VARCHAR(255),
    zona_descripcion VARCHAR(255),
    total_ejecutores INTEGER,
    total_diligencias INTEGER,
    total_gastos NUMERIC,
    promedio_gastos_ejecutor NUMERIC,
    ejecutor_mayor_productividad VARCHAR(255),
    ejecutor_menor_productividad VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.recaudadora,
        z.zona as zona_descripcion,
        COUNT(DISTINCT e.cve_eje)::INTEGER as total_ejecutores,
        COUNT(a.folio)::INTEGER as total_diligencias,
        SUM(a.importe_gastos) as total_gastos,
        AVG(a.importe_gastos) as promedio_gastos_ejecutor,
        -- Ejecutor con mayor productividad
        (SELECT e2.nombre FROM public.ta_15_ejecutores e2
         JOIN public.ta_15_apremios a2 ON e2.cve_eje = a2.ejecutor AND e2.id_rec = a2.zona
         WHERE e2.id_rec = r.id_rec
         AND a2.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
         AND a2.vigencia = '2' AND a2.clave_practicado = 'P'
         GROUP BY e2.nombre, e2.cve_eje
         ORDER BY COUNT(a2.folio) DESC LIMIT 1) as ejecutor_mayor_productividad,
        -- Ejecutor con menor productividad
        (SELECT e3.nombre FROM public.ta_15_ejecutores e3
         JOIN public.ta_15_apremios a3 ON e3.cve_eje = a3.ejecutor AND e3.id_rec = a3.zona
         WHERE e3.id_rec = r.id_rec
         AND a3.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
         AND a3.vigencia = '2' AND a3.clave_practicado = 'P'
         GROUP BY e3.nombre, e3.cve_eje
         ORDER BY COUNT(a3.folio) ASC LIMIT 1) as ejecutor_menor_productividad
    FROM public.ta_12_recaudadoras r
    JOIN public.ta_12_zonas z ON r.id_zona = z.id_zona
    JOIN public.ta_15_ejecutores e ON r.id_rec = e.id_rec
    JOIN public.ta_15_apremios a ON e.cve_eje = a.ejecutor AND e.id_rec = a.zona
    WHERE a.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
    AND a.vigencia = '2'
    AND a.clave_practicado = 'P'
    AND a.importe_gastos > 0
    GROUP BY r.recaudadora, z.zona, r.id_rec
    ORDER BY r.recaudadora;
END;
$$;

-- =============================================
-- SECCIÓN: CAMBIO DE CONTRASEÑAS
-- =============================================

-- SP_APREMIOSSVN_CAMBIAR_PASSWORD - Cambiar contraseña de usuario
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_CAMBIAR_PASSWORD(
    p_usuario_id INTEGER,
    p_password_actual VARCHAR(255),
    p_password_nuevo VARCHAR(255)
) RETURNS TABLE(
    resultado INTEGER,
    mensaje TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    v_password_actual VARCHAR(255);
    v_usuario_existe INTEGER;
BEGIN
    -- Verificar que el usuario existe
    SELECT COUNT(*) INTO v_usuario_existe
    FROM public.ta_12_passwords
    WHERE id_usuario = p_usuario_id;
    
    IF v_usuario_existe = 0 THEN
        RETURN QUERY SELECT 0, 'Usuario no encontrado'::TEXT;
        RETURN;
    END IF;
    
    -- Obtener contraseña actual
    SELECT password INTO v_password_actual
    FROM public.ta_12_passwords
    WHERE id_usuario = p_usuario_id;
    
    -- Verificar contraseña actual (en producción usar hash)
    IF v_password_actual != p_password_actual THEN
        RETURN QUERY SELECT 0, 'Contraseña actual incorrecta'::TEXT;
        RETURN;
    END IF;
    
    -- Actualizar contraseña
    UPDATE public.ta_12_passwords
    SET password = p_password_nuevo,
        fecha_cambio = CURRENT_DATE,
        ultimo_acceso = NOW()
    WHERE id_usuario = p_usuario_id;
    
    RETURN QUERY SELECT 1, 'Contraseña cambiada exitosamente'::TEXT;
END;
$$;

-- SP_APREMIOSSVN_VALIDAR_PASSWORD_ACTUAL - Validar contraseña actual
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_VALIDAR_PASSWORD_ACTUAL(
    p_usuario_id INTEGER,
    p_password VARCHAR(255)
) RETURNS TABLE(
    valida INTEGER,
    mensaje TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    v_password_actual VARCHAR(255);
    v_usuario_existe INTEGER;
BEGIN
    -- Verificar que el usuario existe
    SELECT COUNT(*) INTO v_usuario_existe
    FROM public.ta_12_passwords
    WHERE id_usuario = p_usuario_id;
    
    IF v_usuario_existe = 0 THEN
        RETURN QUERY SELECT 0, 'Usuario no encontrado'::TEXT;
        RETURN;
    END IF;
    
    -- Obtener contraseña actual
    SELECT password INTO v_password_actual
    FROM public.ta_12_passwords
    WHERE id_usuario = p_usuario_id;
    
    -- Validar contraseña
    IF v_password_actual = p_password THEN
        RETURN QUERY SELECT 1, 'Contraseña válida'::TEXT;
    ELSE
        RETURN QUERY SELECT 0, 'Contraseña incorrecta'::TEXT;
    END IF;
END;
$$;

-- =============================================
-- SECCIÓN: UTILIDADES DEL SISTEMA
-- =============================================

-- SP_APREMIOSSVN_VERIFICAR_VERSION - Verificar nueva versión del sistema
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_VERIFICAR_VERSION() RETURNS TABLE(
    version_actual VARCHAR(20),
    version_disponible VARCHAR(20),
    requiere_actualizacion INTEGER,
    fecha_version DATE,
    notas_version TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.version_actual,
        v.version_disponible,
        CASE WHEN v.version_actual != v.version_disponible THEN 1 ELSE 0 END as requiere_actualizacion,
        v.fecha_version,
        v.notas_version
    FROM public.sistema_versiones v
    ORDER BY v.fecha_version DESC
    LIMIT 1;
END;
$$;

-- SP_APREMIOSSVN_OBTENER_USUARIO_CREDENCIALES - Obtener usuario por credenciales
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_OBTENER_USUARIO_CREDENCIALES(
    p_usuario VARCHAR(50),
    p_password VARCHAR(255)
) RETURNS TABLE(
    id_usuario INTEGER,
    usuario VARCHAR(50),
    nombre VARCHAR(255),
    nivel_acceso INTEGER,
    activo INTEGER,
    ultimo_acceso TIMESTAMP,
    intentos_fallidos INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id_usuario,
        u.usuario,
        u.nombre,
        u.nivel_acceso,
        CASE WHEN u.activo THEN 1 ELSE 0 END as activo,
        u.ultimo_acceso,
        COALESCE(u.intentos_fallidos, 0) as intentos_fallidos
    FROM public.ta_12_passwords u
    WHERE u.usuario = p_usuario 
    AND u.password = p_password
    AND u.activo = TRUE;
END;
$$;

-- SP_APREMIOSSVN_REGISTRAR_ACCESO_USUARIO - Registrar acceso de usuario
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REGISTRAR_ACCESO_USUARIO(
    p_usuario_id INTEGER,
    p_ip VARCHAR(50) DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
) RETURNS TABLE(
    registrado INTEGER,
    mensaje TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    -- Actualizar último acceso
    UPDATE public.ta_12_passwords
    SET ultimo_acceso = NOW(),
        intentos_fallidos = 0
    WHERE id_usuario = p_usuario_id;
    
    -- Registrar en log de accesos
    INSERT INTO public.log_accesos (
        usuario_id, fecha_acceso, ip_address, user_agent
    ) VALUES (
        p_usuario_id, NOW(), p_ip, p_user_agent
    );
    
    RETURN QUERY SELECT 1, 'Acceso registrado exitosamente'::TEXT;
END;
$$;