-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: TramiteBajaAnun
-- Generado: 2025-08-27 19:45:07
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_tramite_baja_anun_buscar
-- Tipo: CRUD
-- Descripción: Busca un anuncio, sus saldos y la licencia relacionada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tramite_baja_anun_buscar(p_anuncio INTEGER)
RETURNS TABLE(
    anuncio JSONB,
    saldos JSONB,
    licencia JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        row_to_json(a),
        (SELECT json_agg(row_to_json(s)) FROM detsal_lic s WHERE s.id_anuncio = a.id_anuncio AND s.cvepago = 0),
        row_to_json(l)
    FROM anuncios a
    LEFT JOIN licencias l ON l.id_licencia = a.id_licencia
    WHERE a.anuncio = p_anuncio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_tramite_baja_anun_tramitar
-- Tipo: CRUD
-- Descripción: Tramita la baja de un anuncio, cancela adeudos, recalcula saldo de licencia y registra en lic_cancel.
-- --------------------------------------------

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

-- ============================================

-- SP 3/3: calc_sdosl
-- Tipo: CRUD
-- Descripción: Recalcula el saldo de la licencia (dummy, debe implementarse según lógica de negocio).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION calc_sdosl(p_id_licencia INTEGER)
RETURNS VOID AS $$
BEGIN
    -- Aquí va la lógica para recalcular el saldo de la licencia
    -- Por ejemplo, sumar los saldos de detsal_lic y actualizar saldos_lic
    -- Esta función debe ser implementada según la lógica real
    NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================

