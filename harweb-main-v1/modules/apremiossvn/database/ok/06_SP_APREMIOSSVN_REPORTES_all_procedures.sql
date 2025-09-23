-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULO APREMIOSSVN - REPORTES Y CONSULTAS
-- Archivo: 06_SP_APREMIOSSVN_REPORTES_all_procedures.sql
-- Basado en: RprtCATAL_EJE, RprtEstadxfolio, Modifcar y otros archivos de reportes
-- ============================================

-- =============================================
-- SECCIÓN: REPORTES DE EJECUTORES
-- =============================================

-- SP_APREMIOSSVN_REPORTE_CATALOGO_EJECUTORES - Catálogo de ejecutores con información completa
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTE_CATALOGO_EJECUTORES(
    p_id_rec INTEGER,
    p_vigencia VARCHAR(1) DEFAULT NULL
) RETURNS TABLE(
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc VARCHAR(4),
    fec_rfc DATE,
    hom_rfc VARCHAR(3),
    nombre VARCHAR(60),
    id_rec SMALLINT,
    categoria VARCHAR(255),
    observacion VARCHAR(255),
    oficio VARCHAR(14),
    fecinic DATE,
    fecterm DATE,
    vigencia VARCHAR(1),
    recaudadora_nombre VARCHAR(255),
    zona VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id_ejecutor,
        e.cve_eje,
        e.ini_rfc,
        e.fec_rfc,
        e.hom_rfc,
        e.nombre,
        e.id_rec,
        e.categoria,
        e.observacion,
        e.oficio,
        e.fecinic,
        e.fecterm,
        e.vigencia,
        r.recaudadora_1 as recaudadora_nombre,
        z.zona
    FROM public.ta_15_ejecutores e
    JOIN public.ta_12_recaudadoras r ON e.id_rec = r.id_rec
    JOIN public.ta_12_zonas z ON r.id_zona = z.id_zona
    WHERE e.id_rec = p_id_rec
    AND (p_vigencia IS NULL OR p_vigencia = '' OR e.vigencia = p_vigencia)
    ORDER BY e.cve_eje;
END;
$$;

-- =============================================
-- SECCIÓN: REPORTES ESTADÍSTICOS
-- =============================================

-- SP_APREMIOSSVN_REPORTE_ESTADISTICAS_FOLIO - Estadísticas por folio y vigencia
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTE_ESTADISTICAS_FOLIO(
    p_modulo INTEGER,
    p_recaudadora INTEGER,
    p_folio_inicio INTEGER,
    p_folio_fin INTEGER
) RETURNS TABLE(
    vigencia VARCHAR(1),
    clave_practicado VARCHAR(10),
    cantidad_folios INTEGER,
    total_gastos_pago NUMERIC(18,2),
    total_gastos_gastos NUMERIC(18,2),
    total_adeudo NUMERIC(18,2),
    total_recargos NUMERIC(18,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.vigencia,
        a.clave_practicado,
        COUNT(*)::INTEGER as cantidad_folios,
        SUM(a.importe_pago) as total_gastos_pago,
        SUM(a.importe_gastos) as total_gastos_gastos,
        SUM(a.importe_global) as total_adeudo,
        SUM(a.importe_recargo) as total_recargos
    FROM public.ta_15_apremios a
    WHERE a.modulo = p_modulo
    AND a.zona = p_recaudadora
    AND a.folio BETWEEN p_folio_inicio AND p_folio_fin
    GROUP BY a.vigencia, a.clave_practicado
    ORDER BY a.vigencia, a.clave_practicado;
END;
$$;

-- SP_APREMIOSSVN_INFO_RECAUDADORA_ZONA - Información de recaudadora y zona
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_INFO_RECAUDADORA_ZONA(
    p_id_recaudadora INTEGER
) RETURNS TABLE(
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora VARCHAR(255),
    domicilio VARCHAR(255),
    telefono VARCHAR(50),
    recaudador VARCHAR(255),
    sector VARCHAR(255),
    id_zona_detalle INTEGER,
    zona VARCHAR(255)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id_rec,
        r.id_zona,
        r.recaudadora,
        r.domicilio,
        r.tel as telefono,
        r.recaudador,
        r.sector,
        z.id_zona as id_zona_detalle,
        z.zona
    FROM public.ta_12_recaudadoras r
    JOIN public.ta_12_zonas z ON r.id_zona = z.id_zona
    WHERE r.id_rec = p_id_recaudadora;
END;
$$;

-- =============================================
-- SECCIÓN: MODIFICACIONES Y HISTORIAL
-- =============================================

-- SP_APREMIOSSVN_OBTENER_APREMIO - Obtener datos completos de un apremio
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_OBTENER_APREMIO(
    p_modulo INTEGER,
    p_folio INTEGER,
    p_recaudadora INTEGER
) RETURNS TABLE(
    id_control INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    control_otr INTEGER,
    folio INTEGER,
    diligencia VARCHAR(255),
    importe_global NUMERIC,
    importe_multa NUMERIC,
    importe_recargo NUMERIC,
    importe_gastos NUMERIC,
    zona_apremio SMALLINT,
    fecha_emision DATE,
    clave_practicado VARCHAR(10),
    fecha_practicado DATE,
    fecha_entrega1 DATE,
    fecha_entrega2 DATE,
    fecha_citatorio DATE,
    hora TIMESTAMP,
    ejecutor SMALLINT,
    clave_secuestro SMALLINT,
    clave_remate VARCHAR(50),
    fecha_remate DATE,
    porcentaje_multa SMALLINT,
    observaciones VARCHAR(500),
    fecha_pago DATE,
    recaudadora SMALLINT,
    caja VARCHAR(50),
    operacion INTEGER,
    importe_pago NUMERIC,
    vigencia VARCHAR(1),
    fecha_actualiz DATE,
    usuario INTEGER,
    clave_mov VARCHAR(10)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_control,
        a.zona,
        a.modulo,
        a.control_otr,
        a.folio,
        a.diligencia,
        a.importe_global,
        a.importe_multa,
        a.importe_recargo,
        a.importe_gastos,
        a.zona_apremio,
        a.fecha_emision,
        a.clave_practicado,
        a.fecha_practicado,
        a.fecha_entrega1,
        a.fecha_entrega2,
        a.fecha_citatorio,
        a.hora,
        a.ejecutor,
        a.clave_secuestro,
        a.clave_remate,
        a.fecha_remate,
        a.porcentaje_multa,
        a.observaciones,
        a.fecha_pago,
        a.recaudadora,
        a.caja,
        a.operacion,
        a.importe_pago,
        a.vigencia,
        a.fecha_actualiz,
        a.usuario,
        a.clave_mov
    FROM public.ta_15_apremios a
    WHERE a.modulo = p_modulo 
    AND a.folio = p_folio 
    AND a.zona = p_recaudadora;
END;
$$;

-- SP_APREMIOSSVN_MODIFICAR_APREMIO - Modificar apremio con historial
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_MODIFICAR_APREMIO(
    p_id_control INTEGER,
    p_modulo INTEGER,
    p_folio INTEGER,
    p_usuario INTEGER,
    p_cambios JSONB
) RETURNS TABLE(
    resultado TEXT
) LANGUAGE plpgsql AS $$
DECLARE
    v_registro_anterior RECORD;
BEGIN
    -- Verificar que existe el registro
    SELECT * INTO v_registro_anterior 
    FROM public.ta_15_apremios 
    WHERE id_control = p_id_control AND modulo = p_modulo AND folio = p_folio;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT 'ERROR: No existe el folio especificado'::TEXT;
        RETURN;
    END IF;
    
    -- Actualizar registro con cambios dinámicos del JSON
    UPDATE public.ta_15_apremios
    SET 
        usuario = p_usuario,
        fecha_actualiz = CURRENT_DATE,
        zona_apremio = COALESCE((p_cambios->>'zona_apremio')::SMALLINT, zona_apremio),
        observaciones = COALESCE(p_cambios->>'observaciones', observaciones),
        porcentaje_multa = COALESCE((p_cambios->>'porcentaje_multa')::SMALLINT, porcentaje_multa),
        clave_mov = COALESCE(p_cambios->>'clave_mov', clave_mov),
        importe_gastos = COALESCE((p_cambios->>'importe_gastos')::NUMERIC, importe_gastos),
        importe_multa = COALESCE((p_cambios->>'importe_multa')::NUMERIC, importe_multa),
        clave_practicado = COALESCE(p_cambios->>'clave_practicado', clave_practicado),
        fecha_practicado = COALESCE((p_cambios->>'fecha_practicado')::DATE, fecha_practicado),
        fecha_citatorio = COALESCE((p_cambios->>'fecha_citatorio')::DATE, fecha_citatorio),
        hora = COALESCE((p_cambios->>'hora')::TIMESTAMP, hora),
        ejecutor = COALESCE((p_cambios->>'ejecutor')::SMALLINT, ejecutor),
        fecha_entrega1 = COALESCE((p_cambios->>'fecha_entrega1')::DATE, fecha_entrega1),
        fecha_entrega2 = COALESCE((p_cambios->>'fecha_entrega2')::DATE, fecha_entrega2),
        fecha_pago = COALESCE((p_cambios->>'fecha_pago')::DATE, fecha_pago),
        recaudadora = COALESCE((p_cambios->>'recaudadora')::SMALLINT, recaudadora),
        caja = COALESCE(p_cambios->>'caja', caja),
        operacion = COALESCE((p_cambios->>'operacion')::INTEGER, operacion),
        importe_pago = COALESCE((p_cambios->>'importe_pago')::NUMERIC, importe_pago),
        clave_secuestro = COALESCE((p_cambios->>'clave_secuestro')::SMALLINT, clave_secuestro),
        clave_remate = COALESCE(p_cambios->>'clave_remate', clave_remate),
        fecha_remate = COALESCE((p_cambios->>'fecha_remate')::DATE, fecha_remate),
        vigencia = COALESCE(p_cambios->>'vigencia', vigencia)
    WHERE id_control = p_id_control AND modulo = p_modulo AND folio = p_folio;
    
    -- Registrar en historial
    INSERT INTO public.ta_15_historia (
        id_control, control, zona, modulo, control_otr, folio, diligencia, 
        importe_global, importe_multa, importe_recargo, importe_gastos, 
        zona_apremio, fecha_emision, clave_practicado, fecha_practicado, 
        fecha_entrega1, fecha_entrega2, fecha_citatorio, hora, ejecutor, 
        clave_secuestro, clave_remate, fecha_remate, porcentaje_multa, 
        observaciones, fecha_pago, recaudadora, caja, operacion, importe_pago, 
        vigencia, fecha_actualiz, usuario, clave_mov, hora_practicado
    ) VALUES (
        v_registro_anterior.id_control, v_registro_anterior.control, 
        v_registro_anterior.zona, v_registro_anterior.modulo, 
        v_registro_anterior.control_otr, v_registro_anterior.folio, 
        v_registro_anterior.diligencia, v_registro_anterior.importe_global, 
        v_registro_anterior.importe_multa, v_registro_anterior.importe_recargo, 
        v_registro_anterior.importe_gastos, v_registro_anterior.zona_apremio, 
        v_registro_anterior.fecha_emision, v_registro_anterior.clave_practicado, 
        v_registro_anterior.fecha_practicado, v_registro_anterior.fecha_entrega1, 
        v_registro_anterior.fecha_entrega2, v_registro_anterior.fecha_citatorio, 
        v_registro_anterior.hora, v_registro_anterior.ejecutor, 
        v_registro_anterior.clave_secuestro, v_registro_anterior.clave_remate, 
        v_registro_anterior.fecha_remate, v_registro_anterior.porcentaje_multa, 
        v_registro_anterior.observaciones, v_registro_anterior.fecha_pago, 
        v_registro_anterior.recaudadora, v_registro_anterior.caja, 
        v_registro_anterior.operacion, v_registro_anterior.importe_pago, 
        v_registro_anterior.vigencia, v_registro_anterior.fecha_actualiz, 
        v_registro_anterior.usuario, v_registro_anterior.clave_mov, 
        v_registro_anterior.hora_practicado
    );
    
    RETURN QUERY SELECT 'OK: Apremio modificado exitosamente'::TEXT;
END;
$$;

-- SP_APREMIOSSVN_HISTORIAL_APREMIO - Consultar historial de cambios
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_HISTORIAL_APREMIO(
    p_id_control INTEGER
) RETURNS TABLE(
    fecha_actualizacion DATE,
    usuario_modificacion INTEGER,
    clave_movimiento VARCHAR(10),
    observaciones VARCHAR(500),
    fecha_registro TIMESTAMP
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.fecha_actualiz as fecha_actualizacion,
        h.usuario as usuario_modificacion,
        h.clave_mov as clave_movimiento,
        h.observaciones,
        h.fecha_actualiz::TIMESTAMP as fecha_registro
    FROM public.ta_15_historia h
    WHERE h.id_control = p_id_control
    ORDER BY h.fecha_actualiz DESC;
END;
$$;

-- =============================================
-- SECCIÓN: REPORTES DE PRODUCTIVIDAD
-- =============================================

-- SP_APREMIOSSVN_REPORTE_PRODUCTIVIDAD_EJECUTORES - Productividad por ejecutor
CREATE OR REPLACE FUNCTION SP_APREMIOSSVN_REPORTE_PRODUCTIVIDAD_EJECUTORES(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_id_rec INTEGER DEFAULT NULL
) RETURNS TABLE(
    ejecutor_id INTEGER,
    ejecutor_nombre VARCHAR(60),
    diligencias_practicadas INTEGER,
    notificaciones_realizadas INTEGER,
    pagos_gestionados INTEGER,
    monto_total_gestionado NUMERIC,
    efectividad NUMERIC(5,2)
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.cve_eje as ejecutor_id,
        e.nombre as ejecutor_nombre,
        COUNT(CASE WHEN a.clave_practicado = 'P' THEN 1 END)::INTEGER as diligencias_practicadas,
        COUNT(CASE WHEN a.fecha_citatorio IS NOT NULL THEN 1 END)::INTEGER as notificaciones_realizadas,
        COUNT(CASE WHEN a.fecha_pago IS NOT NULL THEN 1 END)::INTEGER as pagos_gestionados,
        SUM(COALESCE(a.importe_pago, 0)) as monto_total_gestionado,
        (COUNT(CASE WHEN a.fecha_pago IS NOT NULL THEN 1 END) * 100.0 / 
         NULLIF(COUNT(CASE WHEN a.clave_practicado = 'P' THEN 1 END), 0))::NUMERIC(5,2) as efectividad
    FROM public.ta_15_ejecutores e
    LEFT JOIN public.ta_15_apremios a ON e.cve_eje = a.ejecutor 
        AND a.fecha_practicado BETWEEN p_fecha_desde AND p_fecha_hasta
    WHERE (p_id_rec IS NULL OR e.id_rec = p_id_rec)
    AND e.vigencia = 'A'
    GROUP BY e.cve_eje, e.nombre
    HAVING COUNT(CASE WHEN a.clave_practicado = 'P' THEN 1 END) > 0
    ORDER BY efectividad DESC, monto_total_gestionado DESC;
END;
$$;