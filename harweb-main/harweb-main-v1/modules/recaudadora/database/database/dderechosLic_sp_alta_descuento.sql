-- Stored Procedure: sp_alta_descuento
-- Tipo: CRUD
-- Descripción: Da de alta un nuevo descuento para licencia/anuncio/forma
-- Generado para formulario: dderechosLic
-- Fecha: 2025-08-26 23:58:23

CREATE OR REPLACE FUNCTION sp_alta_descuento(p_tipo TEXT, p_licencia INTEGER, p_porcentaje INTEGER, p_axoini INTEGER, p_axofin INTEGER, p_autoriza INTEGER, p_user TEXT)
RETURNS TABLE(result TEXT) AS $$
DECLARE
  v_id INTEGER;
BEGIN
  INSERT INTO descderlic (tipo, licencia, porcentaje, fecalta, captalta, fecbaja, captbaja, estado, cvepago, axoini, axofin, autoriza)
  VALUES (p_tipo, p_licencia, p_porcentaje, CURRENT_DATE, p_user, NULL, NULL, 'V', NULL, p_axoini, p_axofin, p_autoriza)
  RETURNING id_descto INTO v_id;
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;