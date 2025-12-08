-- ============================================
-- DEPLOY: bloqueoRFCfrm.vue
-- Módulo: padron_licencias
-- Total SPs: 4
-- Fecha: 2025-11-20
-- ============================================

\echo 'Desplegando bloqueoRFCfrm (4 SPs)...'

CREATE OR REPLACE FUNCTION public.sp_bloqueorfc_list()
RETURNS TABLE(
    id INTEGER,
    rfc VARCHAR,
    motivo VARCHAR,
    fecha_bloqueo DATE,
    vigente CHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.id, b.rfc, b.motivo, b.fecha_bloqueo, b.vigente
    FROM public.bloqueo_rfc b
    WHERE b.vigente = 'V'
    ORDER BY b.fecha_bloqueo DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_bloqueorfc_buscar_tramite(p_tramite INTEGER)
RETURNS TABLE(
    tramite INTEGER,
    rfc VARCHAR,
    propietario VARCHAR,
    vigente CHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.tramite, e.rfc, e.propietario, t.vigente
    FROM comun.tramites t
    JOIN comun.empresas e ON t.empresa = e.empresa
    WHERE t.tramite = p_tramite;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_bloqueorfc_create(
    p_rfc VARCHAR,
    p_motivo VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.bloqueo_rfc WHERE rfc = p_rfc AND vigente = 'V') THEN
        RETURN QUERY SELECT FALSE, 'El RFC ya está bloqueado'::TEXT;
    ELSE
        INSERT INTO public.bloqueo_rfc (rfc, motivo, fecha_bloqueo, vigente)
        VALUES (p_rfc, p_motivo, NOW(), 'V');
        RETURN QUERY SELECT TRUE, 'RFC bloqueado exitosamente'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_bloqueorfc_desbloquear(p_rfc VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE public.bloqueo_rfc
    SET vigente = 'C'
    WHERE rfc = p_rfc AND vigente = 'V';

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'RFC desbloqueado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'RFC no encontrado o ya desbloqueado'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'bloqueoRFCfrm completado'
