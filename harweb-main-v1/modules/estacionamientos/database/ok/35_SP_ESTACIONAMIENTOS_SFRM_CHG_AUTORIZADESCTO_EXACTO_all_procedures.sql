-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_CHG_AUTORIZADESCTO (EXACTO del archivo original)
-- Archivo: 35_SP_ESTACIONAMIENTOS_SFRM_CHG_AUTORIZADESCTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRM_CHG_AUTORIZADESCTO (EXACTO del archivo original)
-- Archivo: 35_SP_ESTACIONAMIENTOS_SFRM_CHG_AUTORIZADESCTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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

