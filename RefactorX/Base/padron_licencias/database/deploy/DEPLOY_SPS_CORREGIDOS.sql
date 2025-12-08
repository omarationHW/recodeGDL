-- ============================================
-- SPs CORREGIDOS CON ESTRUCTURA REAL DE TABLAS
-- Módulo: padron_licencias
-- Fecha: 2025-11-21
-- ============================================

-- ============================================
-- CONSULTALICENCIAFRM - Consulta de adeudos
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_licencia_get_adeudos(
    p_id INTEGER,
    p_tipo VARCHAR(1)
)
RETURNS TABLE(
    id_licencia INTEGER,
    id_anuncio INTEGER,
    axo SMALLINT,
    forma NUMERIC,
    derechos NUMERIC,
    derechos2 NUMERIC,
    recargos NUMERIC,
    desc_derechos NUMERIC,
    desc_recargos NUMERIC,
    desc_forma NUMERIC,
    actualizacion NUMERIC,
    saldo NUMERIC,
    cvepago INTEGER
) AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_id es requerido';
    END IF;

    IF p_tipo = 'L' THEN
        RETURN QUERY
        SELECT d.id_licencia, d.id_anuncio, d.axo, d.forma, d.derechos, d.derechos2,
               d.recargos, d.desc_derechos, d.desc_recargos, d.desc_forma,
               d.actualizacion, d.saldo, d.cvepago
        FROM comun.detsal_lic d
        WHERE d.id_licencia = p_id AND d.cvepago = 0
        ORDER BY d.axo DESC;
    ELSIF p_tipo = 'A' THEN
        RETURN QUERY
        SELECT d.id_licencia, d.id_anuncio, d.axo, d.forma, d.derechos, d.derechos2,
               d.recargos, d.desc_derechos, d.desc_recargos, d.desc_forma,
               d.actualizacion, d.saldo, d.cvepago
        FROM comun.detsal_lic d
        WHERE d.id_anuncio = p_id AND d.cvepago = 0
        ORDER BY d.axo DESC;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CONSULTALICENCIAFRM - Datos de licencia
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_licencia_get_datos(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    id_giro INTEGER,
    zona SMALLINT,
    subzona SMALLINT,
    propietario VARCHAR,
    rfc VARCHAR,
    actividad VARCHAR,
    ubicacion VARCHAR,
    fecha_otorgamiento DATE,
    bloqueado SMALLINT,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.empresa, l.id_giro, l.zona, l.subzona,
           TRIM(l.propietario)::VARCHAR, TRIM(l.rfc)::VARCHAR,
           TRIM(l.actividad)::VARCHAR, TRIM(l.ubicacion)::VARCHAR,
           l.fecha_otorgamiento, l.bloqueado, TRIM(l.vigente)::VARCHAR
    FROM comun.licencias l
    WHERE l.id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CONSULTALICENCIAFRM - Buscar licencia
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_licencia_buscar(
    p_licencia INTEGER DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
    p_propietario VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    actividad VARCHAR,
    zona SMALLINT,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia,
           TRIM(l.propietario)::VARCHAR, TRIM(l.rfc)::VARCHAR,
           TRIM(l.actividad)::VARCHAR, l.zona, TRIM(l.vigente)::VARCHAR
    FROM comun.licencias l
    WHERE (p_licencia IS NULL OR l.licencia = p_licencia)
      AND (p_rfc IS NULL OR TRIM(l.rfc) ILIKE '%' || p_rfc || '%')
      AND (p_propietario IS NULL OR TRIM(l.propietario) ILIKE '%' || p_propietario || '%')
    ORDER BY l.licencia
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CONSULTALICENCIAFRM - Total adeudo
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_licencia_total_adeudo(
    p_id INTEGER,
    p_tipo VARCHAR(1)
)
RETURNS TABLE(
    total_forma NUMERIC,
    total_derechos NUMERIC,
    total_recargos NUMERIC,
    total_actualizacion NUMERIC,
    total_saldo NUMERIC,
    anios_adeudo INTEGER
) AS $$
BEGIN
    IF p_tipo = 'L' THEN
        RETURN QUERY
        SELECT COALESCE(SUM(d.forma), 0)::NUMERIC,
               COALESCE(SUM(d.derechos), 0)::NUMERIC,
               COALESCE(SUM(d.recargos), 0)::NUMERIC,
               COALESCE(SUM(d.actualizacion), 0)::NUMERIC,
               COALESCE(SUM(d.saldo), 0)::NUMERIC,
               COUNT(DISTINCT d.axo)::INTEGER
        FROM comun.detsal_lic d
        WHERE d.id_licencia = p_id AND d.cvepago = 0;
    ELSIF p_tipo = 'A' THEN
        RETURN QUERY
        SELECT COALESCE(SUM(d.forma), 0)::NUMERIC,
               COALESCE(SUM(d.derechos), 0)::NUMERIC,
               COALESCE(SUM(d.recargos), 0)::NUMERIC,
               COALESCE(SUM(d.actualizacion), 0)::NUMERIC,
               COALESCE(SUM(d.saldo), 0)::NUMERIC,
               COUNT(DISTINCT d.axo)::INTEGER
        FROM comun.detsal_lic d
        WHERE d.id_anuncio = p_id AND d.cvepago = 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ANUNCIOS - Consulta datos de anuncio
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_anuncio_get_datos(
    p_id_anuncio INTEGER
)
RETURNS TABLE(
    id_anuncio INTEGER,
    anuncio INTEGER,
    id_licencia INTEGER,
    id_giro INTEGER,
    zona SMALLINT,
    subzona SMALLINT,
    ubicacion VARCHAR,
    area_anuncio NUMERIC,
    num_caras SMALLINT,
    texto_anuncio VARCHAR,
    fecha_otorgamiento DATE,
    bloqueado SMALLINT,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_anuncio, a.anuncio, a.id_licencia, a.id_giro, a.zona, a.subzona,
           TRIM(a.ubicacion)::VARCHAR, a.area_anuncio, a.num_caras,
           TRIM(a.texto_anuncio)::VARCHAR, a.fecha_otorgamiento,
           a.bloqueado, TRIM(a.vigente)::VARCHAR
    FROM comun.anuncios a
    WHERE a.id_anuncio = p_id_anuncio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ANUNCIOS - Buscar anuncio
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_anuncio_buscar(
    p_anuncio INTEGER DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_texto VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id_anuncio INTEGER,
    anuncio INTEGER,
    id_licencia INTEGER,
    ubicacion VARCHAR,
    texto_anuncio VARCHAR,
    zona SMALLINT,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_anuncio, a.anuncio, a.id_licencia,
           TRIM(a.ubicacion)::VARCHAR, TRIM(a.texto_anuncio)::VARCHAR,
           a.zona, TRIM(a.vigente)::VARCHAR
    FROM comun.anuncios a
    WHERE (p_anuncio IS NULL OR a.anuncio = p_anuncio)
      AND (p_id_licencia IS NULL OR a.id_licencia = p_id_licencia)
      AND (p_texto IS NULL OR TRIM(a.texto_anuncio) ILIKE '%' || p_texto || '%')
    ORDER BY a.anuncio
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRAMITES - Consulta datos de trámite
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_tramite_get_datos(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    id_giro INTEGER,
    zona SMALLINT,
    propietario VARCHAR,
    rfc VARCHAR,
    actividad VARCHAR,
    ubicacion VARCHAR,
    estatus VARCHAR,
    feccap DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.folio, TRIM(t.tipo_tramite)::VARCHAR, t.id_giro, t.zona,
           TRIM(t.propietario)::VARCHAR, TRIM(t.rfc)::VARCHAR,
           TRIM(t.actividad)::VARCHAR, TRIM(t.ubicacion)::VARCHAR,
           TRIM(t.estatus)::VARCHAR, t.feccap
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRAMITES - Buscar trámite
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_tramite_buscar(
    p_folio INTEGER DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
    p_propietario VARCHAR DEFAULT NULL,
    p_estatus VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    propietario VARCHAR,
    rfc VARCHAR,
    estatus VARCHAR,
    feccap DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.folio, TRIM(t.tipo_tramite)::VARCHAR,
           TRIM(t.propietario)::VARCHAR, TRIM(t.rfc)::VARCHAR,
           TRIM(t.estatus)::VARCHAR, t.feccap
    FROM comun.tramites t
    WHERE (p_folio IS NULL OR t.folio = p_folio)
      AND (p_rfc IS NULL OR TRIM(t.rfc) ILIKE '%' || p_rfc || '%')
      AND (p_propietario IS NULL OR TRIM(t.propietario) ILIKE '%' || p_propietario || '%')
      AND (p_estatus IS NULL OR TRIM(t.estatus) = p_estatus)
    ORDER BY t.folio DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- GIROS - Consulta catálogo de giros
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogo_giros_list(
    p_vigente VARCHAR DEFAULT 'S',
    p_limit INTEGER DEFAULT 1000
)
RETURNS TABLE(
    id_giro INTEGER,
    cod_giro INTEGER,
    descripcion VARCHAR,
    caracteristicas VARCHAR,
    clasificacion VARCHAR,
    tipo VARCHAR,
    reglamentada VARCHAR,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT g.id_giro, g.cod_giro, TRIM(g.descripcion)::VARCHAR,
           TRIM(g.caracteristicas)::VARCHAR, TRIM(g.clasificacion)::VARCHAR,
           TRIM(g.tipo)::VARCHAR, TRIM(g.reglamentada)::VARCHAR,
           TRIM(g.vigente)::VARCHAR
    FROM comun.c_giros g
    WHERE (p_vigente IS NULL OR TRIM(g.vigente) = p_vigente)
    ORDER BY g.descripcion
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- GIROS - Buscar giro por descripción
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_catalogo_giros_buscar(
    p_descripcion VARCHAR DEFAULT NULL,
    p_cod_giro INTEGER DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id_giro INTEGER,
    cod_giro INTEGER,
    descripcion VARCHAR,
    tipo VARCHAR,
    reglamentada VARCHAR,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT g.id_giro, g.cod_giro, TRIM(g.descripcion)::VARCHAR,
           TRIM(g.tipo)::VARCHAR, TRIM(g.reglamentada)::VARCHAR,
           TRIM(g.vigente)::VARCHAR
    FROM comun.c_giros g
    WHERE (p_descripcion IS NULL OR TRIM(g.descripcion) ILIKE '%' || p_descripcion || '%')
      AND (p_cod_giro IS NULL OR g.cod_giro = p_cod_giro)
    ORDER BY g.descripcion
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- LICENCIAS_400 - Consulta AS/400
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_consulta_lic400_get(
    p_numlic INTEGER
)
RETURNS TABLE(
    ofna SMALLINT,
    numlic INTEGER,
    inirfc VARCHAR,
    codgir SMALLINT,
    descripcion_giro VARCHAR,
    ubicacion VARCHAR,
    numext INTEGER,
    numzon SMALLINT,
    fecalt INTEGER,
    fecbaj INTEGER,
    vigenc SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.ofna, l.numlic, TRIM(l.inirfc)::VARCHAR, l.codgir,
           TRIM(l.ilgir1 || ' ' || l.ilgir2)::VARCHAR,
           TRIM(l.nomcal)::VARCHAR, l.numext, l.numzon,
           l.fecalt, l.fecbaj, l.vigenc
    FROM comun.licencias_400 l
    WHERE l.numlic = p_numlic;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- USUARIOS - Validar usuario
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_usuario_validar(
    p_usuario VARCHAR,
    p_clave VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    usuario VARCHAR,
    nombres VARCHAR,
    nivel SMALLINT,
    cvedepto INTEGER
) AS $$
DECLARE
    v_user RECORD;
BEGIN
    SELECT u.usuario, u.nombres, u.clave, u.nivel, u.cvedepto, u.fecbaj
    INTO v_user
    FROM comun.usuarios u
    WHERE TRIM(u.usuario) = UPPER(TRIM(p_usuario));

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado'::TEXT,
                            NULL::VARCHAR, NULL::VARCHAR, NULL::SMALLINT, NULL::INTEGER;
        RETURN;
    END IF;

    IF v_user.fecbaj IS NOT NULL THEN
        RETURN QUERY SELECT FALSE, 'Usuario dado de baja'::TEXT,
                            NULL::VARCHAR, NULL::VARCHAR, NULL::SMALLINT, NULL::INTEGER;
        RETURN;
    END IF;

    IF TRIM(v_user.clave) != TRIM(p_clave) THEN
        RETURN QUERY SELECT FALSE, 'Contraseña incorrecta'::TEXT,
                            NULL::VARCHAR, NULL::VARCHAR, NULL::SMALLINT, NULL::INTEGER;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'OK'::TEXT,
                        TRIM(v_user.usuario)::VARCHAR, TRIM(v_user.nombres)::VARCHAR,
                        v_user.nivel, v_user.cvedepto;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ESTADÍSTICAS GENERALES
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_estadisticas_licencias(
    p_zona SMALLINT DEFAULT NULL
)
RETURNS TABLE(
    total_licencias BIGINT,
    licencias_vigentes BIGINT,
    licencias_bloqueadas BIGINT,
    total_anuncios BIGINT,
    anuncios_vigentes BIGINT,
    total_tramites BIGINT,
    tramites_pendientes BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM comun.licencias WHERE p_zona IS NULL OR zona = p_zona),
        (SELECT COUNT(*) FROM comun.licencias WHERE TRIM(vigente) = 'S' AND (p_zona IS NULL OR zona = p_zona)),
        (SELECT COUNT(*) FROM comun.licencias WHERE bloqueado > 0 AND (p_zona IS NULL OR zona = p_zona)),
        (SELECT COUNT(*) FROM comun.anuncios WHERE p_zona IS NULL OR zona = p_zona),
        (SELECT COUNT(*) FROM comun.anuncios WHERE TRIM(vigente) = 'S' AND (p_zona IS NULL OR zona = p_zona)),
        (SELECT COUNT(*) FROM comun.tramites WHERE p_zona IS NULL OR zona = p_zona),
        (SELECT COUNT(*) FROM comun.tramites WHERE TRIM(estatus) = 'P' AND (p_zona IS NULL OR zona = p_zona));
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- DETALLE SALDO - Por año
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_detsal_lic_por_anio(
    p_id_licencia INTEGER,
    p_axo SMALLINT DEFAULT NULL
)
RETURNS TABLE(
    axo SMALLINT,
    total_forma NUMERIC,
    total_derechos NUMERIC,
    total_recargos NUMERIC,
    total_actualizacion NUMERIC,
    total_saldo NUMERIC,
    registros INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.axo,
           SUM(d.forma)::NUMERIC,
           SUM(d.derechos)::NUMERIC,
           SUM(d.recargos)::NUMERIC,
           SUM(d.actualizacion)::NUMERIC,
           SUM(d.saldo)::NUMERIC,
           COUNT(*)::INTEGER
    FROM comun.detsal_lic d
    WHERE d.id_licencia = p_id_licencia
      AND d.cvepago = 0
      AND (p_axo IS NULL OR d.axo = p_axo)
    GROUP BY d.axo
    ORDER BY d.axo DESC;
END;
$$ LANGUAGE plpgsql;

-- FIN DEL SCRIPT
