-- Stored Procedure: sp_cambiar_a_tesorero
-- Tipo: CRUD
-- Descripción: Actualiza el campo obs a 'Tesorero' en ta14_folios_free para el axo y folio dados.
-- Generado para formulario: sfrm_chg_autorizadescto
-- Fecha: 2025-08-27 14:10:52

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