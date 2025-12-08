-- =====================================================
-- STORED PROCEDURES CORREGIDOS PARA FRONTEND
-- Módulo: padron_licencias
-- Fecha: 2025-11-21
-- =====================================================

-- 1. DETALLE ANUNCIO - Corregido con estructura real
DROP FUNCTION IF EXISTS public.sp_detalle_anuncio_get(INTEGER);
CREATE OR REPLACE FUNCTION public.sp_detalle_anuncio_get(
    p_id_anuncio INTEGER
)
RETURNS TABLE(
    id_anuncio INTEGER,
    anuncio INTEGER,
    id_licencia INTEGER,
    id_giro INTEGER,
    giro VARCHAR,
    ubicacion VARCHAR,
    zona SMALLINT,
    subzona SMALLINT,
    fecha_otorgamiento DATE,
    medidas1 NUMERIC,
    medidas2 NUMERIC,
    area_anuncio NUMERIC,
    num_caras SMALLINT,
    texto_anuncio VARCHAR,
    vigente VARCHAR,
    propietario VARCHAR,
    rfc VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_anuncio,
        a.anuncio,
        a.id_licencia,
        a.id_giro,
        COALESCE(g.descripcion, 'Sin giro')::VARCHAR,
        COALESCE(a.ubicacion, '')::VARCHAR,
        a.zona,
        a.subzona,
        a.fecha_otorgamiento,
        a.medidas1,
        a.medidas2,
        a.area_anuncio,
        a.num_caras,
        COALESCE(a.texto_anuncio, '')::VARCHAR,
        COALESCE(a.vigente, '')::VARCHAR,
        COALESCE(l.propietario || ' ' || COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, ''), '')::VARCHAR,
        COALESCE(l.rfc, '')::VARCHAR
    FROM comun.anuncios a
    LEFT JOIN comun.licencias l ON a.id_licencia = l.id_licencia
    LEFT JOIN comun.c_giros g ON a.id_giro = g.id_giro
    WHERE a.id_anuncio = p_id_anuncio;
END;
$$ LANGUAGE plpgsql;

-- 2. BUSQUEDA ACTIVIDAD - Corregido con estructura real
DROP FUNCTION IF EXISTS public.sp_busqueda_actividad_search(VARCHAR, BOOLEAN, INTEGER);
CREATE OR REPLACE FUNCTION public.sp_busqueda_actividad_search(
    p_termino VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    generico SMALLINT,
    uso SMALLINT,
    actividad SMALLINT,
    concepto VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.generico,
        a.uso,
        a.actividad,
        COALESCE(a.concepto, '')::VARCHAR
    FROM comun.c_actividades a
    WHERE p_termino IS NULL OR a.concepto ILIKE '%' || p_termino || '%'
    ORDER BY a.generico, a.uso, a.actividad
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- 3. BUSQUEDA SCIAN - Corregido con estructura real (catastro_gdl)
DROP FUNCTION IF EXISTS public.sp_busqueda_scian_search(VARCHAR, VARCHAR, INTEGER);
CREATE OR REPLACE FUNCTION public.sp_busqueda_scian_search(
    p_codigo VARCHAR DEFAULT NULL,
    p_descripcion VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    codigo_scian INTEGER,
    descripcion VARCHAR,
    vigente VARCHAR,
    es_microgenerador VARCHAR,
    tipo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.codigo_scian,
        COALESCE(s.descripcion, '')::VARCHAR,
        COALESCE(s.vigente, '')::VARCHAR,
        COALESCE(s.es_microgenerador, 'N')::VARCHAR,
        COALESCE(s.tipo, '')::VARCHAR
    FROM catastro_gdl.c_scian s
    WHERE (p_codigo IS NULL OR s.codigo_scian::TEXT ILIKE '%' || p_codigo || '%')
      AND (p_descripcion IS NULL OR s.descripcion ILIKE '%' || p_descripcion || '%')
    ORDER BY s.codigo_scian
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- 4. CONSULTA TRAMITE DETALLE - Corregido con estructura real
DROP FUNCTION IF EXISTS public.sp_consulta_tramite_detalle(INTEGER);
CREATE OR REPLACE FUNCTION public.sp_consulta_tramite_detalle(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    id_giro INTEGER,
    giro VARCHAR,
    zona SMALLINT,
    subzona SMALLINT,
    actividad VARCHAR,
    propietario VARCHAR,
    rfc VARCHAR,
    domicilio VARCHAR,
    telefono VARCHAR,
    email VARCHAR,
    tramita_apoderado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        COALESCE(t.tipo_tramite, '')::VARCHAR,
        t.id_giro,
        COALESCE(g.descripcion, '')::VARCHAR,
        t.zona,
        t.subzona,
        COALESCE(t.actividad, '')::VARCHAR,
        COALESCE(t.propietario || ' ' || COALESCE(t.primer_ap, '') || ' ' || COALESCE(t.segundo_ap, ''), '')::VARCHAR,
        COALESCE(t.rfc, '')::VARCHAR,
        COALESCE(t.domicilio, '')::VARCHAR,
        COALESCE(t.telefono_prop, '')::VARCHAR,
        COALESCE(t.email, '')::VARCHAR,
        COALESCE(t.tramita_apoderado, '')::VARCHAR
    FROM comun.tramites t
    LEFT JOIN comun.c_giros g ON t.id_giro = g.id_giro
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- FIN DE STORED PROCEDURES CORREGIDOS
-- =====================================================
