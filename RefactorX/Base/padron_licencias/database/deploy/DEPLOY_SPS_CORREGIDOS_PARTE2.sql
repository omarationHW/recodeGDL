-- ============================================
-- SPs CORREGIDOS - PARTE 2
-- Módulo: padron_licencias
-- Fecha: 2025-11-21
-- ============================================

-- ============================================
-- BAJAANUNCIOFRM - Baja de anuncios
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_baja_anuncio_buscar(
    p_anuncio INTEGER DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL
)
RETURNS TABLE(
    id_anuncio INTEGER,
    anuncio INTEGER,
    id_licencia INTEGER,
    ubicacion VARCHAR,
    texto_anuncio VARCHAR,
    area_anuncio NUMERIC,
    vigente VARCHAR,
    bloqueado SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_anuncio, a.anuncio, a.id_licencia,
           TRIM(a.ubicacion)::VARCHAR, TRIM(a.texto_anuncio)::VARCHAR,
           a.area_anuncio, TRIM(a.vigente)::VARCHAR, a.bloqueado
    FROM comun.anuncios a
    WHERE (p_anuncio IS NULL OR a.anuncio = p_anuncio)
      AND (p_id_licencia IS NULL OR a.id_licencia = p_id_licencia)
      AND TRIM(a.vigente) = 'S';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_baja_anuncio_procesar(
    p_id_anuncio INTEGER,
    p_folio_baja INTEGER,
    p_capturista VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE comun.anuncios
    SET vigente = 'N',
        fecha_baja = CURRENT_DATE,
        axo_baja = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,
        folio_baja = p_folio_baja
    WHERE id_anuncio = p_id_anuncio;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Anuncio no encontrado'::TEXT;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'Anuncio dado de baja exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- BAJALICENCIAFRM - Baja de licencias
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_baja_licencia_consulta(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    actividad VARCHAR,
    ubicacion VARCHAR,
    vigente VARCHAR,
    bloqueado SMALLINT,
    tiene_anuncios BIGINT,
    tiene_adeudos BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia,
           TRIM(l.propietario)::VARCHAR, TRIM(l.rfc)::VARCHAR,
           TRIM(l.actividad)::VARCHAR, TRIM(l.ubicacion)::VARCHAR,
           TRIM(l.vigente)::VARCHAR, l.bloqueado,
           (SELECT COUNT(*) FROM comun.anuncios a WHERE a.id_licencia = l.id_licencia AND TRIM(a.vigente) = 'S'),
           (SELECT COUNT(*) FROM comun.detsal_lic d WHERE d.id_licencia = l.id_licencia AND d.cvepago = 0 AND d.saldo > 0)
    FROM comun.licencias l
    WHERE l.id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_baja_licencia_procesar(
    p_id_licencia INTEGER,
    p_folio_baja INTEGER,
    p_capturista VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_tiene_anuncios INTEGER;
    v_tiene_adeudos INTEGER;
BEGIN
    -- Verificar anuncios vigentes
    SELECT COUNT(*) INTO v_tiene_anuncios
    FROM comun.anuncios WHERE id_licencia = p_id_licencia AND TRIM(vigente) = 'S';

    IF v_tiene_anuncios > 0 THEN
        RETURN QUERY SELECT FALSE, 'La licencia tiene anuncios vigentes'::TEXT;
        RETURN;
    END IF;

    -- Verificar adeudos
    SELECT COUNT(*) INTO v_tiene_adeudos
    FROM comun.detsal_lic WHERE id_licencia = p_id_licencia AND cvepago = 0 AND saldo > 0;

    IF v_tiene_adeudos > 0 THEN
        RETURN QUERY SELECT FALSE, 'La licencia tiene adeudos pendientes'::TEXT;
        RETURN;
    END IF;

    UPDATE comun.licencias
    SET vigente = 'N',
        fecha_baja = CURRENT_DATE,
        axo_baja = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER,
        folio_baja = p_folio_baja
    WHERE id_licencia = p_id_licencia;

    RETURN QUERY SELECT TRUE, 'Licencia dada de baja exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- BLOQUEODOMICILIOSFRM - Bloqueo por domicilio
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_bloqueo_domicilios_list(
    p_cvecalle INTEGER DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    ubicacion VARCHAR,
    cvecalle INTEGER,
    bloqueado SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia,
           TRIM(l.propietario)::VARCHAR, TRIM(l.ubicacion)::VARCHAR,
           l.cvecalle, l.bloqueado
    FROM comun.licencias l
    WHERE (p_cvecalle IS NULL OR l.cvecalle = p_cvecalle)
    ORDER BY l.ubicacion
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_bloqueo_domicilios_aplicar(
    p_cvecalle INTEGER,
    p_tipo_bloqueo SMALLINT,
    p_capturista VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    licencias_afectadas INTEGER
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE comun.licencias
    SET bloqueado = p_tipo_bloqueo
    WHERE cvecalle = p_cvecalle AND TRIM(vigente) = 'S';

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN QUERY SELECT TRUE, 'Bloqueo aplicado'::TEXT, v_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CANCELATRAMITEFRM - Cancelación de trámites
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_cancela_tramite_buscar(
    p_folio INTEGER DEFAULT NULL,
    p_id_tramite INTEGER DEFAULT NULL
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
      AND (p_id_tramite IS NULL OR t.id_tramite = p_id_tramite)
      AND TRIM(t.estatus) NOT IN ('C', 'X');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_cancela_tramite_procesar(
    p_id_tramite INTEGER,
    p_motivo TEXT,
    p_capturista VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE comun.tramites
    SET estatus = 'C',
        observaciones = COALESCE(observaciones, '') || E'\n[CANCELADO] ' || p_motivo
    WHERE id_tramite = p_id_tramite;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Trámite no encontrado'::TEXT;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'Trámite cancelado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- REACTIVATRAMITE - Reactivar trámites
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_reactiva_tramite_buscar(
    p_folio INTEGER DEFAULT NULL,
    p_id_tramite INTEGER DEFAULT NULL
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    propietario VARCHAR,
    estatus VARCHAR,
    feccap DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.folio, TRIM(t.tipo_tramite)::VARCHAR,
           TRIM(t.propietario)::VARCHAR, TRIM(t.estatus)::VARCHAR, t.feccap
    FROM comun.tramites t
    WHERE (p_folio IS NULL OR t.folio = p_folio)
      AND (p_id_tramite IS NULL OR t.id_tramite = p_id_tramite)
      AND TRIM(t.estatus) = 'C';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_reactiva_tramite_procesar(
    p_id_tramite INTEGER,
    p_motivo TEXT,
    p_capturista VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE comun.tramites
    SET estatus = 'P',
        observaciones = COALESCE(observaciones, '') || E'\n[REACTIVADO] ' || p_motivo
    WHERE id_tramite = p_id_tramite AND TRIM(estatus) = 'C';

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Trámite no encontrado o no está cancelado'::TEXT;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'Trámite reactivado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- LICENCIASVIGENTESFRM - Reporte licencias vigentes
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_licencias_vigentes_reporte(
    p_zona SMALLINT DEFAULT NULL,
    p_id_giro INTEGER DEFAULT NULL,
    p_limit INTEGER DEFAULT 1000
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    actividad VARCHAR,
    ubicacion VARCHAR,
    zona SMALLINT,
    fecha_otorgamiento DATE,
    bloqueado SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia,
           TRIM(l.propietario)::VARCHAR, TRIM(l.rfc)::VARCHAR,
           TRIM(l.actividad)::VARCHAR, TRIM(l.ubicacion)::VARCHAR,
           l.zona, l.fecha_otorgamiento, l.bloqueado
    FROM comun.licencias l
    WHERE TRIM(l.vigente) = 'S'
      AND (p_zona IS NULL OR l.zona = p_zona)
      AND (p_id_giro IS NULL OR l.id_giro = p_id_giro)
    ORDER BY l.licencia
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_licencias_vigentes_estadisticas()
RETURNS TABLE(
    zona SMALLINT,
    total_licencias BIGINT,
    total_bloqueadas BIGINT,
    total_anuncios BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.zona,
           COUNT(*)::BIGINT,
           COUNT(CASE WHEN l.bloqueado > 0 THEN 1 END)::BIGINT,
           (SELECT COUNT(*) FROM comun.anuncios a WHERE a.id_licencia IN (SELECT id_licencia FROM comun.licencias WHERE zona = l.zona AND TRIM(vigente) = 'S'))::BIGINT
    FROM comun.licencias l
    WHERE TRIM(l.vigente) = 'S'
    GROUP BY l.zona
    ORDER BY l.zona;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- GIROSDCONADEUDOFRM - Giros con adeudo
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_giros_con_adeudo(
    p_zona SMALLINT DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id_giro INTEGER,
    descripcion VARCHAR,
    total_licencias BIGINT,
    licencias_con_adeudo BIGINT,
    total_adeudo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT g.id_giro, TRIM(g.descripcion)::VARCHAR,
           COUNT(DISTINCT l.id_licencia)::BIGINT,
           COUNT(DISTINCT CASE WHEN d.saldo > 0 THEN l.id_licencia END)::BIGINT,
           COALESCE(SUM(d.saldo), 0)::NUMERIC
    FROM comun.c_giros g
    LEFT JOIN comun.licencias l ON l.id_giro = g.id_giro AND TRIM(l.vigente) = 'S'
                                   AND (p_zona IS NULL OR l.zona = p_zona)
    LEFT JOIN comun.detsal_lic d ON d.id_licencia = l.id_licencia AND d.cvepago = 0
    WHERE TRIM(g.vigente) = 'S'
    GROUP BY g.id_giro, g.descripcion
    HAVING COALESCE(SUM(d.saldo), 0) > 0
    ORDER BY COALESCE(SUM(d.saldo), 0) DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CONSLIC400FRM - Consulta licencias AS/400
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_cons_lic_400_buscar(
    p_numlic INTEGER DEFAULT NULL,
    p_inirfc VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    ofna SMALLINT,
    numlic INTEGER,
    inirfc VARCHAR,
    codgir SMALLINT,
    descripcion VARCHAR,
    nomcal VARCHAR,
    numext INTEGER,
    numzon SMALLINT,
    vigenc SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.ofna, l.numlic, TRIM(l.inirfc)::VARCHAR, l.codgir,
           TRIM(l.ilgir1)::VARCHAR, TRIM(l.nomcal)::VARCHAR,
           l.numext, l.numzon, l.vigenc
    FROM comun.licencias_400 l
    WHERE (p_numlic IS NULL OR l.numlic = p_numlic)
      AND (p_inirfc IS NULL OR TRIM(l.inirfc) ILIKE p_inirfc || '%')
    ORDER BY l.numlic
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- EMPRESASFRM - Gestión de empresas
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_empresas_list(
    p_propietario VARCHAR DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    actividad VARCHAR,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.empresa,
           TRIM(l.propietario)::VARCHAR, TRIM(l.rfc)::VARCHAR,
           TRIM(l.actividad)::VARCHAR, TRIM(l.vigente)::VARCHAR
    FROM comun.licencias l
    WHERE (p_propietario IS NULL OR TRIM(l.propietario) ILIKE '%' || p_propietario || '%')
      AND (p_rfc IS NULL OR TRIM(l.rfc) ILIKE '%' || p_rfc || '%')
    ORDER BY l.propietario
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- MODTRAMITEFRM - Modificar trámite
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_mod_tramite_get(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    id_giro INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    actividad VARCHAR,
    ubicacion VARCHAR,
    estatus VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.folio, TRIM(t.tipo_tramite)::VARCHAR, t.id_giro,
           TRIM(t.propietario)::VARCHAR, TRIM(t.rfc)::VARCHAR,
           TRIM(t.actividad)::VARCHAR, TRIM(t.ubicacion)::VARCHAR,
           TRIM(t.estatus)::VARCHAR
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_mod_tramite_update(
    p_id_tramite INTEGER,
    p_propietario VARCHAR DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
    p_actividad VARCHAR DEFAULT NULL,
    p_ubicacion VARCHAR DEFAULT NULL,
    p_capturista VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE comun.tramites
    SET propietario = COALESCE(p_propietario, propietario),
        rfc = COALESCE(p_rfc, rfc),
        actividad = COALESCE(p_actividad, actividad),
        ubicacion = COALESCE(p_ubicacion, ubicacion),
        capturista = COALESCE(p_capturista, capturista),
        feccap = CURRENT_DATE
    WHERE id_tramite = p_id_tramite;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Trámite no encontrado'::TEXT;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'Trámite actualizado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CRUCES - Búsqueda por cruces de calles
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_cruces_buscar_licencias(
    p_cvecalle INTEGER,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    ubicacion VARCHAR,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia,
           TRIM(l.propietario)::VARCHAR, TRIM(l.ubicacion)::VARCHAR,
           TRIM(l.vigente)::VARCHAR
    FROM comun.licencias l
    WHERE l.cvecalle = p_cvecalle
    ORDER BY l.ubicacion
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- FIN DEL SCRIPT PARTE 2
