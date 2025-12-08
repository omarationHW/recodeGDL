-- ============================================
-- SPs CORREGIDOS - PARTE 3
-- Módulo: padron_licencias
-- Fecha: 2025-11-21
-- ============================================

-- ============================================
-- CARGADATOSFRM - Carga de datos prediales
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_carga_datos_get_licencia(
    p_cvecuenta INTEGER
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    cvecuenta INTEGER,
    propietario VARCHAR,
    ubicacion VARCHAR,
    actividad VARCHAR,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.cvecuenta,
           TRIM(l.propietario)::VARCHAR, TRIM(l.ubicacion)::VARCHAR,
           TRIM(l.actividad)::VARCHAR, TRIM(l.vigente)::VARCHAR
    FROM comun.licencias l
    WHERE l.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_carga_datos_update_cuenta(
    p_id_licencia INTEGER,
    p_cvecuenta INTEGER,
    p_capturista VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE comun.licencias
    SET cvecuenta = p_cvecuenta
    WHERE id_licencia = p_id_licencia;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada'::TEXT;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'Cuenta catastral actualizada'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- CARGA_IMAGEN - Gestión de imágenes
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_carga_imagen_get_licencia(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    ubicacion VARCHAR,
    actividad VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia,
           TRIM(l.propietario)::VARCHAR, TRIM(l.ubicacion)::VARCHAR,
           TRIM(l.actividad)::VARCHAR
    FROM comun.licencias l
    WHERE l.id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PROPUESTATAB - Propuestas de valores
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_propuesta_get_licencia(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    cvecuenta INTEGER,
    propietario VARCHAR,
    ubicacion VARCHAR,
    base_impuesto NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.cvecuenta,
           TRIM(l.propietario)::VARCHAR, TRIM(l.ubicacion)::VARCHAR,
           l.base_impuesto
    FROM comun.licencias l
    WHERE l.id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_propuesta_get_saldos(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    axo SMALLINT,
    forma NUMERIC,
    derechos NUMERIC,
    recargos NUMERIC,
    saldo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.axo, d.forma, d.derechos, d.recargos, d.saldo
    FROM comun.detsal_lic d
    WHERE d.id_licencia = p_id_licencia AND d.cvepago = 0
    ORDER BY d.axo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIRMAUSUARIO - Validación de firma
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_firma_usuario_validar(
    p_usuario VARCHAR,
    p_firma VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    usuario VARCHAR,
    nombres VARCHAR,
    nivel SMALLINT
) AS $$
DECLARE
    v_user RECORD;
BEGIN
    SELECT u.usuario, u.nombres, u.clave, u.nivel, u.fecbaj
    INTO v_user
    FROM comun.usuarios u
    WHERE TRIM(u.usuario) = UPPER(TRIM(p_usuario));

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado'::TEXT,
                            NULL::VARCHAR, NULL::VARCHAR, NULL::SMALLINT;
        RETURN;
    END IF;

    IF v_user.fecbaj IS NOT NULL THEN
        RETURN QUERY SELECT FALSE, 'Usuario dado de baja'::TEXT,
                            NULL::VARCHAR, NULL::VARCHAR, NULL::SMALLINT;
        RETURN;
    END IF;

    -- Validar firma (comparación simple, se puede mejorar con hash)
    IF TRIM(v_user.clave) != TRIM(p_firma) THEN
        RETURN QUERY SELECT FALSE, 'Firma incorrecta'::TEXT,
                            NULL::VARCHAR, NULL::VARCHAR, NULL::SMALLINT;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'Firma válida'::TEXT,
                        TRIM(v_user.usuario)::VARCHAR, TRIM(v_user.nombres)::VARCHAR,
                        v_user.nivel;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- DETALLELICENCIA - Detalle de adeudos
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_detalle_licencia_get(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    ubicacion VARCHAR,
    actividad VARCHAR,
    zona SMALLINT,
    vigente VARCHAR,
    bloqueado SMALLINT,
    total_saldo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia,
           TRIM(l.propietario)::VARCHAR, TRIM(l.rfc)::VARCHAR,
           TRIM(l.ubicacion)::VARCHAR, TRIM(l.actividad)::VARCHAR,
           l.zona, TRIM(l.vigente)::VARCHAR, l.bloqueado,
           COALESCE((SELECT SUM(d.saldo) FROM comun.detsal_lic d WHERE d.id_licencia = l.id_licencia AND d.cvepago = 0), 0)::NUMERIC
    FROM comun.licencias l
    WHERE l.id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_detalle_licencia_saldos(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    axo SMALLINT,
    forma NUMERIC,
    derechos NUMERIC,
    derechos2 NUMERIC,
    recargos NUMERIC,
    desc_derechos NUMERIC,
    desc_recargos NUMERIC,
    desc_forma NUMERIC,
    actualizacion NUMERIC,
    saldo NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.axo, d.forma, d.derechos, d.derechos2, d.recargos,
           d.desc_derechos, d.desc_recargos, d.desc_forma,
           d.actualizacion, d.saldo
    FROM comun.detsal_lic d
    WHERE d.id_licencia = p_id_licencia AND d.cvepago = 0
    ORDER BY d.axo DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- REPDOC - Reportes documentales
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_repdoc_licencia(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    domicilio VARCHAR,
    ubicacion VARCHAR,
    actividad VARCHAR,
    fecha_otorgamiento DATE,
    descripcion_giro VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia,
           TRIM(l.propietario)::VARCHAR,
           TRIM(l.primer_ap)::VARCHAR,
           TRIM(l.segundo_ap)::VARCHAR,
           TRIM(l.rfc)::VARCHAR,
           TRIM(l.curp)::VARCHAR,
           TRIM(l.domicilio)::VARCHAR,
           TRIM(l.ubicacion)::VARCHAR,
           TRIM(l.actividad)::VARCHAR,
           l.fecha_otorgamiento,
           TRIM(g.descripcion)::VARCHAR
    FROM comun.licencias l
    LEFT JOIN comun.c_giros g ON g.id_giro = l.id_giro
    WHERE l.id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PRIVILEGIOS - Consulta de privilegios
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_privilegios_usuario(
    p_usuario VARCHAR
)
RETURNS TABLE(
    usuario VARCHAR,
    nombres VARCHAR,
    nivel SMALLINT,
    cvedepto INTEGER,
    fecalt DATE,
    activo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT TRIM(u.usuario)::VARCHAR, TRIM(u.nombres)::VARCHAR,
           u.nivel, u.cvedepto, u.fecalt,
           (u.fecbaj IS NULL)::BOOLEAN
    FROM comun.usuarios u
    WHERE TRIM(u.usuario) ILIKE '%' || p_usuario || '%'
    ORDER BY u.usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- DEPENDENCIAS - Catálogo de dependencias
-- ============================================

DROP FUNCTION IF EXISTS public.sp_dependencias_list();
CREATE OR REPLACE FUNCTION public.sp_dependencias_list()
RETURNS TABLE(
    cvedepto INTEGER,
    total_usuarios BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.cvedepto, COUNT(*)::BIGINT
    FROM comun.usuarios u
    WHERE u.fecbaj IS NULL
    GROUP BY u.cvedepto
    ORDER BY u.cvedepto;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FORMATOSECOLOGIAFRM - Formatos de ecología
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_formatos_ecologia_get_tramite(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    propietario VARCHAR,
    ubicacion VARCHAR,
    actividad VARCHAR,
    descripcion_giro VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.folio, TRIM(t.tipo_tramite)::VARCHAR,
           TRIM(t.propietario)::VARCHAR, TRIM(t.ubicacion)::VARCHAR,
           TRIM(t.actividad)::VARCHAR, TRIM(g.descripcion)::VARCHAR
    FROM comun.tramites t
    LEFT JOIN comun.c_giros g ON g.id_giro = t.id_giro
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- DOCTOSFRM - Documentos de trámites
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_doctos_tramite_get(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio INTEGER,
    documentos TEXT,
    propietario VARCHAR,
    estatus VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id_tramite, t.folio, t.documentos,
           TRIM(t.propietario)::VARCHAR, TRIM(t.estatus)::VARCHAR
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_doctos_tramite_update(
    p_id_tramite INTEGER,
    p_documentos TEXT,
    p_capturista VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE comun.tramites
    SET documentos = p_documentos,
        capturista = p_capturista,
        feccap = CURRENT_DATE
    WHERE id_tramite = p_id_tramite;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Trámite no encontrado'::TEXT;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'Documentos actualizados'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- IMPLICENCIAREGLAMENTADAFRM - Licencias reglamentadas
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_imp_licencia_reglamentada_get(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    ubicacion VARCHAR,
    actividad VARCHAR,
    descripcion_giro VARCHAR,
    reglamentada VARCHAR,
    bloqueado SMALLINT,
    saldo_total NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia,
           TRIM(l.propietario)::VARCHAR, TRIM(l.rfc)::VARCHAR,
           TRIM(l.ubicacion)::VARCHAR, TRIM(l.actividad)::VARCHAR,
           TRIM(g.descripcion)::VARCHAR, TRIM(g.reglamentada)::VARCHAR,
           l.bloqueado,
           COALESCE((SELECT SUM(d.saldo) FROM comun.detsal_lic d WHERE d.id_licencia = l.id_licencia AND d.cvepago = 0), 0)::NUMERIC
    FROM comun.licencias l
    LEFT JOIN comun.c_giros g ON g.id_giro = l.id_giro
    WHERE l.id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_imp_licencia_reglamentada_buscar(
    p_licencia INTEGER DEFAULT NULL,
    p_reglamentada VARCHAR DEFAULT 'S',
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    ubicacion VARCHAR,
    descripcion_giro VARCHAR,
    reglamentada VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia,
           TRIM(l.propietario)::VARCHAR, TRIM(l.ubicacion)::VARCHAR,
           TRIM(g.descripcion)::VARCHAR, TRIM(g.reglamentada)::VARCHAR
    FROM comun.licencias l
    JOIN comun.c_giros g ON g.id_giro = l.id_giro
    WHERE TRIM(l.vigente) = 'S'
      AND (p_licencia IS NULL OR l.licencia = p_licencia)
      AND (p_reglamentada IS NULL OR TRIM(g.reglamentada) = p_reglamentada)
    ORDER BY l.licencia
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- BUSQUE - Búsqueda general
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_busque_licencia(
    p_licencia INTEGER DEFAULT NULL,
    p_propietario VARCHAR DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
    p_ubicacion VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    ubicacion VARCHAR,
    actividad VARCHAR,
    zona SMALLINT,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia,
           TRIM(l.propietario)::VARCHAR, TRIM(l.rfc)::VARCHAR,
           TRIM(l.ubicacion)::VARCHAR, TRIM(l.actividad)::VARCHAR,
           l.zona, TRIM(l.vigente)::VARCHAR
    FROM comun.licencias l
    WHERE (p_licencia IS NULL OR l.licencia = p_licencia)
      AND (p_propietario IS NULL OR TRIM(l.propietario) ILIKE '%' || p_propietario || '%')
      AND (p_rfc IS NULL OR TRIM(l.rfc) ILIKE '%' || p_rfc || '%')
      AND (p_ubicacion IS NULL OR TRIM(l.ubicacion) ILIKE '%' || p_ubicacion || '%')
    ORDER BY l.licencia
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_busque_anuncio(
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

CREATE OR REPLACE FUNCTION public.sp_busque_tramite(
    p_folio INTEGER DEFAULT NULL,
    p_propietario VARCHAR DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
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
      AND (p_propietario IS NULL OR TRIM(t.propietario) ILIKE '%' || p_propietario || '%')
      AND (p_rfc IS NULL OR TRIM(t.rfc) ILIKE '%' || p_rfc || '%')
      AND (p_estatus IS NULL OR TRIM(t.estatus) = p_estatus)
    ORDER BY t.folio DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- FIN DEL SCRIPT PARTE 3
