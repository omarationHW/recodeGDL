-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: bajaLicenciafrm
-- Generado: 2025-08-27 15:59:40
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_baja_licencia
-- Tipo: CRUD
-- Descripción: Realiza la baja de una licencia y sus anuncios ligados, cancela adeudos y actualiza estatus.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_baja_licencia(
    p_id_licencia INTEGER,
    p_motivo TEXT,
    p_anio INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_baja_error BOOLEAN DEFAULT FALSE,
    p_usuario TEXT
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_licencia RECORD;
    v_anuncio RECORD;
BEGIN
    SELECT * INTO v_licencia FROM licencias WHERE id_licencia = p_id_licencia;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada.';
        RETURN;
    END IF;
    IF v_licencia.vigente <> 'V' THEN
        RETURN QUERY SELECT FALSE, 'La licencia ya está dada de baja o cancelada.';
        RETURN;
    END IF;
    IF v_licencia.bloqueado > 0 AND v_licencia.bloqueado < 5 THEN
        RETURN QUERY SELECT FALSE, 'La licencia está bloqueada.';
        RETURN;
    END IF;
    -- Verificar anuncios bloqueados
    FOR v_anuncio IN SELECT * FROM anuncios WHERE id_licencia = p_id_licencia AND vigente = 'V' LOOP
        IF v_anuncio.bloqueado > 0 THEN
            RETURN QUERY SELECT FALSE, 'No se puede dar de baja la licencia. El anuncio ' || v_anuncio.anuncio || ' está bloqueado.';
            RETURN;
        END IF;
    END LOOP;
    -- Cancelar adeudos de la licencia
    UPDATE detsal_lic SET cvepago = 999999 WHERE id_licencia = p_id_licencia AND (id_anuncio IS NULL OR id_anuncio = 0) AND cvepago = 0;
    -- Dar de baja anuncios y sus adeudos
    FOR v_anuncio IN SELECT * FROM anuncios WHERE id_licencia = p_id_licencia AND vigente = 'V' LOOP
        UPDATE detsal_lic SET cvepago = 999999 WHERE id_anuncio = v_anuncio.id_anuncio AND cvepago = 0;
        UPDATE anuncios SET vigente = 'C', fecha_baja = CURRENT_DATE, axo_baja = p_anio, folio_baja = p_folio, espubic = p_motivo WHERE id_anuncio = v_anuncio.id_anuncio;
    END LOOP;
    -- Recalcular saldo de la licencia (puede ser otro SP)
    -- Aquí se asume que existe un SP llamado calc_sdosl
    PERFORM calc_sdosl(p_id_licencia);
    -- Dar de baja la licencia
    UPDATE licencias SET vigente = 'C', fecha_baja = CURRENT_DATE, axo_baja = p_anio, folio_baja = p_folio, espubic = p_motivo WHERE id_licencia = p_id_licencia;
    -- Registrar bitácora (opcional)
    INSERT INTO lic_bajas_bitacora(id_licencia, usuario, fecha, motivo, anio, folio, baja_error)
    VALUES (p_id_licencia, p_usuario, CURRENT_TIMESTAMP, p_motivo, p_anio, p_folio, p_baja_error);
    RETURN QUERY SELECT TRUE, 'Licencia dada de baja correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: calc_sdosl
-- Tipo: CRUD
-- Descripción: Recalcula el saldo de la licencia después de la baja.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION calc_sdosl(p_id_licencia INTEGER) RETURNS VOID AS $$
BEGIN
    -- Lógica de recálculo de saldos (simplificada)
    UPDATE saldos_lic SET total = (
        COALESCE(derechos,0) + COALESCE(anuncios,0) + COALESCE(recargos,0) + COALESCE(gastos,0) + COALESCE(multas,0) + COALESCE(formas,0)
    ) WHERE id_licencia = p_id_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

