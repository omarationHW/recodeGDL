-- Stored Procedure: sp_reqtransm_folio_data
-- Tipo: CRUD
-- Descripción: Devuelve los datos generales de un folio de transmisión patrimonial
-- Generado para formulario: ReqTrans
-- Fecha: 2025-08-27 15:05:46

CREATE OR REPLACE FUNCTION sp_reqtransm_folio_data(p_foliotrans integer) RETURNS TABLE(
    *
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM datos_gral WHERE cvecuenta = (SELECT cvecuenta FROM actostransm WHERE folio = p_foliotrans);
END;
$$ LANGUAGE plpgsql;