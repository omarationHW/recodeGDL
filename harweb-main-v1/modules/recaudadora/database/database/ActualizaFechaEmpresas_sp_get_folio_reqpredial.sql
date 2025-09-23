-- Stored Procedure: sp_get_folio_reqpredial
-- Tipo: Catalog
-- Descripción: Obtiene el folio de reqpredial por cvecuenta, folioreq y axoreq.
-- Generado para formulario: ActualizaFechaEmpresas
-- Fecha: 2025-08-26 20:24:51

CREATE OR REPLACE FUNCTION sp_get_folio_reqpredial(p_cvecuenta INTEGER, p_folioreq INTEGER, p_axoreq INTEGER)
RETURNS TABLE(cvereq INTEGER, folioreq INTEGER, axoreq INTEGER, cveejecut INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT cvereq, folioreq, axoreq, cveejecut FROM reqpredial WHERE cvecuenta = p_cvecuenta AND folioreq = p_folioreq AND axoreq = p_axoreq;
END;
$$ LANGUAGE plpgsql;