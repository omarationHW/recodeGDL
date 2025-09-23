-- Stored Procedure: sp_tramite_baja_anun_tramitar
-- Tipo: CRUD
-- Descripción: Tramita la baja de un anuncio, cancela adeudos, recalcula saldo de licencia y registra en lic_cancel.
-- Generado para formulario: TramiteBajaAnun
-- Fecha: 2025-08-27 19:45:07

CREATE OR REPLACE FUNCTION sp_tramite_baja_anun_tramitar(
    p_anuncio INTEGER,
    p_motivo TEXT,
    p_usuario TEXT,
    p_axo_baja INTEGER DEFAULT NULL,
    p_folio_baja INTEGER DEFAULT NULL,
    p_rec INTEGER DEFAULT 0,
    p_imp_solicitud NUMERIC DEFAULT 0,
    p_imp_licencia NUMERIC DEFAULT 0,
    p_importe NUMERIC DEFAULT 0
) RETURNS TEXT AS $$
DECLARE
    v_anuncio RECORD;
    v_folio INTEGER;
    v_axo INTEGER := COALESCE(p_axo_baja, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);
BEGIN
    SELECT * INTO v_anuncio FROM anuncios WHERE anuncio = p_anuncio FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No se encontró el anuncio';
    END IF;
    IF v_anuncio.vigente <> 'V' THEN
        RAISE EXCEPTION 'El anuncio ya se encuentra cancelado.';
    END IF;
    -- Actualizar anuncio
    UPDATE anuncios SET vigente = 'C', fecha_baja = NOW(), axo_baja = v_axo, folio_baja = COALESCE(p_folio_baja, 0), espubic = p_motivo WHERE anuncio = p_anuncio;
    -- Cancelar adeudos
    UPDATE detsal_lic SET cvepago = 999999 WHERE id_anuncio = v_anuncio.id_anuncio AND cvepago = 0;
    -- Recalcular saldo de la licencia
    PERFORM calc_sdosl(v_anuncio.id_licencia);
    -- Insertar registro en lic_cancel
    SELECT COALESCE(MAX(folio),0)+1 INTO v_folio FROM lic_cancel WHERE rec = p_rec AND axo = v_axo;
    INSERT INTO lic_cancel (rec, axo, folio, licencia, anuncio, motivo, usuario, fecha, imp_solicitud, imp_licencia, importe, cvepago)
    VALUES (p_rec, v_axo, v_folio, 0, v_anuncio.anuncio, p_motivo, p_usuario, NOW(), p_imp_solicitud, p_imp_licencia, p_importe, 0);
    RETURN 'Baja tramitada correctamente';
END;
$$ LANGUAGE plpgsql;