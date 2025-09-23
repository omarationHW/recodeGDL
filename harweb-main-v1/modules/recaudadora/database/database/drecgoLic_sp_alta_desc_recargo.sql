-- Stored Procedure: sp_alta_desc_recargo
-- Tipo: CRUD
-- Descripción: Alta de descuento de recargo para licencia/anuncio
-- Generado para formulario: drecgoLic
-- Fecha: 2025-08-27 00:52:37

CREATE OR REPLACE FUNCTION sp_alta_desc_recargo(
  p_tipo VARCHAR, p_licencia INTEGER, p_porcentaje SMALLINT, p_usuario VARCHAR, p_axoini INTEGER, p_axofin INTEGER, p_autoriza SMALLINT, p_minmax VARCHAR
) RETURNS TABLE(id_descto INTEGER) AS $$
DECLARE
  v_id INTEGER;
BEGIN
  INSERT INTO descreclic (tipo, licencia, porcentaje, fecalta, captalta, fecbaja, captbaja, estado, cvepago, axoini, axofin, autoriza)
  VALUES (p_tipo, p_licencia, p_porcentaje, CURRENT_DATE, p_usuario, NULL, NULL, 'V', NULL, p_axoini, p_axofin, p_autoriza)
  RETURNING id_descto INTO v_id;
  RETURN QUERY SELECT v_id;
END;
$$ LANGUAGE plpgsql;