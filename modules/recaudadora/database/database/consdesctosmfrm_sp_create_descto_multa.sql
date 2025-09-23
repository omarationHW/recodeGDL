-- Stored Procedure: sp_create_descto_multa
-- Tipo: CRUD
-- Descripción: Crea un nuevo descuento para una multa municipal.
-- Generado para formulario: consdesctosmfrm
-- Fecha: 2025-08-26 23:23:39

CREATE OR REPLACE FUNCTION sp_create_descto_multa(
  p_id_multa INTEGER,
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
DECLARE
  v_folio INTEGER;
BEGIN
  INSERT INTO descmultampal (id_multa, tipo_descto, valor, autoriza, observacion, user_cap, fecha_act, vigencia)
  VALUES (p_id_multa, p_tipo_descto, p_valor, p_autoriza, p_observacion, p_user_cap, NOW(), 'V')
  RETURNING folio_descto INTO v_folio;
  RETURN QUERY SELECT folio_descto, datos_descto, fecha_inicio, fecha_fin, por_aut, monto_aut, fecha_act, user_cap, us_aplico, fe_aplico, vigencia
    FROM descmultampal WHERE folio_descto = v_folio;
END;
$$ LANGUAGE plpgsql;