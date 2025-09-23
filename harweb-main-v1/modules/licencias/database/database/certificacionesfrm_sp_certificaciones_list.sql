-- Stored Procedure: sp_certificaciones_list
-- Tipo: Report
-- Descripción: Obtiene listado de certificaciones por tipo
-- Generado para formulario: certificacionesfrm
-- Fecha: 2025-08-27 17:08:49

CREATE OR REPLACE FUNCTION sp_certificaciones_list(p_tipo TEXT)
RETURNS TABLE(id INT, axo INT, folio INT, id_licencia INT, partidapago TEXT, observacion TEXT, vigente TEXT, feccap DATE, capturista TEXT, tipo TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id, axo, folio, id_licencia, partidapago, observacion, vigente, feccap, capturista, tipo FROM certificaciones WHERE tipo = p_tipo ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;