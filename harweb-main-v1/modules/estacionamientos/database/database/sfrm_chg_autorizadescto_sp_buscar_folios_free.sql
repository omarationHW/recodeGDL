-- Stored Procedure: sp_buscar_folios_free
-- Tipo: Report
-- Descripción: Obtiene los descuentos otorgados (ta14_folios_free) para un axo y folio.
-- Generado para formulario: sfrm_chg_autorizadescto
-- Fecha: 2025-08-27 14:10:52

CREATE OR REPLACE FUNCTION sp_buscar_folios_free(p_axo SMALLINT, p_folio INTEGER)
RETURNS TABLE(axo SMALLINT, folio INTEGER, fecha_otorga DATE, porc_cobro SMALLINT, obs VARCHAR, fec_cap DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, folio, fecha_otorga, porc_cobro, obs, fec_cap
    FROM ta14_folios_free
    WHERE axo = p_axo AND folio = p_folio;
END;
$$ LANGUAGE plpgsql;