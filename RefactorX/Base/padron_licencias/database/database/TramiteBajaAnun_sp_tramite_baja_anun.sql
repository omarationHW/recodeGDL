-- Stored Procedure: sp_tramite_baja_anun
-- Tipo: CRUD
-- Descripción: Tramita la baja de un anuncio, cancela adeudos, actualiza estatus y registra folio de baja.
-- Generado para formulario: TramiteBajaAnun
-- Fecha: 2025-08-26 18:20:02

CREATE OR REPLACE FUNCTION sp_tramite_baja_anun(
    p_id_anuncio INTEGER,
    p_motivo TEXT,
    p_usuario TEXT,
    p_folio INTEGER DEFAULT NULL,
    p_axo INTEGER DEFAULT NULL,
    p_baja_error BOOLEAN DEFAULT FALSE,
    p_baja_tiempo BOOLEAN DEFAULT FALSE
) RETURNS TABLE(folio INTEGER, axo INTEGER, fecha TIMESTAMP, mensaje TEXT) AS $$
DECLARE
    v_anuncio RECORD;
    v_licencia INTEGER;
    v_folio INTEGER;
    v_axo INTEGER;
    v_fecha TIMESTAMP := NOW();
    v_total NUMERIC;
    v_costo_solicitud NUMERIC;
BEGIN
    -- Validar existencia y vigencia
    SELECT * INTO v_anuncio FROM anuncios WHERE id_anuncio = p_id_anuncio;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe el anuncio';
    END IF;
    IF v_anuncio.vigente <> 'V' THEN
        RAISE EXCEPTION 'El anuncio ya se encuentra cancelado';
    END IF;
    v_licencia := v_anuncio.id_licencia;
    -- Cancelar adeudos
    UPDATE detsal_lic SET cvepago = 999999 WHERE id_anuncio = p_id_anuncio AND cvepago = 0;
    -- Recalcular saldo de la licencia
    PERFORM calc_sdosl(v_licencia);
    -- Obtener folio y año
    IF p_axo IS NULL THEN
        v_axo := EXTRACT(YEAR FROM v_fecha)::INTEGER;
    ELSE
        v_axo := p_axo;
    END IF;
    IF p_folio IS NULL THEN
        SELECT COALESCE(MAX(folio),0)+1 INTO v_folio FROM lic_cancel WHERE axo = v_axo;
    ELSE
        v_folio := p_folio;
    END IF;
    -- Obtener costo de solicitud
    SELECT costo_solicitud INTO v_costo_solicitud FROM parametros_lic LIMIT 1;
    SELECT COALESCE(SUM(saldo),0) INTO v_total FROM detsal_lic WHERE id_anuncio = p_id_anuncio AND cvepago = 0;
    -- Actualizar anuncio
    UPDATE anuncios SET vigente = 'C', fecha_baja = v_fecha, axo_baja = v_axo, folio_baja = v_folio, espubic = p_motivo WHERE id_anuncio = p_id_anuncio;
    -- Insertar registro en lic_cancel
    INSERT INTO lic_cancel (rec, axo, folio, licencia, anuncio, motivo, usuario, fecha, imp_solicitud, imp_licencia, importe, cvepago)
    VALUES (0, v_axo, v_folio, 0, p_id_anuncio, p_motivo, p_usuario, v_fecha, v_costo_solicitud, v_total, v_costo_solicitud + v_total, 0)
    RETURNING folio, axo, fecha, 'Baja tramitada'::TEXT AS mensaje;
END;
$$ LANGUAGE plpgsql;