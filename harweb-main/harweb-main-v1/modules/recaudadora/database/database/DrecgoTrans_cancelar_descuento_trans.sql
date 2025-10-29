-- Stored Procedure: cancelar_descuento_trans
-- Tipo: CRUD
-- Descripción: Cancela un descuento en recargos de transmisión
-- Generado para formulario: DrecgoTrans
-- Fecha: 2025-08-27 01:13:21

CREATE OR REPLACE FUNCTION cancelar_descuento_trans(
  p_folio integer,
  p_id_descto integer,
  p_user text
) RETURNS TABLE(result text) AS $$
BEGIN
  UPDATE descrectrans
    SET estado = 'C', fecbaja = CURRENT_DATE, captbaja = p_user
    WHERE folio = p_folio AND id_descto = p_id_descto AND estado = 'V';
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;