-- ============================================
-- DEPLOY: bajaAnunciofrm.vue
-- Módulo: padron_licencias
-- Total SPs: 3
-- Fecha: 2025-11-20
-- ============================================

\echo 'Desplegando bajaAnunciofrm (3 SPs)...'

CREATE OR REPLACE FUNCTION public.sp_baja_anuncio_buscar(p_anuncio INTEGER)
RETURNS TABLE(
    anuncio INTEGER,
    licencia INTEGER,
    empresa INTEGER,
    descripcion VARCHAR,
    ubicacion VARCHAR,
    vigente CHAR,
    propietario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.anuncio, a.licencia, a.empresa, a.descripcion, a.ubicacion,
           a.vigente, e.propietario
    FROM comun.anuncios a
    LEFT JOIN comun.empresas e ON a.empresa = e.empresa
    WHERE a.anuncio = p_anuncio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_verifica_firma(
    p_usuario VARCHAR,
    p_firma VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_firma_stored VARCHAR;
BEGIN
    SELECT firma INTO v_firma_stored FROM public.usuarios WHERE usuario = p_usuario;

    IF v_firma_stored IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado'::TEXT;
    ELSIF v_firma_stored = p_firma THEN
        RETURN QUERY SELECT TRUE, 'Firma válida'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Firma inválida'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_baja_anuncio_procesar(
    p_anuncio INTEGER,
    p_motivo VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE comun.anuncios
    SET vigente = 'C', fecha_baja = NOW(), motivo_baja = p_motivo
    WHERE anuncio = p_anuncio;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Anuncio dado de baja exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Anuncio no encontrado'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'bajaAnunciofrm completado'
