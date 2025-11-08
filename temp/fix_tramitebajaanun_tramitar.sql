-- Fix: TramiteBajaAnun_sp_tramite_baja_anun_tramitar
-- Corrección: usar public.lic_cancel

DROP FUNCTION IF EXISTS comun.TramiteBajaAnun_sp_tramite_baja_anun_tramitar(INTEGER, TEXT, TEXT, INTEGER, INTEGER, INTEGER, NUMERIC, NUMERIC, NUMERIC);

CREATE OR REPLACE FUNCTION comun.TramiteBajaAnun_sp_tramite_baja_anun_tramitar(
    p_anuncio INTEGER,
    p_motivo TEXT,
    p_usuario TEXT,
    p_axo_baja INTEGER DEFAULT NULL,
    p_folio_baja INTEGER DEFAULT NULL,
    p_rec INTEGER DEFAULT 0,
    p_imp_solicitud NUMERIC DEFAULT 0,
    p_imp_licencia NUMERIC DEFAULT 0,
    p_importe NUMERIC DEFAULT 0
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_anuncio RECORD;
    v_folio INTEGER;
    v_axo INTEGER := COALESCE(p_axo_baja, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);
BEGIN
    -- Buscar el anuncio
    SELECT * INTO v_anuncio FROM comun.anuncios a WHERE a.anuncio = p_anuncio FOR UPDATE;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'No se encontró el anuncio'::TEXT;
        RETURN;
    END IF;

    IF v_anuncio.vigente <> 'V' THEN
        RETURN QUERY SELECT FALSE, 'El anuncio ya se encuentra cancelado.'::TEXT;
        RETURN;
    END IF;

    -- Actualizar anuncio
    UPDATE comun.anuncios
    SET vigente = 'C',
        fecha_baja = NOW(),
        axo_baja = v_axo,
        folio_baja = COALESCE(p_folio_baja, 0),
        espubic = p_motivo
    WHERE anuncio = p_anuncio;

    -- Cancelar adeudos
    UPDATE comun.detsal_lic
    SET cvepago = 999999
    WHERE id_anuncio = v_anuncio.id_anuncio
    AND cvepago = 0;

    -- Recalcular saldo de la licencia
    PERFORM comun.TramiteBajaAnun_calc_sdosl(v_anuncio.id_licencia);

    -- Insertar registro en lic_cancel (está en public)
    SELECT COALESCE(MAX(folio),0)+1 INTO v_folio
    FROM public.lic_cancel
    WHERE rec = p_rec AND axo = v_axo;

    INSERT INTO public.lic_cancel (rec, axo, folio, licencia, anuncio, motivo, usuario, fecha, imp_solicitud, imp_licencia, importe, cvepago)
    VALUES (p_rec, v_axo, v_folio, 0, v_anuncio.anuncio, p_motivo, p_usuario, NOW(), p_imp_solicitud, p_imp_licencia, p_importe, 0);

    RETURN QUERY SELECT TRUE, 'Baja tramitada correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.TramiteBajaAnun_sp_tramite_baja_anun_tramitar(INTEGER, TEXT, TEXT, INTEGER, INTEGER, INTEGER, NUMERIC, NUMERIC, NUMERIC) IS
'Tramita la baja de un anuncio, cancela adeudos y registra en lic_cancel. FIXED: usa public.lic_cancel';
