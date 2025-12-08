-- ============================================
-- DEPLOY: ligaAnunciofrm.vue
-- Módulo: padron_licencias
-- Total SPs: 4
-- Fecha: 2025-11-20
-- ============================================

\echo 'Desplegando ligaAnunciofrm (4 SPs)...'

CREATE OR REPLACE FUNCTION public.sp_buscar_licencia(p_licencia INTEGER)
RETURNS TABLE(
    licencia INTEGER,
    empresa INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    ubicacion VARCHAR,
    vigente CHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.licencia, l.empresa, e.propietario, e.rfc, e.ubicacion, l.vigente
    FROM comun.licencias l
    JOIN comun.empresas e ON l.empresa = e.empresa
    WHERE l.licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_buscar_empresa(p_empresa INTEGER)
RETURNS TABLE(
    empresa INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    ubicacion VARCHAR,
    vigente CHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.empresa, e.propietario, e.rfc, e.ubicacion, e.vigente
    FROM comun.empresas e
    WHERE e.empresa = p_empresa;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_buscar_anuncio(p_anuncio INTEGER)
RETURNS TABLE(
    anuncio INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    descripcion VARCHAR,
    ubicacion VARCHAR,
    vigente CHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.anuncio, a.licencia, a.empresa, a.descripcion, a.ubicacion, a.vigente
    FROM comun.anuncios a
    WHERE a.anuncio = p_anuncio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_ligar_anuncio(
    p_anuncio INTEGER,
    p_licencia INTEGER
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_anuncio_vigente CHAR;
    v_licencia_vigente CHAR;
BEGIN
    -- Verificar que el anuncio existe y está vigente
    SELECT vigente INTO v_anuncio_vigente FROM comun.anuncios WHERE anuncio = p_anuncio;

    IF v_anuncio_vigente IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Anuncio no encontrado'::TEXT;
        RETURN;
    END IF;

    IF v_anuncio_vigente <> 'V' THEN
        RETURN QUERY SELECT FALSE, 'El anuncio no está vigente'::TEXT;
        RETURN;
    END IF;

    -- Verificar que la licencia existe y está vigente
    SELECT vigente INTO v_licencia_vigente FROM comun.licencias WHERE licencia = p_licencia;

    IF v_licencia_vigente IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada'::TEXT;
        RETURN;
    END IF;

    IF v_licencia_vigente <> 'V' THEN
        RETURN QUERY SELECT FALSE, 'La licencia no está vigente'::TEXT;
        RETURN;
    END IF;

    -- Ligar el anuncio a la licencia
    UPDATE comun.anuncios SET licencia = p_licencia WHERE anuncio = p_anuncio;

    RETURN QUERY SELECT TRUE, 'Anuncio ligado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

\echo 'ligaAnunciofrm completado'
