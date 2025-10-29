-- Stored Procedure: sp_update_descto_multa
-- Tipo: CRUD
-- Descripción: Actualiza un descuento existente para una multa municipal.
-- Generado para formulario: consdesctosmfrm
-- Fecha: 2025-08-26 23:23:39

CREATE OR REPLACE FUNCTION sp_update_descto_multa(
  p_folio_descto INTEGER,
  p_tipo_descto TEXT,
  p_valor NUMERIC,
  p_autoriza INTEGER,
  p_observacion TEXT,
  p_user_cap TEXT
) RETURNS TABLE (
  folio_descto INTEGER,
  datos_descto TEXT,
  fecha_inicio DATE,
  fecha_fin DATE,
  por_aut INTEGER,
  monto_aut NUMERIC,
  fecha_act DATE,
  user_cap TEXT,
  us_aplico TEXT,
  fe_aplico DATE,
  vigencia TEXT
) AS $$
BEGIN
  UPDATE descmultampal
  SET tipo_descto = p_tipo_descto,
      valor = p_valor,
      autoriza = p_autoriza,
      observacion = p_observacion,
      user_cap = p_user_cap,
      fecha_act = NOW()
  WHERE folio_descto = p_folio_descto;
  RETURN QUERY SELECT folio_descto, datos_descto, fecha_inicio, fecha_fin, por_aut, monto_aut, fecha_act, user_cap, us_aplico, fe_aplico, vigencia
    FROM descmultampal WHERE folio_descto = p_folio_descto;
END;
$$ LANGUAGE plpgsql;