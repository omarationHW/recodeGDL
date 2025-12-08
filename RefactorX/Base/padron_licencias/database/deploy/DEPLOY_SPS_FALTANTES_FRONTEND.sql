-- =====================================================
-- STORED PROCEDURES FALTANTES PARA FRONTEND
-- Módulo: padron_licencias
-- Fecha: 2025-11-21
-- =====================================================

-- =====================================================
-- 1. DETALLE ANUNCIO - SPs para DetalleAnuncio.vue
-- =====================================================

-- SP para obtener detalle completo de un anuncio
CREATE OR REPLACE FUNCTION public.sp_detalle_anuncio_get(
    p_id_anuncio INTEGER
)
RETURNS TABLE(
    id_anuncio INTEGER,
    anuncio VARCHAR,
    id_licencia INTEGER,
    licencia VARCHAR,
    empresa VARCHAR,
    id_giro INTEGER,
    giro VARCHAR,
    ubicacion TEXT,
    zona VARCHAR,
    subzona VARCHAR,
    tipo_anuncio VARCHAR,
    medidas VARCHAR,
    cantidad INTEGER,
    fecha_otorgamiento DATE,
    fecha_vigencia DATE,
    estatus VARCHAR,
    propietario VARCHAR,
    rfc VARCHAR,
    domicilio_fiscal TEXT,
    telefono VARCHAR,
    email VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_anuncio,
        a.anuncio::VARCHAR,
        a.id_licencia,
        l.licencia::VARCHAR,
        a.empresa::VARCHAR,
        a.id_giro,
        COALESCE(g.giro, 'Sin giro')::VARCHAR,
        COALESCE(a.ubicacion, '')::TEXT,
        COALESCE(a.zona, '')::VARCHAR,
        COALESCE(a.subzona, '')::VARCHAR,
        COALESCE(a.tipo_anuncio, '')::VARCHAR,
        COALESCE(a.medidas, '')::VARCHAR,
        COALESCE(a.cantidad, 1)::INTEGER,
        a.fecha_otorgamiento,
        a.fecha_vigencia,
        CASE
            WHEN a.status = 'A' THEN 'ACTIVO'
            WHEN a.status = 'B' THEN 'BAJA'
            WHEN a.status = 'S' THEN 'SUSPENDIDO'
            ELSE 'DESCONOCIDO'
        END::VARCHAR,
        COALESCE(l.propietario || ' ' || COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, ''), '')::VARCHAR,
        COALESCE(l.rfc, '')::VARCHAR,
        COALESCE(l.domicilio, '')::TEXT,
        COALESCE(a.telefono, '')::VARCHAR,
        COALESCE(a.email, '')::VARCHAR
    FROM comun.anuncios a
    LEFT JOIN comun.licencias l ON a.id_licencia = l.id_licencia
    LEFT JOIN comun.c_giros g ON a.id_giro = g.id_giro
    WHERE a.id_anuncio = p_id_anuncio;
END;
$$ LANGUAGE plpgsql;

-- SP para obtener saldos/adeudos de un anuncio
CREATE OR REPLACE FUNCTION public.sp_detalle_anuncio_saldos(
    p_id_anuncio INTEGER
)
RETURNS TABLE(
    id_anuncio INTEGER,
    axo SMALLINT,
    forma VARCHAR,
    derechos NUMERIC,
    derechos2 NUMERIC,
    recargos NUMERIC,
    actualizacion NUMERIC,
    saldo NUMERIC,
    pagado BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id_anuncio,
        d.axo,
        d.forma::VARCHAR,
        COALESCE(d.derechos, 0)::NUMERIC,
        COALESCE(d.derechos2, 0)::NUMERIC,
        COALESCE(d.recargos, 0)::NUMERIC,
        COALESCE(d.actualizacion, 0)::NUMERIC,
        COALESCE(d.saldo, 0)::NUMERIC,
        COALESCE(d.cvepago > 0, FALSE)::BOOLEAN
    FROM comun.detsal_lic d
    WHERE d.id_anuncio = p_id_anuncio
    ORDER BY d.axo DESC, d.forma;
END;
$$ LANGUAGE plpgsql;

-- SP para obtener historial de pagos de un anuncio
CREATE OR REPLACE FUNCTION public.sp_detalle_anuncio_pagos(
    p_id_anuncio INTEGER
)
RETURNS TABLE(
    id_pago INTEGER,
    fecha_pago DATE,
    monto NUMERIC,
    concepto VARCHAR,
    folio_recibo VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    -- Retornar estructura vacía si no existe tabla de pagos específica
    RETURN QUERY
    SELECT
        0::INTEGER as id_pago,
        CURRENT_DATE as fecha_pago,
        0::NUMERIC as monto,
        'Sin historial disponible'::VARCHAR as concepto,
        ''::VARCHAR as folio_recibo,
        ''::VARCHAR as usuario
    WHERE FALSE; -- Retorna vacío, ajustar según estructura real
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. BUSQUEDA ACTIVIDAD - SPs adicionales
-- =====================================================

-- SP para búsqueda de actividades por nombre
CREATE OR REPLACE FUNCTION public.sp_busqueda_actividad_search(
    p_termino VARCHAR DEFAULT NULL,
    p_vigente BOOLEAN DEFAULT TRUE,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    id_actividad INTEGER,
    actividad VARCHAR,
    descripcion TEXT,
    vigente BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_actividad,
        a.actividad::VARCHAR,
        COALESCE(a.descripcion, '')::TEXT,
        COALESCE(a.vigente, TRUE)::BOOLEAN
    FROM comun.c_actividades a
    WHERE (p_termino IS NULL OR a.actividad ILIKE '%' || p_termino || '%')
      AND (p_vigente IS NULL OR a.vigente = p_vigente)
    ORDER BY a.actividad
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. BUSQUEDA SCIAN - SPs adicionales
-- =====================================================

-- SP para búsqueda de códigos SCIAN
CREATE OR REPLACE FUNCTION public.sp_busqueda_scian_search(
    p_codigo VARCHAR DEFAULT NULL,
    p_descripcion VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    id_scian INTEGER,
    codigo VARCHAR,
    descripcion TEXT,
    sector VARCHAR,
    vigente BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id_scian,
        s.codigo::VARCHAR,
        COALESCE(s.descripcion, '')::TEXT,
        COALESCE(s.sector, '')::VARCHAR,
        COALESCE(s.vigente, TRUE)::BOOLEAN
    FROM comun.c_scian s
    WHERE (p_codigo IS NULL OR s.codigo ILIKE '%' || p_codigo || '%')
      AND (p_descripcion IS NULL OR s.descripcion ILIKE '%' || p_descripcion || '%')
    ORDER BY s.codigo
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. CONSULTA TRAMITE - SPs adicionales
-- =====================================================

-- SP para obtener detalle de trámite
CREATE OR REPLACE FUNCTION public.sp_consulta_tramite_detalle(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio VARCHAR,
    tipo_tramite VARCHAR,
    id_licencia INTEGER,
    licencia VARCHAR,
    empresa VARCHAR,
    giro VARCHAR,
    fecha_solicitud DATE,
    fecha_resolucion DATE,
    estatus VARCHAR,
    dictamen VARCHAR,
    observaciones TEXT,
    usuario_captura VARCHAR,
    usuario_revision VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio::VARCHAR,
        COALESCE(t.tipo_tramite, '')::VARCHAR,
        t.id_licencia,
        COALESCE(l.licencia, '')::VARCHAR,
        COALESCE(t.empresa, '')::VARCHAR,
        COALESCE(g.giro, '')::VARCHAR,
        t.fecha_solicitud,
        t.fecha_resolucion,
        CASE
            WHEN t.status = 'P' THEN 'PENDIENTE'
            WHEN t.status = 'A' THEN 'APROBADO'
            WHEN t.status = 'R' THEN 'RECHAZADO'
            WHEN t.status = 'C' THEN 'CANCELADO'
            ELSE 'DESCONOCIDO'
        END::VARCHAR,
        COALESCE(t.dictamen, '')::VARCHAR,
        COALESCE(t.observaciones, '')::TEXT,
        COALESCE(t.usuario_captura, '')::VARCHAR,
        COALESCE(t.usuario_revision, '')::VARCHAR
    FROM comun.tramites t
    LEFT JOIN comun.licencias l ON t.id_licencia = l.id_licencia
    LEFT JOIN comun.c_giros g ON t.id_giro = g.id_giro
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FIN DE STORED PROCEDURES FALTANTES
-- =====================================================
