-- ============================================
-- STORED PROCEDURES PARA DICTAMENFRM
-- Base de datos: padron_licencias
-- Siguiendo patrón de consultapredial.vue
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- SP_DICTAMEN_LIST: Lista dictámenes con filtros
-- Basado en la tabla anuncios y licencias
CREATE OR REPLACE FUNCTION SP_DICTAMEN_LIST(
    p_anuncio INTEGER DEFAULT NULL,
    p_propietario VARCHAR DEFAULT NULL,
    p_clasificacion VARCHAR DEFAULT NULL,
    p_ubicacion VARCHAR DEFAULT NULL,
    p_vigente VARCHAR DEFAULT 'V',
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id integer,
    anuncio integer,
    propietario varchar,
    propietarionvo varchar,
    clasificacion varchar,
    ubicacion varchar,
    numext_ubic integer,
    letraext_ubic varchar,
    colonia_ubic varchar,
    medidas1 double precision,
    medidas2 double precision,
    area_anuncio double precision,
    num_caras smallint,
    descripcion varchar,
    vigente varchar,
    fecha_otorgamiento date,
    cp integer,
    id_licencia integer,
    licencia integer,
    actividad varchar,
    total_registros bigint
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_anuncio as id,
        a.anuncio,
        COALESCE(l.propietario, '') as propietario,
        TRIM(
            COALESCE(TRIM(l.primer_ap), '') || ' ' ||
            COALESCE(TRIM(l.segundo_ap), '') || ' ' ||
            COALESCE(TRIM(l.propietario), '')
        ) AS propietarionvo,
        g.clasificacion,
        a.ubicacion,
        a.numext_ubic,
        a.letraext_ubic,
        a.colonia_ubic,
        a.medidas1,
        a.medidas2,
        a.area_anuncio,
        a.num_caras,
        g.descripcion,
        a.vigente,
        l.fecha_otorgamiento,
        COALESCE(a.cp, 0) as cp,
        a.id_licencia,
        l.licencia,
        g.descripcion as actividad,
        COUNT(*) OVER() as total_registros
    FROM anuncios a
    INNER JOIN licencias l ON a.id_licencia = l.id_licencia
    INNER JOIN c_giros g ON a.id_giro = g.id_giro
    WHERE (p_anuncio IS NULL OR a.anuncio = p_anuncio)
      AND (p_propietario IS NULL OR UPPER(l.propietario) LIKE UPPER('%' || p_propietario || '%'))
      AND (p_clasificacion IS NULL OR UPPER(g.clasificacion) LIKE UPPER('%' || p_clasificacion || '%'))
      AND (p_ubicacion IS NULL OR UPPER(a.ubicacion) LIKE UPPER('%' || p_ubicacion || '%'))
      AND (p_vigente IS NULL OR a.vigente = p_vigente)
    ORDER BY a.anuncio DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- SP_DICTAMEN_CREATE: Crear nuevo dictamen (anuncio)
CREATE OR REPLACE FUNCTION SP_DICTAMEN_CREATE(
    p_anuncio INTEGER,
    p_id_licencia INTEGER,
    p_id_giro INTEGER,
    p_ubicacion VARCHAR,
    p_numext_ubic INTEGER DEFAULT NULL,
    p_letraext_ubic VARCHAR DEFAULT NULL,
    p_colonia_ubic VARCHAR DEFAULT NULL,
    p_medidas1 DOUBLE PRECISION DEFAULT 0,
    p_medidas2 DOUBLE PRECISION DEFAULT 0,
    p_num_caras SMALLINT DEFAULT 1,
    p_texto_anuncio VARCHAR DEFAULT NULL,
    p_cp INTEGER DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR,
    id_anuncio INTEGER
) AS $$
DECLARE
    v_id_anuncio INTEGER;
    v_area_calculada DOUBLE PRECISION;
BEGIN
    -- Verificar si ya existe el anuncio
    IF EXISTS (SELECT 1 FROM anuncios WHERE anuncio = p_anuncio) THEN
        RETURN QUERY SELECT FALSE, 'El número de anuncio ya existe'::VARCHAR, NULL::INTEGER;
        RETURN;
    END IF;

    -- Calcular área
    v_area_calculada := COALESCE(p_medidas1, 0) * COALESCE(p_medidas2, 0);

    -- Insertar nuevo anuncio
    INSERT INTO anuncios (
        anuncio, id_licencia, id_giro, ubicacion, numext_ubic, letraext_ubic,
        colonia_ubic, medidas1, medidas2, area_anuncio, num_caras,
        texto_anuncio, vigente, cp, fecha_otorgamiento
    ) VALUES (
        p_anuncio, p_id_licencia, p_id_giro, p_ubicacion, p_numext_ubic,
        p_letraext_ubic, p_colonia_ubic, p_medidas1, p_medidas2,
        v_area_calculada, p_num_caras, p_texto_anuncio, 'V', p_cp, CURRENT_DATE
    ) RETURNING id_anuncio INTO v_id_anuncio;

    RETURN QUERY SELECT TRUE, 'Anuncio creado exitosamente'::VARCHAR, v_id_anuncio;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, ('Error al crear anuncio: ' || SQLERRM)::VARCHAR, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- SP_DICTAMEN_UPDATE: Actualizar dictamen existente
CREATE OR REPLACE FUNCTION SP_DICTAMEN_UPDATE(
    p_id_anuncio INTEGER,
    p_ubicacion VARCHAR,
    p_numext_ubic INTEGER DEFAULT NULL,
    p_letraext_ubic VARCHAR DEFAULT NULL,
    p_colonia_ubic VARCHAR DEFAULT NULL,
    p_medidas1 DOUBLE PRECISION DEFAULT NULL,
    p_medidas2 DOUBLE PRECISION DEFAULT NULL,
    p_num_caras SMALLINT DEFAULT NULL,
    p_texto_anuncio VARCHAR DEFAULT NULL,
    p_cp INTEGER DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_area_calculada DOUBLE PRECISION;
BEGIN
    -- Verificar si existe el anuncio
    IF NOT EXISTS (SELECT 1 FROM anuncios WHERE id_anuncio = p_id_anuncio) THEN
        RETURN QUERY SELECT FALSE, 'El anuncio no existe'::VARCHAR;
        RETURN;
    END IF;

    -- Calcular área si se proporcionan medidas
    IF p_medidas1 IS NOT NULL AND p_medidas2 IS NOT NULL THEN
        v_area_calculada := p_medidas1 * p_medidas2;
    END IF;

    -- Actualizar anuncio
    UPDATE anuncios SET
        ubicacion = COALESCE(p_ubicacion, ubicacion),
        numext_ubic = COALESCE(p_numext_ubic, numext_ubic),
        letraext_ubic = COALESCE(p_letraext_ubic, letraext_ubic),
        colonia_ubic = COALESCE(p_colonia_ubic, colonia_ubic),
        medidas1 = COALESCE(p_medidas1, medidas1),
        medidas2 = COALESCE(p_medidas2, medidas2),
        area_anuncio = COALESCE(v_area_calculada, area_anuncio),
        num_caras = COALESCE(p_num_caras, num_caras),
        texto_anuncio = COALESCE(p_texto_anuncio, texto_anuncio),
        cp = COALESCE(p_cp, cp)
    WHERE id_anuncio = p_id_anuncio;

    RETURN QUERY SELECT TRUE, 'Anuncio actualizado exitosamente'::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, ('Error al actualizar anuncio: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- SP_DICTAMEN_DETAILS: Obtener detalles completos del anuncio para dictamen
CREATE OR REPLACE FUNCTION SP_DICTAMEN_DETAILS(p_anuncio INTEGER)
RETURNS TABLE(
    anuncio integer,
    propietarionvo varchar,
    clasificacion varchar,
    ubicacion varchar,
    numext_ubic integer,
    letraext_ubic varchar,
    numint_ubic varchar,
    letraint_ubic varchar,
    colonia_ubic varchar,
    cp integer,
    medidas1 double precision,
    medidas2 double precision,
    area_anuncio double precision,
    num_caras smallint,
    descripcion varchar,
    texto_anuncio varchar,
    vigente varchar,
    fecha_otorgamiento date,
    licencia integer,
    actividad varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.anuncio,
        TRIM(
            COALESCE(TRIM(l.primer_ap), '') || ' ' ||
            COALESCE(TRIM(l.segundo_ap), '') || ' ' ||
            COALESCE(TRIM(l.propietario), '')
        ) AS propietarionvo,
        g.clasificacion,
        a.ubicacion,
        a.numext_ubic,
        a.letraext_ubic,
        a.numint_ubic,
        a.letraint_ubic,
        a.colonia_ubic,
        a.cp,
        a.medidas1,
        a.medidas2,
        a.area_anuncio,
        a.num_caras,
        g.descripcion,
        a.texto_anuncio,
        a.vigente,
        a.fecha_otorgamiento,
        l.licencia,
        g.descripcion as actividad
    FROM anuncios a
    INNER JOIN licencias l ON a.id_licencia = l.id_licencia
    INNER JOIN c_giros g ON a.id_giro = g.id_giro
    WHERE a.anuncio = p_anuncio
      AND a.vigente = 'V';
END;
$$ LANGUAGE plpgsql;

-- Crear índices para optimizar rendimiento
CREATE INDEX IF NOT EXISTS idx_anuncios_numero ON anuncios(anuncio);
CREATE INDEX IF NOT EXISTS idx_anuncios_vigente ON anuncios(vigente);
CREATE INDEX IF NOT EXISTS idx_anuncios_ubicacion ON anuncios(ubicacion);

-- ============================================
-- FIN DE STORED PROCEDURES PARA DICTAMENFRM
-- ============================================