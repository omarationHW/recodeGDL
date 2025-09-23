-- Stored Procedure: sp_alta_desc_multa
-- Tipo: CRUD
-- Descripción: Alta de descuento de multa para licencia/anuncio
-- Generado para formulario: drecgoLic
-- Fecha: 2025-08-27 00:52:37

CREATE OR REPLACE FUNCTION sp_alta_desc_multa(
  p_tipo VARCHAR, p_licencia INTEGER, p_porcentaje SMALLINT, p_usuario VARCHAR, p_autoriza SMALLINT, p_minmax VARCHAR, p_axoini INTEGER, p_axofin INTEGER
) RETURNS TABLE(id_descto INTEGER) AS $$
DECLARE
  v_id INTEGER;
BEGIN
  INSERT INTO descmultalic (tipo, id_licanun, porcentaje, fecalta, useralta, fecbaja, userbaja, vigencia, cvepago, folio, autoriza, fecact, useract)
  VALUES (p_tipo, p_licencia, p_porcentaje, CURRENT_DATE, p_usuario, NULL, NULL, 'V', NULL, NULL, p_autoriza, CURRENT_DATE, p_usuario)
  RETURNING id_descto INTO v_id;
  RETURN QUERY SELECT v_id;
END;
$$ LANGUAGE plpgsql;