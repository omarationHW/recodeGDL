-- Stored Procedure: sp_cancelar_descuento
-- Tipo: CRUD
-- Descripción: Cancela un descuento vigente
-- Generado para formulario: dderechosLic
-- Fecha: 2025-08-26 23:58:23

CREATE OR REPLACE FUNCTION sp_cancelar_descuento(p_id_descto INTEGER, p_licencia INTEGER, p_user TEXT)
RETURNS TABLE(result TEXT) AS $$
BEGIN
  UPDATE descderlic
  SET estado='C', fecbaja=CURRENT_DATE, captbaja=p_user
  WHERE licencia=p_licencia AND id_descto=p_id_descto;
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;