-- Stored Procedure: sp_delete_descto_multa
-- Tipo: CRUD
-- Descripción: Cancela (elimina lógicamente) un descuento de multa municipal.
-- Generado para formulario: consdesctosmfrm
-- Fecha: 2025-08-26 23:23:39

CREATE OR REPLACE FUNCTION sp_delete_descto_multa(
  p_folio_descto INTEGER,
  p_user_cap TEXT
) RETURNS TABLE (
  folio_descto INTEGER,
  vigencia TEXT,
  fecha_act DATE,
  user_cap TEXT
) AS $$
BEGIN
  UPDATE descmultampal
  SET vigencia = 'C', fecha_act = NOW(), user_cap = p_user_cap
  WHERE folio_descto = p_folio_descto;
  RETURN QUERY SELECT folio_descto, vigencia, fecha_act, user_cap
    FROM descmultampal WHERE folio_descto = p_folio_descto;
END;
$$ LANGUAGE plpgsql;