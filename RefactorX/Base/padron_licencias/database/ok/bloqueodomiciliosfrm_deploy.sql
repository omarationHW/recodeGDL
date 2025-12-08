-- ============================================
-- DEPLOY: bloqueoDomiciliosfrm.vue
-- Módulo: padron_licencias
-- Total SPs: 4
-- Fecha: 2025-11-20
-- ============================================

\echo 'Desplegando bloqueoDomiciliosfrm (4 SPs)...'

CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_list()
RETURNS TABLE(
    id INTEGER,
    calle VARCHAR,
    numext INTEGER,
    colonia VARCHAR,
    motivo VARCHAR,
    fecha_bloqueo DATE,
    vigente CHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.id, b.calle, b.numext, b.colonia, b.motivo, b.fecha_bloqueo, b.vigente
    FROM public.bloqueo_domicilios b
    WHERE b.vigente = 'V'
    ORDER BY b.fecha_bloqueo DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_create(
    p_calle VARCHAR,
    p_numext INTEGER,
    p_colonia VARCHAR,
    p_motivo VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    INSERT INTO public.bloqueo_domicilios (calle, numext, colonia, motivo, fecha_bloqueo, vigente)
    VALUES (p_calle, p_numext, p_colonia, p_motivo, NOW(), 'V');

    RETURN QUERY SELECT TRUE, 'Bloqueo creado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_update(
    p_id INTEGER,
    p_motivo VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE public.bloqueo_domicilios
    SET motivo = p_motivo
    WHERE id = p_id;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Bloqueo actualizado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Bloqueo no encontrado'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_cancel(p_id INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE public.bloqueo_domicilios
    SET vigente = 'C'
    WHERE id = p_id;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Bloqueo cancelado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Bloqueo no encontrado'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'bloqueoDomiciliosfrm completado'
