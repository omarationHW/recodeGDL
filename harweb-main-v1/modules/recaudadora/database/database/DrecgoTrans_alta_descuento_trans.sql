-- Stored Procedure: alta_descuento_trans
-- Tipo: CRUD
-- Descripción: Da de alta un descuento en recargos de transmisión
-- Generado para formulario: DrecgoTrans
-- Fecha: 2025-08-27 01:13:21

CREATE OR REPLACE FUNCTION alta_descuento_trans(
  p_folio integer,
  p_porcentaje numeric,
  p_observaciones text,
  p_autoriza integer,
  p_user text
) RETURNS TABLE(result text) AS $$
DECLARE
  v_id integer;
BEGIN
  INSERT INTO descrectrans (folio, porcentaje, fecalta, captalta, fecbaja, captbaja, estado, cvepago, autoriza, observaciones)
  VALUES (p_folio, p_porcentaje, CURRENT_DATE, p_user, NULL, NULL, 'V', NULL, p_autoriza, p_observaciones)
  RETURNING id_descto INTO v_id;
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;