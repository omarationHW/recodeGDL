-- Stored Procedure: sp_certificaciones_create
-- Tipo: CRUD
-- Descripción: Crea una nueva certificación y actualiza el folio
-- Generado para formulario: certificacionesfrm
-- Fecha: 2025-08-27 17:08:49

CREATE OR REPLACE FUNCTION sp_certificaciones_create(p_tipo TEXT, p_id_licencia INT, p_observacion TEXT, p_partidapago TEXT, p_capturista TEXT)
RETURNS INT AS $$
DECLARE
  new_folio INT;
  new_id INT;
BEGIN
  SELECT certificacion INTO new_folio FROM parametros_lic;
  new_folio := new_folio + 1;
  UPDATE parametros_lic SET certificacion = new_folio;
  INSERT INTO certificaciones(tipo, id_licencia, axo, folio, vigente, observacion, partidapago, feccap, capturista)
  VALUES (p_tipo, p_id_licencia, EXTRACT(YEAR FROM CURRENT_DATE), new_folio, 'V', p_observacion, p_partidapago, CURRENT_DATE, p_capturista)
  RETURNING id INTO new_id;
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;