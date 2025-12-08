-- ============================================
-- DEPLOY: bajaLicenciafrm.vue
-- Módulo: padron_licencias
-- Total SPs: 4
-- Fecha: 2025-11-20
-- ============================================

\echo 'Desplegando bajaLicenciafrm (4 SPs)...'

CREATE OR REPLACE FUNCTION public.sp_baja_licencia_consulta(p_licencia INTEGER)
RETURNS TABLE(
    licencia INTEGER,
    empresa INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    ubicacion VARCHAR,
    vigente CHAR,
    zona SMALLINT,
    subzona SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.licencia, l.empresa, e.propietario, e.rfc, e.ubicacion,
           l.vigente, l.zona, l.subzona
    FROM comun.licencias l
    JOIN comun.empresas e ON l.empresa = e.empresa
    WHERE l.licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_consulta_anuncios_licencia(p_licencia INTEGER)
RETURNS TABLE(
    anuncio INTEGER,
    descripcion VARCHAR,
    ubicacion VARCHAR,
    vigente CHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.anuncio, a.descripcion, a.ubicacion, a.vigente
    FROM comun.anuncios a
    WHERE a.licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_verifica_firma_usuario(
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

CREATE OR REPLACE FUNCTION public.sp_baja_licencia(
    p_licencia INTEGER,
    p_motivo VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    -- Dar de baja la licencia
    UPDATE comun.licencias
    SET vigente = 'C', fecha_baja = NOW(), motivo_baja = p_motivo
    WHERE licencia = p_licencia;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada'::TEXT;
        RETURN;
    END IF;

    -- Dar de baja todos los anuncios de la licencia
    UPDATE comun.anuncios
    SET vigente = 'C', fecha_baja = NOW(), motivo_baja = 'Baja por licencia cancelada'
    WHERE licencia = p_licencia AND vigente = 'V';

    RETURN QUERY SELECT TRUE, 'Licencia y anuncios dados de baja exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

\echo 'bajaLicenciafrm completado'
