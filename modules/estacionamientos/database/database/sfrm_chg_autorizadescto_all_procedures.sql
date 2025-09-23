-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_chg_autorizadescto
-- Generado: 2025-08-27 14:10:52
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_buscar_folios_histo
-- Tipo: Report
-- Descripción: Obtiene los folios históricos para una placa entre el 01/10/2013 y 31/12/2014.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_folios_histo(p_placa VARCHAR)
RETURNS TABLE(axo SMALLINT, folio INTEGER, placa VARCHAR, fecha_folio DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, folio, placa, fecha_folio
    FROM ta14_folios_histo
    WHERE placa = p_placa
      AND fecha_folio BETWEEN DATE '2013-10-01' AND DATE '2014-12-31';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_buscar_folios_free
-- Tipo: Report
-- Descripción: Obtiene los descuentos otorgados (ta14_folios_free) para un axo y folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_folios_free(p_axo SMALLINT, p_folio INTEGER)
RETURNS TABLE(axo SMALLINT, folio INTEGER, fecha_otorga DATE, porc_cobro SMALLINT, obs VARCHAR, fec_cap DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, folio, fecha_otorga, porc_cobro, obs, fec_cap
    FROM ta14_folios_free
    WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_cambiar_a_tesorero
-- Tipo: CRUD
-- Descripción: Actualiza el campo obs a 'Tesorero' en ta14_folios_free para el axo y folio dados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cambiar_a_tesorero(p_axo SMALLINT, p_folio INTEGER)
RETURNS TABLE(updated BOOLEAN) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE ta14_folios_free
    SET obs = 'Tesorero'
    WHERE axo = p_axo AND folio = p_folio;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN QUERY SELECT v_count > 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

