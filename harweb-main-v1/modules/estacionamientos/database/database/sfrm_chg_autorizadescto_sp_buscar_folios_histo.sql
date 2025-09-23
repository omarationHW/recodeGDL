-- Stored Procedure: sp_buscar_folios_histo
-- Tipo: Report
-- Descripción: Obtiene los folios históricos para una placa entre el 01/10/2013 y 31/12/2014.
-- Generado para formulario: sfrm_chg_autorizadescto
-- Fecha: 2025-08-27 14:10:52

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